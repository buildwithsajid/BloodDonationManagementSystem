package com.bdms.service;

import java.util.List;
import com.bdms.entity.Donor;

public interface DonorService {

	Donor registerDonor(Donor donor);

    Donor getDonorById(Long donorId);

    Donor getDonorByUserId(Long userId);

    List<Donor> getAllDonors();

    List<Donor> getAvailableDonors();

    List<Donor> getAvailableDonorsByCity(String city);

    List<Donor> getAvailableDonorsByBloodGroup(String groupName);
}
