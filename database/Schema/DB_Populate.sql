use medisense;
INSERT INTO user (username, password, email, role)
VALUES 
('john_doe', 'password123', 'john@example.com', 'patient'),
('dr_smith', 'docpass', 'smith@example.com', 'doctor'),
('pharma1', 'pharmapass', 'pharma1@example.com', 'pharmacy');

UPDATE doctors
SET nic = 'NIC123456', 
    doctor_license = 'LIC78910', 
    description = 'Cardiologist with 10 years of experience'
WHERE user_id = 8;

UPDATE pharmacies
SET district = 'Central District', 
    town = 'Metropolis', 
    street = 'Main Street 12', 
    con_number = '9876543210', 
    rating = 4.5
WHERE user_id = 9;

UPDATE patients
SET dob = '1990-05-10', 
    nic = 'NIC987654', 
    doctor_id = 8, 
    emergency_contact = '1234567890', 
    weight = 70.5, 
    height = 175.2, 
    allergies = 'None'
WHERE user_id = 7;

INSERT INTO rating (pharm_id, user_id, rating)
VALUES 
(1, 1, 4.2);

INSERT INTO booking (patient_id, pharm_id, description, status)
VALUES 
(1, 1, 'Blood pressure medication refill', 'requested');

INSERT INTO pilldiary (patient_id, date, time, record)
VALUES 
(1, '2024-10-14', '08:00:00', 'Took 1 pill of aspirin');

INSERT INTO reminders (id, date, time, record, status)
VALUES 
(1, '2024-10-15', '08:00:00', 'Take morning pill', 'pending');
