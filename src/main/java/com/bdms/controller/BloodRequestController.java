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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.bdms.dto.BloodRequestCreateRequest;
import com.bdms.dto.BloodRequestResponse;
import com.bdms.dto.UserResponse;
import com.bdms.entity.BloodGroup;
import com.bdms.entity.BloodRequest;
import com.bdms.entity.User;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.RequestStatus;
import com.bdms.enums.UrgencyLevel;
import com.bdms.enums.UserRole;
import com.bdms.exception.BusinessRuleException;
import com.bdms.exception.ResourceNotFoundException;
import com.bdms.service.*;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

@Controller
@RequestMapping("/blood-requests")
public class BloodRequestController {

	private final BloodRequestService bloodRequestService;
	private final BloodGroupService bloodGroupService;
	private final UserService userService;

	public BloodRequestController(BloodRequestService bloodRequestService, BloodGroupService bloodGroupService,
			UserService userService) {
		this.bloodRequestService = bloodRequestService;
		this.bloodGroupService = bloodGroupService;
		this.userService = userService;
	}

	// Display All Open Blood Requests
	@GetMapping
	public String getAllOpenBloodRequests(Model model) {

		List<BloodRequestResponse> requests = bloodRequestService.getBloodRequestsByStatus(RequestStatus.PENDING)
				.stream().map(this::convertToResponse).toList();

		List<BloodRequestResponse> inProgressRequests = bloodRequestService
				.getBloodRequestsByStatus(RequestStatus.IN_PROGRESS).stream().map(this::convertToResponse).toList();

		List<BloodRequestResponse> openRequests = new java.util.ArrayList<>(requests);

		openRequests.addAll(inProgressRequests);

		model.addAttribute("bloodRequests", openRequests);

		return "requests/list";
	}

	// Display Blood Request Details
	@GetMapping("/{requestId}")
	public String getBloodRequestDetails(@PathVariable Long requestId, Model model) {

		BloodRequest bloodRequest = bloodRequestService.getBloodRequestById(requestId);

		model.addAttribute("bloodRequest", convertToResponse(bloodRequest));

		model.addAttribute("requestStatuses", RequestStatus.values());

		return "requests/details";
	}

	// Display Create Blood Request Form
	@GetMapping("/create")
	public String showCreateRequestForm(HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		model.addAttribute("bloodRequestCreateRequest", new BloodRequestCreateRequest());

		model.addAttribute("bloodGroups", bloodGroupService.getAllBloodGroups());

		model.addAttribute("urgencyLevels", UrgencyLevel.values());

		return "requests/create";
	}

	// Create Blood Request
	@PostMapping("/create")
	public String createBloodRequest(
			@Valid @ModelAttribute("bloodRequestCreateRequest") BloodRequestCreateRequest request,
			BindingResult bindingResult, HttpSession session, Model model, RedirectAttributes redirectAttributes) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		if (bindingResult.hasErrors()) {

			model.addAttribute("bloodGroups", bloodGroupService.getAllBloodGroups());

			model.addAttribute("urgencyLevels", UrgencyLevel.values());

			return "requests/create";
		}

