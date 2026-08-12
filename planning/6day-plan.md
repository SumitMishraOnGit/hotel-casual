# Hotel Casual — 6-Day Execution Plan + Client Checklist

> Starting point: Flutter installed on office laptop, **zero code written**, no Firebase/Play accounts yet.
> Target: working core loop demo-ready in 6 days (+ Day 7 buffer if available).

---

## Part 0 — Do this BEFORE Day 1 (no code, but time-sensitive)

1. **Send the client the checklist in Part 2 today.** The account setup (Play verification, Blaze billing) has lead time and can block your release. Trigger it now so it runs in parallel while you build.
2. **Create your OWN temporary Firebase project** to develop against. You'll migrate to the client's project on Day 6. This means client delays don't block your coding.
3. **You are not blocked by client accounts to start.** Build using direct login / simple auth on Firebase (no OTP / SMS verification required for v1).

> **Reality check:** Building 12 screens from scratch in 6 days solo is aggressive. It's achievable **only** with ruthless scope discipline: build the happy path first, skip every nice-to-have, and do not polish anything until Day 6. Never cut the accept-loop.

---

## Part 1 — The 6-Day Plan (mapped to the 12 screens)

### Day 1 — Skeleton + Firebase + Auth working (Direct Login)
- GetX folder structure, theme/colors, routes, `main.dart` (GetMaterialApp).
- Connect Firebase (your temp project): FlutterFire configure, `google-services.json`, enable **Auth + Firestore**.
- Screens: **S1 Splash** (routing stub) · **S2 Login/Phone** (direct authentication, no OTP screen).
- ✅ Done when: login → lands on a placeholder home / dashboard.

### Day 2 — Profile + user doc + Admin posting
- **S4 Complete Profile** (role picker Driver/Steward/Chef) → writes `users` doc.
- Lock the `users` + `jobs` data models.
- **A1 Admin Dashboard** (real-time list, empty at first).
- **A2 Create Job** → writes `jobs` doc. Dialogs: Confirm Post, Posted Success.
- ✅ Done when: log in as seeded admin → post a job → it appears on the dashboard.

### Day 3 — Worker core loop *(the most important day)*
- **W1 Job Feed**: role + city filter, real-time, empty state, availability toggle.
- **W2 Job Detail**.
- **Accept transaction** + **"Job Just Filled" dialog (#9)** + Accept confirm/success.
- ✅ Done when: worker sees the job, accepts, slot count updates live for everyone; two accounts racing the last slot → one gets the "just filled" dialog, not a silent error.

### Day 4 — Close the loop on both sides
- **W3 My Jobs** (tabs: Upcoming / Completed).
- **Withdraw** (reverse transaction: decrement, reopen if it was full).
- **A3 Admin Job Detail**: accepted-workers list + Call button + worker mini-profile sheet.
- **Cancel Job** (admin) → notify accepted workers.
- ✅ Done when: accept / withdraw / cancel all behave correctly on both sides.

### Day 5 — Notifications + profile + polish
- **W4 Notifications** (in-app): write notif docs on key events; bell list, read/unread.
- **W5 Worker Profile/Settings**: view, edit, logout, availability.
- Admin logout (app-bar menu). Loaders, empty states, form validation everywhere.
- **TODO**: Clear system notification tray on logout & suppress historical notification popups on login (`NotificationService`).
- ✅ Done when: notifications show up, profiles editable, logout works.

### Day 6 — Migrate to client Firebase, test, build
- Switch to the **client's Firebase project**: new `google-services.json`, add **SHA-1/SHA-256**, turn on **App Check**.
- Direct login & end-to-end flow test.
- Race-condition + edge-case testing, offline banner, bugfixes.
- UI cleanup pass. Build **release APK**.
- ✅ Done when: login & main flow works on a real phone via the client's project; demo-ready APK exists.

### Day 7 — Buffer (if you have it)
Overflow, FCM push if time allows, demo prep. Do **not** add new features here.

> If the client's Firebase isn't ready by Day 6, keep demoing on your own project and migrate whenever they hand it over.

---

## Part 2 — Client Checklist (ask all of this at once)

### A. Accounts & access (they set up or grant you)
1. **Firebase project** — best if the client creates it under **their** Google account and adds you as **Owner/Editor**, so data + billing stay with them.
2. **Blaze plan billing** — *(Optional for v1 as OTP SMS is disabled)* client attaches credit/debit card to Google Cloud billing if using paid services. Set a **budget alert (~₹2,000/mo)**.
3. **Google Play Console account** — client's own, **$25 one-time**. **Identity verification can take several days — ask them to start it immediately.**
4. **(If iOS is in scope)** Apple Developer account — **$99/year** — under the client.

### B. Assets & branding
5. Final **app name**.
6. **Logo** + app icon source (ideally 1024×1024 PNG).
7. **Brand colours** (or explicit permission for you to choose).
8. Splash imagery / any graphics.

### C. Content & legal
9. **Privacy policy URL** — **required** by the Play Store and because the app collects phone numbers + personal data. Client provides it or approves one you draft. This blocks publishing if missing.
10. Terms of use (optional but good to have).

### D. Data to seed
11. **Admin phone number(s)** — central admin account tied to phone/identifier to grant admin role.
12. **City list** (if city-based) and any **venue list** to preload.
13. Any default wage ranges.

### E. Decisions still open (need answers)
14. **City filtering** — all cities, one city, or per-city feed? *(changes the feed query + City fields)*
15. **Platform** — Android only, or iOS too?
16. **Language** — English only, or Hindi / bilingual? *(workers may prefer Hindi; localization adds time)*
17. **Who marks a job "completed"** — admin manually, or auto after the event date?
18. **Payment** — confirm out of scope for v1 (wage shown only, paid offline)?
19. **Aadhaar/ID verification** — out of scope v1?
20. **Ratings** — out of scope v1?
21. **Web admin panel** — out of scope v1?
22. **Handover** — where does the code repo live? Do they want source + keystore at the end?
23. **"Done" for the deadline** — a working APK installed on a phone, or actually published on Play?

---

## Part 3 — Gotchas to keep in mind

- **Play Console verification lead time** — start it client-side on day one or it blocks release.
- **Privacy policy blocks Play publishing** — sort it early, not at the end.
- **Firebase migration** (your project → client's) = new `google-services.json` + re-add SHA + re-seed admin. Do it **once**, on Day 6, not repeatedly.
- **Release keystore** — whoever holds it controls future updates. Losing it means you can never update the published app. Decide now who keeps it and back it up.
- **Admin account** — ensure a stable admin phone number/identifier is used for admin seeding.
- **iOS (if in scope)** adds an Apple Developer account + APNs setup for push — real extra time, factor it in.