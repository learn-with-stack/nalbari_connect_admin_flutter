# Nalbari Connect - Complete API Integration Guide

**Based on actual backend code from:** `nalbari-connect-backend` (Java Spring Boot)

---

## 📊 Response Format (BaseResponse Wrapper)

All API responses follow this structure:

```json
{
  "data": {
    // Actual response data
  },
  "result": {
    "responseCode": 0,        // HTTP status code
    "responseDescription": "Success message"
  },
  "errorFields": {            // Only on validation errors
    "fieldName": "error message"
  }
}
```

---

## 🔐 Authentication Endpoints

### 1. Admin Login
```
POST /api/auth/login/admin
Content-Type: application/json

Request:
{
  "username": "string",
  "password": "string"
}

Response (200 OK):
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "expiresInMs": 86400000,
    "userId": 1,
    "role": "ADMIN"
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "Login successful"
  }
}
```

### 2. User OTP Login
```
POST /api/auth/login/otp
Content-Type: application/json

Request:
{
  "firebaseIdToken": "FIREBASE_ID_TOKEN_FROM_SDK"
}

Response (200 OK):
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "tokenType": "Bearer",
    "expiresInMs": 604800000,
    "userId": 2,
    "role": "USER"
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "Login successful"
  }
}
```

---

## 📱 User Profile

### Get Current User
```
GET /api/me
Authorization: Bearer {JWT_TOKEN}

Response (200 OK):
{
  "data": {
    "id": 2,
    "mobileNumber": "9876543210",
    "email": "user@example.com",
    "fullName": "John Doe",
    "aadhaarNumber": null,
    "createdAt": "2026-07-28T10:00:00Z"
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "OK"
  }
}
```

---

## 📅 Appointments

### User: Create Appointment
```
POST /api/appointments
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data

Form Data:
- data: JSON string {
    "officeId": 1,
    "date": "2026-08-15",
    "time": "14:30",
    "purpose": "Document verification"
  }
- aadhaar: (optional) binary file

Response (201 CREATED):
{
  "data": {
    "id": 123,
    "officeId": 1,
    "officeName": "District Office",
    "applicantName": "John Doe",
    "mobileNumber": "9876543210",
    "date": "2026-08-15",
    "time": "14:30:00",
    "purpose": "Document verification",
    "status": "PENDING",
    "rejectReason": null,
    "createdAt": "2026-07-28T10:00:00Z"
  },
  "result": {
    "responseCode": 201,
    "responseDescription": "Appointment created successfully"
  }
}
```

### User: Get My Appointments
```
GET /api/me/appointments?page=0&size=20&sort=createdAt,desc
Authorization: Bearer {JWT_TOKEN}

Response (200 OK):
{
  "data": [
    {
      "id": 123,
      "officeId": 1,
      "officeName": "District Office",
      "applicantName": "John Doe",
      "mobileNumber": "9876543210",
      "date": "2026-08-15",
      "time": "14:30:00",
      "purpose": "Document verification",
      "status": "PENDING",
      "rejectReason": null,
      "createdAt": "2026-07-28T10:00:00Z"
    }
  ],
  "result": {
    "responseCode": 200,
    "responseDescription": "OK"
  }
}
```

### Admin: Get All Appointments
```
GET /api/admin/appointments?status=PENDING&page=0&size=20&sort=createdAt,desc
Authorization: Bearer {JWT_TOKEN}

Query Parameters:
- status: PENDING | APPROVED | REJECTED | RESCHEDULED | COMPLETED | CANCELLED
- page: 0-based page number
- size: items per page
- sort: field,direction (default: createdAt,desc)

Response: Same as Get My Appointments (paginated list)
```

### Admin: Accept Appointment
```
PUT /api/admin/appointments/{id}/accept
Authorization: Bearer {JWT_TOKEN}

Response (200 OK):
{
  "data": {
    "id": 123,
    ...
    "status": "APPROVED",
    ...
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "Appointment accepted"
  }
}
```

### Admin: Reject Appointment
```
PUT /api/admin/appointments/{id}/reject
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json

Request:
{
  "reason": "Office closed on this date"
}

Response (200 OK):
{
  "data": {
    "id": 123,
    ...
    "status": "REJECTED",
    "rejectReason": "Office closed on this date",
    ...
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "Appointment rejected"
  }
}
```

### Admin: Reschedule Appointment
```
PUT /api/admin/appointments/{id}/reschedule
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json

Request:
{
  "date": "2026-08-20",
  "time": "15:00"
}

Response (200 OK):
{
  "data": {
    "id": 123,
    "date": "2026-08-20",
    "time": "15:00:00",
    "status": "RESCHEDULED",
    ...
  },
  "result": {
    "responseCode": 200,
    "responseDescription": "Appointment rescheduled"
  }
}
```

---

## 📝 Complaints

