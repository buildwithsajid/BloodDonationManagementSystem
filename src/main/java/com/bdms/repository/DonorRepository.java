package com.bdms.repository;

import java.util.*;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;

public interface DonorRepository extends JpaRepository<Donor, Long> {

	// Fetch User and BloodGroup along with Donor.
	@EntityGraph(attributePaths = {"user", "bloodGroup"})
	Optional<Donor> findByUser_UserId(Long userId);

	// Fetch relationships for available donors.
	@EntityGraph(attributePaths = {"user", "bloodGroup"})
    List<Donor> findByAvailabilityTrue();

	// Fetch relationships for city-based donor search.
	@EntityGraph(attributePaths = {"user", "bloodGroup"})
    List<Donor> findByAvailabilityTrueAndCityIgnoreCase(String city);

	// Fetch relationships for blood-group-based donor search.
	@EntityGraph(attributePaths = {"user", "bloodGroup"})
    List<Donor> findByBloodGroup_GroupNameAndAvailabilityTrue(String groupName);
	
	@Override
	@EntityGraph(attributePaths = {"user", "bloodGroup"})
	Optional<Donor> findById(Long donorId);
}
