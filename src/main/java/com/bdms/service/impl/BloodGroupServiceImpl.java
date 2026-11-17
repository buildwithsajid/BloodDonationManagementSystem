package com.bdms.service.impl;

import java.util.List;
import org.springframework.stereotype.Service;
import com.bdms.entity.BloodGroup;
import com.bdms.exception.ResourceNotFoundException;
import com.bdms.repository.BloodGroupRepository;
import com.bdms.service.BloodGroupService;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class BloodGroupServiceImpl implements BloodGroupService {

	private final BloodGroupRepository bloodGroupRepository;

	public BloodGroupServiceImpl(BloodGroupRepository bloodGroupRepository) {
		this.bloodGroupRepository = bloodGroupRepository;
	}

	@Override
	public List<BloodGroup> getAllBloodGroups() {
		return bloodGroupRepository.findAll();
	}

	@Override
	public BloodGroup getBloodGroupById(Long bloodGroupId) {

		if (bloodGroupId == null || bloodGroupId <= 0) {
			throw new IllegalArgumentException("Blood group ID must be a positive number.");
		}

		return bloodGroupRepository.findById(bloodGroupId)
				.orElseThrow(() -> new ResourceNotFoundException("Blood group not found with ID: " + bloodGroupId));
	}
}
