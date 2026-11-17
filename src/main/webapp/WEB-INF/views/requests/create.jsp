<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Create Blood Request - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="form-container">
        <h2 class="form-title">Create Emergency Blood Request</h2>
        <p class="form-subtitle">Record a patient blood requirement submitted by a medical facility</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <span>${errorMessage}</span>
                <button type="button" class="alert-close">&times;</button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/blood-requests/create" method="post">
            <div class="form-grid">
                <div class="form-group col-span-2">
                    <label class="form-label required" for="patientName">Patient Full Name</label>
                    <input type="text" id="patientName" name="patientName" class="form-control"
                           value="${bloodRequestCreateRequest.patientName}" required placeholder="e.g. Alice Smith">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="bloodGroupId">Blood Group Needed</label>
                    <select id="bloodGroupId" name="bloodGroupId" class="form-control" required>
                        <option value="">-- Select Blood Group --</option>
                        <c:forEach var="bg" items="${bloodGroups}">
                            <option value="${bg.bloodGroupId}" ${bloodRequestCreateRequest.bloodGroupId == bg.bloodGroupId ? 'selected' : ''}>
                                ${bg.groupName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label required" for="unitsRequired">Units Required (Quantity)</label>
                    <input type="number" id="unitsRequired" name="unitsRequired" class="form-control"
                           min="1" max="50" value="${bloodRequestCreateRequest.unitsRequired != null ? bloodRequestCreateRequest.unitsRequired : 1}" required>
                </div>

                <div class="form-group col-span-2">
                    <label class="form-label required" for="hospitalName">Hospital / Clinic Name</label>
                    <input type="text" id="hospitalName" name="hospitalName" class="form-control"
                           value="${bloodRequestCreateRequest.hospitalName}" required placeholder="e.g. City General Hospital">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="city">City</label>
                    <input type="text" id="city" name="city" class="form-control"
                           value="${bloodRequestCreateRequest.city}" required placeholder="e.g. Mumbai">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="contactNumber">Attendant / Hospital Contact</label>
                    <input type="tel" id="contactNumber" name="contactNumber" class="form-control"
                           value="${bloodRequestCreateRequest.contactNumber}" required placeholder="e.g. 9876543210">
                </div>

                <div class="form-group">
                    <label class="form-label required" for="urgency">Urgency Level</label>
                    <select id="urgency" name="urgency" class="form-control" required>
                        <c:forEach var="lvl" items="${urgencyLevels}">
                            <option value="${lvl}" ${bloodRequestCreateRequest.urgency == lvl ? 'selected' : ''}>
                                ${lvl}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="requiredBy">Required By Date & Time</label>
                    <input type="datetime-local" id="requiredBy" name="requiredBy" class="form-control"
                           value="${bloodRequestCreateRequest.requiredBy}">
                </div>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">Save Blood Request</button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
