# Nalbari Connect API Contract

The Flutter app currently uses fake in-memory data with this shape. Keep the real API responses close to these contracts so the frontend can switch from fake repository to Dio calls with minimal changes.

## Environment

```env
API_BASE_URL=https://your-backend.example.com/api/v1
USE_FAKE_API=false
```

## Auth

### POST `/auth/request-otp`

Request:

```json
{
  "phone": "9876543210"
}
```

Response:

```json
{
  "success": true,
  "otp_request_id": "otp_123"
}
```

### POST `/auth/verify-otp`

Request:

```json
{
  "phone": "9876543210",
  "otp": "123456"
}
```

Response:

```json
{
  "token": "jwt-token",
  "user": {
    "id": "citizen-001",
    "name": "Verified Resident",
    "phone": "9876543210",
    "role": "citizen",
    "id_proof_linked": false
  }
}
```

Allowed roles: `citizen`, `admin`.

## News

### GET `/news`

Response:

```json
[
  {
    "id": "n1",
    "title": "New Digital Services Portal Launched",
    "summary": "Government introduces streamlined portal for citizen services.",
    "body": "Full article text.",
    "published_at": "2026-06-04T00:00:00Z"
  }
]
```

## Appointments

### GET `/appointments`

Response:

```json
[
  {
    "id": "a1",
    "full_name": "Sarah Johnson",
    "with_person": "MLA Office",
    "date": "2026-06-08",
    "time": "10:30 AM",
    "reason": "Annual checkup and blood pressure monitoring",
    "status": "pending",
    "created_at": "2026-06-05T00:00:00Z"
  }
]
```

Allowed statuses: `pending`, `approved`, `rejected`.

### POST `/appointments`

Request:

```json
{
  "full_name": "Verified Resident",
  "date": "2026-06-08",
  "time": "10:00 AM",
  "reason": "Personal appointment request",
  "id_proof_file_url": "https://storage.example.com/id-proof.jpg"
}
```

### PATCH `/appointments/{id}/status`

Request:

```json
{
  "status": "approved",
  "remarks": "Approved by MLA office"
}
```

## Complaints

### GET `/complaints`

Response:

```json
[
  {
    "id": "c1",
    "reporter_name": "Verified Resident",
    "area_type": "ward",
    "area_number": "4",
    "description": "Street light not working near school junction.",
    "status": "newRequest",
    "priority": "medium",
    "media_url": null,
    "latitude": 26.444,
    "longitude": 91.441,
    "created_at": "2026-06-05T00:00:00Z"
  }
]
```

Allowed area types: `ward`, `panchayat`.

Allowed statuses: `newRequest`, `inReview`, `resolved`.

Allowed priorities: `low`, `medium`, `high`.

### POST `/complaints`

Request:

```json
{
  "area_type": "ward",
  "area_number": "4",
  "description": "Road damage near market.",
  "media_urls": ["https://storage.example.com/complaint.jpg"],
  "latitude": 26.444,
  "longitude": 91.441
}
```

## Security Notes

- Use HTTPS only.
- JWT must include role and user id.
- Encrypt phone number and identity proof metadata at rest.
- Admin actions should be logged with actor id, timestamp, action, and target id.
- Media upload should validate MIME type and file size before storage.
