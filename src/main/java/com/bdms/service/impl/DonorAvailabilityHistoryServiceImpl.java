package com.bdms.service.impl;

import com.bdms.entity.DonorAvailabilityHistory;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;

import java.util.List;
import java.util.Objects;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.bdms.entity.*;
import com.bdms.exception.*;
import com.bdms.repository.*;
import com.bdms.service.DonorAvailabilityHistoryService;

@Service
@Transactional
public class DonorAvailabilityHistoryServiceImpl implements DonorAvailabilityHistoryService {

	private final DonorAvailabilityHistoryRepository historyRepository;
	private final DonorRepository donorRepository;
	private final UserRepository userRepository;

	public DonorAvailabilityHistoryServiceImpl(DonorAvailabilityHistoryRepository historyRepository,
			DonorRepository donorRepository, UserRepository userRepository) {
		this.historyRepository = historyRepository;
		this.donorRepository = donorRepository;
		this.userRepository = userRepository;
	}

	@Override
	public DonorAvailabilityHistory updateDonorAvailability(Long donorId, Boolean newAvailability,
			Long updatedByUserId) {

		// Validate input values.
		validateDonorId(donorId);

		if (newAvailability == null) {
			throw new BusinessRuleException("New availability status is required.");
		}

		if (updatedByUserId == null || updatedByUserId <= 0) {
			throw new BusinessRuleException("A valid user ID is required for recording the update.");
		}

		// Retrieve the donor.
		Donor donor = donorRepository.findById(donorId)
				.orElseThrow(() -> new ResourceNotFoundException("Donor not found with ID: " + donorId));

		// Retrieve the user performing the update.
		User updatedBy = userRepository.findById(updatedByUserId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + updatedByUserId));

		// Only active users can update availability.
		if (updatedBy.getAccountStatus() != AccountStatus.ACTIVE) {
			throw new BusinessRuleException("Inactive users cannot update donor availability.");
		}

		// Authorization based on the updater's role.
		if (updatedBy.getRole() == UserRole.ADMIN) {
			// Active administrators can update any donor's availability.
		} else if (updatedBy.getRole() == UserRole.DONOR) {
			// Donors can update only their own availability.
			Donor updatingDonor = donorRepository.findByUser_UserId(updatedByUserId)
					.orElseThrow(() -> new ResourceNotFoundException("Donor profile not found for user ID: " + updatedByUserId));
			if (!updatingDonor.getDonorId().equals(donorId)) {
				throw new BusinessRuleException("You are not authorized to update another donor's availability.");
			}
		} else {
			throw new BusinessRuleException("You are not authorized to update donor availability.");
		}

		// Get the donor's previous availability.
		Boolean previousAvailability = donor.getAvailability();

		// Avoid unnecessary history records.
		if (Objects.equals(newAvailability, previousAvailability)) {
			throw new BusinessRuleException("Donor availability is already set to " + newAvailability + ".");
		}

		// Update the donor's current availability.
		donor.setAvailability(newAvailability);

		donorRepository.save(donor);

		// Create an availability history record.
		DonorAvailabilityHistory history = new DonorAvailabilityHistory();

		history.setDonor(donor);
		history.setPreviousStatus(previousAvailability);
		history.setNewStatus(newAvailability);
		history.setUpdatedBy(updatedBy);

		// Save and return the history record.
		return historyRepository.save(history);
	}

	@Override
	@Transactional(readOnly = true)
	public List<DonorAvailabilityHistory> getHistoryByDonorId(Long donorId) {

		validateDonorId(donorId);

		return historyRepository.findByDonor_DonorId(donorId);
	}

	@Override
	@Transactional(readOnly = true)
	public List<DonorAvailabilityHistory> getHistoryByDonorIdOrderByUpdatedAtDesc(Long donorId) {

		validateDonorId(donorId);

		return historyRepository.findByDonor_DonorIdOrderByUpdatedAtDesc(donorId);
	}

	private void validateDonorId(Long donorId) {

		if (donorId == null || donorId <= 0) {
			throw new BusinessRuleException("A valid donor ID is required.");
		}
	}
}
