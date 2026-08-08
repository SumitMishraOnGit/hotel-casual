# Hotel Casual — Complete Research & Flow Document
> **Purpose**: Present this to the recruiter tomorrow. Covers domain research, complete app flow, every screen, every dialog, and your questions.

---

## Part 1: Domain Research

### What This App Is
This is a **temporary staffing / gig economy platform** specifically for the **hospitality & events industry**. Think of it as "Urban Company but for daily-wage hospitality workers."

### Existing Competitors in India
| App | What They Do | Key Insight for Us |
|---|---|---|
| **GigHour** | Hourly-pay platform for hotel/catering roles (waiters, kitchen helpers) | Commission-free, UPI payouts, transparent pay |
| **QES (Quick Event Staff)** | Aadhaar-verified staff for events (catering, security, ushers) | Verification is a big deal — employers trust verified workers |
| **Ziggers** | Temp staff marketplace for hospitality, events, logistics | Covers similar roles — drivers, stewards, chefs |
| **Hotel Jobber** | Dedicated to Indian hotel industry, daily/permanent roles | WhatsApp integration for communication |
| **Instawork** (US) | The gold standard — pre-vetted hospitality & event staff | Auto-scheduling, geofencing for clock-in, ratings system |
| **Digital Labour Chowk** | Digitized version of traditional labor chowk | Simple approach — post need, workers apply |

### What Makes Our App Different?
This is what you should clarify with the recruiter, but likely:
- **Niche focus**: Only 3 roles (Driver, Steward, Chef) — simpler, more focused
- **Auto-fill mechanism**: Job auto-closes when slots are filled (no manual intervention)
- **Push notifications**: Workers get instant alerts for matching jobs
- **Simplicity**: No complex scheduling, no payment integration (initially)

### The Word "Steward" — Clarified
You mentioned "stuart or stewart" — it's **Steward**. Here's what they do:

| Duty | Description |
|---|---|
| **Table Setup** | Arranging tables, chairs, cutlery, glassware for events |
| **Guest Service** | Welcoming guests, escorting to seats, serving food/water |
| **Cleanup** | Clearing tables, cleaning dining areas post-event |
| **Kitchen Support** | Washing dishes, polishing silverware, maintaining hygiene |
| **Event Flow** | Managing crowd flow, ensuring event stays on schedule |

So in this app: **Steward = the person who serves food, manages tables, and assists at venues/events.**

---

## Part 2: User Roles & What Each Can Do

### 👔 Role 1: Recruiter (Hotel/Venue/Event Organizer)
> The person who POSTS job requirements

**What they can do:**
- Sign up / Log in as "Recruiter"
- Create their business profile (hotel name, venue name, logo, address)
- Post new job requirements (need 5 drivers on Sunday, etc.)
- See who has applied/accepted their jobs
- Cancel a job posting
- Mark a job as "completed" after the event
- View history of past postings
- Edit their profile

### 👷 Role 2: Worker (Driver / Steward / Chef)
> The person who ACCEPTS job requirements

**What they can do:**
- Sign up / Log in with role selection (Driver, Steward, or Chef)
- Set up their profile (name, phone, experience, photo)
- Browse available jobs matching their role
- Accept a job
- Withdraw from an accepted job (before event date)
- View their upcoming accepted jobs
- View history of completed jobs
- Toggle their availability (available / not available)
- Receive push notifications for new matching jobs
- Edit their profile

---

## Part 3: Complete Screen Map

### 📱 COMMON SCREENS (Both Roles)

---

#### Screen 1: `Splash Screen`
- **What shows**: App logo + loading animation
- **Logic**: Check if user is logged in → route to correct dashboard
- **Duration**: 2-3 seconds

---

#### Screen 2: `Onboarding / Welcome Screen`
- **What shows**: 2-3 swipeable slides explaining the app
  - Slide 1: "Find temporary staff instantly" (for recruiters)
  - Slide 2: "Get daily wage jobs near you" (for workers)
  - Slide 3: "Auto-matching. Instant notifications."
- **Buttons**: "Get Started" → goes to Login

---

#### Screen 3: `Login Screen`
- **Fields**: Phone Number / Email + Password
- **Buttons**: "Login", "Sign Up", "Forgot Password?"
- **Logic**: After login, check user role → route to correct dashboard

> **🔲 Dialog: Forgot Password**
> - Type: **Bottom Sheet**
> - Content: Email/Phone input field + "Send Reset Link" button
> - Shows success snackbar after sending

---

