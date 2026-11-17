package com.bdms.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import com.bdms.entity.*;
import com.bdms.enums.*;

public interface UserRepository extends JpaRepository<User, Long>{
	
	Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    Optional<User> findByEmailAndAccountStatus(String email,AccountStatus accountStatus);
}
