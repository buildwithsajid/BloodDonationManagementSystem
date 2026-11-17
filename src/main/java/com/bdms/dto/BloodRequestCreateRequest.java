package com.bdms.dto;

import java.time.LocalDateTime;

import com.bdms.enums.*;

import jakarta.validation.constraints.*;

public class BloodRequestCreateRequest {

	@NotBlank(message = "Patient name is required")
    @Size(max = 100, message = "Patient name cannot exceed 100 characters")
    private String patientName;

    @NotBlank(message = "Contact number is required")
    @Pattern(regexp = "^\\+?[0-9]{10,15}$", message = "Please provide a valid contact number")
    private String contactNumber;

    @NotNull(message = "Blood group is required")
    @Positive(message = "Invalid blood group ID")
    private Long bloodGroupId;

    @NotNull(message = "Units required is mandatory")
    @Positive(message = "Units required must be greater than zero")
    private Integer unitsRequired;

    @NotBlank(message = "Hospital name is required")
    @Size(max = 150, message = "Hospital name cannot exceed 150 characters")
    private String hospitalName;

    @NotBlank(message = "City is required")
    @Size(max = 100, message = "City cannot exceed 100 characters")
    private String city;

    @NotNull(message = "Urgency level is required")
    private UrgencyLevel urgency;

    private LocalDateTime requiredBy;

    // Constructors
    public BloodRequestCreateRequest() {
    }

    // Getters and Setters
    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public Long getBloodGroupId() {
        return bloodGroupId;
    }

    public void setBloodGroupId(Long bloodGroupId) {
        this.bloodGroupId = bloodGroupId;
    }

    public Integer getUnitsRequired() {
        return unitsRequired;
    }

    public void setUnitsRequired(Integer unitsRequired) {
        this.unitsRequired = unitsRequired;
    }

    public String getHospitalName() {
        return hospitalName;
    }

    public void setHospitalName(String hospitalName) {
        this.hospitalName = hospitalName;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public UrgencyLevel getUrgency() {
        return urgency;
    }

    public void setUrgency(UrgencyLevel urgency) {
        this.urgency = urgency;
    }

    public LocalDateTime getRequiredBy() {
        return requiredBy;
    }

    public void setRequiredBy(LocalDateTime requiredBy) {
        this.requiredBy = requiredBy;
    }
}
