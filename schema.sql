-- =====================================================================
-- Clinic database: schema, sample data and row-level security (Supabase)
-- Author: James Mwai
--
-- Run in the Supabase SQL Editor. Patients and doctors are linked to
-- Supabase Auth users through auth_id; the RLS policies at the bottom use
-- auth.uid() to decide which rows each signed-in user can see or change.
-- Security tests are in tests.sql. All names and numbers are fictional.
-- =====================================================================

-- Patients Table
CREATE TABLE Patients (
    patient_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    contact_info VARCHAR(100),
    auth_id UUID
);

-- Doctors Table
CREATE TABLE Doctors (
    doctor_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty VARCHAR(50),
    contact_info VARCHAR(100),
    auth_id UUID
);

-- Appointments Table
CREATE TABLE Appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) REFERENCES Patients(patient_id),
    doctor_id VARCHAR(10) REFERENCES Doctors(doctor_id),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit VARCHAR(255),
    appointment_status VARCHAR(50) 
);

-- Treatments Table
CREATE TABLE Treatments (
    treatment_id VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10) REFERENCES Appointments(appointment_id),
    treatment_description VARCHAR(255),
    treatment_date DATE,
    treatment_cost DECIMAL(10, 2)
);
-- Insert Patients
INSERT INTO Patients (patient_id, first_name, last_name, date_of_birth, gender, contact_info) VALUES
('P001', 'John', 'Kamau', '1980-01-15', 'Male', '0798532678'),
('P002', 'Jane', 'Wanjiku', '1990-02-25', 'Female', '0720867589'),
('P003', 'Alice', 'Mwangi', '2000-03-10', 'Female', '0739236490'),
('P004', 'Bob', 'Otieno', '1975-04-05', 'Male', '0743779012'),
('P005', 'Charlie', 'Njoroge', '1985-05-20', 'Male', '0755566012'),
('P006', 'Grace', 'Achieng', '1995-06-30', 'Female', '0763324563'),
('P007', 'Mercy', 'Kariuki', '1988-07-25', 'Female', '0778426334'),
('P008', 'Joy', 'Mutua', '1992-08-15', 'Female', '0783357834'),
('P009', 'Brian', 'Omondi', '1982-09-10', 'Male', '0790100645'),
('P010', 'Aisha', 'Ali', '1998-10-05', 'Female', '0701481167');

-- Insert Doctors
INSERT INTO Doctors (doctor_id, first_name, last_name, specialty, contact_info) VALUES
('D001', 'Emily', 'Wangari', 'Cardiology', '0717384678'),
('D002', 'Michael', 'Oluoch', 'Neurology', '0711956789'),
('D003', 'Sarah', 'Kilonzo', 'Pediatrics', '0796357890'),
('D004', 'David', 'Mutiso', 'Orthopedics', '0745046901'),
('D005', 'Laura', 'Kariuki', 'Dermatology', '0754672512'),
('D006', 'James', 'Mwangi', 'General Surgery', '0765096423'),
('D007', 'Anne', 'Ndungu', 'Gynecology', '0711468534'),
('D008', 'Peter', 'Omondi', 'ENT', '0785499845');

-- Insert Appointments
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, appointment_time, reason_for_visit, appointment_status) VALUES
('A001', 'P001', 'D001', '2025-09-01', '09:00:00', 'Routine Checkup', 'Completed'),
('A002', 'P002', 'D002', '2025-09-15', '10:00:00', 'Headache', 'Completed'),
('A003', 'P003', 'D003', '2025-09-20', '11:00:00', 'Fever', 'Completed'),
('A004', 'P004', 'D004', '2025-09-25', '12:00:00', 'Back Pain', 'Completed'),
('A005', 'P005', 'D005', '2025-09-30', '13:00:00', 'Skin Rash', 'Completed'),
('A006', 'P006', 'D006', '2025-10-05', '14:00:00', 'Stomach Ache', 'Completed'),
('A007', 'P007', 'D007', '2025-10-10', '15:00:00', 'Pregnancy Checkup', 'Completed'),
('A008', 'P008', 'D008', '2025-10-15', '16:00:00', 'Ear Infection', 'Completed'),
('A009', 'P009', 'D001', '2025-10-20', '17:00:00', 'Chest Pain', 'Pending'),
('A010', 'P010', 'D002', '2025-10-25', '18:00:00', 'Migraine', 'Pending');

-- Insert Treatments
INSERT INTO Treatments (treatment_id, appointment_id, treatment_description, treatment_date, treatment_cost) VALUES
('T001', 'A001', 'Blood Test', '2025-09-01', 1000.00),
('T002', 'A002', 'MRI Scan', '2025-09-15', 5000.00),
('T003', 'A003', 'Medication', '2025-09-20', 500.00),
('T004', 'A004', 'Physical Therapy', '2025-09-25', 2000.00),
('T005', 'A005', 'Skin Biopsy', '2025-09-30', 1500.00),
('T006', 'A006', 'Endoscopy', '2025-10-05', 3000.00),
('T007', 'A007', 'Ultrasound', '2025-10-10', 2500.00),
('T008', 'A008', 'Ear Cleaning', '2025-10-15', 800.00);

