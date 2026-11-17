<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Administrator Dashboard - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Administrator Console</h1>
            <p class="page-subtitle">Central operations and clinical inventory monitoring</p>
        </div>
        <div style="display: flex; gap: 8px;">
            <a href="${pageContext.request.contextPath}/donations/create" class="btn btn-primary btn-sm">+ Record Donation</a>
            <a href="${pageContext.request.contextPath}/blood-requests/create" class="btn btn-secondary btn-sm">+ Create Request</a>
        </div>
    </div>

    <!-- Summary Metrics -->
    <div class="stats-grid">
        <div class="stat-card stat-primary">
            <span class="stat-label">Total Donors</span>
            <span class="stat-number">${totalDonors}</span>
        </div>

        <div class="stat-card stat-success">
            <span class="stat-label">Available Donors</span>
            <span class="stat-number">${availableDonors}</span>
        </div>

        <div class="stat-card stat-warning">
            <span class="stat-label">Blood Requests</span>
            <span class="stat-number">${totalRequests}</span>
        </div>

        <div class="stat-card">
            <span class="stat-label">Total Donations</span>
            <span class="stat-number">${totalDonations}</span>
        </div>
    </div>

    <!-- Quick Navigation Panels -->
    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;">
        <div class="card" style="margin-bottom: 0;">
            <div class="card-body">
                <h4 style="font-size: 15px; margin-bottom: 6px;">Manage Blood Requests</h4>
                <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Review emergency requests, change statuses to in-progress or fulfilled.</p>
                <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline btn-sm">All Requests &rarr;</a>
            </div>
        </div>

        <div class="card" style="margin-bottom: 0;">
            <div class="card-body">
                <h4 style="font-size: 15px; margin-bottom: 6px;">Record Donations</h4>
                <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Log completed donations, update donor last donation dates.</p>
                <a href="${pageContext.request.contextPath}/donations" class="btn btn-outline btn-sm">All Donations &rarr;</a>
            </div>
        </div>

        <div class="card" style="margin-bottom: 0;">
            <div class="card-body">
                <h4 style="font-size: 15px; margin-bottom: 6px;">Donor Directory</h4>
                <p style="font-size: 13px; color: var(--text-secondary); margin-bottom: 14px;">Search suitable donors by blood group and city for quick response.</p>
                <a href="${pageContext.request.contextPath}/donors/available" class="btn btn-outline btn-sm">Search Donors &rarr;</a>
            </div>
        </div>
    </div>

    <!-- Recent Requests -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Recent Blood Requests</h3>
            <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline btn-sm">View All</a>
        </div>
        <div class="card-body" style="padding: 0;">
            <c:choose>
                <c:when test="${not empty recentRequests}">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Blood Group</th>
                                <th>Patient Name</th>
                                <th>Hospital</th>
                                <th>Units</th>
                                <th>Urgency</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="req" items="${recentRequests}">
                                <tr>
                                    <td>#${req.requestId}</td>
                                    <td><span class="blood-badge">${req.bloodGroup.groupName}</span></td>
                                    <td>${req.patientName}</td>
                                    <td>${req.hospitalName}, ${req.city}</td>
                                    <td>${req.unitsRequired}</td>
                                    <td>
                                        <span class="urgency-pill urgency-${req.urgency.toString().toLowerCase()}">
                                            ${req.urgency}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-pill status-${req.status.toString().toLowerCase().replace('_', '-')}">
                                            ${req.status}
                                        </span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/blood-requests/${req.requestId}" class="btn btn-outline btn-sm">Details</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-title">No Requests Logged</div>
                        <p>There are currently no blood requests in the system.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
