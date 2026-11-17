package com.bdms.dto;

import jakarta.validation.constraints.NotNull;

public class AvailabilityUpdateRequest {

	@NotNull(message = "Availability status is required")
    private Boolean availability;

    // Constructors
    public AvailabilityUpdateRequest() {
    }

    public AvailabilityUpdateRequest(Boolean availability) {
        this.availability = availability;
    }

    // Getters and Setters
    public Boolean getAvailability() {
        return availability;
    }

    public void setAvailability(Boolean availability) {
        this.availability = availability;
    }
}
