/// Admin App API Routes
/// All endpoints under /api/admin/* and /api/auth/login/admin
abstract class AdminApiRoutes {
  // ============ AUTH ============
  static const String adminLogin = '/api/auth/login/admin';
  static const String otpLogin = '/api/auth/login/otp';

  // ============ APPOINTMENTS ============
  // Get all appointments with filters (PENDING, APPROVED, REJECTED, etc.)
  static const String adminAppointments = '/api/admin/appointments';

  // Accept an appointment
  static String adminAppointmentAccept(int id) =>
      '/api/admin/appointments/$id/accept';

  // Reject an appointment with reason
  static String adminAppointmentReject(int id) =>
      '/api/admin/appointments/$id/reject';

  // Reschedule an appointment
  static String adminAppointmentReschedule(int id) =>
      '/api/admin/appointments/$id/reschedule';

  // ============ COMPLAINTS ============
  // Get all complaints with filters (OPEN, IN_PROGRESS, RESOLVED, REJECTED)
  static const String adminComplaints = '/api/admin/complaints';

  // Get single complaint detail
  static String adminComplaintDetail(int id) => '/api/admin/complaints/$id';

  // Update complaint status
  static String adminComplaintStatus(int id) =>
      '/api/admin/complaints/$id/status';

  // ============ NEWS ============
  // Get all news/campaigns/schemes
  static const String adminNews = '/api/admin/news';

  // Get single news detail
  static String adminNewsDetail(int id) => '/api/admin/news/$id';

  // Create new news/campaign/scheme (POST)
  // Update news/campaign/scheme (PUT)
  // Delete news/campaign/scheme (DELETE)
  static String adminNewsById(int id) => '/api/admin/news/$id';

  // ============ OFFICES ============
  // Get all offices with pagination
  static const String adminOffices = '/api/admin/offices';

  // Get single office detail
  static String adminOfficeDetail(int id) => '/api/admin/offices/$id';

  // Create, Update, Delete offices
  static String adminOfficeById(int id) => '/api/admin/offices/$id';
}
