import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/fake_api_controls_provider.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect/src/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(appAuthProvider);
    final portal = ref.watch(portalControllerProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Center(child: AppLogoMark(size: 72.w)),
          SizedBox(height: 12.h),
          Text(
            user?.name ?? 'User',
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            '+91 ${user?.phone ?? ''}',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Chip(
              avatar: Icon(
                user?.role.name == 'admin' ? Icons.admin_panel_settings_outlined : Icons.person_outline,
                size: 18.sp,
              ),
              label: Text((user?.role.name ?? 'citizen').toUpperCase()),
            ),
          ),
          SizedBox(height: 22.h),
          _ProfileLink(icon: Icons.settings_outlined, label: 'profile.settings'.tr(), route: AppRoutes.settings),
          _ProfileLink(icon: Icons.info_outline, label: 'profile.about'.tr(), route: AppRoutes.about),
          _ProfileLink(icon: Icons.help_outline, label: 'profile.faq'.tr(), route: AppRoutes.faq),
          _ProfileLink(icon: Icons.privacy_tip_outlined, label: 'profile.privacy'.tr(), route: AppRoutes.privacy),
          Card(
            color: context.colors.surface,
            child: ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: Text('home.logout'.tr()),
              onTap: () async {
                await ref.read(appAuthProvider.notifier).logout();
                if (context.mounted) context.showSuccessSnackBar('Logged out successfully.');
              },
            ),
          ),
          SizedBox(height: 18.h),
          Text('profile.appointments'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          if (portal.appointments.isEmpty)
            const AppEmptyState(title: 'No appointments yet')
          else
            for (final appointment in portal.appointments.take(4))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(appointment.reason),
                subtitle: Text('${appointment.time} - ${appointment.status.name}'),
                leading: const Icon(Icons.calendar_month_outlined),
              ),
          SizedBox(height: 12.h),
          Text('profile.complaints'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          if (portal.complaints.isEmpty)
            const AppEmptyState(title: 'No complaints yet')
          else
            for (final complaint in portal.complaints.take(4))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${complaint.areaType == AreaType.ward ? 'Ward' : 'Panchayat'} ${complaint.areaNumber}'),
                subtitle: Text(complaint.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                leading: const Icon(Icons.report_problem_outlined),
              ),
        ],
      ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.surface,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final fakeApi = ref.watch(fakeApiControlsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Card(
            color: context.colors.surface,
            child: ListTile(
              leading: AppLogoMark(size: 42.w),
              title: Text('app.name'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              subtitle: Text('app.tagline'.tr()),
            ),
          ),
          SizedBox(height: 18.h),
          Text('settings.language'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ChoiceChip(
                label: const Text('English'),
                selected: context.locale.languageCode == 'en',
                onSelected: (_) async {
                  await context.setLocale(const Locale('en'));
                  if (!context.mounted) return;
                  context.showSuccessSnackBar('Language changed to English.');
                },
              ),
              ChoiceChip(
                label: const Text('Assamese'),
                selected: context.locale.languageCode == 'as',
                onSelected: (_) async {
                  await context.setLocale(const Locale('as'));
                  if (!context.mounted) return;
                  context.showSuccessSnackBar('Language changed to Assamese.');
                },
              ),
              ChoiceChip(
                label: const Text('Hindi'),
                selected: context.locale.languageCode == 'hi',
                onSelected: (_) async {
                  await context.setLocale(const Locale('hi'));
                  if (!context.mounted) return;
                  context.showSuccessSnackBar('Language changed to Hindi.');
                },
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text('Theme', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.phone_android_outlined)),
              ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (value) {
              ref.read(appSettingsProvider.notifier).setThemeMode(value.first);
              context.showSuccessSnackBar('Theme updated.');
            },
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(appSettingsProvider.notifier).setNotificationsEnabled(value);
              context.showSuccessSnackBar(value ? 'Notifications enabled.' : 'Notifications disabled.');
            },
            title: Text('settings.notifications'.tr()),
            subtitle: const Text('Appointment and complaint updates'),
          ),
          SizedBox(height: 18.h),
          Text('Fake API mode', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 8.h),
          Text(
            'Use this while backend is not ready. The app uses the same async repository shape that the real API will use later.',
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<FakeApiFailureMode>(
              segments: const [
                ButtonSegment(value: FakeApiFailureMode.none, label: Text('Working'), icon: Icon(Icons.cloud_done_outlined)),
                ButtonSegment(value: FakeApiFailureMode.offline, label: Text('Offline'), icon: Icon(Icons.wifi_off_outlined)),
                ButtonSegment(value: FakeApiFailureMode.serverError, label: Text('Server'), icon: Icon(Icons.error_outline)),
              ],
              selected: {fakeApi.failureMode},
              onSelectionChanged: (value) {
                final mode = value.first;
                ref.read(fakeApiControlsProvider.notifier).setFailureMode(mode);
                ref.invalidate(newsProvider);
                ref.read(portalControllerProvider.notifier).load();
                final message = switch (mode) {
                  FakeApiFailureMode.none => 'Fake API restored. GET/POST/PATCH will work.',
                  FakeApiFailureMode.offline => 'Fake API is offline. Requests will show network error.',
                  FakeApiFailureMode.serverError => 'Fake API will return server error.',
                };
                context.showSuccessSnackBar(message);
              },
            ),
          ),
          SizedBox(height: 14.h),
          Card(
            color: context.colors.surface,
            child: ListTile(
              leading: const Icon(Icons.http_outlined),
              title: const Text('API base URL'),
              subtitle: Text(dotenv.get('API_BASE_URL', fallback: 'Fake API enabled')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.verified_outlined),
            title: Text('settings.version'.tr()),
            subtitle: Text(dotenv.get('APP_VERSION_LABEL', fallback: '1.0.0')),
          ),
        ],
      ),
    );
  }
}

class StaticInfoScreen extends StatelessWidget {
  const StaticInfoScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Center(child: AppLogoMark(size: 76.w)),
          SizedBox(height: 16.h),
          Text(title, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 12.h),
          Text(body, style: context.textTheme.bodyLarge?.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}
