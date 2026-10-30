# Security Implementation Notes

## Overview
This document explains the security architecture of the Clinic Database System, detailing how roles, policies, and Row Level Security (RLS) are implemented to protect sensitive medical data.

## 🔐 Security Architecture

### User Roles
The system implements two primary roles:

1. **Patients** (`patient` role)
   - Read-only access to their own medical records
   - Can view personal appointments and treatments
   - Cannot modify any data

2. **Doctors** (`doctor` role) 
   - Full read/write access to all medical records
   - Can manage appointments and treatments for all patients
   - Can view all patient information

## 🛡️ Row Level Security (RLS) Implementation

### Table Security Policies

#### Patients Table
```sql
-- Patients can only view their own profile
CREATE POLICY "Patients can view own profile" ON Patients
FOR SELECT USING (auth_id = auth.uid());

-- Doctors can view all patients
CREATE POLICY "Doctors can view all patients" ON Patients
FOR SELECT USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);
```

#### Doctors Table
```sql
-- Patients can view all doctors (for appointment booking)
CREATE POLICY "Patients can view doctors" ON Doctors
FOR SELECT USING (true);

-- Doctors can view all doctors  
CREATE POLICY "Doctors can view all doctors" ON Doctors
FOR SELECT USING (true);
```

#### Appointments Table
```sql
-- Patients can view only their own appointments (read-only)
CREATE POLICY "Patients can view own appointments" ON Appointments
FOR SELECT USING (
  patient_id IN (SELECT patient_id FROM Patients WHERE auth_id = auth.uid())
);

-- Doctors have full CRUD access to all appointments
CREATE POLICY "Doctors full access to appointments" ON Appointments
FOR ALL USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);
```

#### Treatments Table
```sql
-- Patients can view only their own treatments (read-only)
CREATE POLICY "Patients can view own treatments" ON Treatments
FOR SELECT USING (
  appointment_id IN (
    SELECT appointment_id FROM Appointments 
    WHERE patient_id IN (SELECT patient_id FROM Patients WHERE auth_id = auth.uid())
  )
);

-- Doctors have full CRUD access to all treatments
CREATE POLICY "Doctors full access to treatments" ON Treatments
FOR ALL USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);
```

## 🔗 Authentication Integration

### User Identification
- Each user (patient or doctor) has a Supabase Auth account
- The `auth_id` column in Patients/Doctors tables links to `auth.users.id`
- Policies use `auth.uid()` to identify the currently authenticated user

### Role Determination
- Role is determined by presence in the respective table:
  - If user exists in `Patients` table → Patient role
  - If user exists in `Doctors` table → Doctor role
- No explicit role column needed - role is inferred from table membership

## 🧪 Security Testing

### Patient Access Test
```sql
-- Test as patient (should only see own data)
SET ROLE authenticated;
SET "request.jwt.claim.sub" TO 'patient-auth-uuid';
SELECT * FROM Appointments;  -- Should return only patient's appointments
SELECT * FROM Treatments;    -- Should return only patient's treatments
```

### Doctor Access Test  
```sql
-- Test as doctor (should see all data)
SET ROLE authenticated;
SET "request.jwt.claim.sub" TO 'doctor-auth-uuid';
SELECT * FROM Appointments;  -- Should return all appointments
SELECT * FROM Treatments;    -- Should return all treatments
```

### Permission Test
```sql
-- Patient tries to edit: RLS hides the row, so nothing changes (UPDATE 0, no error)
SET "request.jwt.claim.sub" TO 'patient-auth-uuid';
UPDATE Appointments SET appointment_status = 'Cancelled' WHERE appointment_id = 'A001';

-- Doctor edits: succeeds (UPDATE 1)
SET "request.jwt.claim.sub" TO 'doctor-auth-uuid';
UPDATE Appointments SET appointment_status = 'Completed' WHERE appointment_id = 'A009';
```

The full set of tests, with the expected result above each query, is in [`tests.sql`](tests.sql).

## 📋 Policy Verification

Check active RLS policies:
```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
```

Verify RLS is enabled:
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('patients', 'doctors', 'appointments', 'treatments');
```

## 🚨 Security Considerations

### Data Privacy
- Patient data is filtered by the database itself, so a bug in an app cannot leak another patient's records.
- Someone who is signed in but not registered as a patient or doctor sees no medical data.

### Access Control
- Patients get read-only access to their own records.
- All doctors can see all records. That suits a small clinic; a larger one would limit doctors to their own patients.
- The doctor list is readable by anyone, so patients can choose a doctor when booking.

### What this project does not cover
These would be needed before real patient data went in:
- Audit logs recording who viewed or changed a record
- Limiting doctors to their own patients
- Review against Kenya's Data Protection Act, 2019

## 🛠️ Maintenance

### Adding New Users
1. Create the user in Supabase Auth
2. Insert a row in the right table (Patients or Doctors)
3. Set `auth_id` to the Auth user's ID
4. The policies apply automatically
