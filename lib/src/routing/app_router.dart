import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/models/app_session.dart';
import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/features/auth/presentation/screens/login_screen.dart';
import 'package:nalbari_connect_admin/src/features/auth/presentation/screens/otp_screen.dart';
import 'package:nalbari_connect_admin/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:nalbari_connect_admin/src/features/onboarding/presentation/screens/onboarding_page.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/screens/admin_dashboard_screen.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/screens/notifications_screen.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/screens/profile_screen.dart';
import 'package:nalbari_connect_admin/src/routing/app_routes.dart';
import 'package:nalbari_connect_admin/src/routing/global_navigator.dart';

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
      };

      if (auth.status == AuthStatus.unknown) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!auth.isAuthenticated) {
        if (location == AppRoutes.splash) {
          return auth.hasCompletedLanguageSetup ? AppRoutes.login : AppRoutes.onboarding;
        }
        if (publicRoutes.contains(location)) return null;
        return AppRoutes.login;
      }

      if (publicRoutes.contains(location)) return AppRoutes.adminDashboard;
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
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
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
          title: 'About Admin App',
          body: 'Nalbari Admin is a prototype executive dashboard for approving appointment requests, reviewing public complaints, tracking notifications, and validating backend API contracts with fake async responses.',
        ),
      ),
      GoRoute(
        path: AppRoutes.faq,
        name: 'faq',
        builder: (context, state) => const StaticInfoScreen(
          title: 'FAQ',
          body: '1. Login uses phone and OTP.\n\n2. Demo admin phone is 9999999999.\n\n3. Demo OTP is 123456.\n\n4. Appointment approve/reject and complaint status changes use fake API calls now, ready for backend replacement later.',
        ),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const StaticInfoScreen(
          title: 'Privacy & Security',
          body: 'Production should use HTTPS, encrypted token storage, role-based access control, staff audit logs, media validation, and strict Firebase notification topic permissions. This build stores only fake demo data locally.',
        ),
      ),
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}


