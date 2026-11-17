<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Supported Blood Groups - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">Supported Blood Groups</h1>
            <p class="page-subtitle">The eight standard ABO and Rh blood groups configured in the system</p>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
        <c:forEach var="bg" items="${bloodGroups}">
            <div class="card" style="text-align: center; margin-bottom: 0;">
                <div class="card-body" style="padding: 28px 20px;">
                    <div style="margin-bottom: 14px;">
                        <span class="blood-badge lg" style="font-size: 20px; padding: 6px 18px; border-radius: 20px;">
                            ${bg.groupName}
                        </span>
                    </div>
                    <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 18px;">
                        Group ID: #${bg.bloodGroupId}
                    </div>
                    <a href="${pageContext.request.contextPath}/donors/available?bloodGroup=${bg.groupName}"
                       class="btn btn-outline btn-sm" style="width: 100%;">
                        Search Donors
                    </a>
                </div>
            </div>
        </c:forEach>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
