package com.bdms.service;

import java.util.List;

import com.bdms.entity.DonorAvailabilityHistory;

public interface DonorAvailabilityHistoryService {
	
	DonorAvailabilityHistory updateDonorAvailability(Long donorId, Boolean newAvailability, Long updatedByUserId);

    List<DonorAvailabilityHistory> getHistoryByDonorId(Long donorId);

    List<DonorAvailabilityHistory> getHistoryByDonorIdOrderByUpdatedAtDesc(Long donorId);
}
