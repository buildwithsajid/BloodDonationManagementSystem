package com.bdms.dto;

public class BloodGroupResponse {

	private Long bloodGroupId;
    private String groupName;

    // Constructors
    public BloodGroupResponse() {
    }

    public BloodGroupResponse(Long bloodGroupId, String groupName) {
        this.bloodGroupId = bloodGroupId;
        this.groupName = groupName;
    }

    // Getters and Setters
    public Long getBloodGroupId() {
        return bloodGroupId;
    }

    public void setBloodGroupId(Long bloodGroupId) {
        this.bloodGroupId = bloodGroupId;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }
}
