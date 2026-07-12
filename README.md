# ALULink

A Flutter + Firebase marketplace connecting ALU students to verified ALU-run startups for real internships and gigs.

## What it does

ALULink is a two-sided app:

- **Students** browse and apply to roles at ALU-affiliated startups, track application status in real time, chat with founders, and build a verified "Experience Passport" they can export as a PDF.
- **Founders** verify their startup, post roles with custom screening questions, review applicants in a drag-and-drop pipeline, message and schedule interviews, and extend offers or decline — all backed by live data.

Sign-in is Google-based and restricted to `@alustudent.com` / `@alueducation.com` accounts.

## Tech stack

- **Flutter** / Dart — single codebase for Web, Android, and Windows
- **Firebase Authentication** — Google Sign-In, ALU-domain gated
- **Cloud Firestore** — the only backend; every screen reads/writes live data, no custom server
- `image_picker` / `file_picker` — logo, photo, and document uploads
- `pdf` / `printing` — Experience Passport PDF export

## Getting started

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (3.44+) and fetch dependencies:
   ```
   flutter pub get
   ```
2. Make sure `lib/firebase_options.dart` and `android/app/google-services.json` are present (generate them with `flutterfire configure` against your own Firebase project if starting fresh).
3. In the Firebase Console, enable the **Google** sign-in provider, then deploy the security rules:
   ```
   firebase deploy --only firestore:rules
   ```
4. Run the app:
   ```
   flutter run -d chrome
   ```

## Project structure

```
lib/
├── data/       domain models, static option lists
├── services/   AuthService, MarketplaceRepository (all Firestore access)
├── widgets/    shared design-system components
├── screens/
│   ├── a_auth/     splash, onboarding, sign-in, setup/verification
│   ├── b_student/  student-facing screens
│   └── c_startup/  founder-facing screens
└── theme.dart  colors, typography, shape tokens
```

## Testing

```
flutter analyze
flutter test
```
