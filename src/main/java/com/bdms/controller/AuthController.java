package com.bdms.controller;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.bdms.dto.*;
import com.bdms.entity.*;
import com.bdms.enums.UserRole;
import com.bdms.exception.*;
import com.bdms.service.*;

import jakarta.servlet.http.*;
import jakarta.validation.Valid;

@Controller
public class AuthController {

    private final UserService userService;
    private final DonorService donorService;
    private final BloodGroupService bloodGroupService;
    private final PasswordEncoder passwordEncoder;

    public AuthController(UserService userService, DonorService donorService,
            BloodGroupService bloodGroupService, PasswordEncoder passwordEncoder) {
        this.userService = userService;
        this.donorService = donorService;
        this.bloodGroupService = bloodGroupService;
        this.passwordEncoder = passwordEncoder;
    }

    // Home Page Redirection
    @GetMapping("/")
    public String index() {
        return "redirect:/donors/available";
    }

    // Display Login Page
    @GetMapping("/login")
    public String showLoginPage(Model model) {

        model.addAttribute("loginRequest", new LoginRequest());

        return "auth/login";
    }

    // Process Login
    @PostMapping("/login")
    public String login( @Valid @ModelAttribute("loginRequest") LoginRequest loginRequest,
            BindingResult bindingResult,
            HttpServletRequest request,
            Model model) {

        if (bindingResult.hasErrors()) {
            return "auth/login";
        }

        try {

            String email = loginRequest.getEmail().trim().toLowerCase();

            User user = userService.getActiveUserByEmail(email);

            if (!passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {

                model.addAttribute("errorMessage", "Invalid email or password.");

                return "auth/login";
            }

            // Create session after successful authentication.
            HttpSession session = request.getSession(true);

            // Protect against session fixation.
            request.changeSessionId();

            UserResponse userResponse = new UserResponse(user.getUserId(), user.getFullName(), user.getEmail(), user.getRole(), user.getAccountStatus(),
                    user.getCreatedAt());

            // Store safe user information in session.
            session.setAttribute("loggedInUser", userResponse);

            if (user.getRole() == UserRole.ADMIN) {
                return "redirect:/admin/dashboard";
            }

            return "redirect:/donor/dashboard";

        } catch (ResourceNotFoundException exception) {
        	
            model.addAttribute("errorMessage","Invalid email or password.");
            return "auth/login";
        }
    }

    // Display Donor Registration Page
    @GetMapping("/register")
    public String showRegistrationPage(Model model) {

        model.addAttribute("registerRequest", new RegisterDonorRequest());
        model.addAttribute("bloodGroups", bloodGroupService.getAllBloodGroups());

        return "auth/register";
    }

    // Process Donor Registration
    @PostMapping("/register")
    public String registerDonor(@Valid @ModelAttribute("registerRequest")
            RegisterDonorRequest registerRequest,
            BindingResult bindingResult,
            Model model,
            RedirectAttributes redirectAttributes) {

        if (bindingResult.hasErrors()) {
            model.addAttribute("bloodGroups", bloodGroupService.getAllBloodGroups());
            return "auth/register";
        }

        try {
            // Create User entity.
            User user = new User();

            user.setFullName(registerRequest.getFullName());
            user.setEmail(registerRequest.getEmail());
            user.setPassword(registerRequest.getPassword());

            // Create Donor entity.
            Donor donor = new Donor();

            donor.setUser(user);

            // Associate the selected blood group.
            BloodGroup bloodGroup = new BloodGroup();

            bloodGroup.setBloodGroupId(registerRequest.getBloodGroupId());

            donor.setBloodGroup(bloodGroup);

            donor.setDateOfBirth(registerRequest.getDateOfBirth());

            donor.setPhone(registerRequest.getPhone());
            donor.setGender(registerRequest.getGender());
            donor.setCity(registerRequest.getCity());
            donor.setArea(registerRequest.getArea());

            // Register User and Donor through service layer.
            donorService.registerDonor(donor);

            redirectAttributes.addFlashAttribute("successMessage", "Registration successful. Please log in.");

            return "redirect:/login";

        } catch (BusinessRuleException | ResourceNotFoundException exception) {

            redirectAttributes.addFlashAttribute("errorMessage", exception.getMessage());

            return "redirect:/register";
        }
    }

    // Logout
    @GetMapping("/logout")
    public String logout(HttpSession session) {

        if (session != null) {
            session.invalidate();
        }

        return "redirect:/login";
    }
}
