package com.bdms.dto;

import jakarta.validation.constraints.*;

import java.time.LocalDate;

public class RegisterDonorRequest {

		@NotBlank(message = "Full name is required")
	    @Size(max = 100, message = "Full name cannot exceed 100 characters")
	    private String fullName;

	    @NotBlank(message = "Email is required")
	    @Email(message = "Please provide a valid email address")
	    private String email;

	    @NotBlank(message = "Password is required")
	    @Size(min = 8, max = 72, message = "Password must contain between 8 and 72 characters")
	    private String password;

	    @NotNull(message = "Blood group is required")
	    @Positive(message = "Invalid blood group ID")
	    private Long bloodGroupId;

	    @NotNull(message = "Date of birth is required")
	    @Past(message = "Date of birth must be in the past")
	    private LocalDate dateOfBirth;

	    @NotBlank(message = "Phone number is required")
	    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Please provide a valid phone number")
	    private String phone;

	    @Pattern(regexp = "MALE|FEMALE|OTHER|PREFER_NOT_TO_SAY",message = "Invalid gender value")
	    private String gender;

	    @NotBlank(message = "City is required")
	    private String city;

	    private String area;

	    
	    // Getters and Setters
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

	    public String getPassword() {
	        return password;
	    }

	    public void setPassword(String password) {
	        this.password = password;
	    }

	    public Long getBloodGroupId() {
	        return bloodGroupId;
	    }

	    public void setBloodGroupId(Long bloodGroupId) {
	        this.bloodGroupId = bloodGroupId;
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
}
