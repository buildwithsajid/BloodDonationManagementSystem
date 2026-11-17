<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Request Details #${bloodRequest.requestId} - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Blood Request #${bloodRequest.requestId}</h1>
            <p class="page-subtitle">Hospital emergency details and fulfillment status</p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline btn-sm">Back to Requests</a>
            <c:if test="${sessionScope.loggedInUser != null && sessionScope.loggedInUser.role == 'ADMIN' && bloodRequest.status != 'FULFILLED' && bloodRequest.status != 'CANCELLED'}">
                <a href="${pageContext.request.contextPath}/blood-requests/${bloodRequest.requestId}/status" class="btn btn-primary btn-sm">
                    Update Request Status
                </a>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <span>${successMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Patient & Medical Requirement</h3>
            <div>
                <span class="blood-badge lg">${bloodRequest.bloodGroup}</span>
            </div>
        </div>
        <div class="card-body">
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Patient Name</span>
                    <span class="info-value">${bloodRequest.patientName}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Hospital Name</span>
                    <span class="info-value">${bloodRequest.hospitalName}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">City</span>
                    <span class="info-value">${bloodRequest.city}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Contact Phone</span>
                    <span class="info-value">${bloodRequest.contactNumber}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Units Demanded</span>
                    <span class="info-value">${bloodRequest.unitsRequired} unit(s)</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Urgency Level</span>
                    <span class="info-value">
                        <span class="urgency-pill urgency-${bloodRequest.urgency.toString().toLowerCase()}">
                            ${bloodRequest.urgency}
                        </span>
                    </span>
                </div>

                <div class="info-item">
                    <span class="info-label">Current Status</span>
                    <span class="info-value">
                        <span class="status-pill status-${bloodRequest.status.toString().toLowerCase().replace('_', '-')}">
                            ${bloodRequest.status}
                        </span>
                    </span>
                </div>

                <div class="info-item">
                    <span class="info-label">Required By</span>
                    <span class="info-value">${bloodRequest.requiredBy != null ? bloodRequest.requiredBy : 'As soon as possible'}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Request Date</span>
                    <span class="info-value">${bloodRequest.requestDate}</span>
                </div>

                <div class="info-item">
                    <span class="info-label">Recorded By Administrator</span>
                    <span class="info-value">${bloodRequest.creatorName} (ID: ${bloodRequest.creatorUserId})</span>
                </div>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
