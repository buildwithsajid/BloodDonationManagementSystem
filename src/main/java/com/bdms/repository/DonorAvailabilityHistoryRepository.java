package com.bdms.repository;

import java.util.List;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;

public interface DonorAvailabilityHistoryRepository extends JpaRepository<DonorAvailabilityHistory, Long> {

	@EntityGraph(attributePaths = {"donor", "donor.user", "updatedBy"})
	List<DonorAvailabilityHistory> findByDonor_DonorId(Long donorId);

	@EntityGraph(attributePaths = {"donor", "donor.user", "updatedBy"})
    List<DonorAvailabilityHistory> findByDonor_DonorIdOrderByUpdatedAtDesc(Long donorId);
}
