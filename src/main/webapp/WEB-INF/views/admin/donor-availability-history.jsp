<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donor Availability History - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Availability History: ${donor.fullName}</h1>
            <p class="page-subtitle">Administrative audit trail of status modifications for Donor #${donor.donorId}</p>
        </div>
        <a href="${pageContext.request.contextPath}/donors/available" class="btn btn-outline btn-sm">Donor Directory</a>
    </div>

    <div class="card" style="margin-bottom: 20px;">
        <div class="card-body" style="padding: 16px 20px;">
            <div style="display: flex; gap: 24px; align-items: center;">
                <div><strong>Blood Group:</strong> <span class="blood-badge">${donor.bloodGroup}</span></div>
                <div><strong>City:</strong> ${donor.city}</div>
                <div><strong>Contact:</strong> ${donor.phone}</div>
                <div>
                    <strong>Current Status:</strong>
                    <span class="status-pill ${donor.availability ? 'status-available' : 'status-unavailable'}">
                        ${donor.availability ? 'Available' : 'Unavailable'}
                    </span>
                </div>
            </div>
        </div>
    </div>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty availabilityHistory}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Audit ID</th>
                            <th>Previous Status</th>
                            <th>New Status</th>
                            <th>Updated By</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="h" items="${availabilityHistory}">
                            <tr>
                                <td>#${h.historyId}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${h.previousStatus == null}">
                                            <span style="color: var(--text-light);">Registration Default</span>
                                        </c:when>
                                        <c:when test="${h.previousStatus}">
                                            <span class="status-pill status-available">Available</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill status-unavailable">Unavailable</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${h.newStatus}">
                                            <span class="status-pill status-available">Available</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-pill status-unavailable">Unavailable</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${h.updatedByName} (User #${h.updatedByUserId})</td>
                                <td style="color: var(--text-secondary);">${h.updatedAt}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">No Audit History Found</div>
                    <p>No availability changes have been recorded yet for this donor.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
