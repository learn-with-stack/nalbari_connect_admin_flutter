/// Complete API routes configuration for BOTH Admin and User Apps
/// This file separates Admin endpoints from Public/User endpoints

abstract class AdminApiRoutes {
  // Base path
  static const String apiVersion = '/api';

  // ============ ADMIN AUTHENTICATION ============
  static const String adminLogin = '$apiVersion/auth/login/admin';

  // ============ ADMIN - OFFICES ============
  static const String offices = '$apiVersion/admin/offices';
  static String officeDetail(int id) => '$offices/$id';

  // ============ ADMIN - APPOINTMENTS ============
  static const String appointments = '$apiVersion/admin/appointments';
  static String appointmentDetail(int id) => '$appointments/$id';
  static String acceptAppointment(int id) => '$appointments/$id/accept';
  static String rejectAppointment(int id) => '$appointments/$id/reject';
  static String rescheduleAppointment(int id) => '$appointments/$id/reschedule';

  // ============ ADMIN - COMPLAINTS ============
  static const String complaints = '$apiVersion/admin/complaints';
  static String complaintDetail(int id) => '$complaints/$id';
  static String updateComplaintStatus(int id) => '$complaints/$id/status';

  // ============ ADMIN - NEWS ============
  static const String newsList = '$apiVersion/admin/news';
  static String newsDetail(int id) => '$newsList/$id';
}

abstract class UserApiRoutes {
  static const String apiVersion = '/api';

  // ============ USER AUTHENTICATION ============
  /// Firebase phone OTP login - requires Firebase ID token
  static const String otpLogin = '$apiVersion/auth/login/otp';

  // ============ USER - PROFILE ============
  /// Get current user profile
  static const String currentUser = '$apiVersion/me';

  // ============ USER - APPOINTMENTS ============
  /// Create new appointment booking
  static const String createAppointment = '$apiVersion/appointments';
  /// Get appointment details
  static String appointmentDetail(int id) => '$createAppointment/$id';
  /// Get user's own appointments
  static const String userMyAppointments = '$currentUser/appointments';

  // ============ USER - COMPLAINTS ============
  /// File new complaint with documents/voice notes
  static const String fileComplaint = '$apiVersion/complaints';
  /// Get complaint details
  static String complaintDetail(int id) => '$fileComplaint/$id';
  /// Get user's own complaints
  static const String userMyComplaints = '$currentUser/complaints';

  // ============ PUBLIC - OFFICES ============
  /// Get all offices list
  static const String publicOffices = '$apiVersion/offices';

  // ============ PUBLIC - NEWS ============
  /// Get all news, campaigns, schemes
  static const String publicNews = '$apiVersion/news';
  /// Get specific news detail
  static String publicNewsDetail(int id) => '$publicNews/$id';
}

// ============ RESPONSE MODELS ============

/// Generic API Response structure used by all endpoints
/// All API responses follow this pattern
abstract class ApiResponseModels {
  /// Success Response Format:
  /// ```json
  /// {
  ///   "data": { /* actual response */ },
  ///   "result": {
  ///     "responseCode": 0,
  ///     "responseDescription": "Success"
  ///   },
  ///   "errorFields": null
  /// }
  /// ```

  /// Error Response Format:
  /// ```json
  /// {
  ///   "data": null,
  ///   "result": {
  ///     "responseCode": 1,
  ///     "responseDescription": "Error message"
  ///   },
  ///   "errorFields": {
  ///     "field_name": "Validation error"
  ///   }
  /// }
  /// ```
}

// ============ ADMIN API REQUEST/RESPONSE MODELS ============

/// Admin Login Request & Response
///
/// REQUEST:
/// ```
/// POST /api/auth/login/admin
/// {
///   "username": "string",
///   "password": "string"
/// }
/// ```
///
/// RESPONSE:
/// ```
/// {
///   "data": {
///     "token": "JWT_TOKEN",
///     "refreshToken": "REFRESH_TOKEN",
///     "user": {
///       "id": 1,
///       "username": "admin",
///       "email": "admin@example.com",
///       "name": "Admin Name"
///     }
///   },
///   "result": {
///     "responseCode": 0,
///     "responseDescription": "Login successful"
///   }
/// }
/// ```
abstract class AdminLoginModels {}

/// Office CRUD Models
///
/// GET /api/admin/offices (paginated)
/// Response: List<OfficeModel>
///
/// POST /api/admin/offices
/// Request: { "name": "string", "address": "string", "active": true }
/// Response: OfficeModel
///
/// PUT /api/admin/offices/{id}
/// Request: { "name": "string", "address": "string", "active": true }
/// Response: OfficeModel
///
/// DELETE /api/admin/offices/{id}
/// Response: { "data": {} }
abstract class AdminOfficeModels {}

/// Appointment Management Models
///
/// GET /api/admin/appointments
/// Query: name, mobile, officeId, status, page, size, sort
/// Response: List<AppointmentModel>
///
/// PUT /api/admin/appointments/{id}/accept
/// Response: AppointmentModel (status: APPROVED)
///
/// PUT /api/admin/appointments/{id}/reject
/// Request: { "reason": "string" }
/// Response: AppointmentModel (status: REJECTED)
///
/// PUT /api/admin/appointments/{id}/reschedule
/// Request: { "date": "2026-08-15", "time": { "hour": 14, "minute": 30 } }
/// Response: AppointmentModel (status: RESCHEDULED)
abstract class AdminAppointmentModels {}

