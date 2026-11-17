package com.bdms.dto;

import java.time.LocalDate;

import jakarta.validation.constraints.*;

public class DonationCreateRequest {

	@NotNull(message = "Donor ID is required")
    @Positive(message = "Invalid donor ID")
    private Long donorId;

    @NotNull(message = "Donation date is required")
    @PastOrPresent(message = "Donation date cannot be in the future")
    private LocalDate donationDate;

    @NotBlank(message = "Donation location is required")
    @Size(max = 150, message = "Donation location cannot exceed 150 characters")
    private String donationLocation;

    @Size(max = 500, message = "Remarks cannot exceed 500 characters")
    private String remarks;

    // Constructors
    public DonationCreateRequest() {
    }

    // Getters and Setters
    public Long getDonorId() {
        return donorId;
    }

    public void setDonorId(Long donorId) {
        this.donorId = donorId;
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
}
