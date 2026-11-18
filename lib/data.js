// Data + business rules (port of the Spring service layer).
const bcrypt = require('bcryptjs');
const db = require('./db');

class BusinessError extends Error {}
class NotFoundError extends Error {}

const DONOR_SELECT = `
  SELECT d.donor_id AS "donorId", u.user_id AS "userId", u.full_name AS "fullName", u.email,
         bg.group_name AS "bloodGroup", d.date_of_birth AS "dateOfBirth", d.phone, d.gender,
         d.city, d.area, d.last_donation_date AS "lastDonationDate", d.availability,
         d.created_at AS "createdAt"
  FROM donors d JOIN users u ON u.user_id = d.user_id
  JOIN blood_groups bg ON bg.blood_group_id = d.blood_group_id`;

const REQUEST_SELECT = `
  SELECT r.request_id AS "requestId", r.patient_name AS "patientName", r.contact_number AS "contactNumber",
         bg.group_name AS "bloodGroup", r.units_required AS "unitsRequired", r.hospital_name AS "hospitalName",
         r.city, r.urgency, r.status, r.request_date AS "requestDate", r.required_by AS "requiredBy",
         u.user_id AS "createdByUserId", u.full_name AS "createdByName"
  FROM blood_requests r JOIN blood_groups bg ON bg.blood_group_id = r.blood_group_id
  JOIN users u ON u.user_id = r.created_by`;

const DONATION_SELECT = `
  SELECT h.donation_id AS "donationId", d.donor_id AS "donorId", du.full_name AS "donorName",
         bg.group_name AS "bloodGroup", h.donation_date AS "donationDate",
         h.donation_location AS "donationLocation", h.remarks,
         ru.user_id AS "recordedByUserId", ru.full_name AS "recordedByName"
  FROM donation_history h JOIN donors d ON d.donor_id = h.donor_id
  JOIN users du ON du.user_id = d.user_id JOIN blood_groups bg ON bg.blood_group_id = d.blood_group_id
  JOIN users ru ON ru.user_id = h.recorded_by`;

const today = () => new Date().toISOString().slice(0, 10);
const posId = (v, msg) => {
  const n = Number(v);
  if (!Number.isInteger(n) || n <= 0) throw new BusinessError(msg);
  return n;
};

// ---------- users ----------
const userCols = `user_id AS "userId", full_name AS "fullName", email, role, account_status AS "accountStatus", created_at AS "createdAt"`;

async function getActiveUserByEmail(email) {
  const u = await db.one(`SELECT ${userCols}, password FROM users WHERE email=$1 AND account_status='ACTIVE'`, [email]);
  if (!u) throw new NotFoundError('Active account not found');
  return u;
}
async function getUserById(id) {
  const n = posId(id, 'User ID cannot be null.');
  const u = await db.one(`SELECT ${userCols} FROM users WHERE user_id=$1`, [n]);
  if (!u) throw new NotFoundError('User not found with ID: ' + id);
  return u;
}
async function updateAccountStatus(userId, status, adminId) {
  if (!['ACTIVE', 'INACTIVE'].includes(status)) throw new BusinessError('Invalid account status.');
  const admin = await getUserById(adminId);
  if (admin.role !== 'ADMIN' || admin.accountStatus !== 'ACTIVE')
    throw new BusinessError('Only active administrators can update account status.');
  await getUserById(userId);
  if (Number(userId) === adminId && status === 'INACTIVE')
    throw new BusinessError('An administrator cannot deactivate their own account.');
  await db.query('UPDATE users SET account_status=$1 WHERE user_id=$2', [status, Number(userId)]);
}

// ---------- blood groups ----------
const getAllBloodGroups = () =>
  db.query('SELECT blood_group_id AS "bloodGroupId", group_name AS "groupName" FROM blood_groups ORDER BY blood_group_id');
async function getBloodGroupById(id) {
  if (!Number.isInteger(id) || id <= 0) throw new BusinessError('Blood group ID must be a positive number.');
  const g = await db.one(
    'SELECT blood_group_id AS "bloodGroupId", group_name AS "groupName" FROM blood_groups WHERE blood_group_id=$1', [id]);
  if (!g) throw new NotFoundError('Blood group not found with ID: ' + id);
  return g;
}

