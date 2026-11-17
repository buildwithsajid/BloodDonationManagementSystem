package com.bdms.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;
import com.bdms.enums.*;

public interface BloodRequestRepository extends JpaRepository<BloodRequest, Long> {
	
	@Override
    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
    Optional<BloodRequest> findById(Long requestId);

    @Override
    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
    List<BloodRequest> findAll();

    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
	List<BloodRequest> findByStatus(RequestStatus status);

    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
    List<BloodRequest> findByCityIgnoreCase(String city);

    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
    List<BloodRequest> findByBloodGroup_GroupName(String groupName);

    @EntityGraph(attributePaths = {"bloodGroup", "createdBy"})
    List<BloodRequest> findByCreatedBy_UserId(Long userId);
}
