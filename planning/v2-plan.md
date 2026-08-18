# Hotel Casual — v2 Change Plan (6-Day Sprint)

> **Context:** v1 is already built and working. This is a **change-set on top of v1** — not a rebuild.
> Only the new changes below get built. Everything not listed here stays as-is.
> Stack unchanged: Flutter + GetX + Firebase (Firestore + Auth + Storage) + Cloud Functions.

---

## 0. What's Changing (the whole scope, one glance)

| # | Change | Type |
|---|---|---|
| 1 | **APK not installing on Android ≤11 (Realme C3)** | Blocker — build/signing fix |
| 2 | **Auth → Phone + OTP** (was phone/password) | Auth rework |
| 3 | **Three-tier roles:** Super Admin / Hotel / Worker | Architecture |
| 4 | **New signup flow:** OTP → "Work or Hire?" → branch | New screens |
| 5 | **Admin removed from signup** | Cleanup |
| 6 | **Roles renamed:** Chef→**Cook Banquet**, Steward→**Casual Banquet**, Driver→Driver | Rename/migrate |
| 7 | **Worker KYC at signup (mandatory):** Driver→License, others→Aadhaar; number **+** photo of doc | New feature |
| 8 | **Profile photo mandatory at signup**, editable later | New feature |
| 9 | **Hotel onboarding:** GST number (validated) + GST certificate upload | New feature |
| 10 | **City editable in worker profile** (feed follows updated city) | Change |
| 11 | **Experience field → optional** | Small change |

---

## 1. New Role Model (the biggest change)

**Before (v1):** one central admin posts all jobs.
**Now:** three tiers.

| Tier | How they log in | What they can do |
|---|---|---|
| **Super Admin** | Created from the **backend** (Firebase console); one existing admin is promoted to Super Admin | **Full access.** Sees ALL hotels, ALL jobs, ALL workers. **Can also post jobs.** Can view every GST + KYC doc. |
| **Hotel** | Phone + OTP (normal signup, with GST) | Acts as admin **but scoped to itself** — sees/manages **only its own** jobs & applicants. **Posts jobs directly (no approval).** |
| **Worker** | Phone + OTP | Same as v1 — browse feed, accept, withdraw, My Jobs. |

