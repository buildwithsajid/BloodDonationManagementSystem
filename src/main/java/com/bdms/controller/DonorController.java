package com.bdms.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.bdms.dto.*;
import com.bdms.entity.Donor;
import com.bdms.enums.UserRole;
import com.bdms.exception.*;
import com.bdms.service.*;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

@Controller
public class DonorController {

	private final DonorService donorService;
	private final DonorAvailabilityHistoryService availabilityHistoryService;

	public DonorController(DonorService donorService, DonorAvailabilityHistoryService availabilityHistoryService) {
		this.donorService = donorService;
		this.availabilityHistoryService = availabilityHistoryService;
	}

	// Display Donor Dashboard
	@GetMapping("/donor/dashboard")
	public String showDonorDashboard(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInDonor(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {
			Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

			model.addAttribute("donor", convertToResponse(donor));

			return "donor/dashboard";

		} catch (ResourceNotFoundException exception) {
			return "redirect:/login";
		}
	}

	// Display Donor Profile
	@GetMapping("/donor/profile")
	public String showDonorProfile(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInDonor(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {
			Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

			model.addAttribute("donor", convertToResponse(donor));

			model.addAttribute("availabilityUpdateRequest", new AvailabilityUpdateRequest());

			return "donor/profile";

		} catch (ResourceNotFoundException exception) {
			return "redirect:/login";
		}
	}

	// Update Own Donor Availability
	@PostMapping("/donor/availability")
	public String updateAvailability(
			@Valid @ModelAttribute("availabilityUpdateRequest") AvailabilityUpdateRequest availabilityRequest,
			BindingResult bindingResult, HttpSession session, RedirectAttributes redirectAttributes) {

		UserResponse loggedInUser = getLoggedInDonor(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		if (bindingResult.hasErrors()) {
			redirectAttributes.addFlashAttribute("errorMessage", "Please provide a valid availability status.");

			return "redirect:/donor/profile";
		}

		try {
			Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

			availabilityHistoryService.updateDonorAvailability(donor.getDonorId(),
					availabilityRequest.getAvailability(), loggedInUser.getUserId());

			redirectAttributes.addFlashAttribute("successMessage", "Your availability has been updated successfully.");

			return "redirect:/donor/profile";

		} catch (BusinessRuleException | ResourceNotFoundException exception) {

			redirectAttributes.addFlashAttribute("errorMessage", exception.getMessage());

			return "redirect:/donor/profile";
		}
	}

	// Search Available Donors
	@GetMapping("/donors/available")
	public String searchAvailableDonors(@RequestParam(required = false) String city,
			@RequestParam(required = false) String bloodGroup, Model model) {

		List<Donor> donors;

		if (city != null && !city.isBlank()) {
			donors = donorService.getAvailableDonorsByCity(city.trim());
		} else if (bloodGroup != null && !bloodGroup.isBlank()) {
			donors = donorService.getAvailableDonorsByBloodGroup(bloodGroup.trim());
		} else {
			donors = donorService.getAvailableDonors();
		}

		// Apply the second filter if both filters are supplied.
		if (city != null && !city.isBlank() && bloodGroup != null && !bloodGroup.isBlank()) {

			donors = donors.stream()
					.filter(donor -> donor.getBloodGroup().getGroupName().equalsIgnoreCase(bloodGroup.trim())).toList();
		}

		List<DonorResponse> donorResponses = donors.stream().map(this::convertToResponse).toList();

		model.addAttribute("donors", donorResponses);
		model.addAttribute("city", city);
		model.addAttribute("bloodGroup", bloodGroup);

		return "donor/available-donors";
	}

	// Check Logged-in Donor Session
	private UserResponse getLoggedInDonor(HttpSession session) {

		if (session == null) {
			return null;
		}

		Object userObject = session.getAttribute("loggedInUser");

		if (!(userObject instanceof UserResponse)) {
			return null;
		}

		UserResponse user = (UserResponse) userObject;

		if (user.getRole() != UserRole.DONOR) {
			return null;
		}

		return user;
	}

	// Convert Donor Entity into DonorResponse DTO
	private DonorResponse convertToResponse(Donor donor) {

		return new DonorResponse(donor.getDonorId(), donor.getUser().getUserId(), donor.getUser().getFullName(),
				donor.getUser().getEmail(), donor.getBloodGroup().getGroupName(), donor.getDateOfBirth(),
				donor.getPhone(), donor.getGender(), donor.getCity(), donor.getArea(), donor.getLastDonationDate(),
				donor.getAvailability(), donor.getCreatedAt());
	}
}
