package com.bdms.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class DonorResponse {

	private Long donorId;
    private Long userId;
    private String fullName;
    private String email;
    private String bloodGroup;
    private LocalDate dateOfBirth;
    private String phone;
    private String gender;
    private String city;
    private String area;
    private LocalDate lastDonationDate;
    private Boolean availability;
    private LocalDateTime createdAt;

    // Constructors
    public DonorResponse() {
    }

    public DonorResponse(Long donorId, Long userId, String fullName, String email, String bloodGroup, LocalDate dateOfBirth, String phone, String gender, 
    		String city, String area, LocalDate lastDonationDate, Boolean availability, LocalDateTime createdAt) {

        this.donorId = donorId;
        this.userId = userId;
        this.fullName = fullName;
        this.email = email;
        this.bloodGroup = bloodGroup;
        this.dateOfBirth = dateOfBirth;
        this.phone = phone;
        this.gender = gender;
        this.city = city;
        this.area = area;
        this.lastDonationDate = lastDonationDate;
        this.availability = availability;
        this.createdAt = createdAt;
    }

    // Getters and Setters

    public Long getDonorId() {
        return donorId;
    }

    public void setDonorId(Long donorId) {
        this.donorId = donorId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getBloodGroup() {
        return bloodGroup;
    }

    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getArea() {
        return area;
    }

    public void setArea(String area) {
        this.area = area;
    }

    public LocalDate getLastDonationDate() {
        return lastDonationDate;
    }

    public void setLastDonationDate(LocalDate lastDonationDate) {
        this.lastDonationDate = lastDonationDate;
    }

    public Boolean getAvailability() {
        return availability;
    }

    public void setAvailability(Boolean availability) {
        this.availability = availability;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

}
