package com.bdms.service.impl;

import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdms.entity.DonationHistory;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;
import com.bdms.entity.*;
import com.bdms.exception.*;
import com.bdms.repository.*;
import com.bdms.service.DonationHistoryService;

@Service
@Transactional
public class DonationHistoryServiceImpl implements DonationHistoryService {

	private final DonationHistoryRepository donationHistoryRepository;
	private final DonorRepository donorRepository;
	private final UserRepository userRepository;

	public DonationHistoryServiceImpl(DonationHistoryRepository donationHistoryRepository,
			DonorRepository donorRepository, UserRepository userRepository) {
		this.donationHistoryRepository = donationHistoryRepository;
		this.donorRepository = donorRepository;
		this.userRepository = userRepository;
	}

	@Override
	public DonationHistory recordDonation(DonationHistory donationHistory, Long recordedByUserId) {

		// Validate donation details.
		if (donationHistory == null) {
			throw new BusinessRuleException("Donation details cannot be empty.");
		}

		if (donationHistory.getDonor() == null || donationHistory.getDonor().getDonorId() == null
				|| donationHistory.getDonor().getDonorId() <= 0) {
			throw new BusinessRuleException("A valid donor ID is required.");
		}

		if (donationHistory.getDonationDate() == null) {
			throw new BusinessRuleException("Donation date is required.");
		}

		if (donationHistory.getDonationDate().isAfter(LocalDate.now())) {
			throw new BusinessRuleException("Donation date cannot be in the future.");
		}

		if (donationHistory.getDonationLocation() == null || donationHistory.getDonationLocation().isBlank()) {
			throw new BusinessRuleException("Donation location is required.");
		}

		if (recordedByUserId == null || recordedByUserId <= 0) {
			throw new BusinessRuleException("Recording user ID is required.");
		}

		// Retrieve the donor from the database.
		Long donorId = donationHistory.getDonor().getDonorId();

		Donor donor = donorRepository.findById(donorId)
				.orElseThrow(() -> new ResourceNotFoundException("Donor not found with ID: " + donorId));

		// Retrieve the user recording the donation.
		User recordedBy = userRepository.findById(recordedByUserId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + recordedByUserId));

		// Only administrators can record donations.
		if (recordedBy.getRole() != UserRole.ADMIN || recordedBy.getAccountStatus() != AccountStatus.ACTIVE) {
			throw new BusinessRuleException("Only active administrators can record blood donations.");
		}

		// Reject donations dated before the previous recorded donation.
		LocalDate previousDonationDate = donor.getLastDonationDate();

		if (previousDonationDate != null && donationHistory.getDonationDate().isBefore(previousDonationDate)) {
			throw new BusinessRuleException(
					"Donation date cannot be earlier than the " + "donor's previous donation date.");
		}

		// Associate the actual database entities.
		donationHistory.setDonor(donor);
		donationHistory.setRecordedBy(recordedBy);

		// Save donation history.
		DonationHistory savedDonation = donationHistoryRepository.save(donationHistory);

		// Update donor's last donation date.
		donor.setLastDonationDate(donationHistory.getDonationDate());

		donorRepository.save(donor);

		return savedDonation;
	}

	@Override
	@Transactional(readOnly = true)
	public DonationHistory getDonationById(Long donationId) {

		return donationHistoryRepository.findById(donationId)
				.orElseThrow(() -> new ResourceNotFoundException("Donation record not found with ID: " + donationId));
	}

	@Override
	@Transactional(readOnly = true)
	public List<DonationHistory> getAllDonations() {

		return donationHistoryRepository.findAll();
	}

	@Override
	@Transactional(readOnly = true)
	public List<DonationHistory> getDonationHistoryByDonorId(Long donorId) {

		validateDonorId(donorId);

		return donationHistoryRepository.findByDonor_DonorId(donorId);
	}

	@Override
	@Transactional(readOnly = true)
	public List<DonationHistory> getDonationHistoryByDonorIdOrderByDateDesc(Long donorId) {

		validateDonorId(donorId);

		return donationHistoryRepository.findByDonor_DonorIdOrderByDonationDateDesc(donorId);
	}

	private void validateDonorId(Long donorId) {

		if (donorId == null || donorId <= 0) {
			throw new BusinessRuleException("Donor ID is required.");
		}
	}
}
