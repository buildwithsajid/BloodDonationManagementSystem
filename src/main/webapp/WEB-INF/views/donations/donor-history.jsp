<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donor Donation History - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Donations by ${donor}</h1>
            <p class="page-subtitle">Historical donation records for this donor</p>
        </div>
        <a href="${pageContext.request.contextPath}/donations" class="btn btn-outline btn-sm">All Donations</a>
    </div>

    <div class="data-table-container">
        <c:choose>
            <c:when test="${not empty donations}">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Donation ID</th>
                            <th>Donation Date</th>
                            <th>Location</th>
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
                                <td>${not empty dn.remarks ? dn.remarks : '-'}</td>
                                <td>${dn.recordedByName}</td>
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
                    <div class="empty-state-title">No Donations Found for ${donor}</div>
                    <p>This donor does not have any recorded donations in the database.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
