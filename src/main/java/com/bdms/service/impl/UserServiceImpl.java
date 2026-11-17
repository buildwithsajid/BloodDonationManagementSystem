package com.bdms.service.impl;

import com.bdms.entity.*;
import com.bdms.enums.*;
import com.bdms.exception.*;
import com.bdms.repository.UserRepository;
import com.bdms.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;

@Service
@Transactional
public class UserServiceImpl implements UserService {

	private final UserRepository userRepository;
	private final PasswordEncoder passwordEncoder;

	public UserServiceImpl(UserRepository userRepository, PasswordEncoder passwordEncoder) {
		this.userRepository = userRepository;
		this.passwordEncoder = passwordEncoder;
	}

	@Override
	public User registerDonorAccount(User user) {

		if (user == null) {
			throw new BusinessRuleException("User details cannot be empty.");
		}

		if (user.getEmail() == null || user.getEmail().isBlank()) {
			throw new BusinessRuleException("Email address is required.");
		}

		if (user.getPassword() == null || user.getPassword().isBlank()) {
			throw new BusinessRuleException("Password is required.");
		}

		String normalizedEmail = user.getEmail().trim().toLowerCase();

		if (userRepository.existsByEmail(normalizedEmail)) {
			throw new BusinessRuleException("An account with this email already exists.");
		}

		user.setEmail(normalizedEmail);

		// Public registration always creates a DONOR account.
		user.setRole(UserRole.DONOR);

		// New accounts are active by default.
		user.setAccountStatus(AccountStatus.ACTIVE);

		// Store the BCrypt hash instead of the plain-text password.
		user.setPassword(passwordEncoder.encode(user.getPassword()));

		return userRepository.save(user);
	}

	@Override
	@Transactional(readOnly = true)
	public User getUserById(Long userId) {

		// Validate ID before repository access.
		if (userId == null) {
			throw new BusinessRuleException("User ID cannot be null.");
		}

		return userRepository.findById(userId)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with ID: " + userId));
	}

	@Override
	@Transactional(readOnly = true)
	public User getUserByEmail(String email) {

		if (email == null || email.isBlank()) {
			throw new BusinessRuleException("Email address is required.");
		}

		String normalizedEmail = email.trim().toLowerCase();

		return userRepository.findByEmail(normalizedEmail)
				.orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + normalizedEmail));
	}

	@Override
	@Transactional(readOnly = true)
	public User getActiveUserByEmail(String email) {

		if (email == null || email.isBlank()) {
			throw new BusinessRuleException("Email address is required.");
		}

		String normalizedEmail = email.trim().toLowerCase();

		return userRepository.findByEmailAndAccountStatus(normalizedEmail, AccountStatus.ACTIVE).orElseThrow(
				() -> new ResourceNotFoundException("Active account not found with email: " + normalizedEmail));
	}

	@Override
	@Transactional(readOnly = true)
	public boolean isEmailAvailable(String email) {

		if (email == null || email.isBlank()) {
			return false;
		}

		return !userRepository.existsByEmail(email.trim().toLowerCase());
	}

	@Override
	public User updateAccountStatus(Long userId, AccountStatus accountStatus, Long updatedByUserId) {

		// Validate target user ID.
		if (userId == null) {
			throw new BusinessRuleException("User ID cannot be null.");
		}

		// Validate requested account status.
		if (accountStatus == null) {
			throw new BusinessRuleException("Account status cannot be empty.");
		}

		// Validate administrator ID.
		if (updatedByUserId == null) {
			throw new BusinessRuleException("Administrator ID cannot be null.");
		}

		// Verify that the person performing the update
		// is an ACTIVE administrator.
		User updatedByUser = getUserById(updatedByUserId);
		if (updatedByUser.getRole() != UserRole.ADMIN || updatedByUser.getAccountStatus() != AccountStatus.ACTIVE) {
			throw new BusinessRuleException("Only active administrators can update account status.");
		}

		// Fetch the account whose status needs updating.
		User user = getUserById(userId);

		// Prevent an administrator from deactivating themselves.
		if (userId.equals(updatedByUserId) && accountStatus == AccountStatus.INACTIVE) {
			throw new BusinessRuleException("An administrator cannot deactivate their own account.");
		}

		user.setAccountStatus(accountStatus);

		return userRepository.save(user);
	}
}
