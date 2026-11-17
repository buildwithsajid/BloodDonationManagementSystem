<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Record Donation - BDMS" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <div class="form-container">
        <h2 class="form-title">Record Blood Donation</h2>
        <p class="form-subtitle">Log a verified blood donation for a registered donor and update their last donation date</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <span>${errorMessage}</span>
                <button type="button" class="alert-close">&times;</button>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/donations/create" method="post">
            <div class="form-grid">
                <div class="form-group col-span-2">
                    <label class="form-label required" for="donorId">Donor ID</label>
                    <input type="number" id="donorId" name="donorId" class="form-control"
                           value="${donationCreateRequest.donorId}" required min="1" placeholder="Enter numerical Donor ID (e.g. 1)">
                    <small style="color: var(--text-secondary); margin-top: 4px; font-size: 12px;">
                        Need to find a donor's ID? Check the <a href="${pageContext.request.contextPath}/donors/available" target="_blank" style="color: var(--primary);">Available Donors</a> directory.
                    </small>
                </div>

                <div class="form-group col-span-2">
                    <label class="form-label required" for="donationDate">Donation Date</label>
                    <input type="date" id="donationDate" name="donationDate" class="form-control"
                           value="${donationCreateRequest.donationDate}" required>
                </div>

                <div class="form-group col-span-2">
                    <label class="form-label required" for="donationLocation">Donation Location / Blood Bank / Camp</label>
                    <input type="text" id="donationLocation" name="donationLocation" class="form-control"
                           value="${donationCreateRequest.donationLocation}" required placeholder="e.g. Red Cross Blood Center, Room 204">
                </div>

                <div class="form-group col-span-2">
                    <label class="form-label" for="remarks">Clinical Remarks / Notes (Optional)</label>
                    <textarea id="remarks" name="remarks" class="form-control" placeholder="e.g. 450ml Whole Blood, Donor tolerated well">${donationCreateRequest.remarks}</textarea>
                </div>
            </div>

            <div class="form-actions">
                <a href="${pageContext.request.contextPath}/donations" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">Save Donation Record</button>
            </div>
        </form>
    </div>
</main>

<jsp:include page="../common/footer.jsp" />
