#!/usr/bin/env bash
# BDMS functional test suite (black-box HTTP tests).
# Usage: BASE=http://localhost:8080 bash testing/functional-tests.sh
# Writes results to testing/results.tsv  (ID | Module | Test case | Expected | Actual | Result)
BASE="${BASE:-http://localhost:8080}"
OUT="$(dirname "$0")/results.tsv"
TMP="$(mktemp -d)"
: > "$OUT"
N=0; PASS=0; FAIL=0
STAMP=$(date +%s)
D_PAST10=$(date -d "-10 days" +%F)
D_PAST20=$(date -d "-20 days" +%F)
D_FUT5=$(date -d "+5 days" +%F)
EMAIL_A="test.a.$STAMP@example.com"; EMAIL_B="test.b.$STAMP@example.com"
PATIENT="ZZ Test Patient $STAMP"

# req JAR METHOD PATH [curl args...] -> sets CODE, LOC, BODY (redirects not followed)
req() { local jar="$1" m="$2" p="$3"; shift 3
  CODE=$(curl -s -m 90 -D "$TMP/h" -o "$TMP/b" -w '%{http_code}' -c "$TMP/$jar" -b "$TMP/$jar" "$@" "$BASE$p")
  LOC=$(grep -i '^location:' "$TMP/h" | tr -d '\r' | sed 's/^[Ll]ocation: *//'); BODY=$(cat "$TMP/b"); }
reqf() { req "$@" -L; }
# rec MODULE NAME EXPECTED ACTUAL OK(1/0)
rec() {
  N=$((N+1)); local r=FAIL; if [ "$5" = 1 ]; then r=PASS; PASS=$((PASS+1)); else FAIL=$((FAIL+1)); fi
  printf 'TC%02d\t%s\t%s\t%s\t%s\t%s\n' "$N" "$1" "$2" "$3" "$4" "$r" >> "$OUT"
  printf 'TC%02d %-4s %s | %s\n' "$N" "$r" "$1" "$2"; }
has() { echo "$BODY" | grep -q -- "$1"; }
ok() { if "$@"; then echo 1; else echo 0; fi; }
isredir() { [[ "$CODE" = 302 && "$LOC" == *"$1"* ]]; }
is200() { [[ "$CODE" = 200 ]]; }
okand() { if is200 && "$@"; then echo 1; else echo 0; fi; }
okno() { if is200 && ! has "$1"; then echo 1; else echo 0; fi; }

echo "== BDMS functional tests against $BASE =="
# ---------------- Public pages ----------------
req pub GET /
rec "Public" "Home page redirects to donor search" "302 to /donors/available" "$CODE $LOC" $(ok isredir /donors/available)
req pub GET /donors/available; C=$(echo "$BODY" | grep -c 'blood-badge')
rec "Public" "Donor search lists all available donors" "HTTP 200, at least 24 donor rows" "HTTP $CODE, $C rows" $(ok test "$CODE" = 200 -a "$C" -ge 24)
req pub GET "/donors/available?bloodGroup=O%2B"; C=$(echo "$BODY" | grep -c 'blood-badge')
rec "Public" "Filter donors by blood group O+" "HTTP 200, 3 or more O+ rows" "HTTP $CODE, $C rows" $(ok test "$CODE" = 200 -a "$C" -ge 3)
req pub GET "/donors/available?city=Pune"; C=$(echo "$BODY" | grep -c 'blood-badge')
rec "Public" "Filter donors by city (Pune)" "HTTP 200, Pune donors listed" "HTTP $CODE, $C rows" $(ok test "$CODE" = 200 -a "$C" -ge 1)
req pub GET "/donors/available?city=Mumbai&bloodGroup=A%2B"; C=$(echo "$BODY" | grep -c 'blood-badge')
rec "Public" "Combined filter city + blood group" "HTTP 200, 1 to 3 Mumbai A+ rows" "HTTP $CODE, $C rows" $(ok test "$CODE" = 200 -a "$C" -ge 1 -a "$C" -le 3)
req pub GET "/donors/available?city=Atlantis"; C=$(echo "$BODY" | grep -c 'blood-badge')
rec "Public" "Search with no matching city" "HTTP 200, 0 rows (empty state)" "HTTP $CODE, $C rows" $(ok test "$CODE" = 200 -a "$C" = 0)
req pub GET /blood-groups; C=$(echo "$BODY" | grep -c 'bloodGroup=')
rec "Public" "Blood groups page shows the 8 groups" "HTTP 200, 8 groups" "HTTP $CODE, $C groups" $(ok test "$CODE" = 200 -a "$C" -ge 8)
req pub GET /blood-groups/1
rec "Public" "Blood group details page" "HTTP 200" "HTTP $CODE" $(ok is200)
req pub GET /blood-requests
rec "Public" "Open blood requests list is public" "HTTP 200" "HTTP $CODE" $(ok is200)
req pub GET "/blood-requests/search?city=Mumbai"
rec "Public" "Blood request search by city" "HTTP 200" "HTTP $CODE" $(ok is200)
req pub GET /register
rec "Public" "Registration page loads with blood group options" "HTTP 200, form present" "HTTP $CODE" $(okand has bloodGroupId)
req pub GET /css/base.css
rec "Public" "Static CSS served" "HTTP 200" "HTTP $CODE" $(ok is200)

