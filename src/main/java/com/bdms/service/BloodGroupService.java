package com.bdms.service;

import java.util.List;
import com.bdms.entity.BloodGroup;

public interface BloodGroupService {
	 List<BloodGroup> getAllBloodGroups();

	 BloodGroup getBloodGroupById(Long bloodGroupId);
}
