import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nalbari_connect/src/features/auth/data/models/app_session.dart';
import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nalbari_connect/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:nalbari_connect/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:nalbari_connect/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:nalbari_connect/src/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:nalbari_connect/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/screens/admin_dashboard_screen.dart';
import 'package:nalbari_connect/src/features/portal/presentation/screens/appointment_screen.dart';
import 'package:nalbari_connect/src/features/portal/presentation/screens/citizen_home_screen.dart';
import 'package:nalbari_connect/src/features/portal/presentation/screens/complaint_screen.dart';
import 'package:nalbari_connect/src/features/portal/presentation/screens/profile_screen.dart';
import 'package:nalbari_connect/src/routing/app_routes.dart';
import 'package:nalbari_connect/src/routing/global_navigator.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref
    ..onDispose(refreshNotifier.dispose)
    ..listen(appAuthProvider, (_, __) => refreshNotifier.refresh());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(appAuthProvider);
      final location = state.matchedLocation;
      final publicRoutes = {
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.verifyOtp,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      };

      if (auth.status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!auth.isAuthenticated) {
        if (location == AppRoutes.splash) {
          return auth.hasCompletedLanguageSetup ? AppRoutes.login : AppRoutes.onboarding;
        }
        if (publicRoutes.contains(location)) {
          return null;
        }
        return AppRoutes.login;
      }

      if (publicRoutes.contains(location)) {
        return auth.isAdmin ? AppRoutes.adminDashboard : AppRoutes.citizenHome;
      }

      if (location == AppRoutes.adminDashboard && !auth.isAdmin) {
        return AppRoutes.citizenHome;
      }

      if (location == AppRoutes.citizenHome && auth.isAdmin) {
        return AppRoutes.adminDashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        name: 'verifyOtp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.citizenHome,
        name: 'citizenHome',
        builder: (context, state) => const CitizenHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.newsDetail,
        name: 'newsDetail',
        builder: (context, state) => NewsDetailScreen(item: state.extra! as NewsItem),
      ),
      GoRoute(
        path: AppRoutes.bookAppointment,
        name: 'bookAppointment',
        builder: (context, state) => const AppointmentScreen(),
      ),
      GoRoute(
        path: AppRoutes.raiseComplaint,
        name: 'raiseComplaint',
        builder: (context, state) => const ComplaintScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const StaticInfoScreen(
          title: 'About App',
          body: 'Nalbari Connect is a prototype civic application for news, appointments, complaints, profile tracking, and executive review. The current build uses fake API data and is ready to connect to the real backend once response contracts are finalized.',
        ),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        builder: (context, state) => const StaticInfoScreen(
          title: 'FAQ',
          body: '1. Login uses phone and OTP.\n\n2. Citizens can book appointments and raise complaints.\n\n3. Admin users can approve or reject appointment requests and review complaints.\n\n4. ID proof is linked once and reused for future appointment requests.',
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const StaticInfoScreen(
          title: 'Privacy & Security',
          body: 'The production backend should use HTTPS, short-lived tokens, encrypted storage for phone and ID proof metadata, role-based access control, audit logs for admin actions, and strict media validation. This prototype stores only a fake token and demo profile data locally.',
        ),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
