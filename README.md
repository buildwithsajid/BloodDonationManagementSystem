# Blood Donation Management System (BDMS)

An enterprise-grade, privacy-protected web application designed to connect voluntary blood donors with regional hospitals, clinics, and emergency patients.

Developed for the **Advanced Java Programming** curriculum at **Guru Nanak Institute of Management Studies (GNIMS)**, Matunga, Mumbai.

---

## 🌟 Key Features

- **Public Donor Directory:** Fast, indexed searching by Blood Group (A+, A-, B+, B-, AB+, AB-, O+, O-) and City.
- **Privacy & Anti-Spam Protection:** Donor telephone numbers and email addresses are shielded from public display to prevent scraping and unsolicited marketing.
- **Role-Based Portals:**
  - **Donor Portal:** Self-service dashboard, live availability toggle (`Available` / `Unavailable`), and verified donation history records.
  - **Administrator Console:** Executive KPI dashboard, emergency blood request creation (`NORMAL`, `URGENT`, `CRITICAL`), verified donation recording, and user account status control.
- **Automated Eligibility Auditing:** Tracks historical availability state changes in an immutable audit ledger (`donor_availability_history`).
- **Standardized Medical UI:** Desktop-optimized presentation implementing a 5-color clinical palette (Warm Alabaster `#FFFDFB`, Clinical Teal `#0F766E`, Vibrant Rose-Red `#E11D48`, Soft Mint `#CCFBF1`, Deep Charcoal `#1E293B`).

---

## 🛠️ Technology Stack

- **Backend:** Java 21 LTS, Spring Boot 4, Spring MVC, Spring Data JPA, Hibernate ORM
- **Security:** BCrypt Password Hashing, Session Fixation Defense
- **Database:** MySQL 8.4 LTS / MySQL Server 8.0
- **Frontend:** Jakarta Server Pages (JSP), JSTL 3.0, HTML5, Vanilla CSS3, Vanilla JavaScript
- **Build Tool:** Apache Maven 3.9+ (Wrapper included)

---

## 🚀 Quick Setup & Execution

### 1. Database Setup
1. Open **MySQL Workbench 8.0 CE** and connect to your local MySQL server.
2. Open and execute the script:
   ```
   database/schema.sql
   ```
   This creates the database `blood_donation_db`, creates all 6 tables, seeds the 8 master blood groups, seeds the default admin, and adds 24 showcase donors (3 per blood type).

### 2. Run Application
Run via the one-click launcher or terminal:
- **Option A (One-Click):** Double-click `run.bat` in the project root.
- **Option B (Command Line):**
  ```cmd
  .\mvnw spring-boot:run
  ```

### 3. Access in Browser
Navigate to:
```
http://localhost:8080/
```

### 4. Default Credentials
| Account Role | Email | Password |
|---|---|---|
| **System Administrator** | `admin@bdms.com` | `admin123` |
| **Showcase Donors (Any)** | `aarav.sharma@example.com` | `donor123` |

---

## 📂 Project Directory Structure

```
BloodDonationManagementSystem/
├── database/
│   ├── README.md
│   └── schema.sql              # Database creation & seed queries
├── docs/                       # Project documentation, UML, and code guides
│   ├── PROJECT_DOCUMENTATION.pdf
│   ├── UML_DIAGRAMS.txt
│   ├── UML_DIAGRAMS_AND_EXPLANATION.pdf
│   └── CODEBASE_EXPLANATION_GUIDE.pdf
├── src/
│   ├── main/
│   │   ├── java/com/bdms/
│   │   │   ├── config/         # Security & Password Encoder configuration
│   │   │   ├── controller/     # Spring MVC Controllers
│   │   │   ├── dto/            # Data Transfer Objects with Bean Validation
│   │   │   ├── entity/         # JPA Persistence Entities
│   │   │   ├── enums/          # Domain Enumerations
│   │   │   ├── exception/      # Custom Runtime Business Exceptions
│   │   │   ├── repository/     # Spring Data JPA Repositories
│   │   │   └── service/        # Service interfaces & @Transactional implementations
│   │   ├── resources/
│   │   │   ├── static/         # CSS Component stylesheets & Vanilla JS
│   │   │   └── application.properties
│   │   └── webapp/WEB-INF/views/ # JSP Views (common, auth, donor, requests, admin)
├── pom.xml
└── run.bat                     # Windows one-click startup batch script
```

---

## 👥 Project Team (GNIMS Mumbai)

- **T087** - Sajid Nafis Khan
- **T088** - Team Member 2
- **T089** - Team Member 3
- **T090** - Team Member 4

Department of Information Technology & Computer Applications  
**Guru Nanak Institute of Management Studies (GNIMS)**, Matunga, Mumbai - 400019
