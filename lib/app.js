const path = require('path');
const express = require('express');
const cookieSession = require('cookie-session');
const bcrypt = require('bcryptjs');
const data = require('./data');

const { BusinessError, NotFoundError } = data;
const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '..', 'views'));
app.set('trust proxy', 1);
app.disable('x-powered-by');

app.use('/css', express.static(path.join(__dirname, '..', 'public', 'css')));
app.use('/js', express.static(path.join(__dirname, '..', 'public', 'js')));
app.use(express.urlencoded({ extended: false }));
app.use(
  cookieSession({
    name: 'bdms',
    keys: [process.env.SESSION_SECRET || 'dev-only-change-me'],
    maxAge: 2 * 60 * 60 * 1000,
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
  })
);

// ---------- helpers ----------
const wrap = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

const notEmpty = (v) => v != null && v !== '' && !(Array.isArray(v) && v.length === 0);
const GROUPS = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
const STATUSES = ['PENDING', 'IN_PROGRESS', 'FULFILLED', 'CANCELLED'];
const URGENCIES = ['NORMAL', 'URGENT', 'CRITICAL'];
const ACCOUNT_STATUSES = ['ACTIVE', 'INACTIVE'];

// Per-request view defaults + one-time flash messages (stored in the signed cookie).
app.use((req, res, next) => {
  const flash = req.session.flash || {};
  req.session.flash = null;
  res.locals = {
    loggedInUser: req.session.user || null,
    successMessage: flash.successMessage,
    errorMessage: flash.errorMessage,
    notEmpty,
    loginRequest: {},
    registerRequest: {},
    bloodRequestCreateRequest: {},
    donationCreateRequest: {},
  };
  next();
});

const flash = (req, type, msg) => {
  req.session.flash = { [type]: msg };
};

const isAdmin = (u) => u && u.role === 'ADMIN' && u.accountStatus === 'ACTIVE';
const isDonor = (u) => u && u.role === 'DONOR';

const requireAdmin = (req, res, next) => (isAdmin(req.session.user) ? next() : res.redirect('/login'));
const requireDonor = (req, res, next) => (isDonor(req.session.user) ? next() : res.redirect('/login'));
const requireUser = (req, res, next) => (req.session.user ? next() : res.redirect('/login'));

const str = (v) => (typeof v === 'string' ? v : '');
const isEmail = (v) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
const phoneOk = (v) => /^\+?[0-9]{10,15}$/.test(v);

// ---------- auth ----------
app.get('/', (req, res) => res.redirect('/donors/available'));

app.get('/login', (req, res) => res.render('auth/login'));

app.post(
  '/login',
  wrap(async (req, res) => {
    const email = str(req.body.email).trim().toLowerCase();
    const password = str(req.body.password);
    const loginRequest = { email: str(req.body.email) };
    if (!email || !isEmail(email) || !password || password.length > 72) {
      return res.render('auth/login', { loginRequest, errorMessage: 'Please enter a valid email and password.' });
    }
    try {
      const user = await data.getActiveUserByEmail(email);
      if (!(await bcrypt.compare(password, user.password))) {
        return res.render('auth/login', { loginRequest, errorMessage: 'Invalid email or password.' });
      }
      req.session = { user: { userId: user.userId, fullName: user.fullName, email: user.email, role: user.role, accountStatus: user.accountStatus } };
      return res.redirect(user.role === 'ADMIN' ? '/admin/dashboard' : '/donor/dashboard');
    } catch (e) {
      if (e instanceof NotFoundError) {
        return res.render('auth/login', { loginRequest, errorMessage: 'Invalid email or password.' });
      }
      throw e;
    }
  })
);

app.get(
  '/register',
  wrap(async (req, res) => {
    res.render('auth/register', { bloodGroups: await data.getAllBloodGroups() });
  })
);

function validateRegister(b) {
  if (!str(b.fullName).trim()) return 'Full name is required';
  if (str(b.fullName).length > 100) return 'Full name cannot exceed 100 characters';
  if (!isEmail(str(b.email).trim())) return 'Please provide a valid email address';
  const pw = str(b.password);
  if (pw.length < 8 || pw.length > 72) return 'Password must contain between 8 and 72 characters';
  if (!(Number(b.bloodGroupId) > 0)) return 'Blood group is required';
  if (!str(b.dateOfBirth)) return 'Date of birth is required';
  if (!(str(b.dateOfBirth) < new Date().toISOString().slice(0, 10))) return 'Date of birth must be in the past';
  if (!phoneOk(str(b.phone).trim())) return 'Please provide a valid phone number';
  if (str(b.gender) && !/^(MALE|FEMALE|OTHER|PREFER_NOT_TO_SAY)$/.test(str(b.gender))) return 'Invalid gender value';
  if (!str(b.city).trim()) return 'City is required';
  return null;
}

