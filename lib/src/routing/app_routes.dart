/// Centralized route path constants for GoRouter.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String verifyOtp = '/verify-otp';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String faq = '/faq';
  static const String privacy = '/privacy';
  static const String adminDashboard = '/admin';
  static const String notifications = '/notifications';

  // Admin app home.
  static const String home = adminDashboard;
}
