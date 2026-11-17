package com.bdms.service;

import java.util.List;

import com.bdms.entity.DonationHistory;

public interface DonationHistoryService {

	DonationHistory recordDonation(DonationHistory donationHistory, Long recordedByUserId);

    DonationHistory getDonationById(Long donationId);

    List<DonationHistory> getAllDonations();

    List<DonationHistory> getDonationHistoryByDonorId(Long donorId);

    List<DonationHistory> getDonationHistoryByDonorIdOrderByDateDesc(Long donorId);
}
