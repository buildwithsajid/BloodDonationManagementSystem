package com.bdms.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;

public interface BloodGroupRepository extends JpaRepository<BloodGroup, Long> {

	Optional<BloodGroup> findByGroupName(String groupName);

    boolean existsByGroupName(String groupName);
}