# ---------------- Authentication ----------------
req au POST /login -d "email=admin@bdms.com&password=wrongpass"
rec "Authentication" "Login with wrong password is rejected" "Stay on login, Invalid email or password" "HTTP $CODE" $(okand has "Invalid email or password")
req au POST /login -d "email=nobody@example.com&password=whatever1"
rec "Authentication" "Login with unknown email is rejected" "Invalid email or password" "HTTP $CODE" $(okand has "Invalid email or password")
req au POST /login -d "email=&password="
rec "Authentication" "Login with empty fields is rejected" "Stay on login page (no redirect)" "HTTP $CODE" $(ok is200)
req ADM POST /login -d "email=admin@bdms.com&password=admin123"
rec "Authentication" "Admin login succeeds" "302 to /admin/dashboard" "$CODE $LOC" $(ok isredir /admin/dashboard)

# ---------------- Registration ----------------
REG="fullName=Test+Donor+A+$STAMP&email=$EMAIL_A&password=Secret123&bloodGroupId=1&dateOfBirth=1999-01-15&phone=9876543210&gender=MALE&city=Mumbai&area=Dadar"
reqf pub POST /register -d "$REG"
rec "Registration" "Register new donor with valid data" "Redirect to login with success message" "HTTP $CODE" $(okand has "Registration successful")
reqf pub POST /register -d "$REG"
rec "Registration" "Duplicate email is rejected" "Error: account with this email already exists" "HTTP $CODE" $(ok has "already exists")
req pub POST /register -d "fullName=X&email=short.$STAMP@example.com&password=abc&bloodGroupId=1&dateOfBirth=1999-01-15&phone=9876543210&city=Mumbai"
rec "Registration" "Password shorter than 8 characters is rejected" "Form re-displayed, no account created" "HTTP $CODE" $(ok is200)
req pub POST /register -d "fullName=X&email=ph.$STAMP@example.com&password=Secret123&bloodGroupId=1&dateOfBirth=1999-01-15&phone=12ab&city=Mumbai"
rec "Registration" "Invalid phone number is rejected" "Form re-displayed, no account created" "HTTP $CODE" $(ok is200)
req pub POST /register -d "fullName=X&email=dob.$STAMP@example.com&password=Secret123&bloodGroupId=1&dateOfBirth=2999-01-01&phone=9876543210&city=Mumbai"
rec "Registration" "Future date of birth is rejected" "Form re-displayed, no account created" "HTTP $CODE" $(ok is200)
req pub POST /register -d "fullName=X&email=bademail&password=Secret123&bloodGroupId=1&dateOfBirth=1999-01-01&phone=9876543210&city=Mumbai"
rec "Registration" "Invalid email format is rejected" "Form re-displayed, no account created" "HTTP $CODE" $(ok is200)
reqf pub POST /register -d "fullName=Test+Donor+B&email=$EMAIL_B&password=Secret123&bloodGroupId=2&dateOfBirth=1998-03-10&phone=9876501234&gender=FEMALE&city=Pune&area=Aundh" >/dev/null

# ---------------- Donor session ----------------
req DA POST /login -d "email=$EMAIL_A&password=Secret123"
rec "Donor" "New donor can log in" "302 to /donor/dashboard" "$CODE $LOC" $(ok isredir /donor/dashboard)
req DB POST /login -d "email=$EMAIL_B&password=Secret123" >/dev/null
req DA GET /donor/dashboard
rec "Donor" "Donor dashboard shows own name" "HTTP 200 with donor name" "HTTP $CODE" $(okand has "Test Donor A $STAMP")
req DA GET /donor/profile
rec "Donor" "Donor profile page loads" "HTTP 200" "HTTP $CODE" $(ok is200)
reqf DA POST /donor/availability -d "availability=false"
rec "Donor" "Donor marks self unavailable" "Success message shown" "HTTP $CODE" $(ok has "updated successfully")
reqf DA POST /donor/availability -d "availability=false"
rec "Donor" "Setting the same availability again is blocked" "Error: already set" "HTTP $CODE" $(ok has "already set")
reqf DA POST /donor/availability -d "availability=true"
rec "Donor" "Donor marks self available again" "Success message shown" "HTTP $CODE" $(ok has "updated successfully")
req DA GET /availability-history/my-history
rec "Donor" "Donor sees own availability history" "HTTP 200" "HTTP $CODE" $(ok is200)
req DA GET /donations/my-history
rec "Donor" "Donor donation history page loads" "HTTP 200" "HTTP $CODE" $(ok is200)