#### Screen 4: `Sign Up Screen`
- **Fields**: Full Name, Email, Phone Number, Password, Confirm Password
- **Next Step**: Goes to Role Selection Screen

---

#### Screen 5: `Role Selection Screen`
- **What shows**: Big visual cards for each role:
  - 👔 "I'm a Recruiter" — "I need to hire temporary staff"
  - 🚗 "I'm a Driver" — "I drive for events and venues"
  - 🍽️ "I'm a Steward" — "I serve at hotels and events"
  - 👨‍🍳 "I'm a Chef" — "I cook for hotels and events"
- **Logic**: Selection determines entire app experience
- **One-time**: This is set during signup, can't be changed easily

> **🔲 Dialog: Confirm Role**
> - Type: **Alert Dialog**
> - Content: "You selected **Driver**. This determines what jobs you'll see. Continue?"
> - Buttons: "Change" / "Confirm"

---

#### Screen 6: `Profile Setup Screen` (after signup)
- **For Recruiter**: Business Name, Business Type (Hotel/Venue/Event Company), Address, City, Logo upload
- **For Worker**: Profile Photo, City, Years of Experience, Aadhaar/ID number (optional), Short Bio

---

### 📱 RECRUITER SCREENS

---

#### Screen R1: `Recruiter Home / Dashboard`
- **What shows**:
  - Welcome header with business name
  - Stats cards: "Active Jobs: 3", "Total Hired This Month: 12"
  - **Active Job Listings** — cards showing each open posting with:
    - Job title, role needed, date
    - Slot progress bar: "3/5 filled"
    - Status badge: 🟢 Open / 🟡 Filled / 🔵 Completed / 🔴 Cancelled
  - FAB (Floating Action Button): ➕ "Post New Job"
- **Tap on job card** → goes to Job Detail Screen

---

#### Screen R2: `Create Job Screen`
- **Fields**:
  - Job Title (text) — e.g., "Drivers for Wedding Reception"
  - Description (textarea) — details about the job
  - Role Required (dropdown) — Driver / Steward / Chef
  - Number of Workers Needed (number) — e.g., 5
  - Event Date (date picker)
  - Event Time — Start Time & End Time (time picker)
  - Venue Name (text)
  - Venue Address (text)
  - City (dropdown/text)
  - Daily Wage ₹ (number) — e.g., ₹800
- **Button**: "Post Job"

> **🔲 Dialog: Confirm Post**
> - Type: **Alert Dialog**
> - Content: Summary of the job details + "This will notify all matching workers in your city. Post this job?"
> - Buttons: "Edit" / "Post Job"

> **🔲 Dialog: Job Posted Success**
> - Type: **Bottom Sheet / Snackbar**
> - Content: "✅ Job posted successfully! Workers will be notified."
> - Auto-dismiss after 3 seconds

---

#### Screen R3: `Recruiter Job Detail Screen`
- **What shows**:
  - Full job details (title, description, date, time, venue, wage)
  - **Slot Progress**: "3/5 workers accepted" with progress bar
  - **Accepted Workers List**: 
    - Each worker card shows: Photo, Name, Role, Phone
    - Tap on worker → see worker mini-profile
  - Status badge
- **Actions available**:
  - "Edit Job" button (only if status is Open and no one has accepted yet)
  - "Cancel Job" button

> **🔲 Dialog: Cancel Job Confirmation**
> - Type: **Alert Dialog**
> - Content: "Are you sure you want to cancel this job? Workers who have already accepted will be notified."
> - Buttons: "Keep Job" / "Cancel Job"
> - ⚠️ **Edge case**: If workers have already accepted, they must be notified of cancellation

> **🔲 Dialog: Worker Mini-Profile**
> - Type: **Bottom Sheet**
> - Content: Worker's photo, name, role, experience, phone number, rating (if we add ratings)
> - Buttons: "Call Worker" (opens phone dialer), "Close"

---

#### Screen R4: `Recruiter Job History`
- **What shows**: List of all past jobs (completed + cancelled)
- **Filters**: By status (Completed / Cancelled), By date range
- **Each card shows**: Title, date, workers hired count, status
- **Tap** → goes to read-only Job Detail

---

#### Screen R5: `Recruiter Profile / Settings`
- **What shows**: 
  - Business name, logo, address, city
  - "Edit Profile" button
  - Account settings (change password, etc.)
  - "Logout" button

> **🔲 Dialog: Logout Confirmation**
> - Type: **Alert Dialog**
> - Content: "Are you sure you want to logout?"
> - Buttons: "Cancel" / "Logout"

