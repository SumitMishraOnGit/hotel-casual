# Hotel Casual — Build Plan (MVP)

> Flutter + GetX + Firebase. Solo build, 6 days + 1 buffer day.
> Goal: a working core loop — admin posts a job, workers get notified, workers accept, slots fill and auto-close.

---

## 0. Stack Decision (locked)

| Layer | Choice | Why |
|---|---|---|
| Frontend | **Flutter + GetX** | Bindings/controllers/views, fast to structure |
| Backend | **Firebase** | No server to build or deploy — biggest time saver |
| Auth | **Phone & Password Auth** | See auth notes below |
| Database | **Cloud Firestore** | Real-time listeners = live slot counts for free |
| Notifications | **In-app (Firestore) for v1**, FCM push if ahead of schedule | Push needs extra setup; don't let it block the MVP |
| File/photo upload | **Firebase Storage** | Profile photos, venue logo (optional) |

**Auth strategy (role-based):**
- **Workers (Driver / Steward / Chef):** Strictly **Phone & Password** — client changed from OTP to simplify.
- **Central Admin:** **Email/Password** — Admin needs reliable access.

**Auth notes:**
- OTP flow is deferred. Use simple Phone/Password login for MVP.
- We will build the UI for Phone/Password login today.

---

## 1.5. Visual Design System & UI Specifications (Locked)

### 🎨 Color System (60 / 30 / 10 Rule)

| Token | Hex Code | Role / Usage |
|---|---|---|
| **60% Background** | `#F6F7F9` | Main screen background |
| **Card Surface** | `#FFFFFF` | Job cards, form containers, elevated sheets |
| **30% Primary** | `#0F766E` | Deep Teal — buttons, top headers, active navigation icons |
| **Teal Dark** | `#0B4F49` | Header banner background, curved top headers |
| **10% Accent** | `#F59E0B` | Amber/Gold — pay rate text (`₹1,200/shift`), driver role pill |
| **Success** | `#16A34A` | Green — `🟢 Available` toggle badge, success dialogs |
| **Danger / Urgent**| `#DC2626` | Red — `1 slot left` warning text, withdraw/cancel actions |
| **Text Ink** | `#14181F` | Primary text, titles, headings |

### 🔤 Typography & Brand Copy

- **Heading Font**: `Plus Jakarta Sans` (Bold, clean headings & app titles)
- **Body & Labels Font**: `Inter` (Legible for body text, numbers, pay rates)
- **Brand Tagline**: *"Kaam milega, aasaan tarike se"*
- **Auth Screen Copy**: *"Log in with your phone and password"*
- **Worker Target Copy**: *"Driver · Steward · Chef ke liye"*
- **Worker Greeting**: *"Namaste 👋 [Name]"*

### 📱 Key Component Wireframe Specs

1. **S2 Phone Login Screen Layout:**
   - **Header Banner**: Deep Teal (`#0B4F49` / `#0F766E`) curved bottom box with briefcase logo + `Hotel Casual` title + Hinglish tagline.
   - **Login Form Card**: Clean white container overlaying bottom of header banner.
   - **Phone Input**: Fixed `+91` prefix with phone number placeholder.
   - **Password Input**: Secure text field for password.
   - **Primary Action**: Full-width rounded teal button: **Log In**.

2. **W1 Job Feed Screen Layout:**
   - **Top Header**: Worker greeting (`Namaste 👋 Rajendra`) + `🟢 Available` status badge.
   - **Filter Bar**: Horizontal scroll chips: `All jobs` (active teal pill), `Driver`, `Delhi`.
   - **Job Card Component**:
     - Header: Job title (e.g., *Banquet Steward*) + Role badge (*Steward* / *Driver*).
     - Location: 📍 *Taj Palace, Delhi*.
     - Pay Rate: Highlighted in Amber (`₹1,200 /shift`).
     - Live Slots: `👥 3/8 filled` (normal) or `🚨 1 slot left` (red bold urgency text).
   - **Bottom Navigation Bar**: 4 destinations (`Feed`, `My Jobs`, `Alerts`, `Profile`).

---

## 2. Folder Structure (GetX, feature-first)

```
lib/
├── main.dart
└── app/
    ├── core/
    │   ├── theme/          → app_colors, text_styles, app_theme
    │   ├── constants/      → strings, enums (Role, JobStatus), db_keys
    │   ├── utils/          → validators, date_helpers
    │   ├── services/       → firebase_service, notification_service (app-level singletons)
    │   └── widgets/        → JobCard, PrimaryButton, EmptyState, Loader
    ├── data/
    │   ├── models/         → user_model, job_model, application_model, notification_model
    │   ├── providers/      → firestore_provider, auth_provider (raw Firebase calls)
    │   └── repositories/   → auth_repo, job_repo (keep THIN; skip if controllers can call providers directly)
    ├── routes/
    │   ├── app_routes.dart → route-name constants
    │   └── app_pages.dart  → GetPage list + bindings
    └── modules/
        ├── splash/         → bindings/ controllers/ views/
        ├── auth/           → login, signup+role, profile_setup
        ├── worker_home/    → job feed
        ├── job_detail/
        ├── my_jobs/
        ├── notifications/
        ├── profile/
        └── admin/          → admin_dashboard, create_job, admin_job_detail
```

Each `modules/<feature>/` folder has the three GetX subfolders: `bindings/`, `controllers/`, `views/`.

> Don't over-build the repository layer. Firestore is already an abstraction. Start with providers; add a repository only when a controller needs two data sources.