### User: File Complaint
```
POST /api/complaints
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data

Form Data:
- data: JSON string {
    "title": "Complaint Title",
    "description": "Detailed complaint...",
    "area": "Ward 5",
    "areaType": "WARD"
  }
- voiceNote: (optional) audio file
- media: (optional) list of image files
- aadhaar: (optional) document file

Response (201 CREATED):
{
  "data": {
    "id": 456,
    "title": "Complaint Title",
    "description": "Detailed complaint...",
    "status": "OPEN",
    "createdBy": "9876543210",
    "mediaUrls": ["url1", "url2"],
    "voiceNoteUrl": "url3",
    "createdAt": "2026-07-28T10:00:00Z"
  },
  "result": {
    "responseCode": 201,
    "responseDescription": "Complaint filed successfully"
  }
}
```

### User: Get My Complaints
```
GET /api/me/complaints?page=0&size=20&sort=createdAt,desc
Authorization: Bearer {JWT_TOKEN}

Response: Paginated list of ComplaintDto
```

### Admin: Get All Complaints
```
GET /api/admin/complaints?status=OPEN&areaType=WARD&page=0&size=20
Authorization: Bearer {JWT_TOKEN}

Query Parameters:
- status: OPEN | IN_PROGRESS | RESOLVED | REJECTED
- areaType: WARD | PANCHAYAT
- page: 0-based
- size: items per page
- sort: field,direction

Response: Paginated list of complaints
```

### Admin: Update Complaint Status
```
PUT /api/admin/complaints/{id}/status
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json

Request:
{
  "status": "IN_PROGRESS"
}

Valid Values: OPEN | IN_PROGRESS | RESOLVED | REJECTED

Response (200 OK): Updated ComplaintDto with new status
```

---

## 📰 News / Campaign / Scheme

### Get Public News
```
GET /api/news?type=NEWS&page=0&size=20&sort=createdAt,desc
No Authorization Required

Query Parameters:
- type: NEWS | CAMPAIGN | SCHEME (optional)
- page: 0-based
- size: items per page
- sort: field,direction

Response (200 OK):
{
  "data": [
    {
      "id": 1,
      "title": "New Scheme Launched",
      "description": "Details...",
      "type": "SCHEME",
      "mediaUrls": ["url1", "url2"],
      "createdAt": "2026-07-28T10:00:00Z"
    }
  ],
  "result": {
    "responseCode": 200,
    "responseDescription": "OK"
  }
}
```

### Admin: Create News
```
POST /api/admin/news
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data

Form Data:
- data: JSON string {
    "title": "News Title",
    "description": "Full description",
    "type": "NEWS|CAMPAIGN|SCHEME"
  }
- media: list of image files

Response (201 CREATED): Created NewsDto
```

### Admin: Update News
```
PUT /api/admin/news/{id}
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data

Same form data as POST

Response (200 OK): Updated NewsDto
```

### Admin: Delete News
```
DELETE /api/admin/news/{id}
Authorization: Bearer {JWT_TOKEN}

Response (204 NO CONTENT)
```

---

## 🏛️ Offices

### Get Public Offices
```
GET /api/offices
No Authorization Required

Response (200 OK):
{
  "data": [
    {
      "id": 1,
      "name": "District Office",
      "address": "123 Main Street",
      "active": true
    }
  ],
  "result": {
    "responseCode": 200,
    "responseDescription": "OK"
  }
}
```

### Admin: CRUD Operations
```
GET    /api/admin/offices?page=0&size=20
POST   /api/admin/offices
PUT    /api/admin/offices/{id}
DELETE /api/admin/offices/{id}

All require: Authorization: Bearer {JWT_TOKEN}
```

---

## 🔑 Important Implementation Notes

### 1. Token Management
- Store JWT token in **SecureStorage** under key: `session.token`
- Attach to all authenticated requests: `Authorization: Bearer {token}`
- Token expires at `expiresInMs` milliseconds

### 2. Role-Based Access
- Admin requests use `/api/admin/*` endpoints
- User requests use `/api/*` or `/api/me/*` endpoints
- Public endpoints (news, offices) require no authentication

### 3. File Uploads
- Use `multipart/form-data` for file uploads
- JSON data must be passed as string in `data` field
- Multiple files in `media` field as array

### 4. Pagination
- All list endpoints support: page, size, sort
- Default page size: 20
- Sort format: "field,direction" (direction: asc or desc)

### 5. Error Handling
- Success responses: responseCode = 2xx HTTP code
- Error responses: responseCode = 4xx/5xx HTTP code
- Field validation errors in `errorFields` map
- Always check `result.responseCode` to verify success

### 6. Firebase Integration
- User login requires Firebase ID Token from SDK
- Token obtained after OTP verification in Firebase
- Pass token to `/api/auth/login/otp` endpoint
- Backend validates Firebase token and issues JWT

---

## 📱 Flutter Implementation Alignment

All Dart models created in the Flutter project match these exact formats:

- `AuthResponse.dart` ✅
- `AppointmentDto.dart` ✅
- `ComplaintDto.dart` ✅
- `NewsDto.dart` ✅
- `OfficeDto.dart` ✅
- `BaseResponse.dart` ✅

Repositories and Providers already configured to handle these responses correctly.

---

**Status**: Backend examined. Flutter code aligned with actual API.
**Next**: Build UI screens using these exact response formats.