---

### 📱 WORKER SCREENS

---

#### Screen W1: `Worker Home / Job Feed`
- **What shows**:
  - Welcome header: "Hey Sumit 👋" + role badge (Driver)
  - **Availability Toggle**: 🟢 Available / 🔴 Not Available
  - **Available Jobs List** — shows ONLY jobs matching the worker's role
    - Each job card shows:
      - Recruiter/Business name + logo
      - Job title
      - 📅 Date & ⏰ Time
      - 📍 Venue + City
      - 💰 ₹800/day
      - Slots: "3/5 filled" with progress bar
      - "View Details" button
  - **Empty state**: "No jobs available right now. We'll notify you when something comes up! 🔔"
- **Pull to refresh**: Refreshes the job list

> **🔲 Dialog: Availability Toggle**
> - Type: **Snackbar / Toast**
> - Content: "You're now set as Unavailable. You won't receive new job notifications."

---

#### Screen W2: `Worker Job Detail Screen`
- **What shows**:
  - Full job details (title, description, recruiter name, date, time, venue, wage)
  - Map preview of venue location (optional/v2)
  - Slots remaining: "2 spots left!"
  - Recruiter info card (business name, contact)
- **Button**: Big green "Accept This Job" button
- **If already accepted**: Shows "✅ You've accepted this job" + "Withdraw" option

> **🔲 Dialog: Accept Job Confirmation**
> - Type: **Bottom Sheet**
> - Content: Job summary + "By accepting, you commit to being at [Venue] on [Date] at [Time]. Accept?"
> - Buttons: "Cancel" / "Accept Job"
> - On success: Shows ✅ animation + snackbar "Job accepted!"

> **🔲 Dialog: Withdraw from Job**
> - Type: **Alert Dialog**
> - Content: "Are you sure you want to withdraw? This will free up your slot for other workers."
> - Buttons: "Stay" / "Withdraw"
> - ⚠️ **Edge case**: Can only withdraw before event date. On/after event date, withdraw is disabled.

---

#### Screen W3: `My Jobs Screen`
- **Tabs**: 
  - **Upcoming** — Jobs accepted but not yet happened
  - **Completed** — Past jobs
  - **Withdrawn** — Jobs they withdrew from
- **Each card shows**: Job title, date, venue, wage, status
- **Tap** → goes to read-only Job Detail

---

#### Screen W4: `Notifications Screen`
- **What shows**: List of notifications
  - 🔔 "New job available: Taj Hotel needs 3 Drivers on Aug 9th" — [Tap to view]
  - ✅ "You've been confirmed for Wedding at Leela Palace"
  - ❌ "Job cancelled: Airport pickup service on Aug 12th"
  - 📢 "Reminder: Your job at Marriott starts tomorrow at 9 AM"
- **Each notification**: Has read/unread indicator (bold = unread)
- **Tap** → goes to relevant job detail

---

#### Screen W5: `Worker Profile / Settings`
- **What shows**:
  - Profile photo, name, role badge, city
  - Experience & bio
  - Stats: "Jobs completed: 12", "Rating: 4.5⭐"
  - "Edit Profile" button
  - Account settings
  - "Logout"

---

### 📱 NAVIGATION STRUCTURE

#### Recruiter Bottom Navigation (4 tabs):
```
🏠 Home    |    📋 History    |    🔔 Notifications    |    👤 Profile
```

#### Worker Bottom Navigation (4 tabs):
```
🏠 Jobs    |    📋 My Jobs    |    🔔 Notifications    |    👤 Profile
```

---

## Part 4: Complete Flow Diagrams

### Flow 1: Recruiter Posts a Job → Workers Get Notified

```
Recruiter opens app
    → Taps ➕ FAB on Dashboard
    → Fills Create Job form
    → Taps "Post Job"
    → [Dialog: Confirm Post] → Confirms
    → Job saved to Firestore
    → [Cloud Function triggers]
        → Finds all workers where role == job.roleRequired AND city == job.city
        → Sends push notification to each matching worker
        → Creates notification document for each worker
    → [Dialog: Success snackbar]
    → Recruiter sees new job card on dashboard with "0/5 filled"
```

### Flow 2: Worker Accepts a Job