**Data model deltas (don't rebuild, just extend):**
```
users/{uid}
  + userType : "worker" | "hotel" | "superadmin"     // NEW discriminator
  role       : "cook_banquet" | "casual_banquet" | "driver"   // RENAMED values (worker only)
  // worker KYC:
  + photoUrl (mandatory), + docType ("license"|"aadhaar"),
  + docNumber, + docImageUrl
  experience → now OPTIONAL
  // hotel fields:
  + gstNumber, + gstCertUrl, + hotelName, + photoUrl

jobs/{jobId}
  adminId → + hotelId (owner of the job; superadmin-posted jobs flagged too)
```
> **Migration:** no complex migration needed — existing **users can just be deleted** and re-created under the new flow. Only add `userType`/`hotelId` going forward and remap role values in code/seed.

---

## 2. New Signup Flow (screens to add)

```
[Phone + OTP screen]  ← replaces phone/password login
        │
        ▼
[Choose: "I want to WORK"  |  "I want to HIRE"]
        │                          │
   WORKER path                 HOTEL path
        │                          │
 [Role select:               [Hotel details:
  Cook Banquet /              GST number (validated)
  Casual Banquet /            GST certificate upload
  Driver]                     profile photo]
        │
 [KYC upload (mandatory):
  Driver  → License no. + license photo
  others  → Aadhaar no. + Aadhaar photo
  + profile photo (mandatory)
  experience (optional)]
```
- **Admin is gone from signup** entirely.
- Auth provider switches to **Firebase Phone Auth (OTP)** — remove password fields; add SHA-1/256; enable Phone provider.

---

## 3. KYC & Documents

- Collected **at signup, mandatory** — worker cannot finish signup without them.
- Store **both**: the **number** (text, normal validation) **and** the **document photo** (Firebase Storage).
- **Auto-accepted** on upload (no verification step for now).
- **Hotel** and **Super Admin** can **view** applicant docs inside the applicants list.
- Profile photo: **mandatory at signup, changeable from Profile** later.
- Aadhaar/license kept as plain images for MVP (simple, per decision) — privacy hardening deferred.

---

## 4. Hotel Onboarding & GST

- GST number → **normal input validation** (format check only, no API verify).
- GST certificate → upload to Storage, viewable by Super Admin.
- Hotel signs up like a worker (phone + OTP) but with the GST fields; then lands on its **own** dashboard (v1 admin dashboard reused, scoped to `hotelId`).

---

## 5. Small Changes

- **City** field made **editable in worker Profile**; feed query keeps filtering by the worker's current city, so editing city updates the feed.
- **Experience** → optional (remove required validation, keep the field).
- **Role rename** applied everywhere: enums, DB values, role pills/badges, feed filter chips, seed data.

---

## 6. The 6-Day Plan

### Day 1 — APK install fix + Auth → OTP + model migration *(front-load the risk)*
- Fix the install blocker (see **Appendix A**), rebuild signed universal APK, **re-test on the Realme C3** first thing.
- Switch auth to **Phone + OTP** (Firebase Phone Auth, SHA added, passwords removed).
- Extend data model: add `userType`, `hotelId`; remap role values. Just **delete existing users** and reseed — no migration overhead.
- ✅ **Done when:** APK installs on the Realme C3, and OTP login works end-to-end.

### Day 2 — New signup flow + role rename + admin-removed
- Build **OTP → "Work / Hire" chooser → branch** screens.
- Rename roles across enums, DB, pills, filter chips, seed (**Cook Banquet / Casual Banquet / Driver**).
- Remove admin from signup. Make experience optional.
- ✅ **Done when:** a new user picks worker/hotel path and new role names show everywhere.

### Day 3 — Worker onboarding: KYC + photo + editable city
- Worker profile-setup: role → **KYC (number + doc photo, mandatory)** + **profile photo (mandatory)**.
- City **editable in Profile**; confirm feed follows the updated city.
- ✅ **Done when:** signup can't complete without photo + required doc; changing city updates the feed.

### Day 4 — Hotel onboarding + hotel-as-admin dashboard
- Hotel path: **GST number (validated) + GST cert upload + photo** → hotel user doc.
- Reuse v1 admin dashboard **scoped to `hotelId`**: hotel sees only its own jobs; Create Job writes `hotelId`; hotel Job Detail shows applicants + their KYC docs (view-only).
- ✅ **Done when:** a hotel signs up with GST, posts a job, sees only its own jobs + applicants.

### Day 5 — Super Admin (full access) + applicant doc viewing
- Seed **Super Admin**: sees ALL hotels, ALL jobs, ALL workers; **can also post jobs**; can view all GST + KYC docs.
- Applicants list (hotel + super admin): worker mini-profile + **doc view**. Auto-accept retained.
- ✅ **Done when:** super admin sees everything across hotels and can post; both hotel & admin can view applicant docs.

### Day 6 — Migrate to client Firebase, test, release build
- Client Firebase project: new `google-services.json`, **SHA-1/256**, App Check.
- Full E2E: OTP login (worker + hotel), KYC gating, city filter, accept race (2 devices), super-admin visibility.
- **Re-verify the signed universal APK installs on the Realme C3 + one Android 11 device.**
- ✅ **Done when:** signed release APK from the client project installs on a low-end device and the full flow passes.

### Day 7 — Buffer
Overflow, migration hiccups, demo prep. No new features.

---

## Appendix A — APK "not installed" on Realme C3 (Android ≤11)

**Symptom:** WhatsApp'd APK → tap install → progress bar → **"App not installed."** Permission was fine (it reached the bar), so this is the **package itself**, not the device settings.

**Most likely cause (in order):**
1. **Missing v1 (JAR) signature.** Realme/Oppo/Vivo (ColorOS) installers on Android 10–11 are picky and often reject APKs signed only with v2/v3. **Fix:** in the release `signingConfig`, enable **v1 + v2 (+v3)** signing and sign with a **proper release keystore** (not debug):
   ```kotlin
   signingConfigs {
       create("release") {
           // ...keystore...
           enableV1Signing = true
           enableV2Signing = true
           enableV3Signing = true
       }
   }
   ```
2. **Bleeding-edge toolchain.** Your **AGP 9.0.1 + Gradle 9.1.0 + Kotlin 2.3.20** are pre-stable and can emit output old installers dislike. If the signing fix doesn't resolve it, **pin to a stable line** (e.g. AGP 8.7.x / Gradle 8.9) and rebuild.
3. **Not a universal APK.** For WhatsApp sideloading, build the **fat** APK: `flutter build apk --release` (avoid `--split-per-abi`, which makes ABI-specific APKs).
4. **minSdk sanity.** Effective `minSdk` is ~21 (fine for the C3, API 29). Set it **explicitly** in `build.gradle.kts` instead of relying on the dynamic Flutter value, and confirm no plugin silently raised it.

**Diagnose the exact reason** (do this first — 2 minutes):
```
adb install app-release.apk
```
The error tells you which fix applies:
- `INSTALL_PARSE_FAILED_NO_CERTIFICATES` / signature error → **cause #1 (signing)**
- `INSTALL_FAILED_OLDER_SDK` → **minSdk (#4)**
- parse/verification failure → **cause #2 (toolchain)**

Also re-download the WhatsApp file and confirm it's a clean `.apk` (WhatsApp occasionally truncates/renames large files).

---

## Decisions (all confirmed — plan is locked)

1. **Super Admin** — created from the **backend** (Firebase console), not through signup. One existing admin account is promoted to Super Admin.
2. **Existing data** — no migration worry; **just delete users** and re-create under the new flow.
3. **Aadhaar/license storage** — plain images, kept simple for MVP. No masking/consent for now.