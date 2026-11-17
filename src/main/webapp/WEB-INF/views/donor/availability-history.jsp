<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Availability Audit History - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Availability History Log</h1>
            <p class="page-subtitle">Complete audit trail of availability updates for ${donor.fullName}</p>
        </div>
        <a href="${pageContext.request.contextPath}/donor/profile" class="btn btn-outline btn-sm">Back to Profile</a>
    </div>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty availabilityHistory}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Audit ID</th>
                            <th>Previous Status</th>
                            <th>Updated Status</th>
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
                                            <span style="color: var(--text-light);">Initial Registration</span>
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
                                <td>${h.updatedByName}</td>
                                <td style="color: var(--text-secondary);">${h.updatedAt}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">No Audit Records Found</div>
                    <p>There are no past availability status changes logged for this account.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
