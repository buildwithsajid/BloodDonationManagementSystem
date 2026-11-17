package com.bdms.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;

public interface DonationHistoryRepository extends JpaRepository<DonationHistory, Long> {
	
	@Override
    @EntityGraph(attributePaths = {"donor", "donor.user", "donor.bloodGroup", "recordedBy"})
    List<DonationHistory> findAll();
	
	@Override
    @EntityGraph(attributePaths = {"donor", "donor.user", "donor.bloodGroup", "recordedBy"})
	Optional<DonationHistory> findById(Long donationId);

	@EntityGraph(attributePaths = {"donor", "donor.user", "donor.bloodGroup", "recordedBy"})
	List<DonationHistory> findByDonor_DonorId(Long donorId);

	@EntityGraph(attributePaths = {"donor", "donor.user", "donor.bloodGroup", "recordedBy"})
    List<DonationHistory> findByDonor_DonorIdOrderByDonationDateDesc(Long donorId);
}
