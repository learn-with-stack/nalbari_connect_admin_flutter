/// Centralized route path constants for GoRouter.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String citizenHome = '/citizen';
  static const String adminDashboard = '/admin';
  static const String newsDetail = '/news-detail';
  static const String bookAppointment = '/book-appointment';
  static const String raiseComplaint = '/raise-complaint';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String faq = '/faq';
  static const String privacy = '/privacy';

  // Backward-compatible alias for older generated code still importing home.
  static const String home = citizenHome;
}
