package com.bdms.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.bdms.dto.*;
import com.bdms.entity.*;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;
import com.bdms.exception.ResourceNotFoundException;
import com.bdms.service.*;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/availability-history")
public class DonorAvailabilityHistoryController {

	private final DonorAvailabilityHistoryService availabilityHistoryService;
	private final DonorService donorService;

	public DonorAvailabilityHistoryController(DonorAvailabilityHistoryService availabilityHistoryService,
			DonorService donorService) {

		this.availabilityHistoryService = availabilityHistoryService;
		this.donorService = donorService;
	}

	// Donor: View their own availability history
	@GetMapping("/my-history")
	public String getMyAvailabilityHistory(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInDonor(session);

		Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

		List<AvailabilityHistoryResponse> history = availabilityHistoryService
				.getHistoryByDonorIdOrderByUpdatedAtDesc(donor.getDonorId()).stream().map(this::mapToResponse).toList();

		model.addAttribute("donor", mapDonorToResponse(donor));
		model.addAttribute("availabilityHistory", history);

		return "donor/availability-history";
	}

	// Admin: View availability history of a specific donor
	@GetMapping("/donor/{donorId}")
	public String getDonorAvailabilityHistory(@PathVariable Long donorId, HttpSession session, Model model) {

		try {
			getLoggedInAdmin(session);
		} catch (Exception e) {
			return "redirect:/login";
		}

		Donor donor = donorService.getDonorById(donorId);

		List<AvailabilityHistoryResponse> history = availabilityHistoryService
				.getHistoryByDonorIdOrderByUpdatedAtDesc(donorId).stream().map(this::mapToResponse).toList();

		model.addAttribute("donor", mapDonorToResponse(donor));
		model.addAttribute("availabilityHistory", history);

		return "admin/donor-availability-history";
	}

	// Convert entity to response DTO
	private AvailabilityHistoryResponse mapToResponse(DonorAvailabilityHistory history) {

		AvailabilityHistoryResponse response = new AvailabilityHistoryResponse();

		response.setHistoryId(history.getHistoryId());
		response.setDonorId(history.getDonor().getDonorId());
		response.setDonorName(history.getDonor().getUser().getFullName());
		response.setPreviousStatus(history.getPreviousStatus());
		response.setNewStatus(history.getNewStatus());
		response.setUpdatedAt(history.getUpdatedAt());

		response.setUpdatedByUserId(history.getUpdatedBy().getUserId());
		response.setUpdatedByName(history.getUpdatedBy().getFullName());

		return response;
	}

	// Convert donor entity to response DTO
	private DonorResponse mapDonorToResponse(Donor donor) {

		DonorResponse response = new DonorResponse();

		response.setDonorId(donor.getDonorId());
		response.setUserId(donor.getUser().getUserId());
		response.setFullName(donor.getUser().getFullName());
		response.setEmail(donor.getUser().getEmail());
		response.setBloodGroup(donor.getBloodGroup().getGroupName());
		response.setDateOfBirth(donor.getDateOfBirth());
		response.setPhone(donor.getPhone());
		response.setGender(donor.getGender());
		response.setCity(donor.getCity());
		response.setArea(donor.getArea());
		response.setLastDonationDate(donor.getLastDonationDate());
		response.setAvailability(donor.getAvailability());
		response.setCreatedAt(donor.getCreatedAt());

		return response;
	}

	// Check whether the logged-in user is a donor
	private UserResponse getLoggedInDonor(HttpSession session) {

		UserResponse loggedInUser = (UserResponse) session.getAttribute("loggedInUser");

		if (loggedInUser == null || loggedInUser.getRole() != UserRole.DONOR || loggedInUser.getAccountStatus() != AccountStatus.ACTIVE) {

			throw new ResourceNotFoundException("Active donor access is required.");
		}

		return loggedInUser;
	}

	// Check whether the logged-in user is an admin
	private UserResponse getLoggedInAdmin(HttpSession session) {

		UserResponse loggedInUser = (UserResponse) session.getAttribute("loggedInUser");

		if (loggedInUser == null || loggedInUser.getRole() != UserRole.ADMIN || loggedInUser.getAccountStatus() != AccountStatus.ACTIVE) {

			throw new ResourceNotFoundException("Admin access is required.");
		}

		return loggedInUser;
	}
}
