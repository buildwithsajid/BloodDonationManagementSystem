<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Donor Registration - Blood Donation System" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="form-container">
        <h2 class="form-title">Donor Registration</h2>
        <p class="form-subtitle">Join the blood donor network and help save lives in emergencies</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <span>${errorMessage}</span>
                <button type="button" class="alert-close">&times;</button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="form-grid">
                <div class="form-group col-span-2">
                    <label class="form-label required" for="fullName">Full Legal Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control"
                           value="${registerRequest.fullName}" required placeholder="e.g. John Doe">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control"
                           value="${registerRequest.email}" required placeholder="john@example.com">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="password">Password (min 8 chars)</label>
                    <input type="password" id="password" name="password" class="form-control"
                           required placeholder="••••••••">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="bloodGroupId">Blood Group</label>
                    <select id="bloodGroupId" name="bloodGroupId" class="form-control" required>
                        <option value="">-- Select Blood Group --</option>
                        <c:forEach var="bg" items="${bloodGroups}">
                            <option value="${bg.bloodGroupId}" ${registerRequest.bloodGroupId == bg.bloodGroupId ? 'selected' : ''}>
                                ${bg.groupName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required" for="dateOfBirth">Date of Birth</label>
                    <input type="date" id="dateOfBirth" name="dateOfBirth" class="form-control"
                           value="${registerRequest.dateOfBirth}" required>
                </div>

                <div class="form-group">
                    <label class="form-label required" for="phone">Contact Phone Number</label>
                    <input type="tel" id="phone" name="phone" class="form-control"
                           value="${registerRequest.phone}" required placeholder="e.g. 9876543210">
                </div>

                <div class="form-group">
                    <label class="form-label" for="gender">Gender</label>
                    <select id="gender" name="gender" class="form-control">
                        <option value="">-- Select Gender --</option>
                        <option value="MALE" ${registerRequest.gender == 'MALE' ? 'selected' : ''}>Male</option>
                        <option value="FEMALE" ${registerRequest.gender == 'FEMALE' ? 'selected' : ''}>Female</option>
                        <option value="OTHER" ${registerRequest.gender == 'OTHER' ? 'selected' : ''}>Other</option>
                        <option value="PREFER_NOT_TO_SAY" ${registerRequest.gender == 'PREFER_NOT_TO_SAY' ? 'selected' : ''}>Prefer not to say</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required" for="city">City</label>
                    <input type="text" id="city" name="city" class="form-control"
                           value="${registerRequest.city}" required placeholder="e.g. Mumbai">
                </div>

                <div class="form-group">
                    <label class="form-label" for="area">Area / Locality</label>
                    <input type="text" id="area" name="area" class="form-control"
                           value="${registerRequest.area}" placeholder="e.g. Andheri West">
                </div>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">Complete Registration</button>
            </div>
        </form>

        <div class="form-footer-link">
            Already registered? <a href="${pageContext.request.contextPath}/login">Sign In here</a>
        </div>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
