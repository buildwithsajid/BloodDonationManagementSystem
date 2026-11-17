package com.bdms.dto;

import java.time.LocalDateTime;

import com.bdms.enums.*;

public class BloodRequestResponse {

	private Long requestId;
    private String patientName;
    private String contactNumber;
    private String bloodGroup;
    private Integer unitsRequired;
    private String hospitalName;
    private String city;
    private UrgencyLevel urgency;
    private RequestStatus status;
    private LocalDateTime requestDate;
    private LocalDateTime requiredBy;
    private Long createdByUserId;
    private String createdByName;

    // Constructors

    public BloodRequestResponse() {
    }

    public BloodRequestResponse(Long requestId, String patientName, String contactNumber, String bloodGroup, Integer unitsRequired, String hospitalName,
            String city, UrgencyLevel urgency, RequestStatus status, LocalDateTime requestDate, LocalDateTime requiredBy, Long createdByUserId, String createdByName) {
        this.requestId = requestId;
        this.patientName = patientName;
        this.contactNumber = contactNumber;
        this.bloodGroup = bloodGroup;
        this.unitsRequired = unitsRequired;
        this.hospitalName = hospitalName;
        this.city = city;
        this.urgency = urgency;
        this.status = status;
        this.requestDate = requestDate;
        this.requiredBy = requiredBy;
        this.createdByUserId = createdByUserId;
        this.createdByName = createdByName;
    }

    // Getters and Setters
    public Long getRequestId() {
        return requestId;
    }

    public void setRequestId(Long requestId) {
        this.requestId = requestId;
    }

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

    public String getBloodGroup() {
        return bloodGroup;
    }

    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
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

    public RequestStatus getStatus() {
        return status;
    }

    public void setStatus(RequestStatus status) {
        this.status = status;
    }

    public LocalDateTime getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(LocalDateTime requestDate) {
        this.requestDate = requestDate;
    }

    public LocalDateTime getRequiredBy() {
        return requiredBy;
    }

    public void setRequiredBy(LocalDateTime requiredBy) {
        this.requiredBy = requiredBy;
    }

    public Long getCreatedByUserId() {
        return createdByUserId;
    }

    public void setCreatedByUserId(Long createdByUserId) {
        this.createdByUserId = createdByUserId;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }
}
