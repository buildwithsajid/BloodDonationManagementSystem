# PROJECT DOCUMENTATION
## BLOOD DONATION MANAGEMENT SYSTEM (BDMS)

**Academic Course:** Advanced Java Programming (Mini-Project)  
**Institution:** Guru Nanak Institute of Management Studies (GNIMS), King's Circle, Matunga, Mumbai - 400019  
**Department:** Department of Information Technology & Computer Applications  
**Academic Year:** 2026-2027  
**Technology Stack:** Java 21 LTS, Spring Boot 4, Spring Data JPA, Hibernate ORM, MySQL 8.4 LTS, JSP, JSTL, CSS3, Vanilla JavaScript  

---

### TABLE OF CONTENTS
1. [Executive Summary & Abstract](#1-executive-summary--abstract)
2. [Introduction & Problem Statement](#2-introduction--problem-statement)
3. [Existing System vs. Proposed System](#3-existing-system-vs-proposed-system)
4. [Project Objectives & Scope](#4-project-objectives--scope)
5. [System Requirements Specifications (SRS)](#5-system-requirements-specifications-srs)
6. [System Architecture & Design](#6-system-architecture--design)
7. [Functional Modules Breakdown](#7-functional-modules-breakdown)
8. [Database Design & Data Dictionary](#8-database-design--data-dictionary)
9. [Advanced Java Syllabus Concepts Demonstrated](#9-advanced-java-syllabus-concepts-demonstrated)
10. [Security, Authorization & Privacy Features](#10-security-authorization--privacy-features)
11. [Testing & Verification](#11-testing--verification)
12. [Conclusion & Future Enhancements](#12-conclusion--future-enhancements)

---

### 1. Executive Summary & Abstract
The **Blood Donation Management System (BDMS)** is an enterprise-grade web application engineered to bridge the life-critical coordination gap between voluntary blood donors, hospital emergency units, and blood bank administrators. 

Traditional blood bank operations suffer from fragmented donor registers, inaccurate availability statuses, and delayed emergency response times. BDMS solves this by providing a unified digital platform featuring:
- Role-based workflows for **Public Visitors**, **Donors**, and **System Administrators**.
- Real-time donor availability search indexed by ABO & Rh blood groups and geographical location.
- Strict **Data Privacy Protection** by masking donor contact details from public web scrapers while retaining administrative dispatch capabilities.
- A clinical emergency requisition lifecycle with urgency-based triage (`NORMAL`, `URGENT`, `CRITICAL`).
- Immutable audit logging for donor availability toggles.

The project is developed using **Java 21**, **Spring Boot 4**, **Spring Data JPA**, **MySQL**, and server-side **JSP (JavaServer Pages)** with componentized CSS following a healthcare-focused 5-color palette.

---

### 2. Introduction & Problem Statement
In clinical emergencies, the availability of compatible blood within the "Golden Hour" directly dictates patient survival rates. Despite widespread willingness among citizens to donate blood, existing mechanisms rely on:
1. Manual paper-based physical registries prone to physical decay, duplication, and human indexing errors.
2. Unverified social media broadcast messages, which lack authenticity and result in spamming donor phone numbers without clinical verification.
3. Lack of status synchronization, where donors who recently donated are contacted despite being medically deferred (the mandatory 90–120 day cooling period).

**Problem Statement:**  
There is an urgent requirement for a secure, localized, and medically sound digital management system that maintains verified donor records, enables rapid multi-criteria searching without privacy leakage, tracks donation intervals, and streamlines hospital requisition workflows.

---

### 3. Existing System vs. Proposed System

| Parameter | Traditional / Existing System | Proposed BDMS Application |
|---|---|---|
| **Record Maintenance** | Physical registers or disparate spreadsheets | Normalized relational MySQL database with foreign-key constraints |
| **Search Mechanism** | Manual lookup; highly inefficient | Instant indexed search by Blood Group and City |
| **Donor Privacy** | Contact details publicly leaked or written in paper | Public search masks Phone & Email; communication handled via Admin |
| **Availability Tracking** | Static; donors called even when unavailable | Live toggle with complete audit history log (`donor_availability_history`) |
| **Security & Passwords** | Plaintext or unencrypted credentials | Industry-standard BCrypt hashing with session fixation defense |
| **Requisition Tracking** | Informal phone calls | Formalized state machine (`PENDING` $\rightarrow$ `IN_PROGRESS` $\rightarrow$ `FULFILLED`) |

---

### 4. Project Objectives & Scope
#### Objectives:
1. Provide a self-service registration portal for voluntary blood donors.
2. Enable public search of eligible donors by blood group and city without exposing private contact info.
3. Implement an Administrative Console to record verified blood donations and track donors' last donation dates.
4. Establish an Emergency Blood Requisition workflow with urgency indicators.
5. Maintain transparent audit trails for all availability changes.

#### Scope:
- **In Scope:** Donor profile management, blood group normalization, availability status updates, emergency blood requisitions, donation history logging, user account status control, and desktop-optimized healthcare UI.
- **Out of Scope (Future Scope):** Automated SMS gateway integration, third-party payment processing, and geographic GPS map radius tracking.

---

### 5. System Requirements Specifications (SRS)

#### Hardware Requirements:
- **Processor:** Intel Core i3 / AMD Ryzen 3 or higher.
- **Memory (RAM):** Minimum 4 GB (8 GB recommended for concurrent IDE + MySQL + Spring Boot execution).
- **Hard Disk Space:** Minimum 500 MB free space.
- **Display Resolution:** Minimum 1280 x 720 (Optimized for desktop/laptop displays).

#### Software Requirements:
- **Operating System:** Windows 10/11, Linux, or macOS.
- **JDK:** OpenJDK 21 LTS or Eclipse Adoptium Temurin 21+.
- **Database Server:** MySQL Server 8.0 / 8.4 LTS (listening on port `3306`).
- **Database Client:** MySQL Workbench 8.0 CE.
- **Build Tool:** Apache Maven 3.9+ (bundled via `mvnw`).
- **Web Browser:** Google Chrome, Microsoft Edge, or Mozilla Firefox.

---

### 6. System Architecture & Design
BDMS is designed around the **MVC (Model-View-Controller)** pattern and follows a **3-Tier Layered Architecture**:

```
[ Client Browser (HTML5 / Vanilla CSS3 / Vanilla JS) ]
                        |
                        | HTTP GET / POST
                        v
[ CONTROLLER LAYER (Spring MVC Controllers) ]
  - AuthController, AdminController, DonorController,
    BloodRequestController, DonationHistoryController,
    UserController, BloodGroupController
                        |
                        | DTOs & Validation (@Valid)
                        v
[ SERVICE LAYER (Business Rules & Transactions) ]
  - DonorService, UserService, BloodRequestService,
    DonationHistoryService, AvailabilityHistoryService
  - Governed by @Transactional (ACID compliance)
                        |
                        | Entities
                        v
[ DATA ACCESS LAYER (Spring Data JPA / Hibernate) ]
  - JpaRepositories with @EntityGraph (Eager Join Fetching)
                        |
                        | JDBC (mysql-connector-j)
                        v
[ PERSISTENCE LAYER (MySQL 8.4 Database: blood_donation_db) ]
```

---

### 7. Functional Modules Breakdown

1. **Authentication & Session Module (`com.bdms.controller.AuthController`)**
   - Public registration for Donors with automatic password hashing via BCrypt.
   - Session-based authentication with session fixation protection (`request.changeSessionId()`).
   - Role-based dashboard dispatch (`ADMIN` $\rightarrow$ `/admin/dashboard`, `DONOR` $\rightarrow$ `/donor/dashboard`).

2. **Donor Management Module (`com.bdms.controller.DonorController`)**
   - Personal dashboard showing blood group, live availability, and last donation date.
   - Profile self-service to toggle availability (`true`/`false`).
   - Public Directory (`/donors/available`) filtering by blood group and city with PII protection.

3. **Emergency Blood Requisition Module (`com.bdms.controller.BloodRequestController`)**
   - Allows administrators to log patient demands specifying hospital, city, urgency level (`NORMAL`, `URGENT`, `CRITICAL`), and required units.
   - Enforces valid lifecycle state transitions (`PENDING` $\rightarrow$ `IN_PROGRESS` $\rightarrow$ `FULFILLED` or `CANCELLED`).

4. **Donation History & Ledger Module (`com.bdms.controller.DonationHistoryController`)**
   - Records verified clinical donation events.
   - Updates the donor's `last_donation_date` in the `donors` table.
   - Enforces chronological integrity (donation date cannot be in the future or prior to a previous donation).

5. **Audit History Module (`com.bdms.controller.DonorAvailabilityHistoryController`)**
   - Immutable audit logging tracking every availability status flip, capturing the previous state, new state, modifying user, and exact timestamp.

6. **Admin Operations & Control Module (`com.bdms.controller.AdminController`, `UserController`)**
   - Central console displaying live aggregate metrics: Total Donors, Available Donors, Total Requests, Total Donations.
   - User account status management (activation and deactivation) with self-lockout prevention.

---

### 8. Database Design & Data Dictionary

The persistence tier consists of 6 relational tables under `blood_donation_db`:

#### Table 1: `users`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `user_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Unique identifier for system user |
| `full_name` | `VARCHAR(100)` | `NOT NULL` | User's full legal name |
| `email` | `VARCHAR(100)` | `NOT NULL, UNIQUE` | Normalized login email address |
| `password` | `VARCHAR(255)` | `NOT NULL` | BCrypt encrypted password hash |
| `role` | `VARCHAR(20)` | `CHECK IN ('ADMIN', 'DONOR')` | Access control role |
| `account_status` | `VARCHAR(20)` | `CHECK IN ('ACTIVE', 'INACTIVE')` | Account standing |
| `created_at` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Account creation timestamp |

#### Table 2: `blood_groups`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `blood_group_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Master blood group identifier |
| `group_name` | `VARCHAR(5)` | `NOT NULL, UNIQUE, CHECK` | One of: `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-` |

#### Table 3: `donors`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `donor_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Unique donor profile identifier |
| `user_id` | `BIGINT` | `FK -> users(user_id), UNIQUE` | 1-to-1 link to user account |
| `blood_group_id` | `BIGINT` | `FK -> blood_groups` | Donor's biological blood group |
| `date_of_birth` | `DATE` | `NOT NULL` | Date of birth for eligibility |
| `phone` | `VARCHAR(15)` | `NOT NULL` | Contact phone number |
| `gender` | `VARCHAR(20)` | `CHECK ('MALE','FEMALE','OTHER',...)` | Biological gender |
| `city` | `VARCHAR(100)` | `NOT NULL, INDEX` | Registered residential city |
| `area` | `VARCHAR(100)` | `NULL` | Locality / neighborhood |
| `last_donation_date`| `DATE` | `NULL` | Most recent donation date |
| `availability` | `BOOLEAN` | `DEFAULT TRUE, INDEX` | Current donation readiness flag |
| `created_at` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Profile creation timestamp |

#### Table 4: `donation_history`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `donation_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Unique donation record ID |
| `donor_id` | `BIGINT` | `FK -> donors(donor_id)` | Donor who donated blood |
| `donation_date` | `DATE` | `NOT NULL` | Date donation took place |
| `donation_location`| `VARCHAR(150)`| `NOT NULL` | Blood bank or camp venue |
| `remarks` | `VARCHAR(255)` | `NULL` | Clinical observations/notes |
| `recorded_by` | `BIGINT` | `FK -> users(user_id)` | Administrator who recorded entry |

#### Table 5: `blood_requests`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `request_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Unique request identifier |
| `patient_name` | `VARCHAR(100)` | `NOT NULL` | Patient requiring blood |
| `contact_number` | `VARCHAR(15)` | `NOT NULL` | Attendant contact number |
| `blood_group_id` | `BIGINT` | `FK -> blood_groups` | Demanded blood group |
| `units_required` | `INT` | `CHECK (units_required >= 1)` | Number of blood units |
| `hospital_name` | `VARCHAR(150)` | `NOT NULL` | Treatment hospital / clinic |
| `city` | `VARCHAR(100)` | `NOT NULL` | City where hospital is located |
| `urgency` | `VARCHAR(20)` | `CHECK ('NORMAL','URGENT','CRITICAL')` | Clinical urgency level |
| `status` | `VARCHAR(20)` | `CHECK ('PENDING','IN_PROGRESS',...)`| Requisition status |
| `request_date` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Submission timestamp |
| `required_by` | `DATETIME` | `NULL` | Deadline for fulfillment |
| `created_by` | `BIGINT` | `FK -> users(user_id)` | Administrator logging request |

#### Table 6: `donor_availability_history`
| Column Name | Data Type | Constraints | Description |
|---|---|---|---|
| `history_id` | `BIGINT` | `PK, AUTO_INCREMENT` | Audit log entry ID |
| `donor_id` | `BIGINT` | `FK -> donors(donor_id)` | Donor whose status changed |
| `previous_status`| `BOOLEAN` | `NULL` | Status before update |
| `new_status` | `BOOLEAN` | `NOT NULL` | Status after update |
| `updated_at` | `DATETIME` | `DEFAULT CURRENT_TIMESTAMP` | Timestamp of update |
| `updated_by` | `BIGINT` | `FK -> users(user_id)` | User who triggered the change |

---

### 9. Advanced Java Syllabus Concepts Demonstrated

1. **Collections Framework & Stream API:**
   - Active utilization of `java.util.List`, `ArrayList`, `Map`, and `Optional<T>`.
   - Complex data pipelines with Stream filtering and mapping:
     ```java
     List<BloodRequestResponse> requests = bloodRequestService
         .getBloodRequestsByStatus(RequestStatus.PENDING)
         .stream()
         .map(this::convertToResponse)
         .toList();
     ```
2. **Spring Boot Framework:**
   - Inversion of Control (IoC) and Constructor-based Dependency Injection.
   - Declarative transaction boundaries with `@Transactional`.
   - Comprehensive request dispatching with `@Controller`, `@GetMapping`, `@PostMapping`, `@ModelAttribute`, `@PathVariable`, and `@RequestParam`.
3. **Database Connectivity (JPA / Hibernate ORM):**
   - Entity relationship mapping (`@OneToOne`, `@ManyToOne`, `@JoinColumn`).
   - Prevention of Hibernate N+1 queries through `@EntityGraph(attributePaths = {"user", "bloodGroup"})`.
   - Custom derived query methods in Spring Data JPA:
     ```java
     List<Donor> findByBloodGroup_GroupNameAndAvailabilityTrue(String groupName);
     List<Donor> findByAvailabilityTrueAndCityIgnoreCase(String city);
     ```
4. **Data Validation (JSR-380 / Bean Validation):**
   - Declarative DTO annotations (`@NotBlank`, `@NotNull`, `@Size`, `@Email`, `@Past`, `@Positive`).
   - Server-side error capture using Spring's `BindingResult`.

---

### 10. Security, Authorization & Privacy Features
1. **BCrypt Password Encryption:**
   - Passwords are salted with a 10-round key derivation function using `BCryptPasswordEncoder`. Plaintext passwords never touch the database.
2. **Session Fixation Countermeasure:**
   - On successful authentication, `request.changeSessionId()` is executed to invalidate the pre-authentication session ID and prevent fixation attacks.
3. **Donor Data Privacy & Anti-Spam Architecture:**
   - The public-facing donor search masks telephone numbers and email addresses to protect voluntary donors from telemarketing and scraping.
4. **Self-Lockout Prevention:**
   - In `UserServiceImpl`, administrators are prevented from deactivating their own administrative user accounts.

---

### 11. Testing & Verification

| Test Case ID | Test Scenario | Input Data | Expected Result | Outcome |
|---|---|---|---|---|
| **TC-01** | Public Donor Search | Blood Group: `O+`, City: `Mumbai` | Displays matching available donors with phone/email masked | **PASS** |
| **TC-02** | Donor Registration | Valid donor details + password | User created with role `DONOR`, redirect to `/login` | **PASS** |
| **TC-03** | Donor Login | Email: `aarav.sharma@example.com`, Password: `donor123` | Session initiated, redirects to `/donor/dashboard` | **PASS** |
| **TC-04** | Toggle Availability | Set availability to `false` | Status updated; audit row inserted in `donor_availability_history` | **PASS** |
| **TC-05** | Admin Login | Email: `admin@bdms.com`, Password: `admin123` | Redirects to `/admin/dashboard` showing aggregate metrics | **PASS** |
| **TC-06** | Create Blood Request | Patient: Alice, Group: `B+`, Units: 2, Hospital: City Hospital | Request saved as `PENDING`, appears in active list | **PASS** |
| **TC-07** | Record Donation | Donor ID: 1, Date: Current Date, Location: Red Cross | Donation logged; donor's `last_donation_date` updated | **PASS** |
| **TC-08** | Future Donation Date Check | Donation Date: Future Date | Rejected with `BusinessRuleException` validation message | **PASS** |

---

### 12. Conclusion & Future Enhancements
The Blood Donation Management System successfully satisfies all requirements for an Advanced Java mini-project. It showcases full-stack development competency, from database modeling and ORM optimization to secure backend business logic and an accessible healthcare-inspired user interface.

**Future Roadmap:**
- Implementation of automated SMS and WhatsApp alerts for `CRITICAL` urgency requests.
- Incorporation of automated blood component inventory (Packed Red Blood Cells, Platelets, Plasma).
- Integration of a donor recognition reward tier and downloadable donation certificates in PDF format.