---

## 3. Trimmed Screen List (~11)

**Auth (shared):** Splash · Login (Phone/Password) · Signup + Role (one flow) · Profile Setup (worker only)
**Worker:** Job Feed · Job Detail · My Jobs (tabbed: Upcoming / Completed) · Notifications · Profile
**Admin:** Dashboard (jobs + FAB) · Create Job · Job Detail (accepted workers)

**Cut for MVP:** Onboarding slides (easiest to add later), standalone role-selection screen (merged into signup).

---

## 4. Firestore Data Model (compact)

```
users/{uid}
  name, phone, role (admin|driver|steward|chef),
  city, experience, photoUrl, available (bool), fcmToken, createdAt

jobs/{jobId}
  adminId, title, description, role,
  venueName, venueAddress, city,
  date, startTime, endTime, wage,
  slotsTotal, slotsFilled, status (open|filled|completed|cancelled), createdAt

applications/{appId}          // or a subcollection under jobs/
  jobId, workerId, status (accepted|withdrawn), createdAt

notifications/{notifId}
  userId, type, title, body, jobId, read (bool), createdAt
```

**The one hard part — accepting a job:** wrap it in a Firestore **transaction**:
read `slotsFilled` → if `< slotsTotal`, create the application + increment the counter → if it now equals `slotsTotal`, set `status = "filled"`. This is what stops two workers grabbing the last slot. Build it carefully; it's the heart of the app.

Feed query for a worker: `jobs where role == myRole && city == myCity && status == "open"` — real-time listener.

---

## 5. Build Order (why this sequence)

Auth is the gate → admin creates the data → worker consumes it. Build in that order so each phase can test the next.

---

## 6. The 6-Day Plan (+ Day 7 buffer)

### Day 1 — Setup + Firebase + Phone/Password login *(the risky day — front-loaded on purpose)*
- Create Flutter project, GetX folder structure, theme, routes skeleton.
- Create Firebase project, connect FlutterFire, enable **Authentication** + **Firestore**.
- Get Phone/Password login working end-to-end: enter number + password → verified session.
- Splash screen with role-based routing stub.
- ✅ **Done when:** you can log in via phone/password and land on a (placeholder) dashboard.

### Day 2 — Auth complete + data model + admin posts a job
- Signup + role selection flow → write `user` doc with role.
- Worker profile setup screen.
- Lock the Firestore collections (section 4).
- Admin: Create Job form → writes a `job` doc.
- Admin dashboard: real-time list of the admin's own jobs.
- ✅ **Done when:** an admin can post a job and watch it appear on the dashboard.

### Day 3 — Worker core loop (the most important day)
- Worker job feed: filtered by role + city, real-time, with empty state.
- Job detail screen.
- **Accept job** with the Firestore transaction (slot increment + auto-close at full).
- ✅ **Done when:** a worker sees a posted job, accepts it, and the slot count updates live for everyone.

### Day 4 — Both-sides loop complete
- My Jobs tabs (Upcoming / Completed).
- Withdraw from a job (reverse transaction: decrement, reopen if it was full).
- Admin Job Detail: list of accepted workers + "Call" button (phone dialer).
- Cancel job (admin) → notify accepted workers.
- ✅ **Done when:** accept / withdraw / cancel all work correctly on both sides.

### Day 5 — Notifications + profiles + availability
- In-app notifications: write `notification` docs on key events; bell screen reads them.
- (If ahead: wire up FCM push. If not: skip — in-app is enough for v1.)
- Worker + admin profile/settings: view, edit, logout.
- Worker availability toggle.
- Loaders + empty states everywhere.
- **TODO**: Clear system notification tray on logout & suppress historical notification popups on login (`NotificationService`).
- ✅ **Done when:** notifications show up and profiles are editable.

### Day 6 — Polish, edge cases, test, build
- Test the slot race condition with two devices/accounts.
- Form validation, error handling, offline banner.
- UI cleanup pass — consistent spacing, colors, buttons.
- Full end-to-end test on a real device.
- Build a debug/release APK to demo.
- ✅ **Done when:** you have a demo-ready build that survives the full flow.

### Day 7 — Buffer
Overflow from any slipped day, unexpected Firebase issues, FCM if not done, demo prep. Do **not** plan new features here — protect it as slack.

---

## 7. Risks & Where Time Actually Goes

| Risk | Mitigation |
|---|---|
| Auth setup eats Day 1 | Focus on simple phone/password first |
| SHA fingerprint / phone-auth config | Do it first thing Day 1, not mid-build |
| The accept transaction | Give it real focus on Day 3; test with 2 accounts |
| Firebase learning curve | It's front-loaded days 1–3; days 4–6 are familiar UI work |
| Scope creep | Everything in "Cut / v2" stays cut until the core loop is solid |

---

## 8. Explicitly Deferred (v2 — do NOT build now)

Ratings · GPS check-in · in-app chat · payment/UPI · analytics dashboard · Aadhaar KYC · recurring jobs · web admin panel · onboarding slides · real FCM push (if it doesn't fit Day 5).

---

## 9. Open Questions / Status

1. ✅ **One central admin confirmed**: Central admin account manages postings; venue details entered per job.
2. ✅ **Auth confirmed**: Workers = Phone + Password. Central Admin = Email/Password.
3. ⏳ **City-based filtering**: Awaiting client input.
4. ✅ **Role set confirmed**: Driver, Steward, and Chef are the 3 fixed roles for v1.