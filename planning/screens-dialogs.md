# Hotel Casual — Screen & Dialog Breakdown (v2)

> Reconciles the original screen map with all locked decisions:
> **OTP-only auth · single central admin · roles Driver/Steward/Chef · onboarding cut · standalone role screen cut.**
> Result: **12 screens**, **~11 core dialogs/sheets** (+ system prompts).

---

## What changed vs the original 16-screen map

**Removed (5):**
- Onboarding / Welcome slides → cut for MVP
- Standalone Role Selection screen → merged into Complete Profile
- Recruiter Sign Up (business) → gone (no recruiter self-signup)
- Recruiter Profile / Business Profile Setup → gone (venue details live on each job)
- Password Sign Up fields / Forgot Password → gone (OTP-only)

**Added (1):**
- OTP Verification screen (the code-entry step)

**Renamed:** Recruiter Dashboard/Detail → **Admin** Dashboard/Detail. Recruiter History → folded into Admin Dashboard as an **Active | Past** tab.

---

## A. Auth / Shared Screens (4)

### S1 · Splash
Logo + loader. Reads auth state and routes: no session → Login · role=worker → Job Feed · role=admin → Admin Dashboard.

### S2 · Login / Phone Entry
Country code (+91 default) + phone number field · **"Send OTP"** button.
No password, no email, no "Forgot Password". Single entry point for both new and returning users.

### S3 · OTP Verification
6-digit code input (auto-read on Android where possible) · resend timer (~30s) then **"Resend OTP"** link · **"Verify"** button.
On success: existing user → route by role · new user → Complete Profile.

### S4 · Complete Profile *(new workers only)*
**Role picker** (segmented: Driver / Steward / Chef) — this is where the old standalone role screen lives now.
Fields: Name, City, Years of experience, Profile photo (optional), short bio (optional). **"Finish"** → writes user doc → Job Feed.
> Admin never sees this — the admin account is seeded manually in Firestore with role=admin.

---

## B. Worker Screens (5)

### W1 · Job Feed (Home)
Header: "Hi <name>", role badge, **availability toggle**. Real-time list of **open jobs matching role + city**.
Card: venue/business name, title, date & time, wage, slots "3/5" progress, "View Details". Empty state + pull-to-refresh.

### W2 · Job Detail
Full job info, slots remaining, venue info. Big **"Accept This Job"** button — or if already accepted: "✅ Accepted" + **Withdraw**.

### W3 · My Jobs *(tabs: Upcoming | Completed)*
Accepted-but-upcoming jobs, and past completed ones. Tap → read-only detail.
*(Withdrawn tab optional — safe to drop for MVP.)*

### W4 · Notifications
List of alerts: new matching job, confirmed, job cancelled, reminder. Read/unread state. Tap → relevant job detail.

### W5 · Profile / Settings
Photo, name, role badge, city, experience, bio. Edit Profile · Logout. *(Completed-jobs count optional for v1.)*

---

## C. Admin Screens (3)

### A1 · Admin Dashboard (hub)
Header + optional stats (active jobs / hired this month). **Active | Past** tabs (replaces the old separate History screen).
Job cards with slot progress + status badge (🟢 Open / 🟡 Filled / 🔵 Completed / 🔴 Cancelled).
**FAB: + Post New Job**. App-bar overflow menu: **Logout**.

### A2 · Create Job
Fields: Title, Description, Role required (Driver/Steward/Chef), Workers needed, Event date, Start/End time, Venue name, Venue address, City, Daily wage ₹. **"Post Job"**.

### A3 · Admin Job Detail
Full job + slot progress + **accepted-workers list** (photo, name, phone, **Call** button).
**Edit** (only while status=Open and nobody has accepted) · **Cancel Job**.

---

## D. Navigation

- **Worker — bottom nav (4 tabs):** 🏠 Jobs · 📋 My Jobs · 🔔 Notifications · 👤 Profile
- **Admin — no bottom nav:** single Dashboard hub (Active/Past tabs + FAB + app-bar menu). Only 3 screens, so a bottom bar is overkill.
  > Admin sees accept/withdraw activity **live** on the dashboard and job detail — no separate admin notifications screen in v1.

---

## E. Dialogs / Bottom Sheets / Snackbars

| # | Element | Type | Where | Status |
|---|---|---|---|---|
| 1 | Invalid / expired OTP | Snackbar | OTP Verification | 🆕 new |
| 2 | Confirm Post Job (summary + "notify matching workers?") | Alert | Create Job | kept |
| 3 | Job Posted Success | Snackbar | Create Job | kept |
| 4 | Cancel Job Confirmation ("accepted workers will be notified") | Alert | Admin Job Detail | kept |
| 5 | Worker Mini-Profile (photo, exp, phone, Call) | Bottom Sheet | Admin Job Detail | kept |
| 6 | Availability toggle feedback | Snackbar | Job Feed | kept |
| 7 | Accept Job Confirmation (commitment summary) | Bottom Sheet | Worker Job Detail | kept |
| 8 | Accept Success (✅ animation) | Snackbar | Worker Job Detail | kept |
| 9 | **Job Just Filled** (last slot taken by someone else) | Alert | Worker Job Detail | 🆕 **new — critical** |
| 10 | Withdraw Confirmation | Alert | Worker Job Detail | kept |
| 11 | Logout Confirmation | Alert | Profile + Admin menu | kept |

**Plus system prompts (not custom UI):** notification permission (after login), photo/camera permission (Complete Profile / edit).
**Inline, not a dialog:** the resend-OTP countdown link on S3.

**Removed dialogs:** Forgot Password (no passwords).
**Optional / v2:**
- Confirm Role (a light "You're registering as Driver — this sets the jobs you'll see" alert on Complete Profile submit). Nice-to-have since role is semi-permanent.
- "You already have a job on that date" double-booking warning (edge case) — defer unless quick.

> **Why #9 matters:** it's the visible half of the Firestore accept-transaction. When two workers tap Accept on the last slot at the same moment, the transaction lets one through and the other's write fails — that failure must surface as this dialog, not a silent error or a false "accepted". Build the dialog the same day you build the transaction (Day 3).

---

## F. Final Counts

| Group | Screens |
|---|---|
| Auth / Shared | 4 (Splash, Login, OTP, Complete Profile) |
| Worker | 5 |
| Admin | 3 |
| **Total** | **12** |

Dialogs/sheets/snackbars: **11 core** (9 kept + 2 new) + system permission prompts.

---

## G. Dependency flag

**City-based filtering (still open with client)** directly drives the W1 feed query
(`jobs where role == myRole && city == myCity && status == "open"`). If the client says
"all cities / one city only," the `city` filter and the City field on Complete Profile + Create Job
change. Settle this before Day 3.