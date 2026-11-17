<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Login - Blood Donation System" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="form-container narrow">
        <h2 class="form-title">Portal Login</h2>
        <p class="form-subtitle">Enter your credentials to access your BDMS account</p>

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

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group">
                <label class="form-label required" for="email">Email Address</label>
                <input type="email" id="email" name="email" class="form-control"
                       value="${loginRequest.email}" required autofocus placeholder="name@example.com">
            </div>

            <div class="form-group">
                <label class="form-label required" for="password">Password</label>
                <input type="password" id="password" name="password" class="form-control"
                       required placeholder="••••••••">
            </div>

            <div class="form-actions" style="justify-content: stretch;">
                <button type="submit" class="btn btn-primary" style="width: 100%;">Sign In</button>
            </div>
        </form>

        <div class="form-footer-link">
            Don't have an account? <a href="${pageContext.request.contextPath}/register">Register as Donor</a>
        </div>

        <div style="margin-top: 20px; padding: 12px; background: #f8fafc; border-radius: 4px; font-size: 12px; color: #64748b; border: 1px dashed #cbd5e1;">
            <strong>Demo Admin Account:</strong><br>
            Email: <code>admin@bdms.com</code> | Password: <code>admin123</code>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
