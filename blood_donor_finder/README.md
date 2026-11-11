# Blood Donor Finder

A simple Flutter app to find blood donors nearby. **No backend** — all data is stored locally on the device using `shared_preferences`. It gives a real-time feel: searching and filtering update the list instantly, and changes persist between sessions.

## Stack

- **Framework**: Flutter
- **State**: `flutter_riverpod` (providers only — no codegen)
- **Persistence**: `shared_preferences` (JSON strings for donors + session)
- **No network packages, no Firebase**

## Features

- **Mock login** — sign in with any email and a password of at least 6 characters. Your session is remembered so the app reopens logged in. Log out from the Profile tab.
- **Seed data** — on first launch the app creates ~12 demo donors across blood groups O+, O-, A+, A-, B+, B-, AB+ and several cities.
- **Find Donors** — search by name or city, filter by blood group with chips. Results update instantly as you type/tap.
- **Donor details** — tap any donor card to see full details.
- **My Profile** — create or edit your own donor profile (name, blood group, city, phone, last donation date). Saving persists it locally and it immediately appears in the Donor list.

## Getting started

```bash
flutter pub get
flutter run
```

Supported platforms: **Android**, **iOS**, **Web**.

## Running tests & analysis

```bash
flutter analyze
flutter test
```

Tests cover: login screen, instant donor filtering (blood group + search), and profile creation updating the donor list with validation.

## Project structure

```
lib/
  models/       Donor model
  services/     StorageService, AuthService, SeedData
  providers/    auth, donor list, filters, current user profile, service providers
  screens/      Login, Home (bottom nav), DonorList, DonorDetail, Profile, Add/Edit Donor
  widgets/      BloodGroupBadge, SearchField, BloodGroupFilterChips, DonorCard
  theme.dart    Colors & TextTheme (primary red #E53935)
```