app.post(
  '/register',
  wrap(async (req, res) => {
    const b = req.body;
    const err = validateRegister(b);
    if (err) {
      return res.render('auth/register', {
        registerRequest: b,
        bloodGroups: await data.getAllBloodGroups(),
        errorMessage: err,
      });
    }
    try {
      await data.registerDonor({
        fullName: str(b.fullName), email: str(b.email), password: str(b.password),
        bloodGroupId: b.bloodGroupId, dateOfBirth: str(b.dateOfBirth), phone: str(b.phone),
        gender: str(b.gender), city: str(b.city), area: str(b.area),
      });
      flash(req, 'successMessage', 'Registration successful. Please log in.');
      res.redirect('/login');
    } catch (e) {
      if (e instanceof BusinessError || e instanceof NotFoundError) {
        flash(req, 'errorMessage', e.message);
        return res.redirect('/register');
      }
      throw e;
    }
  })
);

app.get('/logout', (req, res) => {
  req.session = null;
  res.redirect('/login');
});

// ---------- admin ----------
app.get(
  '/admin/dashboard',
  requireAdmin,
  wrap(async (req, res) => {
    const [donors, requests, donations] = await Promise.all([
      data.getAllDonors(), data.getAllBloodRequests(), data.getAllDonations(),
    ]);
    res.render('admin/dashboard', {
      totalDonors: donors.length,
      availableDonors: donors.filter((d) => d.availability).length,
      totalRequests: requests.length,
      totalDonations: donations.length,
      recentRequests: requests.slice(0, 5),
    });
  })
);

app.get(
  '/users/:userId',
  requireAdmin,
  wrap(async (req, res) => {
    res.render('admin/user-details', {
      user: await data.getUserById(req.params.userId),
      accountStatuses: ACCOUNT_STATUSES,
    });
  })
);

app.post(
  '/users/:userId/status',
  requireAdmin,
  wrap(async (req, res) => {
    const userId = Number(req.params.userId);
    const status = str(req.body.accountStatus);
    const me = req.session.user;
    const back = '/users/' + req.params.userId;
    if (me.userId === userId && status === 'INACTIVE') {
      flash(req, 'errorMessage', 'You cannot deactivate your own administrator account.');
      return res.redirect(back);
    }
    try {
      await data.updateAccountStatus(userId, status, me.userId);
      flash(req, 'successMessage', 'User account status updated successfully.');
    } catch (e) {
      if (!(e instanceof BusinessError || e instanceof NotFoundError)) throw e;
      flash(req, 'errorMessage', e.message);
    }
    res.redirect(back);
  })
);

// ---------- donors ----------
app.get(
  '/donor/dashboard',
  requireDonor,
  wrap(async (req, res) => {
    try {
      res.render('donor/dashboard', { donor: await data.getDonorByUserId(req.session.user.userId) });
    } catch (e) {
      if (e instanceof NotFoundError) return res.redirect('/login');
      throw e;
    }
  })
);

app.get(
  '/donor/profile',
  requireDonor,
  wrap(async (req, res) => {
    try {
      res.render('donor/profile', { donor: await data.getDonorByUserId(req.session.user.userId) });
    } catch (e) {
      if (e instanceof NotFoundError) return res.redirect('/login');
      throw e;
    }
  })
);

app.post(
  '/donor/availability',
  requireDonor,
  wrap(async (req, res) => {
    const v = str(req.body.availability);
    if (v !== 'true' && v !== 'false') {
      flash(req, 'errorMessage', 'Please provide a valid availability status.');
      return res.redirect('/donor/profile');
    }
    try {
      const donor = await data.getDonorByUserId(req.session.user.userId);
      await data.updateDonorAvailability(donor.donorId, v === 'true', req.session.user.userId);
      flash(req, 'successMessage', 'Your availability has been updated successfully.');
    } catch (e) {
      if (!(e instanceof BusinessError || e instanceof NotFoundError)) throw e;
      flash(req, 'errorMessage', e.message);
    }
    res.redirect('/donor/profile');
  })
);

app.get(
  '/donors/available',
  wrap(async (req, res) => {
    const city = str(req.query.city);
    const bloodGroup = str(req.query.bloodGroup);
    res.render('donor/available-donors', {
      donors: await data.searchAvailableDonors(city, bloodGroup),
      city,
      bloodGroup,
    });
  })
);

