<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Blood Donation Management System - Find Donors" />
<jsp:include page="../common/header.jsp" />
<jsp:include page="../common/navbar.jsp" />

<main class="main-container">
    <!-- 1. Hero Section -->
    <section class="hero-section">
        <div class="hero-tag">
            <span>&#9829;</span> Voluntary Blood Donation Network
        </div>
        <h1 class="hero-title">Every Drop Connects a Lifeline for Those in Need</h1>
        <p class="hero-subtitle">
            A verified clinical platform connecting voluntary blood donors with emergency hospital requests.
            Search eligible donors by blood group and city with total privacy protection.
        </p>
        <div class="hero-actions">
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">
                + Register as a Blood Donor
            </a>
            <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-secondary">
                View Emergency Requests
            </a>
            <a href="#donor-search-section" class="btn btn-mint">
                Search Donors &darr;
            </a>
        </div>

        <!-- 3 Medical Trust Badges -->
        <div class="hero-trust-grid">
            <div class="trust-card">
                <div class="trust-icon">&#10003;</div>
                <div>
                    <div class="trust-title">Privacy Protected</div>
                    <div class="trust-desc">Phone numbers & emails shielded against unsolicited spam.</div>
                </div>
            </div>

            <div class="trust-card">
                <div class="trust-icon">&#10010;</div>
                <div>
                    <div class="trust-title">Verified Groups</div>
                    <div class="trust-desc">All 8 ABO and Rh groups indexed for clinical accuracy.</div>
                </div>
            </div>

            <div class="trust-card">
                <div class="trust-icon">&#9733;</div>
                <div>
                    <div class="trust-title">Emergency Dispatch</div>
                    <div class="trust-desc">Direct hospital and administrative liaison for urgent units.</div>
                </div>
            </div>
        </div>
    </section>

    <!-- 2. Search & Donor Directory Section -->
    <section id="donor-search-section">
        <div class="page-header">
            <div>
                <h2 class="page-title">Search Available Blood Donors</h2>
                <p class="page-subtitle">Locate active donors ready to respond in your geographical vicinity</p>
            </div>
            <div>
                <span class="privacy-badge">
                    <span>&#128274;</span> Contact details protected &bull; Mediated via Administration
                </span>
            </div>
        </div>

        <!-- Filter Form -->
        <form action="${pageContext.request.contextPath}/donors/available" method="get" class="filter-bar">
            <div class="form-group">
                <label class="form-label" for="bloodGroup">Filter by Blood Group</label>
                <select id="bloodGroup" name="bloodGroup" class="form-control">
                    <option value="">All Blood Groups (A, B, AB, O)</option>
                    <c:forEach var="bg" items="${['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']}">
                        <option value="${bg}" ${bloodGroup == bg ? 'selected' : ''}>${bg}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="city">Filter by City</label>
                <input type="text" id="city" name="city" class="form-control"
                       value="${city}" placeholder="e.g. Mumbai, Pune, Thane">
            </div>

            <div style="display: flex; gap: 8px;">
                <button type="submit" class="btn btn-secondary">Search Donors</button>
                <a href="${pageContext.request.contextPath}/donors/available" class="btn btn-outline">Reset Filter</a>
            </div>
        </form>

        <!-- Donors Directory Table (NO phone or email exposed to prevent spam) -->
        <div class="data-table-container">
            <c:choose>
                <c:when test="${not empty donors}">
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Blood Group</th>
                                <th>Donor Name</th>
                                <th>City / Area</th>
                                <th>Last Donated</th>
                                <th>Status</th>
                                <th>Coordination</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="d" items="${donors}">
                                <tr>
                                    <td>
                                        <span class="blood-badge">${d.bloodGroup}</span>
                                    </td>
                                    <td style="font-weight: 600;">${d.fullName}</td>
                                    <td>
                                        ${d.city}
                                        <c:if test="${not empty d.area}">
                                            <span style="color: var(--text-secondary); font-size: 13px;">(${d.area})</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty d.lastDonationDate}">
                                                ${d.lastDonationDate}
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color: var(--text-muted);">First time donor</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="status-pill status-available">Available to Donate</span>
                                    </td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/blood-requests" class="btn btn-outline btn-sm">
                                            Request via Admin
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-state-title">No Available Donors Found</div>
                        <p>No active donors currently match your filter criteria. Try resetting the filters or broadening your search city.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- 3. Blood Donation FAQs Accordion Section -->
    <section class="faq-section">
        <div class="section-header">
            <h2 class="section-title">Frequently Asked Questions</h2>
            <p class="section-subtitle">Clinical guidelines, donor eligibility, and system security practices</p>
        </div>

        <div class="accordion-container">
            <!-- FAQ 1 -->
            <div class="accordion-item">
                <button type="button" class="accordion-header">
                    <span>Who is medically eligible to donate blood?</span>
                    <span class="accordion-icon">&#43;</span>
                </button>
                <div class="accordion-content">
                    <div class="accordion-inner">
                        Generally, healthy individuals between <strong>18 and 65 years of age</strong>, weighing at least <strong>50 kg</strong> (110 lbs), with normal hemoglobin levels (&ge; 12.5 g/dL), and without active chronic infections or recent major surgeries are eligible to donate whole blood.
                    </div>
                </div>
            </div>

            <!-- FAQ 2 -->
            <div class="accordion-item">
                <button type="button" class="accordion-header">
                    <span>How often can a healthy individual donate blood?</span>
                    <span class="accordion-icon">&#43;</span>
                </button>
                <div class="accordion-content">
                    <div class="accordion-inner">
                        The human body replaces plasma within 24–48 hours, while red blood cells require approximately 4–8 weeks to regenerate fully. As per national health guidelines, male donors should wait at least <strong>90 days</strong> and female donors at least <strong>120 days</strong> between consecutive whole blood donations.
                    </div>
                </div>
            </div>

            <!-- FAQ 3 -->
            <div class="accordion-item">
                <button type="button" class="accordion-header">
                    <span>Why are donor phone numbers and email addresses hidden from the public?</span>
                    <span class="accordion-icon">&#43;</span>
                </button>
                <div class="accordion-content">
                    <div class="accordion-inner">
                        To protect our voluntary donors from unsolicited spam, marketing calls, and security harassment, personal contact information is kept strictly confidential. When a hospital requires blood, authorized hospital coordinators and administrators communicate with the donor through secure official channels.
                    </div>
                </div>
            </div>

            <!-- FAQ 4 -->
            <div class="accordion-item">
                <button type="button" class="accordion-header">
                    <span>What are the key blood compatibility rules during emergency transfusions?</span>
                    <span class="accordion-icon">&#43;</span>
                </button>
                <div class="accordion-content">
                    <div class="accordion-inner">
                        <strong>O- (O Negative)</strong> donors are universal red cell donors and their blood can be safely transfused to patients of any blood type during extreme emergencies. Conversely, <strong>AB+ (AB Positive)</strong> individuals are universal recipients and can safely receive red blood cells from any blood group.
                    </div>
                </div>
            </div>

            <!-- FAQ 5 -->
            <div class="accordion-item">
                <button type="button" class="accordion-header">
                    <span>What steps should I take before and after donating blood?</span>
                    <span class="accordion-icon">&#43;</span>
                </button>
                <div class="accordion-content">
                    <div class="accordion-inner">
                        <strong>Before:</strong> Drink plenty of water (at least 500ml), eat a nutritious iron-rich meal, and avoid smoking/alcohol for at least 24 hours.<br>
                        <strong>After:</strong> Rest for 10–15 minutes, consume a healthy snack or juice, stay hydrated, and refrain from strenuous physical lifting for the rest of the day.
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="../common/footer.jsp" />
