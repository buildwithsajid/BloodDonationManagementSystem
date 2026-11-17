<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="top-navbar">
    <div class="navbar-inner">
        <a href="${pageContext.request.contextPath}/" class="navbar-brand">
            <div class="brand-icon">+</div>
            <div>
                <span class="brand-name">BDMS</span>
                <span class="brand-sub">Blood Donation System</span>
            </div>
        </a>

        <ul class="navbar-menu">
            <c:choose>
                <c:when test="${sessionScope.loggedInUser != null && sessionScope.loggedInUser.role == 'ADMIN'}">
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Admin Console</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/blood-requests">Blood Requests</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donations/create">Record Donation</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donations">Donations</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donors/available">Search Donors</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/blood-groups">Blood Groups</a></li>
                </c:when>

                <c:when test="${sessionScope.loggedInUser != null && sessionScope.loggedInUser.role == 'DONOR'}">
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donor/dashboard">Dashboard</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donor/profile">My Profile</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donations/my-history">Donation History</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donors/available">Search Donors</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/blood-requests">Requests</a></li>
                </c:when>

                <c:otherwise>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/donors/available">Search Donors</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/blood-requests">Blood Requests</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/blood-groups">Blood Groups</a></li>
                </c:otherwise>
            </c:choose>
        </ul>

        <div class="navbar-user">
            <c:choose>
                <c:when test="${sessionScope.loggedInUser != null}">
                    <div class="user-meta">
                        <div class="user-name">${sessionScope.loggedInUser.fullName}</div>
                        <span class="user-role-badge ${sessionScope.loggedInUser.role == 'ADMIN' ? 'role-admin' : 'role-donor'}">
                            ${sessionScope.loggedInUser.role}
                        </span>
                    </div>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-nav-login">Logout</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn-nav-login">Login</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn-nav-cta">Register Donor</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>