// ---------- donors ----------
async function registerDonor(f) {
  const email = f.email.trim().toLowerCase();
  const dob = f.dateOfBirth;
  if (!dob || !(dob < today())) throw new BusinessError('A valid date of birth is required.');
  const gender = f.gender && f.gender.trim() ? f.gender.trim().toUpperCase() : null;
  if (gender && !['MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'].includes(gender))
    throw new BusinessError('Invalid gender selection.');
  await getBloodGroupById(Number(f.bloodGroupId));
  const hash = await bcrypt.hash(f.password, 10);
  await db.tx(async (t) => {
    if (await t.one('SELECT 1 FROM users WHERE email=$1', [email]))
      throw new BusinessError('An account with this email already exists.');
    const u = await t.one(
      `INSERT INTO users (full_name,email,password,role,account_status) VALUES ($1,$2,$3,'DONOR','ACTIVE') RETURNING user_id`,
      [f.fullName.trim(), email, hash]);
    await t.query(
      `INSERT INTO donors (user_id,blood_group_id,date_of_birth,phone,gender,city,area,availability)
       VALUES ($1,$2,$3,$4,$5,$6,$7,TRUE)`,
      [u.user_id, Number(f.bloodGroupId), dob, f.phone.trim(), gender, f.city.trim(), (f.area || '').trim() || null]);
  });
}
async function getDonorByUserId(userId) {
  const d = await db.one(DONOR_SELECT + ' WHERE d.user_id=$1', [userId]);
  if (!d) throw new NotFoundError('Donor profile not found for user ID: ' + userId);
  return d;
}
async function getDonorById(id) {
  const n = posId(id, 'A valid donor ID is required.');
  const d = await db.one(DONOR_SELECT + ' WHERE d.donor_id=$1', [n]);
  if (!d) throw new NotFoundError('Donor not found with ID: ' + id);
  return d;
}
const getAllDonors = () => db.query(DONOR_SELECT + ' ORDER BY d.donor_id');
async function searchAvailableDonors(city, bloodGroup) {
  const where = ['d.availability = TRUE'];
  const p = [];
  if (city && city.trim()) {
    p.push(city.trim());
    where.push('LOWER(d.city)=LOWER($' + p.length + ')');
  }
  if (bloodGroup && bloodGroup.trim()) {
    p.push(bloodGroup.trim().toUpperCase());
    where.push('bg.group_name=$' + p.length);
  }
  return db.query(DONOR_SELECT + ' WHERE ' + where.join(' AND ') + ' ORDER BY d.donor_id', p);
}

// ---------- availability ----------
async function updateDonorAvailability(donorId, newAvail, userId) {
  posId(donorId, 'A valid donor ID is required.');
  await db.tx(async (t) => {
    const donor = await t.one('SELECT donor_id, availability FROM donors WHERE donor_id=$1 FOR UPDATE', [donorId]);
    if (!donor) throw new NotFoundError('Donor not found with ID: ' + donorId);
    const user = await t.one('SELECT user_id, role, account_status FROM users WHERE user_id=$1', [userId]);
    if (!user) throw new NotFoundError('User not found with ID: ' + userId);
    if (user.account_status !== 'ACTIVE') throw new BusinessError('Inactive users cannot update donor availability.');
    if (user.role === 'DONOR') {
      const own = await t.one('SELECT donor_id FROM donors WHERE user_id=$1', [userId]);
      if (!own || own.donor_id !== donorId)
        throw new BusinessError("You are not authorized to update another donor's availability.");
    } else if (user.role !== 'ADMIN') {
      throw new BusinessError('You are not authorized to update donor availability.');
    }
    if (donor.availability === newAvail) throw new BusinessError('Donor availability is already set to ' + newAvail + '.');
    await t.query('UPDATE donors SET availability=$1 WHERE donor_id=$2', [newAvail, donorId]);
    await t.query(
      'INSERT INTO donor_availability_history (donor_id,previous_status,new_status,updated_by) VALUES ($1,$2,$3,$4)',
      [donorId, donor.availability, newAvail, userId]);
  });
}
const getAvailabilityHistory = (donorId) =>
  db.query(
    `SELECT h.history_id AS "historyId", d.donor_id AS "donorId", du.full_name AS "donorName",
            h.previous_status AS "previousStatus", h.new_status AS "newStatus", h.updated_at AS "updatedAt",
            uu.user_id AS "updatedByUserId", uu.full_name AS "updatedByName"
     FROM donor_availability_history h JOIN donors d ON d.donor_id=h.donor_id
     JOIN users du ON du.user_id=d.user_id JOIN users uu ON uu.user_id=h.updated_by
     WHERE h.donor_id=$1 ORDER BY h.updated_at DESC, h.history_id DESC`, [donorId]);

