/// Central API routes configuration for all endpoints
abstract class ApiRoutes {
  // Base path
  static const String apiVersion = '/api';

  // ============ AUTHENTICATION ============
  static const String adminLogin = '$apiVersion/auth/login/admin';
  static const String otpLogin = '$apiVersion/auth/login/otp';

  // ============ OFFICES ============
  static const String offices = '$apiVersion/admin/offices';
  static String officeDetail(int id) => '$offices/$id';

  // ============ APPOINTMENTS ============
  static const String appointments = '$apiVersion/admin/appointments';
  static String appointmentDetail(int id) => '$appointments/$id';
  static String acceptAppointment(int id) => '$appointments/$id/accept';
  static String rejectAppointment(int id) => '$appointments/$id/reject';
  static String rescheduleAppointment(int id) => '$appointments/$id/reschedule';

  // ============ COMPLAINTS ============
  static const String complaints = '$apiVersion/admin/complaints';
  static String complaintDetail(int id) => '$complaints/$id';
  static String updateComplaintStatus(int id) => '$complaints/$id/status';

  // ============ NEWS ============
  static const String newsList = '$apiVersion/admin/news';
  static String newsDetail(int id) => '$newsList/$id';

  // ============ USER PUBLIC ENDPOINTS ============
  static const String userAppointments = '$apiVersion/appointments';
  static String userAppointmentDetail(int id) => '$userAppointments/$id';

  static const String userComplaints = '$apiVersion/complaints';
  static String userComplaintDetail(int id) => '$userComplaints/$id';

  // ============ PUBLIC ENDPOINTS ============
  static const String publicOffices = '$apiVersion/offices';
  static const String publicNews = '$apiVersion/news';
  static String publicNewsDetail(int id) => '$publicNews/$id';

  // ============ USER PROFILE ============
  static const String currentUser = '$apiVersion/me';
  static const String userMyComplaints = '$currentUser/complaints';
  static const String userMyAppointments = '$currentUser/appointments';
}
