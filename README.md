# ALULink

A Flutter + Firebase marketplace connecting ALU students to verified ALU-run startups for real internships and gigs.

## The problem

ALU's campus has a large number of small, student-founded startups that need cheap, trustworthy talent — and ALU students need real, resume-worthy experience a lecture hall can't provide. That matching has historically happened informally over WhatsApp, with no verification of who's a real founder, no structured screening, and no lasting record of what a student actually did once a gig ended.

ALULink formalizes that into one app: every account is a verified member of the ALU community, and every application, message, and hiring decision lives as a real, real-time document both sides can trust.

## What it does

ALULink is a two-sided marketplace with a role-based experience behind one shared sign-in.

**For students**
- Sign in with a Google account gated to `@alustudent.com` / `@alueducation.com`
- Complete a short setup wizard (skills, weekly hours, interests)
- Browse and filter live roles, with a computed match percentage per posting
- Apply, answering whatever screening questions the founder attached to that role
- Track application status in real time — applied, reviewing, interview, offer, or declined
- Chat with a founder and see interview details the moment they're proposed
- Save roles for later, get notified on any status change
- Export a PDF "Experience Passport" of verified roles and endorsed skills

**For founders**
- Submit a startup profile — name, category, city, logo upload, ALU affiliation proof
- Post a role with up to three custom screening questions (short-answer or single-choice)
- Review applicants in a drag-and-drop Kanban pipeline (New → Reviewing → Interview → Offer)
- Message an applicant and propose interview time slots
- Extend an offer or decline, each behind a confirmation step, with the student notified either way
- See a real funnel + top-applicant-skills view in Analytics
- Switch back to a student workspace at any time (gated on having actually completed setup)

## Architecture

- **Client**: a single Flutter/Dart codebase targeting Web, Android, and Windows.
- **Backend**: Firebase only — Firebase Authentication (Google provider) and Cloud Firestore. There is no custom server; Firestore Security Rules are the sole authorization boundary.
- **Data access**: one repository class, `MarketplaceRepository`, mediates every Firestore read and write. Screens never touch Firestore directly.
- **State management**: plain `setState` for screen-local state, `StreamBuilder` over Firestore's `.snapshots()` for anything shared or real-time. No external state-management package — Firestore's streams already are the reactive layer such a package would otherwise provide.
- **Design system**: a single `theme.dart` (colors, type scale, shape tokens) and a shared widget library in `lib/widgets/` used by every one of the app's screens.

## Firestore collections

| Collection | Holds |
|---|---|
| `startups/{uid}` | Founder profile — name, category, logo, verification status |
| `opportunities/{id}` | A posted role, including its screening questions |
| `applications/{id}` | One student's application to one role, and its current status |
| `chats/{chatId}` + `/messages/{id}` | Real-time messages between a student and a founder |
| `users/{uid}/notifications/{id}` | In-app notifications for status changes, new applicants, etc. |

## Tech stack

- **Flutter** / Dart
- **Firebase Authentication** — Google Sign-In, ALU-domain gated
- **Cloud Firestore** — the only backend; every screen reads/writes live data
- `image_picker` / `file_picker` — logo, photo, and document uploads
- `image` — client-side logo compression before it's stored
- `pdf` / `printing` — Experience Passport PDF export
- `google_fonts`, `material_symbols_icons` — the app's type and icon system

## Getting started

### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) 3.44 or later
- A Firebase project with Authentication and Cloud Firestore enabled

### Setup
1. Fetch dependencies:
   ```
   flutter pub get
   ```
2. Make sure `lib/firebase_options.dart` and `android/app/google-services.json` are present. If starting against a fresh Firebase project, generate them with:
   ```
   flutterfire configure
   ```
3. In the Firebase Console, under **Authentication → Sign-in method**, enable the **Google** provider.
4. Deploy the security rules in `firestore.rules`:
   ```
   firebase deploy --only firestore:rules
   ```
5. Run the app:
   ```
   flutter run -d chrome
   ```

## Project structure

```
lib/
├── data/       domain models, static option lists (skills, programs)
├── services/   AuthService, MarketplaceRepository, PDF export
├── widgets/    shared design-system components (buttons, cards, badges, chat view)
├── screens/
│   ├── a_auth/     splash, onboarding, sign-in, setup/verification
│   ├── b_student/  student-facing screens
│   ├── c_startup/  founder-facing screens
│   ├── dev/        hidden QA screen index (long-press the splash logo)
│   └── library/    hidden component-library reference
└── theme.dart  colors, typography, shape tokens
```

## Testing

```
flutter analyze
flutter test
```

## Known limitations

- A student's own profile is currently local-only, not Firestore-backed.
- No automated feature-level test suite beyond the default widget-test scaffold.
- No Firebase Storage, Cloud Messaging, or Cloud Functions — media is compressed and stored inline in Firestore, and notifications only update while the app is open.
- Screening question backend for "verified experience" on the Passport doesn't exist yet, so the Passport always starts at zero until that feature is built.

## Technical Report
You can access the tehcnical report that contains everything to know concerning this project
[a link](https://github.com/user/repo/blob/branch/other_file.md)

## Author

Me (Info in the GitHub Profile), African Leadership University.
You're welcome 🙂.
