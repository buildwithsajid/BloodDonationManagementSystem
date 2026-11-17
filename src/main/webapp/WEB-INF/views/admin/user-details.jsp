<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="User Account Management - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="page-header">
        <div>
            <h1 class="page-title">User Account #${user.userId}</h1>
            <p class="page-subtitle">Security administration and account status management</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-outline btn-sm">Admin Dashboard</a>
    </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger">
            <span>${errorMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success">
            <span>${successMessage}</span>
            <button type="button" class="alert-close">&times;</button>
        </div>
    </c:if>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 24px;">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">User Profile Details</h3>
                <span class="user-role-badge ${user.role == 'ADMIN' ? 'role-admin' : 'role-donor'}">${user.role}</span>
            </div>
            <div class="card-body">
                <div class="info-grid">
                    <div class="info-item">
                        <span class="info-label">User ID</span>
                        <span class="info-value">#${user.userId}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Full Name</span>
                        <span class="info-value">${user.fullName}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Email Address</span>
                        <span class="info-value">${user.email}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Account Role</span>
                        <span class="info-value">${user.role}</span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Current Status</span>
                        <span class="info-value">
                            <span class="status-pill ${user.accountStatus == 'ACTIVE' ? 'status-active' : 'status-inactive'}">
                                ${user.accountStatus}
                            </span>
                        </span>
                    </div>

                    <div class="info-item">
                        <span class="info-label">Registration Date</span>
                        <span class="info-value">${user.createdAt}</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Account Status Control</h3>
            </div>
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/users/${user.userId}/status" method="post">
                    <div class="form-group">
                        <label class="form-label required" for="accountStatus">Set Account Status</label>
                        <select id="accountStatus" name="accountStatus" class="form-control" required>
                            <c:forEach var="st" items="${accountStatuses}">
                                <option value="${st}" ${user.accountStatus == st ? 'selected' : ''}>${st}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 10px;">
                        Save Status Change
                    </button>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