```
Worker receives push notification: "New job available!"
    → Taps notification → Opens Job Detail Screen
    (OR)
    → Opens app → Sees job in feed → Taps "View Details"
    
    → Reads job details
    → Taps "Accept This Job"
    → [Dialog: Confirm Accept] → Confirms
    → [Cloud Function / Firestore Transaction]:
        → Creates application document
        → Increments job.slotsFilled
        → Checks: slotsFilled == slotsTotal?
            → YES: Sets job.status = "filled", stops showing to others
            → NO: Job stays open
    → [Success animation + snackbar]
    → Job appears in "My Jobs > Upcoming"
    → Recruiter gets notification: "Sumit accepted your job"
```

### Flow 3: Job Gets Fully Filled (Auto-Close)

```
Job has slotsTotal = 5

Worker 1 accepts → slotsFilled = 1 → status: "open"
Worker 2 accepts → slotsFilled = 2 → status: "open"
Worker 3 accepts → slotsFilled = 3 → status: "open"
Worker 4 accepts → slotsFilled = 4 → status: "open"
Worker 5 accepts → slotsFilled = 5 → status: "FILLED" ← AUTO-CLOSE

After auto-close:
    → Job disappears from worker feeds
    → New notifications stop
    → Recruiter sees "All 5 slots filled!" on dashboard
    → Recruiter gets notification: "Your job is fully staffed!"
```

### Flow 4: Worker Withdraws → Slot Reopens

```
Worker opens "My Jobs" → "Upcoming" tab
    → Taps on accepted job
    → Taps "Withdraw"
    → [Dialog: Confirm Withdraw] → Confirms
    → [Firestore Transaction]:
        → Removes application
        → Decrements slotsFilled (5 → 4)
        → If status was "filled" → change back to "open"
    → Job reappears in other workers' feeds
    → Recruiter gets notification: "Sumit withdrew from your job. 4/5 slots filled."
    → Other matching workers get re-notified (optional)
```

### Flow 5: Recruiter Cancels a Job

```
Recruiter opens job detail
    → Taps "Cancel Job"
    → [Dialog: Confirm Cancel]
    → If workers have accepted:
        → All accepted workers get notification: "Job cancelled by recruiter"
        → Job removed from their "Upcoming" list
    → Job status → "cancelled"
    → Job moves to History
```

---

## Part 5: Edge Cases & What-Ifs

| # | Edge Case | How to Handle |
|---|---|---|
| 1 | **Race condition**: 2 workers accept the last slot simultaneously | Use Firestore **transaction** — only one succeeds, other gets "Sorry, this job is now full" dialog |
| 2 | **Worker accepts then doesn't show up** | V1: No penalty. V2: Add rating/reliability score (ask recruiter if they want this) |
| 3 | **Recruiter edits job after workers accepted** | Block editing once any worker has accepted. Only allow cancellation. |
| 4 | **Worker tries to accept 2 jobs on same date** | Show warning dialog: "You already have a job on this date. Accept anyway?" (let them decide) |
| 5 | **Event date passes** | Cloud Function runs daily: Jobs past event date → status changes to "completed" automatically |
| 6 | **Worker sets unavailable** | They stop receiving push notifications. Jobs still show in feed but grayed out |
| 7 | **No workers accept** | Recruiter sees "0/5 filled" — no auto-action. They can extend the date or cancel |
| 8 | **Internet connectivity lost** | Show offline banner. Queue actions locally, sync when back online |
| 9 | **Recruiter wants more workers (increase slots)** | Allow editing slotsTotal upward (but not downward below slotsFilled). Re-notify workers. |
| 10 | **Duplicate job posting** | No blocking — recruiter might legitimately need 2 similar jobs |
| 11 | **Worker deletes account** | Withdraw from all accepted jobs, decrement slots, notify recruiters |
| 12 | **Push notifications denied** | Show in-app banner: "Enable notifications to get job alerts instantly!" |

---

## Part 6: Summary — Screen & Dialog Count

### Screens: 16 total

| # | Screen | Role |
|---|---|---|
| 1 | Splash Screen | Common |
| 2 | Onboarding / Welcome | Common |
| 3 | Login | Common |
| 4 | Sign Up | Common |
| 5 | Role Selection | Common |
| 6 | Profile Setup | Common |
| 7 | Recruiter Home / Dashboard | Recruiter |
| 8 | Create Job | Recruiter |
| 9 | Recruiter Job Detail | Recruiter |
| 10 | Recruiter Job History | Recruiter |
| 11 | Recruiter Profile / Settings | Recruiter |
| 12 | Worker Home / Job Feed | Worker |
| 13 | Worker Job Detail | Worker |
| 14 | My Jobs (with tabs) | Worker |
| 15 | Notifications | Common |
| 16 | Worker Profile / Settings | Worker |

