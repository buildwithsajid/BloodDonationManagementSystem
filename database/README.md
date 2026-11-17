# Database Setup – Blood Donation Management System

## Requirements
- MySQL Server 8.4 LTS
- MySQL Workbench

## Database Name
`blood_donation_db`

## Setup Instructions

1. Install and start MySQL Server.
2. Open MySQL Workbench.
3. Connect to your local MySQL server.
4. Open the `schema.sql` file.
5. Execute the complete SQL script.
6. Refresh the Schemas panel.
7. Verify that all six tables have been created.

## Tables

1. users
2. donors
3. blood_groups
4. donation_history
5. blood_requests
6. donor_availability_history

The schema script creates the database and all six tables and inserts the eight supported blood groups.

## Important
Each team member should configure their own local MySQL credentials. Never commit database passwords to GitHub.