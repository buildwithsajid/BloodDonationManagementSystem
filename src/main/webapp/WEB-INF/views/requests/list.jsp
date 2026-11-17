<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Blood Requests - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Emergency Blood Requests</h1>
            <p class="page-subtitle">Patient blood demands across participating hospitals and clinics</p>
        </div>
        <c:if test="${sessionScope.loggedInUser != null && sessionScope.loggedInUser.role == 'ADMIN'}">
            <a href="${pageContext.request.contextPath}/blood-requests/create" class="btn btn-primary btn-sm">
                + Create Blood Request
            </a>
        </c:if>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <span>${successMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <!-- Search / Filter Form -->
    <form action="${pageContext.request.contextPath}/blood-requests/search" method="get" class="filter-bar">
        <div class="form-group">
            <label class="form-label" for="bloodGroup">Blood Group</label>
            <select id="bloodGroup" name="bloodGroup" class="form-control">
                <option value="">All Blood Groups</option>
                <c:forEach var="bg" items="${['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']}">
                    <option value="${bg}" ${bloodGroup == bg ? 'selected' : ''}>${bg}</option>
                </c:forEach>
            </select>
        </div>

        <div class="form-group">
            <label class="form-label" for="city">City</label>
            <input type="text" id="city" name="city" class="form-control"
                   value="${city}" placeholder="Filter by city">
        </div>

        <div class="form-group">
            <label class="form-label" for="status">Status</label>
            <select id="status" name="status" class="form-control">
                <option value="">Open Requests (Pending / In Progress)</option>
                <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Pending</option>
                <option value="IN_PROGRESS" ${status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                <option value="FULFILLED" ${status == 'FULFILLED' ? 'selected' : ''}>Fulfilled</option>
                <option value="CANCELLED" ${status == 'CANCELLED' ? 'selected' : ''}>Cancelled</option>
            </select>
        </div>

        <div style="display: flex; gap: 8px;">
            <button type="submit" class="btn btn-primary">Filter</button>
            <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline">Reset</a>
        </div>
    </form>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty bloodRequests}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Blood Group</th>
                            <th>Patient Name</th>
                            <th>Hospital & City</th>
                            <th>Units</th>
                            <th>Urgency</th>
                            <th>Status</th>
                            <th>Required By</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${bloodRequests}">
                            <tr>
                                <td>#${r.requestId}</td>
                                <td><span class="blood-badge">${r.bloodGroup}</span></td>
                                <td style="font-weight: 500;">${r.patientName}</td>
                                <td>${r.hospitalName}, ${r.city}</td>
                                <td><strong>${r.unitsRequired} unit(s)</strong></td>
                                <td>
                                    <span class="urgency-pill urgency-${r.urgency.toString().toLowerCase()}">
                                        ${r.urgency}
                                    </span>
                                </td>
                                <td>
                                    <span class="status-pill status-${r.status.toString().toLowerCase().replace('_', '-')}">
                                        ${r.status}
                                    </span>
                                </td>
                                <td style="font-size: 13px; color: var(--text-secondary);">
                                    ${r.requiredBy != null ? r.requiredBy : 'Immediate'}
                                </td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/blood-requests/${r.requestId}"
                                       class="btn btn-outline btn-sm">View Details</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">No Blood Requests Matching Criteria</div>
                    <p>There are no active blood requests for the selected filters.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
