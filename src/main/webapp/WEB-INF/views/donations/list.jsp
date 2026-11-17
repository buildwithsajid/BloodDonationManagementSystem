<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="All Blood Donations - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Blood Donation Records</h1>
            <p class="page-subtitle">Historical registry of all completed blood donations</p>
        </div>
        <a href="${pageContext.request.contextPath}/donations/create" class="btn btn-primary btn-sm">
            + Record New Donation
        </a>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <span>${successMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty donations}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Donation ID</th>
                            <th>Donation Date</th>
                            <th>Donor Name</th>
                            <th>Blood Group</th>
                            <th>Location / Camp</th>
                            <th>Remarks</th>
                            <th>Recorded By</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="dn" items="${donations}">
                            <tr>
                                <td>#${dn.donationId}</td>
                                <td><strong>${dn.donationDate}</strong></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/donations/donor/${dn.donorId}" style="color: var(--primary); font-weight: 500; text-decoration: none;">
                                        ${dn.donorName}
                                    </a>
                                </td>
                                <td><span class="blood-badge">${dn.bloodGroup}</span></td>
                                <td>${dn.donationLocation}</td>
                                <td style="color: var(--text-secondary);">${not empty dn.remarks ? dn.remarks : '-'}</td>
                                <td style="font-size: 13px; color: var(--text-secondary);">${dn.recordedByName}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/donations/${dn.donationId}" class="btn btn-outline btn-sm">Details</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">No Donations Recorded Yet</div>
                    <p>Click "Record New Donation" above to log a verified donor contribution.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