/// Complaint Management Models
///
/// GET /api/admin/complaints
/// Query: status, areaType, page, size, sort
/// Response: List<ComplaintModel>
///
/// GET /api/admin/complaints/{id}
/// Response: ComplaintModel
///
/// PUT /api/admin/complaints/{id}/status
/// Request: { "status": "OPEN|IN_PROGRESS|RESOLVED|REJECTED" }
/// Response: ComplaintModel
abstract class AdminComplaintModels {}

/// News/Campaign/Scheme Models
///
/// GET /api/admin/news (paginated)
/// Response: List<NewsModel>
///
/// GET /api/admin/news/{id}
/// Response: NewsModel
///
/// POST /api/admin/news
/// Request: {
///   "title": "string",
///   "description": "string",
///   "type": "NEWS|CAMPAIGN|SCHEME",
///   "mediaUrls": ["url1", "url2"]
/// }
/// Response: NewsModel
///
/// PUT /api/admin/news/{id}
/// Request: Same as POST
/// Response: NewsModel
///
/// DELETE /api/admin/news/{id}
/// Response: { "data": {} }
abstract class AdminNewsModels {}

// ============ USER API REQUEST/RESPONSE MODELS ============

/// User OTP Login with Firebase
///
/// REQUEST:
/// ```
/// POST /api/auth/login/otp
/// {
///   "firebaseIdToken": "FIREBASE_ID_TOKEN"
/// }
/// ```
///
/// RESPONSE:
/// ```
/// {
///   "data": {
///     "token": "JWT_TOKEN",
///     "user": {
///       "id": 1,
///       "phone": "9876543210",
///       "email": "user@example.com",
///       "name": "User Name",
///       "aadhaar": "AADHAAR_NO"
///     }
///   },
///   "result": {
///     "responseCode": 0,
///     "responseDescription": "Login successful"
///   }
/// }
/// ```
abstract class UserLoginModels {}

/// User Profile Model
///
/// GET /api/me
/// Response: {
///   "id": 1,
///   "phone": "9876543210",
///   "email": "user@example.com",
///   "name": "User Name",
///   "aadhaar": "AADHAAR_NO",
///   "createdAt": "2026-07-28T10:00:00Z"
/// }
abstract class UserProfileModels {}

/// Appointment Booking by User
///
/// POST /api/appointments
/// Request: {
///   "data": {
///     "name": "User Name",
///     "email": "user@email.com",
///     "phone": "9876543210",
///     "officeId": 1,
///     "date": "2026-08-15",
///     "time": { "hour": 14, "minute": 30 },
///     "purpose": "string"
///   },
///   "aadhaar": "binary_file"  // multipart file
/// }
/// Response: AppointmentModel with status: PENDING
///
/// GET /api/appointments/{id}
/// Response: AppointmentModel
///
/// GET /api/me/appointments (paginated)
/// Query: page, size, sort
/// Response: List<AppointmentModel>
abstract class UserAppointmentModels {}

/// Complaint Filing by User
///
/// POST /api/complaints
/// Request: {
///   "data": {
///     "title": "Complaint Title",
///     "description": "Complaint description",
///     "area": "Ward/Panchayat name",
///     "areaType": "WARD|PANCHAYAT"
///   },
///   "voiceNote": "binary_file",  // optional audio
///   "media": ["file1", "file2"],  // optional images
///   "aadhaar": "binary_file"      // optional document
/// }
/// Response: ComplaintModel with status: OPEN
///
/// GET /api/complaints/{id}
/// Response: ComplaintModel with details and media URLs
///
/// GET /api/me/complaints (paginated)
/// Query: page, size, sort
/// Response: List<ComplaintModel>
abstract class UserComplaintModels {}

/// Public Content Models
///
/// GET /api/offices
/// Response: List<OfficeModel>
///
/// GET /api/news (paginated)
/// Query: type (NEWS|CAMPAIGN|SCHEME), page, size, sort
/// Response: List<NewsModel>
///
/// GET /api/news/{id}
/// Response: NewsModel with full content
abstract class PublicContentModels {}

// ============ ENUM VALUES ============

/// Appointment Status Values
/// Used in: GET /api/admin/appointments?status=X
/// Used in: PUT /api/admin/complaints/{id}/status
abstract class AppointmentStatusValues {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String rescheduled = 'RESCHEDULED';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
}

/// Complaint Status Values
/// Used in: GET /api/admin/complaints?status=X
/// Used in: PUT /api/admin/complaints/{id}/status
abstract class ComplaintStatusValues {
  static const String open = 'OPEN';
  static const String inProgress = 'IN_PROGRESS';
  static const String resolved = 'RESOLVED';
  static const String rejected = 'REJECTED';
}

/// Area Type Values
/// Used in: GET /api/admin/complaints?areaType=X
abstract class AreaTypeValues {
  static const String ward = 'WARD';
  static const String panchayat = 'PANCHAYAT';
}

/// News Type Values
/// Used in: GET /api/news?type=X
abstract class NewsTypeValues {
  static const String news = 'NEWS';
  static const String campaign = 'CAMPAIGN';
  static const String scheme = 'SCHEME';
}
