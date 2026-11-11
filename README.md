# BloodLink — Blood Donor Finder

BloodLink is a Flutter application that helps connect people who need blood with registered donors. It uses on-device SQLite storage and a Material 3 interface. It does not require a cloud account or cloud database.

## Features

- Local sign-in, account registration and session persistence
- Dashboard with donor, availability, request and city statistics
- Donor registration, editing, search, blood-group filters and favourites
- Donation history and donor eligibility interval display
- Blood requests with urgency and status tracking
- Blood-group compatibility matching, with same-city donors prioritised
- Profile and logout
- Local JSON backup and restore for users, donors, donations and requests
- Transactional restore with backup format validation

## Tech stack

- Flutter 3.47.2 / Dart 3.13.2
- Provider for state management
- SQLite: native `sqflite` on Android/iOS and `sqflite_common_ffi` on desktop
- Shared Preferences for session persistence
- File Picker for local backup export/import
- Material 3

## Run locally

1. Install Flutter and verify it with `flutter doctor`.
2. Open this folder in VS Code or Android Studio.
3. Run `flutter pub get`.
4. Run `flutter run -d windows` for Windows desktop, or select an available Android/iOS device.

## Quality checks

```powershell
flutter analyze
flutter test
```

## Backup and restore

Open **Profile** in BloodLink:
- Choose **Create backup** to save a JSON backup file.
- Choose **Restore backup** to select a previously created BloodLink backup.

Restore replaces the current local users, donors, donations and requests. The app asks for confirmation and logs out after a successful restore. Keep backup files in a private, secure location: they contain donor/request personal information and salted password hashes. The app does not encrypt exported backup files.

## Current limitations

- Data is local to each device. There is no cloud sync or shared multi-device database.
- Donor/request matching uses the entered city; live GPS and maps are not connected.
- Push notifications and admin verification are not connected.
- Android builds require the Android SDK. Windows desktop builds with plugins may require Windows Developer Mode (symlink support).
- A successful web compile does not guarantee browser runtime support for this app's local SQLite implementation.

## Important safety note

BloodLink is a coordination tool, not a medical eligibility checker or a replacement for a hospital/blood bank. Blood type compatibility and donor eligibility must be confirmed by qualified medical staff before any donation or transfusion.