### Dialogs / Bottom Sheets / Popups: 11 total

| # | Dialog | Type | Where |
|---|---|---|---|
| 1 | Forgot Password | Bottom Sheet | Login Screen |
| 2 | Confirm Role Selection | Alert Dialog | Role Selection |
| 3 | Confirm Post Job | Alert Dialog | Create Job |
| 4 | Job Posted Success | Snackbar | Create Job |
| 5 | Cancel Job Confirmation | Alert Dialog | Recruiter Job Detail |
| 6 | Worker Mini-Profile | Bottom Sheet | Recruiter Job Detail |
| 7 | Availability Toggle Toast | Snackbar | Worker Home |
| 8 | Accept Job Confirmation | Bottom Sheet | Worker Job Detail |
| 9 | Accept Success | Snackbar + Animation | Worker Job Detail |
| 10 | Withdraw Confirmation | Alert Dialog | Worker Job Detail |
| 11 | Logout Confirmation | Alert Dialog | Profile/Settings |

---

## Part 7: Questions to Ask the Recruiter Tomorrow

### 🔴 Must-Ask (Affects Scope)

1. **"Is this a web app, mobile app, or both?"**
   - You know it's Flutter mobile — but confirm if they also want a web admin panel

2. **"Do you need payment integration?"**
   - i.e., Should workers get paid through the app? (Razorpay/UPI)
   - If yes, this adds 2-3 days to the timeline

3. **"Is there an Admin role?"**
   - Someone who manages all recruiters and workers? Or just the 2 roles?

4. **"Do you want worker verification (Aadhaar/ID)?"**
   - This is common in the industry but adds complexity

5. **"Should jobs be location/city-based?"**
   - i.e., Workers only see jobs in their city? Or all jobs everywhere?

6. **"What happens after the event? Is there a rating system?"**
   - Recruiter rates worker? Worker rates recruiter? Both?

7. **"Do you need chat/messaging between recruiter and worker?"**
   - Or is just showing the phone number enough?

### 🟡 Good to Ask (Shows You've Done Research)

8. **"Are the 3 roles (Driver, Steward, Chef) fixed, or should we allow custom roles?"**
   - Some venues might need "Housekeeping" or "Security" later

9. **"Should workers be able to see past jobs/earnings as a history?"**

10. **"Do you want any analytics? Like 'most in-demand role' or 'jobs filled this month'?"**

11. **"Is there a cancellation policy?"**
    - What happens if a worker accepts and then doesn't show up?

12. **"Do you have any design references or branding guidelines?"**
    - Color scheme, logo, fonts they want

### 🟢 Strategic Questions (Shows You're Thinking Ahead)

13. **"What's the MVP vs future features?"**
    - What must be in v1 vs what can come later?

14. **"Who will be testing this? Will you have real users for beta testing?"**

15. **"Where should this be deployed? Do you have a Google Play / App Store account?"**

---

## Part 8: How to Present This Tomorrow

### Suggested Flow for Your Meeting:

1. **Start with**: "I researched the domain — here's what similar apps look like" (mention GigHour, Instawork, QES)

2. **Show understanding**: "Here's how I understand the app flow" → walk through the user flows

3. **Show the screen count**: "The app will have 16 screens and 11 dialogs — here's each one"

4. **Ask your questions**: Go through the must-ask questions

5. **Give timeline**: "Based on this scope, I estimate 7-10 working days for the MVP"

6. **Show tech stack**: "I'll use Flutter + Firebase — here's why" (cross-platform, real-time, free tier, fast development)

> [!TIP]
> **Pro tip**: Don't show ALL of this. Cherry-pick the flow diagrams and screen list. If you dump everything, it looks like AI did it (😄). Show enough to prove you understand the problem deeply.

---

## Part 9: Features for V2 (Future Scope — Mention Casually)

These are NOT for the test project, but mentioning them shows you're thinking ahead:

- ⭐ **Rating System** — Recruiter rates worker after event, worker rates recruiter
- 📍 **GPS Check-in** — Worker marks attendance at venue via geofencing
- 💬 **In-App Chat** — Between recruiter and accepted worker
- 💳 **Payment Integration** — Pay workers through the app (UPI/Razorpay)
- 📊 **Analytics Dashboard** — Most demanded roles, fill rates, worker reliability
- 🪪 **Aadhaar Verification** — KYC for trusted worker profiles
- 🔄 **Recurring Jobs** — "I need 5 stewards every Saturday"
- 📱 **Web Admin Panel** — For super-admin to manage the platform