# ---------------- Authorization ----------------
for P in /admin/dashboard /donations /donations/create /blood-requests/create /donor/dashboard /donor/profile /donations/my-history; do
  req anon GET "$P"
  rec "Authorization" "Anonymous user blocked from $P" "302 to /login" "$CODE $LOC" $(ok isredir /login)
done
for P in /admin/dashboard /donations /donations/create /blood-requests/create; do
  req DA GET "$P"
  rec "Authorization" "Donor blocked from admin page $P" "302 to /login" "$CODE $LOC" $(ok isredir /login)
done
req ADM GET /donor/dashboard
rec "Authorization" "Admin blocked from donor dashboard" "302 to /login" "$CODE $LOC" $(ok isredir /login)
req anon POST /blood-requests/1/status -d "status=IN_PROGRESS"
rec "Authorization" "Anonymous cannot change request status" "302 to /login" "$CODE $LOC" $(ok isredir /login)

# ---------------- Admin ----------------
req ADM GET /admin/dashboard
rec "Admin" "Admin dashboard loads with statistics" "HTTP 200, Administrator Console" "HTTP $CODE" $(okand has "Administrator Console")
RQ="patientName=ZZ+Test+Patient+$STAMP&contactNumber=9876543210&bloodGroupId=3&unitsRequired=2&hospitalName=City+Hospital&city=Mumbai&urgency=URGENT"
reqf ADM POST /blood-requests/create -d "$RQ"
rec "Admin" "Create blood request with valid data" "Success message, request in open list" "HTTP $CODE" $(ok has "created successfully")
req pub GET /blood-requests; RID=$(echo "$BODY" | grep -A30 "$PATIENT" | grep -o 'blood-requests/[0-9]*' | head -1 | grep -o '[0-9]*$')
rec "Admin" "New request appears in the public open requests list" "Patient visible in list" "request id=$RID" $(ok test -n "$RID")
req ADM POST /blood-requests/create -d "patientName=X&contactNumber=123&bloodGroupId=3&unitsRequired=2&hospitalName=H&city=C&urgency=URGENT"
rec "Admin" "Request with invalid contact number rejected" "Form re-displayed, nothing created" "HTTP $CODE" $(ok is200)
req ADM POST /blood-requests/create -d "patientName=X&contactNumber=9876543210&bloodGroupId=3&unitsRequired=0&hospitalName=H&city=C&urgency=URGENT"
rec "Admin" "Request with 0 units rejected" "Form re-displayed, nothing created" "HTTP $CODE" $(ok is200)
req ADM POST /blood-requests/create -d "$RQ&requiredBy=2020-01-01T10:00"
rec "Admin" "Request with required-by date in the past rejected" "Error: cannot be in the past" "HTTP $CODE" $(okand has "past")
req pub GET /blood-requests/$RID
rec "Admin" "Request details page" "HTTP 200" "HTTP $CODE" $(ok is200)
reqf ADM POST /blood-requests/$RID/status -d "status=PENDING"
rec "Admin" "Status PENDING to PENDING blocked" "Error: already has the status" "HTTP $CODE" $(ok has "already has the status")
reqf ADM POST /blood-requests/$RID/status -d "status=IN_PROGRESS"
rec "Admin" "Status PENDING to IN_PROGRESS allowed" "Success message" "HTTP $CODE" $(ok has "updated successfully")
reqf ADM POST /blood-requests/$RID/status -d "status=PENDING"
rec "Admin" "Status IN_PROGRESS to PENDING blocked" "Error: Invalid request status transition" "HTTP $CODE" $(ok has "Invalid request status transition")
reqf ADM POST /blood-requests/$RID/status -d "status=FULFILLED"
rec "Admin" "Status IN_PROGRESS to FULFILLED allowed" "Success message" "HTTP $CODE" $(ok has "updated successfully")
reqf ADM POST /blood-requests/$RID/status -d "status=CANCELLED"
rec "Admin" "Fulfilled request cannot be changed" "Error: cannot be changed" "HTTP $CODE" $(ok has "cannot be changed")
req pub GET /blood-requests
rec "Admin" "Fulfilled request removed from open list" "Patient not in open list" "HTTP $CODE" $(okno "$PATIENT")

