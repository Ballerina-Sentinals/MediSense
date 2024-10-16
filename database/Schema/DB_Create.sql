drop database if exists medisense;
create database medisense;
use medisense;

drop table if exists user;
CREATE TABLE user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    password VARCHAR(80) NOT NULL,
    email VARCHAR(100) NOT NULL ,
    role enum('patient','doctor','pharmacy') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
drop table if exists doctors;
CREATE TABLE doctors (
    doctor_id int primary key auto_increment,
    user_id INT ,
    name VARCHAR(40) NOT NULL,
    nic VARCHAR(15),
    doctor_license VARCHAR(20) NOT NULL,
    description text,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

create table pharmacies(
    pharm_id int primary key auto_increment,
    user_id int,
    name varchar(80) not null,
    district varchar(80) not null,
    town varchar(80) not null,
    street varchar(80) not null ,
    con_number varchar(10) not null,
    rating decimal(2,1)
);
drop table if exists patients;
create table patients(
    patient_id int primary key auto_increment,
    user_id INT,
    name varchar(80),
    dob date,
    nic varchar(15),
    doctor_id int null ,
    emergency_contact varchar(20) not null,
    weight decimal(5,2) ,
    height decimal(5,2),
    allergies varchar(80),
    foreign key (user_id) references user(id) on delete CASCADE on update cascade ,
    foreign key (doctor_id) references doctors(user_id) on delete cascade on update cascade
);
create table rating(
    rat_id int primary key auto_increment,
    pharm_id int  ,
    user_id int ,
    rating decimal(2,1)
);

create table booking(
    booking_id int primary key auto_increment,
    patient_id int,
    pharm_id int ,
    description varchar(255),
    status enum('requested','accepted','paid','completed')
);

create table pilldiary(
    entry_id int auto_increment primary key ,
    patient_id int,
    date date,
    time time,
    record varchar(255),
    foreign key (patient_id) references patients(patient_id) on delete cascade);


create table reminders(
    reminder_id int auto_increment primary key ,
    id int ,
    date date,
    time time,
    record varchar(255),
    status enum('pending','completed') default 'pending', 
    foreign key (id) references patients(patient_id) on delete cascade
);

DELIMITER //

CREATE TRIGGER after_reminder_update
AFTER UPDATE ON reminders
FOR EACH ROW
BEGIN
    IF NEW.status = 'completed' THEN
        -- Insert a new record into pilldiary when reminder status is completed
        INSERT INTO pilldiary (patient_id, date, time, record)
        SELECT p.patient_id, CURDATE(), CURTIME(), NEW.record
        FROM patients p
        WHERE p.patient_id = NEW.id;
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_user_insert
AFTER INSERT ON user
FOR EACH ROW
BEGIN
    -- Check if the user is a patient
    IF NEW.role = 'patient' THEN
        INSERT INTO patients (user_id, name)
        VALUES (NEW.id, NEW.username);

    -- Check if the user is a doctor
    ELSEIF NEW.role = 'doctor' THEN
        INSERT INTO doctors (user_id, name, doctor_license)
        VALUES (NEW.id, NEW.username, 'default_license');

    -- Check if the user is a pharmacy
    ELSEIF NEW.role = 'pharmacy' THEN
        INSERT INTO pharmacies (user_id, name, district, town, street, con_number, rating)
        VALUES (NEW.id, NEW.username, 'default_district', 'default_town', 'default_street', '0000000000', 0.0);
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE FUNCTION calculate_avg_rating(pharmId INT)
RETURNS DECIMAL(2,1)
DETERMINISTIC
BEGIN
    DECLARE avgRating DECIMAL(2,1);

    SELECT IFNULL(AVG(rating), 0.0) INTO avgRating
    FROM rating
    WHERE pharm_id = pharmId;

    RETURN avgRating;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_rating_insert
AFTER INSERT ON rating
FOR EACH ROW
BEGIN
    -- Update the rating in the pharmacies table for the corresponding pharmacy
    UPDATE pharmacies
    SET rating = calculate_avg_rating(NEW.pharm_id)
    WHERE pharm_id = NEW.pharm_id;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_rating_update
AFTER UPDATE ON rating
FOR EACH ROW
BEGIN
    -- Update the rating in the pharmacies table for the corresponding pharmacy
    UPDATE pharmacies
    SET rating = calculate_avg_rating(NEW.pharm_id)
    WHERE pharm_id = NEW.pharm_id;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_rating_delete
AFTER DELETE ON rating
FOR EACH ROW
BEGIN
    -- Update the rating in the pharmacies table for the corresponding pharmacy
    UPDATE pharmacies
    SET rating = calculate_avg_rating(OLD.pharm_id)
    WHERE pharm_id = OLD.pharm_id;
END//

DELIMITER ;

