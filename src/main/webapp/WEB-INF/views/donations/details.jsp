<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donation Details #${donation.donationId} - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Donation Record #${donation.donationId}</h1>
            <p class="page-subtitle">Verified blood donation certificate entry</p>
        </div>
        <c:choose>
            <c:when test="${sessionScope.loggedInUser != null && sessionScope.loggedInUser.role == 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/donations" class="btn btn-outline btn-sm">Back to All Donations</a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/donations/my-history" class="btn btn-outline btn-sm">Back to My History</a>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Donation Summary</h3>
            <span class="blood-badge lg">${donation.bloodGroup}</span>
        </div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Donor Name</span>
                    <span class="info-value">${donation.donorName} (Donor ID: #${donation.donorId})</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Donation Date</span>
                    <span class="info-value"><strong>${donation.donationDate}</strong></span>
                </div>

                <div class="info-item">
                    <span class="info-label">Blood Group</span>
                    <span class="info-value">${donation.bloodGroup}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Location / Facility</span>
                    <span class="info-value">${donation.donationLocation}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Verified By Admin</span>
                    <span class="info-value">${donation.recordedByName}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Clinical Remarks</span>
                    <span class="info-value">${not empty donation.remarks ? donation.remarks : 'None recorded'}</span>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