# locate ids of test donor A (donor id and user id) by probing admin pages
DID=""; for i in $(seq 25 80); do req ADM GET /donations/donor/$i; if [ "$CODE" = 200 ] && has "Test Donor A $STAMP"; then DID=$i; break; fi; done
UID_A=""; for i in $(seq 26 90); do req ADM GET /users/$i; if [ "$CODE" = 200 ] && has "$EMAIL_A"; then UID_A=$i; break; fi; done
rec "Admin" "Locate registered test donor in admin views" "donor id and user id found" "donor=$DID user=$UID_A" $(ok test -n "$DID" -a -n "$UID_A")
reqf ADM POST /donations/create -d "donorId=$DID&donationDate=$D_PAST10&donationLocation=City+Blood+Bank&remarks=450ml+whole+blood"
rec "Admin" "Record donation with valid data" "Success message" "HTTP $CODE" $(ok has "recorded successfully")
reqf ADM POST /donations/create -d "donorId=$DID&donationDate=$D_PAST20&donationLocation=City+Blood+Bank"
rec "Admin" "Donation earlier than previous donation rejected" "Error: earlier than" "HTTP $CODE" $(okand has "earlier than")
req ADM POST /donations/create -d "donorId=$DID&donationDate=$D_FUT5&donationLocation=City+Blood+Bank"
rec "Admin" "Donation dated in the future rejected" "Form re-displayed, nothing saved" "HTTP $CODE" $(ok is200)
req ADM POST /donations/create -d "donorId=999999&donationDate=$D_PAST10&donationLocation=City+Blood+Bank"
rec "Admin" "Donation for non-existent donor rejected" "Error: Donor not found" "HTTP $CODE" $(okand has "not found")
req ADM GET /donations
rec "Admin" "All donations list loads" "HTTP 200" "HTTP $CODE" $(ok is200)
req ADM GET /donations/donor/$DID
rec "Admin" "Donation history of a donor shows new donation" "HTTP 200, location visible" "HTTP $CODE" $(okand has "City Blood Bank")
req ADM GET /availability-history/donor/$DID
rec "Admin" "Admin views donor availability audit trail" "HTTP 200" "HTTP $CODE" $(ok is200)
req ADM GET /users/$UID_A
rec "Admin" "Admin views user account details" "HTTP 200, email visible" "HTTP $CODE" $(okand has "$EMAIL_A")
reqf ADM POST /users/1/status -d "accountStatus=INACTIVE"
rec "Admin" "Admin cannot deactivate own account" "Error message" "HTTP $CODE" $(ok has "cannot deactivate your own")
reqf ADM POST /users/$UID_A/status -d "accountStatus=INACTIVE"
rec "Admin" "Admin deactivates a donor account" "Success message" "HTTP $CODE" $(ok has "updated successfully")
req tmp POST /login -d "email=$EMAIL_A&password=Secret123"
rec "Admin" "Deactivated donor can no longer log in" "Login rejected" "HTTP $CODE" $(okand has "Invalid email or password")
reqf ADM POST /users/$UID_A/status -d "accountStatus=ACTIVE"
rec "Admin" "Admin reactivates the donor account" "Success message" "HTTP $CODE" $(ok has "updated successfully")
req tmp2 POST /login -d "email=$EMAIL_A&password=Secret123"
rec "Admin" "Reactivated donor can log in again" "302 to /donor/dashboard" "$CODE $LOC" $(ok isredir /donor/dashboard)

# ---------------- Donor data privacy ----------------
req DA GET /donations/my-history
rec "Donor" "Donor sees own recorded donation" "Location visible" "HTTP $CODE" $(okand has "City Blood Bank")
DONID=$(echo "$BODY" | grep -o "donations/[0-9][0-9]*" | head -1 | grep -o "[0-9]*$")
req DA GET /donations/$DONID
rec "Donor" "Donor opens own donation certificate" "HTTP 200" "HTTP $CODE" $(ok is200)
req DB GET /donations/$DONID
rec "Donor" "Donor cannot open another donor donation" "302 to /donations/my-history" "$CODE $LOC" $(ok isredir my-history)

# ---------------- Logout ----------------
req DA GET /logout
rec "Session" "Logout redirects to login" "302 to /login" "$CODE $LOC" $(ok isredir /login)
req DA GET /donor/dashboard
rec "Session" "Dashboard blocked after logout" "302 to /login" "$CODE $LOC" $(ok isredir /login)

echo "TOTAL=$N PASS=$PASS FAIL=$FAIL"
echo "TOTAL=$N PASS=$PASS FAIL=$FAIL" > "$(dirname "$0")/summary.txt"
echo "TEST_EMAILS=$EMAIL_A,$EMAIL_B  PATIENT=$PATIENT" > "$(dirname "$0")/last-run-data.txt"
rm -rf "$TMP"
