package com.bdms.service;

import java.util.List;

import com.bdms.entity.BloodRequest;
import com.bdms.enums.RequestStatus;

public interface BloodRequestService {

	BloodRequest createBloodRequest(BloodRequest bloodRequest, Long createdByUserId);

    BloodRequest getBloodRequestById(Long requestId);

    List<BloodRequest> getAllBloodRequests();

    List<BloodRequest> getBloodRequestsByStatus(RequestStatus status);

    List<BloodRequest> getBloodRequestsByCity(String city);

    List<BloodRequest> getBloodRequestsByBloodGroup(String groupName);

    List<BloodRequest> getBloodRequestsByUserId(Long userId);

    BloodRequest updateBloodRequestStatus(Long requestId, RequestStatus newStatus, Long updatedByUserId);
}
