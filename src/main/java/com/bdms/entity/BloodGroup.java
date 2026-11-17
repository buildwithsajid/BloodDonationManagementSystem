package com.bdms.entity;

import java.util.*;
import jakarta.persistence.*;

@Entity
@Table(name = "blood_groups")
public class BloodGroup {
	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "blood_group_id")
    private Long bloodGroupId;

    @Column(name = "group_name", nullable = false, unique = true, length = 5)
    private String groupName;

    // One blood group can belong to many donors.
    @OneToMany(mappedBy = "bloodGroup")
    private Set<Donor> donors = new HashSet<>();

    // One blood group can be associated with many blood requests.
    @OneToMany(mappedBy = "bloodGroup")
    private Set<BloodRequest> bloodRequests = new HashSet<>();

    public BloodGroup() {
    }

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

    public Set<Donor> getDonors() {
        return donors;
    }

    public Set<BloodRequest> getBloodRequests() {
        return bloodRequests;
    }
}
