package com.bdms.service;

import com.bdms.entity.User;
import com.bdms.enums.AccountStatus;

public interface UserService {

	User registerDonorAccount(User user);

    User getUserById(Long userId);

    User getUserByEmail(String email);

    User getActiveUserByEmail(String email);

    boolean isEmailAvailable(String email);

    User updateAccountStatus(Long userId, AccountStatus accountStatus, Long updatedByUserId);
}
