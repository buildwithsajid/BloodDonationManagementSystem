package com.bdms.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.bdms.dto.UserResponse;
import com.bdms.entity.User;
import com.bdms.enums.AccountStatus;
import com.bdms.enums.UserRole;
import com.bdms.exception.ResourceNotFoundException;
import com.bdms.service.UserService;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/users")
public class UserController {

	private final UserService userService;

	public UserController(UserService userService) {
		this.userService = userService;
	}

	// Admin: View details of a specific user
	@GetMapping("/{userId}")
	public String getUserDetails(@PathVariable Long userId, HttpSession session, Model model,
			RedirectAttributes redirectAttributes) {

		if (getLoggedInAdmin(session) == null) {
			redirectAttributes.addFlashAttribute("errorMessage", "Please log in as an administrator.");
			return "redirect:/login";
		}

		User user = userService.getUserById(userId);

		model.addAttribute("user", mapToResponse(user));
		model.addAttribute("accountStatuses", AccountStatus.values());

		return "admin/user-details";
	}

	// Admin: Activate or deactivate a user account
	@PostMapping("/{userId}/status")
	public String updateAccountStatus(@PathVariable Long userId, @RequestParam AccountStatus accountStatus,
			HttpSession session, RedirectAttributes redirectAttributes) {

		UserResponse loggedInUser = getLoggedInAdmin(session);

		if (loggedInUser == null) {
			redirectAttributes.addFlashAttribute("errorMessage", "Please log in as an administrator.");
			return "redirect:/login";
		}

		// Prevent an administrator from deactivating their own account
		if (loggedInUser.getUserId().equals(userId) && accountStatus == AccountStatus.INACTIVE) {

			redirectAttributes.addFlashAttribute("errorMessage",
					"You cannot deactivate your own administrator account.");

			return "redirect:/users/" + userId;
		}

		try {
			userService.updateAccountStatus(userId, accountStatus, loggedInUser.getUserId());

			redirectAttributes.addFlashAttribute("successMessage", "User account status updated successfully.");

		} catch (ResourceNotFoundException exception) {

			redirectAttributes.addFlashAttribute("errorMessage", exception.getMessage());

		} catch (IllegalArgumentException exception) {

			redirectAttributes.addFlashAttribute("errorMessage", "Invalid account status.");
		}

		return "redirect:/users/" + userId;
	}

	// Convert User entity to UserResponse DTO
	private UserResponse mapToResponse(User user) {

		UserResponse response = new UserResponse();

		response.setUserId(user.getUserId());
		response.setFullName(user.getFullName());
		response.setEmail(user.getEmail());
		response.setRole(user.getRole());
		response.setAccountStatus(user.getAccountStatus());
		response.setCreatedAt(user.getCreatedAt());

		return response;
	}

	// Verify administrator session
	private UserResponse getLoggedInAdmin(HttpSession session) {

		if (session == null) {
			return null;
		}

		UserResponse loggedInUser = (UserResponse) session.getAttribute("loggedInUser");

		if (loggedInUser == null || loggedInUser.getRole() != UserRole.ADMIN || loggedInUser.getAccountStatus() != AccountStatus.ACTIVE) {
			return null;
		}

		return loggedInUser;
	}
}
