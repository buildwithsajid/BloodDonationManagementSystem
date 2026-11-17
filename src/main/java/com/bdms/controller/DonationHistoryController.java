package com.bdms.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.bdms.exception.*;
import com.bdms.dto.*;
import com.bdms.entity.*;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;
import com.bdms.service.*;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/donations")
public class DonationHistoryController {

	private final DonationHistoryService donationHistoryService;
	private final DonorService donorService;

	public DonationHistoryController(DonationHistoryService donationHistoryService, DonorService donorService) {
		this.donationHistoryService = donationHistoryService;
		this.donorService = donorService;
	}

	// Display All Donation Records (Admin)
	@GetMapping
	public String getAllDonations(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		List<DonationResponse> donations = donationHistoryService.getAllDonations().stream()
				.map(this::convertToResponse).toList();

		model.addAttribute("donations", donations);

		return "donations/list";
	}

	// Display Donation Recording Form (Admin)
	@GetMapping("/create")
	public String showDonationForm(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		model.addAttribute("donationCreateRequest", new DonationCreateRequest());

		return "donations/create";
	}

	// Record New Donation (Admin)
	@PostMapping("/create")
	public String recordDonation(@Valid @ModelAttribute("donationCreateRequest") DonationCreateRequest donationRequest,
			BindingResult bindingResult, HttpSession session, Model model, RedirectAttributes redirectAttributes) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		if (bindingResult.hasErrors()) {
			return "donations/create";
		}

		try {

			DonationHistory donation = new DonationHistory();

			Donor donor = donorService.getDonorById(donationRequest.getDonorId());

			donation.setDonor(donor);
			donation.setDonationDate(donationRequest.getDonationDate());
			donation.setDonationLocation(donationRequest.getDonationLocation());
			donation.setRemarks(donationRequest.getRemarks());

			donationHistoryService.recordDonation(donation, loggedInUser.getUserId());

			redirectAttributes.addFlashAttribute("successMessage", "Donation recorded successfully.");

			return "redirect:/donations";

		} catch (BusinessRuleException | ResourceNotFoundException exception) {

			model.addAttribute("errorMessage", exception.getMessage());

			return "donations/create";
		}
	}

	// Display Individual Donation Details
	@GetMapping("/{donationId}")
	public String getDonationDetails(@PathVariable Long donationId, HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInUser(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {

			DonationHistory donation = donationHistoryService.getDonationById(donationId);

			// Donors may only view their own donation records.
			if (loggedInUser.getRole() == UserRole.DONOR) {

				Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

				if (!donation.getDonor().getDonorId().equals(donor.getDonorId())) {

					return "redirect:/donations/my-history";
				}
			}

			model.addAttribute("donation", convertToResponse(donation));

			return "donations/details";

		} catch (BusinessRuleException | ResourceNotFoundException exception) {
			return "redirect:/donations/my-history";
		}
	}

	// Display Donation History of Logged-in Donor
	@GetMapping("/my-history")
	public String getMyDonationHistory(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInDonor(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {

			Donor donor = donorService.getDonorByUserId(loggedInUser.getUserId());

			List<DonationResponse> donations = donationHistoryService
					.getDonationHistoryByDonorIdOrderByDateDesc(donor.getDonorId()).stream()
					.map(this::convertToResponse).toList();

			model.addAttribute("donations", donations);

			return "donations/my-history";

		} catch (ResourceNotFoundException exception) {
			return "redirect:/login";
		}
	}

	// Display Donation History of a Specific Donor (Admin)
	@GetMapping("/donor/{donorId}")
	public String getDonorDonationHistory(@PathVariable Long donorId, HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {

			Donor donor = donorService.getDonorById(donorId);

			List<DonationResponse> donations = donationHistoryService
					.getDonationHistoryByDonorIdOrderByDateDesc(donorId).stream().map(this::convertToResponse).toList();

			model.addAttribute("donor", donor.getUser().getFullName());

			model.addAttribute("donations", donations);

			return "donations/donor-history";

		} catch (ResourceNotFoundException exception) {
			return "redirect:/donations";
		}
	}

	// Check Logged-in User
	private UserResponse getLoggedInUser(HttpSession session) {

		if (session == null) {
			return null;
		}

		Object userObject = session.getAttribute("loggedInUser");

		if (!(userObject instanceof UserResponse)) {
			return null;
		}

		return (UserResponse) userObject;
	}

	// Check Logged-in Admin
	private UserResponse getLoggedInAdmin(HttpSession session) {

		UserResponse user = getLoggedInUser(session);

		if (user == null || user.getRole() != UserRole.ADMIN || user.getAccountStatus() != AccountStatus.ACTIVE) {
			return null;
		}

		return user;
	}

	// Check Logged-in Donor
	private UserResponse getLoggedInDonor(HttpSession session) {

		UserResponse user = getLoggedInUser(session);

		if (user == null || user.getRole() != UserRole.DONOR) {
			return null;
		}

		return user;
	}

	// Convert DonationHistory Entity into DonationResponse DTO
	private DonationResponse convertToResponse(DonationHistory donation) {

		Donor donor = donation.getDonor();

		return new DonationResponse(donation.getDonationId(), donor.getDonorId(), donor.getUser().getFullName(),
				donor.getBloodGroup().getGroupName(), donation.getDonationDate(), donation.getDonationLocation(),
				donation.getRemarks(), donation.getRecordedBy().getUserId(), donation.getRecordedBy().getFullName());
	}
}