		try {

			BloodRequest bloodRequest = new BloodRequest();

			bloodRequest.setPatientName(request.getPatientName());
			bloodRequest.setContactNumber(request.getContactNumber());
			bloodRequest.setUnitsRequired(request.getUnitsRequired());
			bloodRequest.setHospitalName(request.getHospitalName());
			bloodRequest.setCity(request.getCity());
			bloodRequest.setUrgency(request.getUrgency());
			bloodRequest.setRequiredBy(request.getRequiredBy());

			BloodGroup bloodGroup = bloodGroupService.getBloodGroupById(request.getBloodGroupId());

			bloodRequest.setBloodGroup(bloodGroup);

			bloodRequestService.createBloodRequest(bloodRequest, loggedInUser.getUserId());

			redirectAttributes.addFlashAttribute("successMessage", "Blood request created successfully.");

			return "redirect:/blood-requests";

		} catch (BusinessRuleException | ResourceNotFoundException exception) {

			model.addAttribute("errorMessage", exception.getMessage());

			model.addAttribute("bloodGroups", bloodGroupService.getAllBloodGroups());

			model.addAttribute("urgencyLevels", UrgencyLevel.values());

			return "requests/create";
		}
	}

	// Filter Blood Requests
	@GetMapping("/search")
	public String searchBloodRequests(@RequestParam(required = false) String city,
			@RequestParam(required = false) String bloodGroup, @RequestParam(required = false) RequestStatus status,
			Model model) {

		List<BloodRequest> requests;

		if (status != null) {

			requests = bloodRequestService.getBloodRequestsByStatus(status);

		} else if (city != null && !city.isBlank()) {

			requests = bloodRequestService.getBloodRequestsByCity(city.trim());

		} else if (bloodGroup != null && !bloodGroup.isBlank()) {

			requests = bloodRequestService.getBloodRequestsByBloodGroup(bloodGroup.trim());

		} else {

			requests = bloodRequestService.getAllBloodRequests();
		}

		// Keep only open requests.
		requests = requests.stream().filter(request -> request.getStatus() == RequestStatus.PENDING
				|| request.getStatus() == RequestStatus.IN_PROGRESS).toList();

		// Apply additional filters when supplied together.
		if (city != null && !city.isBlank()) {
			requests = requests.stream().filter(request -> request.getCity().equalsIgnoreCase(city.trim())).toList();
		}

		if (bloodGroup != null && !bloodGroup.isBlank()) {
			requests = requests.stream()
					.filter(request -> request.getBloodGroup().getGroupName().equalsIgnoreCase(bloodGroup.trim()))
					.toList();
		}

		model.addAttribute("bloodRequests", requests.stream().map(this::convertToResponse).toList());

		model.addAttribute("city", city);
		model.addAttribute("bloodGroup", bloodGroup);
		model.addAttribute("status", status);

		return "requests/list";
	}

	// Display Status Update Form
	@GetMapping("/{requestId}/status")
	public String showStatusUpdateForm(@PathVariable Long requestId, HttpSession session, Model model) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		BloodRequest bloodRequest = bloodRequestService.getBloodRequestById(requestId);

		model.addAttribute("bloodRequest", convertToResponse(bloodRequest));

		model.addAttribute("requestStatuses", RequestStatus.values());

		return "requests/update-status";
	}

	// Update Blood Request Status
	@PostMapping("/{requestId}/status")
	public String updateBloodRequestStatus(@PathVariable Long requestId, @RequestParam @NotNull RequestStatus status,
			HttpSession session, RedirectAttributes redirectAttributes) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			return "redirect:/login";
		}

		try {

			bloodRequestService.updateBloodRequestStatus(requestId, status, loggedInUser.getUserId());

			redirectAttributes.addFlashAttribute("successMessage", "Blood request status updated successfully.");

			return "redirect:/blood-requests/" + requestId;

		} catch (BusinessRuleException | ResourceNotFoundException exception) {

			redirectAttributes.addFlashAttribute("errorMessage", exception.getMessage());

			return "redirect:/blood-requests/" + requestId + "/status";
		}
	}

	// Check Logged-in Admin Session
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

	// Convert Entity into Response DTO
	private BloodRequestResponse convertToResponse(BloodRequest bloodRequest) {

		User creator = bloodRequest.getCreatedBy();

		return new BloodRequestResponse(bloodRequest.getRequestId(), bloodRequest.getPatientName(),
				bloodRequest.getContactNumber(), bloodRequest.getBloodGroup().getGroupName(),
				bloodRequest.getUnitsRequired(), bloodRequest.getHospitalName(), bloodRequest.getCity(),
				bloodRequest.getUrgency(), bloodRequest.getStatus(), bloodRequest.getRequestDate(),
				bloodRequest.getRequiredBy(), creator.getUserId(), creator.getFullName());
	}
}
