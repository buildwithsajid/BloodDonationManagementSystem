<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donor Profile - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Donor Profile</h1>
            <p class="page-subtitle">Personal registration details and live availability management</p>
        </div>
        <a href="${pageContext.request.contextPath}/availability-history/my-history" class="btn btn-outline btn-sm">
            View Availability Log
        </a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">
            <span>${errorMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <span>${successMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Registration Summary</h3>
                <span class="blood-badge">${donor.bloodGroup}</span>
            </div>
            <div class="card-body">
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">Full Name</span>
                        <span class="info-value">${donor.fullName}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Registered Email</span>
                        <span class="info-value">${donor.email}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Contact Phone</span>
                        <span class="info-value">${donor.phone}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Date of Birth</span>
                        <span class="info-value">${donor.dateOfBirth}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Gender</span>
                        <span class="info-value">${donor.gender != null ? donor.gender : 'Not Specified'}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">City & Area</span>
                        <span class="info-value">${donor.city} ${not empty donor.area ? ', ' : ''}${donor.area}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Last Donation Date</span>
                        <span class="info-value">${donor.lastDonationDate != null ? donor.lastDonationDate : 'None Recorded'}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Member Since</span>
                        <span class="info-value">${donor.createdAt}</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Update Availability</h3>
            </div>
            <div class="card-body">
                <div style="margin-bottom: 16px;">
                    <span class="info-label">Current Status</span>
                    <div>
                        <span class="status-pill ${donor.availability ? 'status-available' : 'status-unavailable'}">
                            ${donor.availability ? 'Available for Donation' : 'Currently Unavailable'}
                        </span>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/donor/availability" method="post">
                    <div class="form-group">
                        <label class="form-label required" for="availability">Set Status</label>
                        <select id="availability" name="availability" class="form-control" required>
                            <option value="true" ${donor.availability ? 'selected' : ''}>Available (Ready to Donate)</option>
                            <option value="false" ${!donor.availability ? 'selected' : ''}>Unavailable (Cannot Donate)</option>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-secondary" style="width: 100%; margin-top: 10px;">
                        Save Status Change
                    </button>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
