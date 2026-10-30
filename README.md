# Hotel Casual

A Flutter mobile app that connects **hotels** with **casual banquet workers** — built on Firebase Realtime Database and Firebase Phone Auth.

---

## User Types

| Type | Description |
|------|-------------|
| **Worker** | Casual banquet staff, cook banquet, or driver |
| **Hotel** | Posts jobs and manages applicants |
| **Super Admin** | Platform-wide visibility over all hotels, workers, and jobs |

---

## Features

### 🔐 Authentication
- Phone number + OTP via Firebase Phone Auth (Indian `+91` numbers)
- New users go through a registration flow; existing users are auto-routed based on their role

---

### 📝 Onboarding / Registration
- **Worker:** selects role (Casual Banquet / Cook Banquet / Driver), enters name, city, years of experience, uploads a KYC document (Aadhaar or License) with photo
- **Hotel:** enters hotel name, GST number, uploads GST certificate, city

---

### 🏢 Hotel (Admin)
- Create jobs with venue name, address, city, date, wage, contact person, and multiple role/title slots (e.g. 3 casual banquet + 2 cooks)
- View own job listings — searchable by venue / city / job ID, filterable by role
- Cancel a job
- View and manage applicants per job slot
- In-app notifications when a worker applies
- Profile management

---

### 👷 Worker
- Browse available job listings
- Apply to jobs per role/title slot (if slots are available and not already applied)
- My Jobs — view jobs applied to
- In-app notifications (e.g. application accepted)
- View and edit own profile

---

### 🛡️ Super Admin
- View all jobs across the platform — filterable by role and status (Open / Cancelled / Past)
- View all hotels — searchable by name, city, GST number
- View all workers — searchable by name, phone, city; filterable by role
- Can post jobs not tied to any specific hotel

---

### 📢 Notifications
- Real-time, stored in Firebase RTDB per user
- Notification types: `new_applicant`, `application_accepted`, `job_cancelled`, `new_job`
- Supports mark-as-read and mark-all-as-read
- FCM token stored per user; cleared on logout

---

### 🏷️ Jobs
- Human-readable job ID in `HC-XXXX` format
- Each job tracks total slots and filled slots per role entry
- Job statuses: `open`, `cancelled`, and auto-detected `past` (based on date)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | GetX |
| Backend | Firebase Realtime Database |
| Authentication | Firebase Phone Auth |
| Push Notifications | Firebase Cloud Messaging (FCM) |

---

## Project Structure

```
app/lib/app/
├── core/
│   ├── services/       # AuthService, JobService, NotificationService
│   ├── theme/
│   └── widgets/
├── data/
│   └── models/         # JobModel, UserModel, JobTitleEntry, NotificationModel
├── modules/
│   ├── auth/           # Login, Register, Role Select, KYC, Hotel Onboarding
│   ├── admin/          # Hotel dashboard, Create Job
│   ├── worker_home/    # Worker job feed
│   ├── applicants/     # Applicant list per job
│   ├── my_jobs/        # Worker's applied jobs
│   ├── notifications/  # Notification centre
│   └── profile/        # User profile
└── routes/
```