// ---------- donations ----------
async function recordDonation(f, adminId) {
  const donorId = posId(f.donorId, 'A valid donor ID is required.');
  if (!f.donationDate) throw new BusinessError('Donation date is required.');
  if (f.donationDate > today()) throw new BusinessError('Donation date cannot be in the future.');
  if (!f.donationLocation || !f.donationLocation.trim()) throw new BusinessError('Donation location is required.');
  await db.tx(async (t) => {
    const donor = await t.one('SELECT donor_id, last_donation_date FROM donors WHERE donor_id=$1 FOR UPDATE', [donorId]);
    if (!donor) throw new NotFoundError('Donor not found with ID: ' + donorId);
    const admin = await t.one('SELECT role, account_status FROM users WHERE user_id=$1', [adminId]);
    if (!admin) throw new NotFoundError('User not found with ID: ' + adminId);
    if (admin.role !== 'ADMIN' || admin.account_status !== 'ACTIVE')
      throw new BusinessError('Only active administrators can record blood donations.');
    if (donor.last_donation_date && f.donationDate < donor.last_donation_date)
      throw new BusinessError("Donation date cannot be earlier than the donor's previous donation date.");
    await t.query(
      'INSERT INTO donation_history (donor_id,donation_date,donation_location,remarks,recorded_by) VALUES ($1,$2,$3,$4,$5)',
      [donorId, f.donationDate, f.donationLocation.trim(), (f.remarks || '').trim() || null, adminId]);
    await t.query('UPDATE donors SET last_donation_date=$1 WHERE donor_id=$2', [f.donationDate, donorId]);
  });
}
const getAllDonations = () => db.query(DONATION_SELECT + ' ORDER BY h.donation_id');
async function getDonationById(id) {
  const n = posId(id, 'Donation record not found.');
  const d = await db.one(DONATION_SELECT + ' WHERE h.donation_id=$1', [n]);
  if (!d) throw new NotFoundError('Donation record not found with ID: ' + id);
  return d;
}
const getDonationsByDonor = (donorId) =>
  db.query(DONATION_SELECT + ' WHERE h.donor_id=$1 ORDER BY h.donation_date DESC, h.donation_id DESC', [donorId]);

// ---------- blood requests ----------
const getAllBloodRequests = () => db.query(REQUEST_SELECT + ' ORDER BY r.request_id');
const getBloodRequestsByStatus = (s) => db.query(REQUEST_SELECT + ' WHERE r.status=$1 ORDER BY r.request_id', [s]);
async function getBloodRequestById(id) {
  const n = posId(id, 'A valid request ID is required.');
  const r = await db.one(REQUEST_SELECT + ' WHERE r.request_id=$1', [n]);
  if (!r) throw new NotFoundError('Blood request not found with ID: ' + id);
  return r;
}
async function createBloodRequest(f, adminId) {
  const bg = await getBloodGroupById(Number(f.bloodGroupId));
  const units = Number(f.unitsRequired);
  if (!Number.isInteger(units) || units <= 0) throw new BusinessError('Units required must be greater than zero.');
  const requiredBy = f.requiredBy ? f.requiredBy : null;
  if (requiredBy && new Date(requiredBy) < new Date()) throw new BusinessError('Required-by date cannot be in the past.');
  const admin = await getUserById(adminId);
  if (admin.role !== 'ADMIN' || admin.accountStatus !== 'ACTIVE')
    throw new BusinessError('Only active administrators can create blood requests.');
  await db.query(
    `INSERT INTO blood_requests (patient_name,contact_number,blood_group_id,units_required,hospital_name,city,urgency,status,required_by,created_by)
     VALUES ($1,$2,$3,$4,$5,$6,$7,'PENDING',$8,$9)`,
    [f.patientName.trim(), f.contactNumber.trim(), bg.bloodGroupId, units, f.hospitalName.trim(), f.city.trim(),
     f.urgency || 'NORMAL', requiredBy, adminId]);
}
async function updateBloodRequestStatus(id, newStatus, adminId) {
  const r = await getBloodRequestById(id);
  if (!['PENDING', 'IN_PROGRESS', 'FULFILLED', 'CANCELLED'].includes(newStatus))
    throw new BusinessError('New request status is required.');
  const cur = r.status;
  if (cur === 'FULFILLED' || cur === 'CANCELLED') throw new BusinessError('A fulfilled or cancelled request cannot be changed.');
  if (cur === newStatus) throw new BusinessError('Request already has the status: ' + newStatus);
  const ok = (cur === 'PENDING' && ['IN_PROGRESS', 'FULFILLED', 'CANCELLED'].includes(newStatus)) ||
             (cur === 'IN_PROGRESS' && ['FULFILLED', 'CANCELLED'].includes(newStatus));
  if (!ok) throw new BusinessError('Invalid request status transition from ' + cur + ' to ' + newStatus + '.');
  const admin = await getUserById(adminId);
  if (admin.role !== 'ADMIN' || admin.accountStatus !== 'ACTIVE')
    throw new BusinessError('Only active administrators can update blood requests.');
  await db.query('UPDATE blood_requests SET status=$1 WHERE request_id=$2', [newStatus, Number(id)]);
}

module.exports = {
  BusinessError, NotFoundError,
  getActiveUserByEmail, getUserById, updateAccountStatus,
  getAllBloodGroups, getBloodGroupById,
  registerDonor, getDonorByUserId, getDonorById, getAllDonors, searchAvailableDonors,
  updateDonorAvailability, getAvailabilityHistory,
  recordDonation, getAllDonations, getDonationById, getDonationsByDonor,
  getAllBloodRequests, getBloodRequestsByStatus, getBloodRequestById, createBloodRequest, updateBloodRequestStatus,
};
