@echo off
title Blood Donation Management System (BDMS)
echo ========================================================
echo   Blood Donation Management System - Starting Server...
echo ========================================================

REM Set JAVA_HOME correctly without trailing \bin
if exist "C:\Program Files\Eclipse Adoptium\jdk-25.0.5.8-hotspot\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-25.0.5.8-hotspot"
) else if exist "C:\Program Files\Java\jdk-27.0.1.0.3\bin\java.exe" (
    set "JAVA_HOME=C:\Program Files\Java\jdk-27.0.1.0.3"
)

echo Using JAVA_HOME: %JAVA_HOME%
echo Database URL: jdbc:mysql://localhost:3306/blood_donation_db
echo Application will be available at: http://localhost:8080/
echo.

call mvnw.cmd spring-boot:run
pause
