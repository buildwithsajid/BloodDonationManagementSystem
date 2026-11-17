<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Update Status - Request #${bloodRequest.requestId}" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="form-container narrow">
        <h2 class="form-title">Update Request Status</h2>
        <p class="form-subtitle">Modify lifecycle state for request #${bloodRequest.requestId} (${bloodRequest.patientName})</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <span>${errorMessage}</span>
                <button type="button" class="alert-close">&times;</button>
            </div>
        </c:if>

        <div style="margin-bottom: 20px; padding: 14px; background: #fafbfc; border-radius: 4px; border: 1px solid var(--border-color); font-size: 14px;">
            <div><strong>Blood Group:</strong> <span class="blood-badge">${bloodRequest.bloodGroup}</span></div>
            <div style="margin-top: 6px;"><strong>Hospital:</strong> ${bloodRequest.hospitalName}, ${bloodRequest.city}</div>
            <div style="margin-top: 6px;">
                <strong>Current Status:</strong>
                <span class="status-pill status-${bloodRequest.status.toString().toLowerCase().replace('_', '-')}">
                    ${bloodRequest.status}
                </span>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/blood-requests/${bloodRequest.requestId}/status" method="post">
            <div class="form-group">
                <label class="form-label required" for="status">New Status Transition</label>
                <select id="status" name="status" class="form-control" required>
                    <c:forEach var="st" items="${requestStatuses}">
                        <option value="${st}" ${bloodRequest.status == st ? 'selected' : ''}>
                            ${st}
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/blood-requests/${bloodRequest.requestId}" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">Update Status</button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
