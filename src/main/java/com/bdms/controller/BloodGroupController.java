package com.bdms.controller;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import com.bdms.dto.BloodGroupResponse;
import com.bdms.entity.BloodGroup;
import com.bdms.service.BloodGroupService;

@Controller
@RequestMapping("/blood-groups")
public class BloodGroupController {

	private final BloodGroupService bloodGroupService;

	public BloodGroupController(BloodGroupService bloodGroupService) {
		this.bloodGroupService = bloodGroupService;
	}

	// Display all blood groups
	@GetMapping
	public String getAllBloodGroups(Model model) {

		List<BloodGroupResponse> bloodGroups = bloodGroupService.getAllBloodGroups().stream()
				.map(this::convertToResponse).toList();

		model.addAttribute("bloodGroups", bloodGroups);

		return "blood-groups/list";
	}

	// Display blood group details
	@GetMapping("/{bloodGroupId}")
	public String getBloodGroupById(@PathVariable Long bloodGroupId, Model model) {

		BloodGroup bloodGroup = bloodGroupService.getBloodGroupById(bloodGroupId);

		model.addAttribute("bloodGroup", convertToResponse(bloodGroup));

		return "blood-groups/details";
	}

	// Convert Entity into DTO
	private BloodGroupResponse convertToResponse(BloodGroup bloodGroup) {

		return new BloodGroupResponse(bloodGroup.getBloodGroupId(), bloodGroup.getGroupName());
	}
}
