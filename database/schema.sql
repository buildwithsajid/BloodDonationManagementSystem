-- Blood Donation Management System
-- Database: blood_donation_db | MySQL 8.4 LTS
-- Run this entire file in MySQL Workbench. It creates the database if needed.
-- This follows the agreed six-table baseline.

CREATE DATABASE IF NOT EXISTS blood_donation_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE blood_donation_db;
SET NAMES utf8mb4;

-- 1. USERS: donor and admin login accounts.
CREATE TABLE IF NOT EXISTS users (
    user_id BIGINT NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL COMMENT 'Store a BCrypt hash, never plain text',
    role VARCHAR(20) NOT NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role CHECK (role IN ('ADMIN', 'DONOR')),
    CONSTRAINT chk_users_account_status CHECK (account_status IN ('ACTIVE', 'INACTIVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. BLOOD GROUPS: the eight supported blood groups.
CREATE TABLE IF NOT EXISTS blood_groups (
    blood_group_id BIGINT NOT NULL AUTO_INCREMENT,
    group_name VARCHAR(5) NOT NULL,
    CONSTRAINT pk_blood_groups PRIMARY KEY (blood_group_id),
    CONSTRAINT uq_blood_groups_group_name UNIQUE (group_name),
    CONSTRAINT chk_blood_groups_name CHECK (group_name IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. DONORS: one-to-one with users; many donors can share a blood group.
CREATE TABLE IF NOT EXISTS donors (
    donor_id BIGINT NOT NULL AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    blood_group_id BIGINT NOT NULL,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(15) NOT NULL,
    gender VARCHAR(20) NULL,
    city VARCHAR(100) NOT NULL,
    area VARCHAR(100) NULL,
    last_donation_date DATE NULL,
    availability BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_donors PRIMARY KEY (donor_id),
    CONSTRAINT uq_donors_user_id UNIQUE (user_id),
    CONSTRAINT fk_donors_user FOREIGN KEY (user_id) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_donors_blood_group FOREIGN KEY (blood_group_id) REFERENCES blood_groups (blood_group_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_donors_gender CHECK (gender IS NULL OR gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY')),
    INDEX idx_donors_blood_group (blood_group_id),
    INDEX idx_donors_city (city),
    INDEX idx_donors_availability (availability),
    INDEX idx_donors_search (blood_group_id, city, availability)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. DONATION HISTORY: donations belong to donors and are recorded by users (normally admins).
CREATE TABLE IF NOT EXISTS donation_history (
    donation_id BIGINT NOT NULL AUTO_INCREMENT,
    donor_id BIGINT NOT NULL,
    donation_date DATE NOT NULL,
    donation_location VARCHAR(150) NOT NULL,
    remarks VARCHAR(255) NULL,
    recorded_by BIGINT NOT NULL,
    CONSTRAINT pk_donation_history PRIMARY KEY (donation_id),
    CONSTRAINT fk_donation_history_donor FOREIGN KEY (donor_id) REFERENCES donors (donor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_donation_history_recorded_by FOREIGN KEY (recorded_by) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_donation_history_donor_date (donor_id, donation_date),
    INDEX idx_donation_history_recorded_by (recorded_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. BLOOD REQUESTS: requests are created and managed by admin users.
CREATE TABLE IF NOT EXISTS blood_requests (
    request_id BIGINT NOT NULL AUTO_INCREMENT,
    patient_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    blood_group_id BIGINT NOT NULL,
    units_required INT NOT NULL,
    hospital_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    urgency VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    request_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    required_by DATETIME NULL,
    created_by BIGINT NOT NULL,
    CONSTRAINT pk_blood_requests PRIMARY KEY (request_id),
    CONSTRAINT fk_blood_requests_blood_group FOREIGN KEY (blood_group_id) REFERENCES blood_groups (blood_group_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_blood_requests_created_by FOREIGN KEY (created_by) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_blood_requests_units CHECK (units_required >= 1),
    CONSTRAINT chk_blood_requests_urgency CHECK (urgency IN ('NORMAL', 'URGENT', 'CRITICAL')),
    CONSTRAINT chk_blood_requests_status CHECK (status IN ('PENDING', 'IN_PROGRESS', 'FULFILLED', 'CANCELLED')),
    CONSTRAINT chk_blood_requests_required_by CHECK (required_by IS NULL OR required_by >= request_date),
    INDEX idx_blood_requests_status (status),
    INDEX idx_blood_requests_blood_group (blood_group_id),
    INDEX idx_blood_requests_city (city),
    INDEX idx_blood_requests_open_search (status, blood_group_id, city),
    INDEX idx_blood_requests_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. DONOR AVAILABILITY HISTORY: records changes to donor availability.
CREATE TABLE IF NOT EXISTS donor_availability_history (
    history_id BIGINT NOT NULL AUTO_INCREMENT,
    donor_id BIGINT NOT NULL,
    previous_status BOOLEAN NULL,
    new_status BOOLEAN NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT NOT NULL,
    CONSTRAINT pk_donor_availability_history PRIMARY KEY (history_id),
    CONSTRAINT fk_availability_history_donor FOREIGN KEY (donor_id) REFERENCES donors (donor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_availability_history_updated_by FOREIGN KEY (updated_by) REFERENCES users (user_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_availability_history_donor_date (donor_id, updated_at),
    INDEX idx_availability_history_updated_by (updated_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Seed the blood-group lookup table. Safe to execute repeatedly.
INSERT IGNORE INTO blood_groups (group_name)
VALUES ('A+'), ('A-'), ('B+'), ('B-'), ('AB+'), ('AB-'), ('O+'), ('O-');

-- Seed default Administrator account (Email: admin@bdms.com | Password: admin123)
INSERT IGNORE INTO users (user_id, full_name, email, password, role, account_status)
VALUES (1, 'System Administrator', 'admin@bdms.com', '$2a$10$nl/dnM3VZjfyM2DN9rxWGuPMv8Et6UElvOcJVVrlv2etuF9jcR6fS', 'ADMIN', 'ACTIVE');

-- Seed 24 Showcase Donors (3 donors per blood type, password for all: donor123)
INSERT IGNORE INTO users (user_id, full_name, email, password, role, account_status) VALUES
(2, 'Aarav Sharma', 'aarav.sharma@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(3, 'Priya Patel', 'priya.patel@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(4, 'Rohan Deshmukh', 'rohan.deshmukh@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(5, 'Ananya Iyer', 'ananya.iyer@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(6, 'Vikram Joshi', 'vikram.joshi@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(7, 'Sneha Kulkarni', 'sneha.kulkarni@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(8, 'Rahul Verma', 'rahul.verma@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(9, 'Pooja Nair', 'pooja.nair@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(10, 'Aditya Shinde', 'aditya.shinde@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(11, 'Riya Sen', 'riya.sen@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(12, 'Kunal Bhatia', 'kunal.bhatia@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(13, 'Tanvi Sawant', 'tanvi.sawant@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(14, 'Sameer Khan', 'sameer.khan@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(15, 'Neha Gupta', 'neha.gupta@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(16, 'Amit Chauhan', 'amit.chauhan@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(17, 'Divya Menon', 'divya.menon@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(18, 'Siddharth Roy', 'siddharth.roy@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(19, 'Meera Merchant', 'meera.merchant@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(20, 'Arjun Rane', 'arjun.rane@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(21, 'Kavita Rao', 'kavita.rao@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(22, 'Gaurav Patil', 'gaurav.patil@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(23, 'Zoya Shaikh', 'zoya.shaikh@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(24, 'Nikhil Kamat', 'nikhil.kamat@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE'),
(25, 'Shreya More', 'shreya.more@example.com', '$2a$10$hL0A3.9rTPNcy/LijMN7c.OBr2qfTOfn2qvG0mwgsNn0nOxw1fwqC', 'DONOR', 'ACTIVE');

-- Seed Donors matching each of the 8 blood groups (3 per blood group)
INSERT IGNORE INTO donors (donor_id, user_id, blood_group_id, date_of_birth, phone, gender, city, area, last_donation_date, availability) VALUES
-- A+ (blood_group_id = 1)
(1, 2, 1, '1998-05-14', '9820112233', 'MALE', 'Mumbai', 'Dadar', '2026-08-10', TRUE),
(2, 3, 1, '2001-09-22', '9820223344', 'FEMALE', 'Pune', 'Kothrud', NULL, TRUE),
(3, 4, 1, '1995-11-03', '9820334455', 'MALE', 'Thane', 'Naupada', '2026-07-15', TRUE),

-- A- (blood_group_id = 2)
(4, 5, 2, '1999-03-18', '9820445566', 'FEMALE', 'Mumbai', 'Bandra West', '2026-06-20', TRUE),
(5, 6, 2, '1992-12-05', '9820556677', 'MALE', 'Navi Mumbai', 'Vashi', NULL, TRUE),
(6, 7, 2, '2002-07-29', '9820667788', 'FEMALE', 'Pune', 'Aundh', '2026-05-12', TRUE),

-- B+ (blood_group_id = 3)
(7, 8, 3, '1997-01-25', '9820778899', 'MALE', 'Mumbai', 'Andheri East', '2026-08-01', TRUE),
(8, 9, 3, '2000-08-11', '9820889900', 'FEMALE', 'Mumbai', 'Goregaon', '2026-09-05', TRUE),
(9, 10, 3, '1996-04-19', '9820990011', 'MALE', 'Pune', 'Shivajinagar', NULL, TRUE),

-- B- (blood_group_id = 4)
(10, 11, 4, '1999-10-14', '9821001122', 'FEMALE', 'Mumbai', 'Juhu', '2026-07-02', TRUE),
(11, 12, 4, '1994-06-30', '9821112233', 'MALE', 'Thane', 'Majiwada', NULL, TRUE),
(12, 13, 4, '2003-02-17', '9821223344', 'FEMALE', 'Navi Mumbai', 'Nerul', '2026-06-18', TRUE),

-- AB+ (blood_group_id = 5)
(13, 14, 5, '1995-09-08', '9821334455', 'MALE', 'Mumbai', 'Kurla', '2026-08-20', TRUE),
(14, 15, 5, '2001-04-03', '9821445566', 'FEMALE', 'Pune', 'Baner', NULL, TRUE),
(15, 16, 5, '1993-11-28', '9821556677', 'MALE', 'Mumbai', 'Chembur', '2026-07-22', TRUE),

-- AB- (blood_group_id = 6)
(16, 17, 6, '1998-12-15', '9821667788', 'FEMALE', 'Mumbai', 'Powai', '2026-05-30', TRUE),
(17, 18, 6, '1996-07-07', '9821778899', 'MALE', 'Pune', 'Hinjewadi', NULL, TRUE),
(18, 19, 6, '2002-01-21', '9821889900', 'FEMALE', 'Thane', 'Ghodbunder', '2026-06-11', TRUE),

-- O+ (blood_group_id = 7)
(19, 20, 7, '1997-03-12', '9821990011', 'MALE', 'Mumbai', 'Dadar West', '2026-08-15', TRUE),
(20, 21, 7, '2000-06-24', '9822001122', 'FEMALE', 'Mumbai', 'Borivali', NULL, TRUE),
(21, 22, 7, '1994-09-17', '9822112233', 'MALE', 'Navi Mumbai', 'Kharghar', '2026-07-10', TRUE),

-- O- (blood_group_id = 8)
(22, 23, 8, '1999-08-05', '9822223344', 'FEMALE', 'Mumbai', 'Colaba', '2026-06-25', TRUE),
(23, 24, 8, '1993-02-14', '9822334455', 'MALE', 'Pune', 'Kalyani Nagar', NULL, TRUE),
(24, 25, 8, '2001-11-30', '9822445566', 'FEMALE', 'Thane', 'Thane West', '2026-08-05', TRUE);

-- Verification
SHOW TABLES;
SELECT blood_group_id, group_name FROM blood_groups ORDER BY blood_group_id;