// ---------- availability history ----------
app.get(
  '/availability-history/my-history',
  requireDonor,
  wrap(async (req, res) => {
    const donor = await data.getDonorByUserId(req.session.user.userId);
    res.render('donor/availability-history', {
      donor,
      availabilityHistory: await data.getAvailabilityHistory(donor.donorId),
    });
  })
);

app.get(
  '/availability-history/donor/:donorId',
  requireAdmin,
  wrap(async (req, res) => {
    const donor = await data.getDonorById(req.params.donorId);
    res.render('admin/donor-availability-history', {
      donor,
      availabilityHistory: await data.getAvailabilityHistory(donor.donorId),
    });
  })
);

// ---------- blood groups ----------
app.get(
  '/blood-groups',
  wrap(async (req, res) => res.render('blood-groups/list', { bloodGroups: await data.getAllBloodGroups() }))
);
app.get(
  '/blood-groups/:id',
  wrap(async (req, res) =>
    res.render('blood-groups/details', { bloodGroup: await data.getBloodGroupById(Number(req.params.id)) })
  )
);

// ---------- blood requests ----------
app.get(
  '/blood-requests',
  wrap(async (req, res) => {
    const [p, i] = await Promise.all([
      data.getBloodRequestsByStatus('PENDING'), data.getBloodRequestsByStatus('IN_PROGRESS'),
    ]);
    res.render('requests/list', { bloodRequests: [...p, ...i], requestStatuses: STATUSES });
  })
);

app.get(
  '/blood-requests/search',
  wrap(async (req, res) => {
    const city = str(req.query.city).trim();
    const bloodGroup = str(req.query.bloodGroup).trim();
    const status = STATUSES.includes(str(req.query.status)) ? str(req.query.status) : null;
    let list = status ? await data.getBloodRequestsByStatus(status) : await data.getAllBloodRequests();
    list = list.filter((r) => r.status === 'PENDING' || r.status === 'IN_PROGRESS');
    if (city) list = list.filter((r) => r.city.toLowerCase() === city.toLowerCase());
    if (bloodGroup) list = list.filter((r) => r.bloodGroup.toLowerCase() === bloodGroup.toLowerCase());
    res.render('requests/list', { bloodRequests: list, city, bloodGroup, status, requestStatuses: STATUSES });
  })
);

async function createFormData(extra) {
  return Object.assign({ bloodGroups: await data.getAllBloodGroups(), urgencyLevels: URGENCIES }, extra);
}

app.get(
  '/blood-requests/create',
  requireAdmin,
  wrap(async (req, res) => res.render('requests/create', await createFormData()))
);

function validateRequest(b) {
  if (!str(b.patientName).trim()) return 'Patient name is required';
  if (str(b.patientName).length > 100) return 'Patient name cannot exceed 100 characters';
  if (!phoneOk(str(b.contactNumber).trim())) return 'Please provide a valid contact number';
  if (!(Number(b.bloodGroupId) > 0)) return 'Blood group is required';
  if (!(Number(b.unitsRequired) > 0)) return 'Units required must be greater than zero';
  if (!str(b.hospitalName).trim()) return 'Hospital name is required';
  if (str(b.hospitalName).length > 150) return 'Hospital name cannot exceed 150 characters';
  if (!str(b.city).trim()) return 'City is required';
  if (!URGENCIES.includes(str(b.urgency))) return 'Urgency level is required';
  return null;
}

app.post(
  '/blood-requests/create',
  requireAdmin,
  wrap(async (req, res) => {
    const b = req.body;
    const err = validateRequest(b);
    if (err) {
      return res.render('requests/create', await createFormData({ bloodRequestCreateRequest: b, errorMessage: err }));
    }
    try {
      await data.createBloodRequest(
        {
          patientName: str(b.patientName), contactNumber: str(b.contactNumber), bloodGroupId: b.bloodGroupId,
          unitsRequired: b.unitsRequired, hospitalName: str(b.hospitalName), city: str(b.city),
          urgency: str(b.urgency), requiredBy: str(b.requiredBy),
        },
        req.session.user.userId
      );
      flash(req, 'successMessage', 'Blood request created successfully.');
      res.redirect('/blood-requests');
    } catch (e) {
      if (e instanceof BusinessError || e instanceof NotFoundError) {
        return res.render('requests/create', await createFormData({ bloodRequestCreateRequest: b, errorMessage: e.message }));
      }
      throw e;
    }
  })
);

