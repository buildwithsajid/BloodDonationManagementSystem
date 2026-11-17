package com.bdms.service.impl;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdms.entity.*;
import com.bdms.enums.*;
import com.bdms.exception.*;
import com.bdms.repository.*;
import com.bdms.service.BloodGroupService;
import com.bdms.service.BloodRequestService;

@Service
@Transactional
public class BloodRequestServiceImpl implements BloodRequestService {

	private final BloodRequestRepository bloodRequestRepository;
	private final UserRepository userRepository;
	private final BloodGroupService bloodGroupService;

	public BloodRequestServiceImpl(BloodRequestRepository bloodRequestRepository, UserRepository userRepository,
			BloodGroupService bloodGroupService) {
		this.bloodRequestRepository = bloodRequestRepository;
		this.userRepository = userRepository;
		this.bloodGroupService = bloodGroupService;
	}

	@Override
	public BloodRequest createBloodRequest(BloodRequest bloodRequest, Long createdByUserId) {

		if (bloodRequest == null) {
			throw new BusinessRuleException("Blood request details cannot be empty.");
		}

		if (createdByUserId == null || createdByUserId <= 0) {
			throw new BusinessRuleException("Creator user ID is required.");
		}

		// Retrieve and verify the administrator.
		User creator = userRepository.findById(createdByUserId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + createdByUserId));

		if (creator.getRole() != UserRole.ADMIN || creator.getAccountStatus() != AccountStatus.ACTIVE) {
			throw new BusinessRuleException("Only active administrators can create blood requests.");
		}

		// Validate required patient and request details.
		if (bloodRequest.getPatientName() == null || bloodRequest.getPatientName().isBlank()) {
			throw new BusinessRuleException("Patient name is required.");
		}

		if (bloodRequest.getContactNumber() == null || bloodRequest.getContactNumber().isBlank()) {
			throw new BusinessRuleException("Contact number is required.");
		}

		if (bloodRequest.getUnitsRequired() == null || bloodRequest.getUnitsRequired() <= 0) {
			throw new BusinessRuleException("Units required must be greater than zero.");
		}

		if (bloodRequest.getHospitalName() == null || bloodRequest.getHospitalName().isBlank()) {
			throw new BusinessRuleException("Hospital name is required.");
		}

		if (bloodRequest.getCity() == null || bloodRequest.getCity().isBlank()) {
			throw new BusinessRuleException("City is required.");
		}

		if (bloodRequest.getBloodGroup() == null || bloodRequest.getBloodGroup().getBloodGroupId() == null) {
			throw new BusinessRuleException("Blood group selection is required.");
		}

		// Validate the optional required-by date.
		LocalDateTime now = LocalDateTime.now();

		if (bloodRequest.getRequiredBy() != null && bloodRequest.getRequiredBy().isBefore(now)) {
			throw new BusinessRuleException("Required-by date cannot be in the past.");
		}

		// Retrieve the actual blood group from the database.
		Long bloodGroupId = bloodRequest.getBloodGroup().getBloodGroupId();

		BloodGroup bloodGroup = bloodGroupService.getBloodGroupById(bloodGroupId);

		// Apply system-controlled values.
		bloodRequest.setBloodGroup(bloodGroup);
		bloodRequest.setCreatedBy(creator);
		bloodRequest.setStatus(RequestStatus.PENDING);

		if (bloodRequest.getUrgency() == null) {
			bloodRequest.setUrgency(UrgencyLevel.NORMAL);
		}

		// Hibernate automatically generates requestDate.
		// Save the request.
		return bloodRequestRepository.save(bloodRequest);
	}

	@Override
	@Transactional(readOnly = true)
	public BloodRequest getBloodRequestById(Long requestId) {

		validateRequestId(requestId);

		return bloodRequestRepository.findById(requestId)
				.orElseThrow(() -> new ResourceNotFoundException("Blood request not found with ID: " + requestId));
	}

	@Override
	@Transactional(readOnly = true)
	public List<BloodRequest> getAllBloodRequests() {

		return bloodRequestRepository.findAll();
	}

	@Override
	@Transactional(readOnly = true)
	public List<BloodRequest> getBloodRequestsByStatus(RequestStatus status) {

		if (status == null) {
			throw new BusinessRuleException("Request status is required.");
		}

		return bloodRequestRepository.findByStatus(status);
	}

	@Override
	@Transactional(readOnly = true)
	public List<BloodRequest> getBloodRequestsByCity(String city) {

		if (city == null || city.isBlank()) {
			throw new BusinessRuleException("City is required.");
		}

		return bloodRequestRepository.findByCityIgnoreCase(city.trim());
	}

	@Override
	@Transactional(readOnly = true)
	public List<BloodRequest> getBloodRequestsByBloodGroup(String groupName) {

		if (groupName == null || groupName.isBlank()) {
			throw new BusinessRuleException("Blood group is required.");
		}

		return bloodRequestRepository.findByBloodGroup_GroupName(groupName.trim().toUpperCase());
	}

	@Override
	@Transactional(readOnly = true)
	public List<BloodRequest> getBloodRequestsByUserId(Long userId) {

		if (userId == null) {
			throw new BusinessRuleException("User ID is required.");
		}

		return bloodRequestRepository.findByCreatedBy_UserId(userId);
	}

	@Override
	public BloodRequest updateBloodRequestStatus(Long requestId, RequestStatus newStatus, Long updatedByUserId) {

		validateRequestId(requestId);

		if (newStatus == null) {
			throw new BusinessRuleException("New request status is required.");
		}

		BloodRequest bloodRequest = getBloodRequestById(requestId);

		RequestStatus currentStatus = bloodRequest.getStatus();

		if (currentStatus == RequestStatus.FULFILLED || currentStatus == RequestStatus.CANCELLED) {
			throw new BusinessRuleException("A fulfilled or cancelled request cannot be changed.");
		}

		if (currentStatus == newStatus) {
			throw new BusinessRuleException("Request already has the status: " + newStatus);
		}

		// Allowed transitions:
		// PENDING -> IN_PROGRESS, FULFILLED, CANCELLED
		// IN_PROGRESS -> FULFILLED, CANCELLED

		boolean validTransition = currentStatus == RequestStatus.PENDING
				&& (newStatus == RequestStatus.IN_PROGRESS || newStatus == RequestStatus.FULFILLED
						|| newStatus == RequestStatus.CANCELLED)
				|| currentStatus == RequestStatus.IN_PROGRESS
						&& (newStatus == RequestStatus.FULFILLED || newStatus == RequestStatus.CANCELLED);

		if (!validTransition) {
			throw new BusinessRuleException(
					"Invalid request status transition from " + currentStatus + " to " + newStatus + ".");
		}

		if (updatedByUserId == null) {
			throw new BusinessRuleException("Administrator user ID is required.");
		}

		User admin = userRepository.findById(updatedByUserId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + updatedByUserId));

		if (admin.getRole() != UserRole.ADMIN || admin.getAccountStatus() != AccountStatus.ACTIVE) {
			throw new BusinessRuleException("Only active administrators can update blood requests.");
		}

		bloodRequest.setStatus(newStatus);

		return bloodRequestRepository.save(bloodRequest);
	}

	private void validateRequestId(Long requestId) {

		if (requestId == null || requestId <= 0) {
			throw new BusinessRuleException("A valid request ID is required.");
		}
	}

}
