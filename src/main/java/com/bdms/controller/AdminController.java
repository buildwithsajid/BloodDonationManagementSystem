package com.bdms.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.bdms.dto.UserResponse;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;
import com.bdms.service.BloodRequestService;
import com.bdms.service.DonationHistoryService;
import com.bdms.service.DonorService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/admin")
public class AdminController {

	private final DonorService donorService;
	private final BloodRequestService bloodRequestService;
	private final DonationHistoryService donationHistoryService;

	public AdminController(DonorService donorService,
			BloodRequestService bloodRequestService,
			DonationHistoryService donationHistoryService) {
		this.donorService = donorService;
		this.bloodRequestService = bloodRequestService;
		this.donationHistoryService = donationHistoryService;
	}

	@GetMapping("/dashboard")
	public String showAdminDashboard(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);
		if (loggedInUser == null) {
			return "redirect:/login";
		}

		model.addAttribute("totalDonors", donorService.getAllDonors().size());
		model.addAttribute("availableDonors", donorService.getAvailableDonors().size());
		model.addAttribute("totalRequests", bloodRequestService.getAllBloodRequests().size());
		model.addAttribute("totalDonations", donationHistoryService.getAllDonations().size());
		model.addAttribute("recentRequests", bloodRequestService.getAllBloodRequests().stream().limit(5).toList());

		return "admin/dashboard";
	}

	private UserResponse getLoggedInAdmin(HttpSession session) {
		if (session == null) {
			return null;
		}

		Object userObject = session.getAttribute("loggedInUser");
		if (!(userObject instanceof UserResponse)) {
			return null;
		}

		UserResponse user = (UserResponse) userObject;
		if (user.getRole() != UserRole.ADMIN || user.getAccountStatus() != AccountStatus.ACTIVE) {
			return null;
		}

		return user;
	}
}
