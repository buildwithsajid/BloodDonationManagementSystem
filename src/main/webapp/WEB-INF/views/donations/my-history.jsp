<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="My Donation History - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">My Donation History</h1>
            <p class="page-subtitle">Your personal record of voluntary blood donations</p>
        </div>
        <a href="${pageContext.request.contextPath}/donor/dashboard" class="btn btn-outline btn-sm">Dashboard</a>
    </div>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty donations}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Donation ID</th>
                            <th>Donation Date</th>
                            <th>Location / Facility</th>
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
                                <td>${dn.donationLocation}</td>
                                <td style="color: var(--text-secondary);">${not empty dn.remarks ? dn.remarks : '-'}</td>
                                <td style="font-size: 13px; color: var(--text-secondary);">${dn.recordedByName}</td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/donations/${dn.donationId}" class="btn btn-outline btn-sm">View Certificate</a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-state-title">No Prior Donations Recorded</div>
                    <p>When you participate in a blood donation camp, your donation record will appear here after verification.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