app.get(
  '/blood-requests/:id/status',
  requireAdmin,
  wrap(async (req, res) =>
    res.render('requests/update-status', {
      bloodRequest: await data.getBloodRequestById(req.params.id),
      requestStatuses: STATUSES,
    })
  )
);

app.post(
  '/blood-requests/:id/status',
  requireAdmin,
  wrap(async (req, res) => {
    const id = req.params.id;
    try {
      await data.updateBloodRequestStatus(id, str(req.body.status), req.session.user.userId);
      flash(req, 'successMessage', 'Blood request status updated successfully.');
      res.redirect('/blood-requests/' + id);
    } catch (e) {
      if (!(e instanceof BusinessError || e instanceof NotFoundError)) throw e;
      flash(req, 'errorMessage', e.message);
      res.redirect('/blood-requests/' + id + '/status');
    }
  })
);

app.get(
  '/blood-requests/:id',
  wrap(async (req, res) =>
    res.render('requests/details', {
      bloodRequest: await data.getBloodRequestById(req.params.id),
      requestStatuses: STATUSES,
    })
  )
);

// ---------- donations ----------
app.get(
  '/donations',
  requireAdmin,
  wrap(async (req, res) => res.render('donations/list', { donations: await data.getAllDonations() }))
);

app.get('/donations/create', requireAdmin, (req, res) => res.render('donations/create'));

app.post(
  '/donations/create',
  requireAdmin,
  wrap(async (req, res) => {
    const b = req.body;
    let err = null;
    if (!(Number(b.donorId) > 0)) err = 'Invalid donor ID';
    else if (!str(b.donationDate)) err = 'Donation date is required';
    else if (str(b.donationDate) > new Date().toISOString().slice(0, 10)) err = 'Donation date cannot be in the future';
    else if (!str(b.donationLocation).trim()) err = 'Donation location is required';
    else if (str(b.donationLocation).length > 150) err = 'Donation location cannot exceed 150 characters';
    else if (str(b.remarks).length > 500) err = 'Remarks cannot exceed 500 characters';
    if (err) return res.render('donations/create', { donationCreateRequest: b, errorMessage: err });
    try {
      await data.recordDonation(
        { donorId: b.donorId, donationDate: str(b.donationDate), donationLocation: str(b.donationLocation), remarks: str(b.remarks) },
        req.session.user.userId
      );
      flash(req, 'successMessage', 'Donation recorded successfully.');
      res.redirect('/donations');
    } catch (e) {
      if (e instanceof BusinessError || e instanceof NotFoundError) {
        return res.render('donations/create', { donationCreateRequest: b, errorMessage: e.message });
      }
      throw e;
    }
  })
);

app.get(
  '/donations/my-history',
  requireDonor,
  wrap(async (req, res) => {
    try {
      const donor = await data.getDonorByUserId(req.session.user.userId);
      res.render('donations/my-history', { donations: await data.getDonationsByDonor(donor.donorId) });
    } catch (e) {
      if (e instanceof NotFoundError) return res.redirect('/login');
      throw e;
    }
  })
);

app.get(
  '/donations/donor/:donorId',
  requireAdmin,
  wrap(async (req, res) => {
    try {
      const donor = await data.getDonorById(req.params.donorId);
      res.render('donations/donor-history', {
        donor: donor.fullName,
        donations: await data.getDonationsByDonor(donor.donorId),
      });
    } catch (e) {
      if (e instanceof NotFoundError) return res.redirect('/donations');
      throw e;
    }
  })
);

app.get(
  '/donations/:id',
  requireUser,
  wrap(async (req, res) => {
    try {
      const donation = await data.getDonationById(req.params.id);
      const me = req.session.user;
      if (me.role === 'DONOR') {
        const donor = await data.getDonorByUserId(me.userId);
        if (donation.donorId !== donor.donorId) return res.redirect('/donations/my-history');
      }
      res.render('donations/details', { donation });
    } catch (e) {
      if (e instanceof BusinessError || e instanceof NotFoundError) return res.redirect('/donations/my-history');
      throw e;
    }
  })
);

// ---------- errors ----------
app.use((req, res) => res.status(404).render('error', { code: 404, message: 'Page not found.' }));

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error(err);
  const known = err instanceof BusinessError || err instanceof NotFoundError;
  res.status(known ? 400 : 500).render('error', {
    code: known ? 400 : 500,
    message: known ? err.message : 'Something went wrong. Please try again.',
  });
});

module.exports = app;
