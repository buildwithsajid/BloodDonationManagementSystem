package com.bdms.dto;

import java.time.LocalDate;

public class DonationResponse {

	private Long donationId;
    private Long donorId;
    private String donorName;
    private String bloodGroup;
    private LocalDate donationDate;
    private String donationLocation;
    private String remarks;
    private Long recordedByUserId;
    private String recordedByName;

    // Constructors

    public DonationResponse() {
    }

    public DonationResponse(Long donationId, Long donorId, String donorName, String bloodGroup, LocalDate donationDate, String donationLocation, String remarks, Long recordedByUserId,
            String recordedByName) {
        this.donationId = donationId;
        this.donorId = donorId;
        this.donorName = donorName;
        this.bloodGroup = bloodGroup;
        this.donationDate = donationDate;
        this.donationLocation = donationLocation;
        this.remarks = remarks;
        this.recordedByUserId = recordedByUserId;
        this.recordedByName = recordedByName;
    }

    // Getters and Setters
    public Long getDonationId() {
        return donationId;
    }

    public void setDonationId(Long donationId) {
        this.donationId = donationId;
    }

    public Long getDonorId() {
        return donorId;
    }

    public void setDonorId(Long donorId) {
        this.donorId = donorId;
    }

    public String getDonorName() {
        return donorName;
    }

    public void setDonorName(String donorName) {
        this.donorName = donorName;
    }

    public String getBloodGroup() {
        return bloodGroup;
    }

    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
    }

    public LocalDate getDonationDate() {
        return donationDate;
    }

    public void setDonationDate(LocalDate donationDate) {
        this.donationDate = donationDate;
    }

    public String getDonationLocation() {
        return donationLocation;
    }

    public void setDonationLocation(String donationLocation) {
        this.donationLocation = donationLocation;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public Long getRecordedByUserId() {
        return recordedByUserId;
    }

    public void setRecordedByUserId(Long recordedByUserId) {
        this.recordedByUserId = recordedByUserId;
    }

    public String getRecordedByName() {
        return recordedByName;
    }

    public void setRecordedByName(String recordedByName) {
        this.recordedByName = recordedByName;
    }
}
