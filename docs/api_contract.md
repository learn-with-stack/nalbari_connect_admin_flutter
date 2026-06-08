# Nalbari Admin API Contract

This document describes the JSON shape currently used by the Flutter fake API. The real backend should keep these response fields stable so the app can switch from fake repository to Dio calls by changing the repository implementation/base URL.

## Auth

### POST /auth/request-otp
Request:
```json
{ "phone_number": "9999999999" }
```
Response:
```json
{ "success": true, "request_id": "otp_req_001", "message": "OTP sent" }
```

### POST /auth/verify-otp
Request:
```json
{ "phone_number": "9999999999", "otp": "123456" }
```
Response:
```json
{
  "token": "jwt-token",
  "user": {
    "id": "admin-001",
    "name": "Nalbari Office Admin",
    "phone": "9999999999",
    "role": "admin"
  }
}
```

## Appointments

### GET /admin/appointments?page=1&limit=8
Response:
```json
{
  "items": [
    {
      "id": "a1",
      "full_name": "Sarah Johnson",
      "phone_number": "9876543210",
      "with_person": "Michael Chen",
      "date": "2026-06-08",
      "time": "10:30 AM",
      "reason": "Annual checkup and blood pressure monitoring",
      "status": "pending",
      "id_proof_name": "aadhaar_sarah.jpg",
      "admin_note": null,
      "created_at": "2026-06-05T09:00:00.000",
      "updated_at": null
    }
  ],
  "page": 1,
  "limit": 8,
  "total": 12,
  "has_more": true
}
```

### PATCH /admin/appointments/{id}/status
Request:
```json
{
  "status": "approved",
  "date": "2026-06-08",
  "time": "10:30 AM",
  "admin_note": "Approved by admin."
}
```
Response: return the updated appointment object using the same fields as above.

Allowed status values: `pending`, `approved`, `rejected`.

## Complaints

### GET /admin/complaints?page=1&limit=8
Response:
```json
{
  "items": [
    {
      "id": "c1",
      "reporter_name": "Jennifer Lee",
      "phone_number": "9876500011",
      "area_type": "ward",
      "area_number": "7",
      "title": "Long wait time in emergency room",
      "description": "Had to wait over 3 hours despite severe pain.",
      "status": "newRequest",
      "priority": "high",
      "media_name": "complaint_er_wait.jpg",
      "latitude": 26.4446,
      "longitude": 91.4411,
      "admin_action": null,
      "created_at": "2026-06-08T08:00:00.000",
      "updated_at": null
    }
  ],
  "page": 1,
  "limit": 8,
  "total": 9,
  "has_more": true
}
```

### PATCH /admin/complaints/{id}/status
Request:
```json
{
  "status": "inReview",
  "admin_action": "Assigned to helpdesk lead for verification."
}
```
Response: return the updated complaint object using the same fields as above.

Allowed status values: `newRequest`, `inReview`, `resolved`.
Allowed priority values: `low`, `medium`, `high`.
Allowed area type values: `ward`, `panchayat`.

## Notifications

### GET /admin/notifications
Response:
```json
{
  "items": [
    {
      "id": "n1",
      "title": "New appointment request",
      "message": "Sarah Johnson requested a meeting for June 8 at 10:30 AM.",
      "type": "appointment",
      "created_at": "2026-06-08T09:10:00.000",
      "is_read": false
    }
  ]
}
```

Allowed type values: `appointment`, `complaint`, `system`.

## Firebase Notification Payload

Foreground/opened Firebase messages should include data fields like:
```json
{
  "type": "complaint",
  "title": "High priority complaint",
  "message": "A new high priority complaint was submitted.",
  "reference_id": "c1"
}
```

The Flutter app maps `type` to the notification list and shows it in the notification badge/list.
