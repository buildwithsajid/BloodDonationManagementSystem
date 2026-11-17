package com.bdms.dto;

import java.time.LocalDateTime;

public class AvailabilityHistoryResponse {

	private Long historyId;
    private Long donorId;
    private String donorName;
    private Boolean previousStatus;
    private Boolean newStatus;
    private LocalDateTime updatedAt;
    private Long updatedByUserId;
    private String updatedByName;

    // Constructors
    public AvailabilityHistoryResponse() {
    }

    public AvailabilityHistoryResponse(Long historyId, Long donorId, String donorName, Boolean previousStatus, Boolean newStatus, LocalDateTime updatedAt, 
    		Long updatedByUserId, String updatedByName) {
        this.historyId = historyId;
        this.donorId = donorId;
        this.donorName = donorName;
        this.previousStatus = previousStatus;
        this.newStatus = newStatus;
        this.updatedAt = updatedAt;
        this.updatedByUserId = updatedByUserId;
        this.updatedByName = updatedByName;
    }

    // Getters and Setters
    public Long getHistoryId() {
        return historyId;
    }

    public void setHistoryId(Long historyId) {
        this.historyId = historyId;
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

    public Boolean getPreviousStatus() {
        return previousStatus;
    }

    public void setPreviousStatus(Boolean previousStatus) {
        this.previousStatus = previousStatus;
    }

    public Boolean getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(Boolean newStatus) {
        this.newStatus = newStatus;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Long getUpdatedByUserId() {
        return updatedByUserId;
    }

    public void setUpdatedByUserId(Long updatedByUserId) {
        this.updatedByUserId = updatedByUserId;
    }

    public String getUpdatedByName() {
        return updatedByName;
    }

    public void setUpdatedByName(String updatedByName) {
        this.updatedByName = updatedByName;
    }
}
