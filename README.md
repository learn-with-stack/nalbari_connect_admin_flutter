# Nalbari Connect

Unified citizen and admin prototype for Nalbari Constituency.

## Current Prototype Flow

- Start app -> onboarding -> phone login -> OTP.
- Use any valid 10 digit phone as a citizen.
- Use `9999999999` as the admin phone.
- Demo OTP is `123456`.
- Citizen can read news, book appointments, raise complaints with ward/panchayat, media, and location.
- Admin can search appointments, filter status, approve/reject requests, and review complaints.

## Environment

Copy `.env.example` to `.env` for a new machine. The current prototype uses:

```env
API_BASE_URL=https://fake-api.nalbari-connect.local/api/v1
USE_FAKE_API=true
FIREBASE_NOTIFICATIONS_ENABLED=false
```

Keep Firebase disabled until Android Firebase native setup and `google-services.json` are ready.

## Backend Contract

Share [docs/api_contract.md](docs/api_contract.md) with the backend developer. The fake API repository already follows those response shapes.

## Run

```bash
flutter pub get
flutter run
```

For checks:

```bash
flutter analyze
flutter test
```
