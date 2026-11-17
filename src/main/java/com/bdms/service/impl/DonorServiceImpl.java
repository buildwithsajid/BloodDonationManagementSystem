package com.bdms.service.impl;

import com.bdms.service.*;
import com.bdms.entity.*;
import com.bdms.exception.*;
import com.bdms.repository.DonorRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@Transactional
public class DonorServiceImpl implements DonorService {

	private final DonorRepository donorRepository;
	private final UserService userService;
	private final BloodGroupService bloodGroupService;

	public DonorServiceImpl(DonorRepository donorRepository, UserService userService,
			BloodGroupService bloodGroupService) {
		this.donorRepository = donorRepository;
		this.userService = userService;
		this.bloodGroupService = bloodGroupService;
	}

	@Override
	public Donor registerDonor(Donor donor) {
		if (donor == null) {
			throw new BusinessRuleException("Donor details cannot be empty.");
		}

		User user = donor.getUser();

		if (user == null) {
			throw new BusinessRuleException("User account details are required.");
		}

		BloodGroup requestedBloodGroup = donor.getBloodGroup();

		if (requestedBloodGroup == null || requestedBloodGroup.getBloodGroupId() == null) {
			throw new BusinessRuleException("Blood group selection is required.");
		}

		if (donor.getDateOfBirth() == null || !donor.getDateOfBirth().isBefore(LocalDate.now())) {
			throw new BusinessRuleException("A valid date of birth is required.");
		}

		if (donor.getPhone() == null || donor.getPhone().isBlank()) {
			throw new BusinessRuleException("Phone number is required.");
		}

		if (donor.getCity() == null || donor.getCity().isBlank()) {
			throw new BusinessRuleException("City is required.");
		}

		// Validate gender when provided.
		if (donor.getGender() != null && !donor.getGender().isBlank()) {
			List<String> validGenders = List.of("MALE", "FEMALE", "OTHER", "PREFER_NOT_TO_SAY");

			if (!validGenders.contains(donor.getGender().trim().toUpperCase())) {
				throw new BusinessRuleException("Invalid gender selection.");
			}

			donor.setGender(donor.getGender().trim().toUpperCase());
		}

		// Validate and retrieve the existing blood group.
		BloodGroup bloodGroup = bloodGroupService.getBloodGroupById(requestedBloodGroup.getBloodGroupId());

		// Register the associated user account.
		User savedUser = userService.registerDonorAccount(user);

		// Connect the saved user and blood group to the donor.
		donor.setUser(savedUser);
		donor.setBloodGroup(bloodGroup);

		// Initial donor availability.
		donor.setAvailability(true);

		// Last donation date is maintained through donation history.
		donor.setLastDonationDate(null);

		// Save the donor profile.
		return donorRepository.save(donor);
	}

	@Override
	@Transactional(readOnly = true)
	public Donor getDonorById(Long donorId) {

		// Validate donor ID.
		if (donorId == null || donorId <= 0) {
			throw new BusinessRuleException("A valid donor ID is required.");
		}

		return donorRepository.findById(donorId)
				.orElseThrow(() -> new ResourceNotFoundException("Donor not found with ID: " + donorId));
	}

	@Override
	@Transactional(readOnly = true)
	public Donor getDonorByUserId(Long userId) {

		// Validate user ID.
		if (userId == null || userId <= 0) {
			throw new BusinessRuleException("A valid user ID is required.");
		}

		return donorRepository.findByUser_UserId(userId)
				.orElseThrow(() -> new ResourceNotFoundException("Donor profile not found for user ID: " + userId));
	}

	@Override
	@Transactional(readOnly = true)
	public List<Donor> getAllDonors() {

		return donorRepository.findAll();
	}

	@Override
	@Transactional(readOnly = true)
	public List<Donor> getAvailableDonors() {

		return donorRepository.findByAvailabilityTrue();
	}

	@Override
	@Transactional(readOnly = true)
	public List<Donor> getAvailableDonorsByCity(String city) {

		if (city == null || city.isBlank()) {
			throw new BusinessRuleException("City is required for donor search.");
		}

		return donorRepository.findByAvailabilityTrueAndCityIgnoreCase(city.trim());
	}

	@Override
	@Transactional(readOnly = true)
	public List<Donor> getAvailableDonorsByBloodGroup(String groupName) {

		if (groupName == null || groupName.isBlank()) {
			throw new BusinessRuleException("Blood group is required for donor search.");
		}

		return donorRepository.findByBloodGroup_GroupNameAndAvailabilityTrue(groupName.trim().toUpperCase());
	}
}
