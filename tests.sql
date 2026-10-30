-- =====================================================================
-- Clinic database: security tests
-- Run after schema.sql, in the Supabase SQL Editor.
--
-- Each block signs in as a test user by setting the JWT "sub" claim
-- (which auth.uid() reads) and switching to the authenticated role.
-- The expected result is written above every query.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Test 1: a patient sees only their own records
-- John Kamau (P001)
-- ---------------------------------------------------------------------
SET ROLE authenticated;
SET request.jwt.claim.sub = '5a25cd02-a6c8-4188-84d3-9bc8f34a682b';

-- Expected: 1 row (P001 only)
SELECT patient_id, first_name, last_name FROM Patients;
-- Expected: 1 row (A001)
SELECT appointment_id, appointment_date, appointment_status FROM Appointments;
-- Expected: 1 row (T001)
SELECT treatment_id, treatment_description, treatment_cost FROM Treatments;
-- Expected: all 8 doctors (the doctor list is public, for booking)
SELECT COUNT(*) AS doctors_visible FROM Doctors;

-- ---------------------------------------------------------------------
-- Test 2: a patient cannot change records
-- With RLS, a blocked UPDATE does not raise an error: it matches no rows.
-- ---------------------------------------------------------------------
-- Expected: UPDATE 0
UPDATE Appointments SET appointment_status = 'Cancelled' WHERE appointment_id = 'A001';
-- Expected: UPDATE 0 (another patient's appointment is invisible too)
UPDATE Appointments SET appointment_status = 'Cancelled' WHERE appointment_id = 'A002';

RESET ROLE;

-- ---------------------------------------------------------------------
-- Test 3: a second patient sees a different set of records
-- Jane Wanjiku (P002)
-- ---------------------------------------------------------------------
SET ROLE authenticated;
SET request.jwt.claim.sub = 'b0bf7a55-da1a-42be-a384-901058e95c9f';

-- Expected: 1 row (A002)
SELECT appointment_id, appointment_date, appointment_status FROM Appointments;
-- Expected: 1 row (T002)
SELECT treatment_id, treatment_description, treatment_cost FROM Treatments;

RESET ROLE;

-- ---------------------------------------------------------------------
-- Test 4: a doctor sees and manages every record
-- Dr Emily Wangari (D001)
-- ---------------------------------------------------------------------
SET ROLE authenticated;
SET request.jwt.claim.sub = '88a9350d-4585-4402-9893-0fff5a0646a5';

-- Expected: 10 patients, 10 appointments, 8 treatments
SELECT (SELECT COUNT(*) FROM Patients)     AS patients,
       (SELECT COUNT(*) FROM Appointments) AS appointments,
       (SELECT COUNT(*) FROM Treatments)   AS treatments;

-- Expected: UPDATE 1 (doctors can update appointments)
UPDATE Appointments SET appointment_status = 'Completed' WHERE appointment_id = 'A009';

-- Expected: INSERT 0 1 (doctors can record treatments)
INSERT INTO Treatments (treatment_id, appointment_id, treatment_description, treatment_date, treatment_cost)
VALUES ('T009', 'A009', 'ECG', '2025-10-20', 1200.00);

RESET ROLE;

-- ---------------------------------------------------------------------
-- Test 5: someone signed in but not registered sees no medical data
-- ---------------------------------------------------------------------
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-000000000000';

-- Expected: 0 patients, 0 appointments, 0 treatments
SELECT (SELECT COUNT(*) FROM Patients)     AS patients,
       (SELECT COUNT(*) FROM Appointments) AS appointments,
       (SELECT COUNT(*) FROM Treatments)   AS treatments;

RESET ROLE;

-- ---------------------------------------------------------------------
-- Checks (run as the database owner)
-- ---------------------------------------------------------------------
-- Every patient and doctor is linked to an auth user. Expected: all true
SELECT 'patient' AS kind, patient_id AS id, auth_id IS NOT NULL AS linked FROM Patients
UNION ALL
SELECT 'doctor', doctor_id, auth_id IS NOT NULL FROM Doctors
ORDER BY kind, id;

-- RLS is switched on for all four tables. Expected: rowsecurity = true
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('patients', 'doctors', 'appointments', 'treatments');

-- The policies in force
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- Undo the test changes so the file can be run again
UPDATE Appointments SET appointment_status = 'Pending' WHERE appointment_id = 'A009';
DELETE FROM Treatments WHERE treatment_id = 'T009';
