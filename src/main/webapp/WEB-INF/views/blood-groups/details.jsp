<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Blood Group Details - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Blood Group: ${bloodGroup.groupName}</h1>
            <p class="page-subtitle">Group profile and system references</p>
        </div>
        <a href="${pageContext.request.contextPath}/blood-groups" class="btn btn-outline btn-sm">All Blood Groups</a>
    </div>

    <div class="card" style="max-width: 500px; margin: 0 auto;">
        <div class="card-header">
            <h3 class="card-title">Group Information</h3>
            <span class="blood-badge lg">${bloodGroup.groupName}</span>
        </div>
        <div class="card-body">
            <div class="info-grid single-col">
                <div class="info-item">
                    <span class="info-label">System Identification ID</span>
                    <span class="info-value">#${bloodGroup.bloodGroupId}</span>
                </div>
                <div class="info-item" style="margin-top: 14px;">
                    <span class="info-label">Group Designation</span>
                    <span class="info-value">${bloodGroup.groupName}</span>
                </div>
            </div>

            <div style="margin-top: 24px;">
                <a href="${pageContext.request.contextPath}/donors/available?bloodGroup=${bloodGroup.groupName}"
                   class="btn btn-primary" style="width: 100%;">
                    Find ${bloodGroup.groupName} Donors
                </a>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
