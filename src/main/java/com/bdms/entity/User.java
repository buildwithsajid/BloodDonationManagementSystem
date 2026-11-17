package com.bdms.entity;

import java.time.LocalDateTime;
import org.hibernate.annotations.CreationTimestamp;
import java.util.*;
import com.bdms.enums.*;
import jakarta.persistence.*;

@Entity
@Table(name="users")
public class User {
	
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "user_id")
	private Long userId;
	
	@Column(name = "full_name", nullable = false, length = 100)
	private String fullName;
	
	@Column(name = "email", nullable = false, unique = true, length = 100)
	private String email;
	
	@Column(name = "password", nullable = false, length = 255)
	private String password;
	
	@Enumerated(EnumType.STRING)
	@Column(name = "role", nullable = false, length = 20)
	private UserRole role;
	
	@Enumerated(EnumType.STRING)
	@Column(name = "account_status", nullable = false, length = 20)
	private AccountStatus accountStatus = AccountStatus.ACTIVE;
	
	@CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
	
	// One user can have one donor profile.
    // Admin users do not need a donor profile.
    @OneToOne(mappedBy = "user", fetch = FetchType.LAZY)
    private Donor donor;
    
    
    // User who recorded donations.
    @OneToMany(mappedBy = "recordedBy")
    private Set<DonationHistory> recordedDonations = new HashSet<>();
    
    // User who created blood requests.
    @OneToMany(mappedBy = "createdBy")
    private Set<BloodRequest> createdBloodRequests = new HashSet<>();
    
    // User who updated donor availability.
    @OneToMany(mappedBy = "updatedBy")
    private Set<DonorAvailabilityHistory> availabilityUpdates = new HashSet<>();

	public User() {
		
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

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public UserRole getRole() {
		return role;
	}

	public void setRole(UserRole role) {
		this.role = role;
	}

	public AccountStatus getAccountStatus() {
		return accountStatus;
	}

	public void setAccountStatus(AccountStatus accountStatus) {
		this.accountStatus = accountStatus;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public Donor getDonor() {
		return donor;
	}

	public Set<DonationHistory> getRecordedDonations() {
		return recordedDonations;
	}

	public Set<BloodRequest> getCreatedBloodRequests() {
		return createdBloodRequests;
	}

	public Set<DonorAvailabilityHistory> getAvailabilityUpdates() {
		return availabilityUpdates;
	}
}