-- Add Auth IDs (Link to Supabase Auth Users)
-- Update Patients with actual auth_ids
UPDATE Patients SET auth_id = '5a25cd02-a6c8-4188-84d3-9bc8f34a682b' WHERE patient_id = 'P001';
UPDATE Patients SET auth_id = 'b0bf7a55-da1a-42be-a384-901058e95c9f' WHERE patient_id = 'P002';
UPDATE Patients SET auth_id = '5eff694a-a841-4b4d-9cb3-f080dcaea914' WHERE patient_id = 'P003';
UPDATE Patients SET auth_id = 'f3277dfc-a4ba-4cff-b5f1-4f8401734e1d' WHERE patient_id = 'P004';
UPDATE Patients SET auth_id = '6ddbd65c-c9fe-4cae-8c53-040412a3a238' WHERE patient_id = 'P005';
UPDATE Patients SET auth_id = 'd65ae330-f65c-4439-bc9f-9d0d35a164a1' WHERE patient_id = 'P006';
UPDATE Patients SET auth_id = 'cdb971f9-32cc-4817-b5a0-e74bfa15740a' WHERE patient_id = 'P007';
UPDATE Patients SET auth_id = '6635a7af-62a0-4e24-8dc3-744f307e84a5' WHERE patient_id = 'P008';
UPDATE Patients SET auth_id = '45a6a100-0125-42f1-885f-3cc3cdc035d0' WHERE patient_id = 'P009';
UPDATE Patients SET auth_id = '1951c1ac-93d5-4475-aeee-2361930bba9f' WHERE patient_id = 'P010';

-- Update Doctors with actual auth_ids
UPDATE Doctors SET auth_id = '88a9350d-4585-4402-9893-0fff5a0646a5' WHERE doctor_id = 'D001';
UPDATE Doctors SET auth_id = '18694e16-5959-449f-8712-ed10e8082fa5' WHERE doctor_id = 'D002';
UPDATE Doctors SET auth_id = '0475bad0-abad-4cf8-a4bb-4b945f4b98f3' WHERE doctor_id = 'D003';
UPDATE Doctors SET auth_id = '0e790733-a5b5-4b25-bf3b-422bacfb5479' WHERE doctor_id = 'D004';
UPDATE Doctors SET auth_id = '9d6357b1-2c2d-430e-b99f-1f6f7d6c7c1c' WHERE doctor_id = 'D005';
UPDATE Doctors SET auth_id = '3fbf9c6d-dbb9-411c-9627-b5b893f01b04' WHERE doctor_id = 'D006';
UPDATE Doctors SET auth_id = '4f029766-6666-4971-adc7-87974fffa6c7' WHERE doctor_id = 'D007';
UPDATE Doctors SET auth_id = 'e0efbcbf-b0db-4707-8bf5-105de3baef29' WHERE doctor_id = 'D008';
-- Enable Row Level Security on all tables
ALTER TABLE Patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE Doctors ENABLE ROW LEVEL SECURITY;
ALTER TABLE Appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE Treatments ENABLE ROW LEVEL SECURITY;
-- SECURITY SETUP (RSL QUERIES)
-- Patients can view their own data
CREATE POLICY "Patients can view own profile" ON Patients
FOR SELECT USING (auth_id = auth.uid());

-- Doctors can view all patients
CREATE POLICY "Doctors can view all patients" ON Patients
FOR SELECT USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);

-- Patients can view doctors
CREATE POLICY "Patients can view doctors" ON Doctors
FOR SELECT USING (true);

-- Doctors can view all doctors  
CREATE POLICY "Doctors can view all doctors" ON Doctors
FOR SELECT USING (true);

-- Patients can view their own appointments (READ ONLY)
CREATE POLICY "Patients can view own appointments" ON Appointments
FOR SELECT USING (
  patient_id IN (SELECT patient_id FROM Patients WHERE auth_id = auth.uid())
);

-- Doctors can do everything with appointments
CREATE POLICY "Doctors full access to appointments" ON Appointments
FOR ALL USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);

-- Patients can view their own treatments (READ ONLY)  
CREATE POLICY "Patients can view own treatments" ON Treatments
FOR SELECT USING (
  appointment_id IN (
    SELECT appointment_id FROM Appointments 
    WHERE patient_id IN (SELECT patient_id FROM Patients WHERE auth_id = auth.uid())
  )
);

-- Doctors can do everything with treatments
CREATE POLICY "Doctors full access to treatments" ON Treatments
FOR ALL USING (
  EXISTS (SELECT 1 FROM Doctors WHERE auth_id = auth.uid())
);
