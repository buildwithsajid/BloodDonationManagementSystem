<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donor Dashboard - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Welcome, ${donor.fullName}</h1>
            <p class="page-subtitle">Your donor profile and quick healthcare activities</p>
        </div>
        <div>
            <span class="blood-badge lg">${donor.bloodGroup}</span>
        </div>
    </div>

    <div class="stats-grid">
        <div class="stat-card stat-primary">
            <span class="stat-label">Blood Group</span>
            <span class="stat-number">${donor.bloodGroup}</span>
        </div>

        <div class="stat-card ${donor.availability ? 'stat-success' : 'stat-warning'}">
            <span class="stat-label">Availability Status</span>
            <span class="stat-number" style="font-size: 20px;">
                ${donor.availability ? 'Available to Donate' : 'Temporarily Unavailable'}
            </span>
        </div>

        <div class="stat-card">
            <span class="stat-label">Last Donation</span>
            <span class="stat-number" style="font-size: 18px;">
                ${donor.lastDonationDate != null ? donor.lastDonationDate : 'No prior donations'}
            </span>
        </div>

        <div class="stat-card">
            <span class="stat-label">Registered City</span>
            <span class="stat-number" style="font-size: 20px;">${donor.city}</span>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Quick Actions & Portal Services</h3>
        </div>
        <div class="card-body">
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;">
                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 18px; background: #fafbfc;">
                    <h4 style="font-size: 15px; margin-bottom: 6px; color: var(--text-primary);">Update Availability</h4>
                    <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Toggle your readiness to receive emergency donation requests.</p>
                    <a href="${pageContext.request.contextPath}/donor/profile" class="btn btn-outline btn-sm">Manage Status</a>
                </div>

                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 18px; background: #fafbfc;">
                    <h4 style="font-size: 15px; margin-bottom: 6px; color: var(--text-primary);">Find Matching Donors</h4>
                    <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Search suitable donors in your city or by blood group.</p>
                    <a href="${pageContext.request.contextPath}/donors/available" class="btn btn-secondary btn-sm">Search Donors</a>
                </div>

                <div style="border: 1px solid var(--border-color); border-radius: var(--radius-sm); padding: 18px; background: #fafbfc;">
                    <h4 style="font-size: 15px; margin-bottom: 6px; color: var(--text-primary);">My Donation Records</h4>
                    <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Review all past blood donations verified by administrators.</p>
                    <a href="${pageContext.request.contextPath}/donations/my-history" class="btn btn-outline btn-sm">View History</a>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
