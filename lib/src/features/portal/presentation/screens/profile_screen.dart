import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(appAuthProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Card(
            color: context.colors.surfaceContainerLowest,
            child: Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                children: [
                  AppLogoMark(size: 72.w),
                  SizedBox(height: 12.h),
                  Text(
                    user?.name ?? 'profile.admin_user'.tr(),
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '+91 ${user?.phone ?? '6207683772'}',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                  SizedBox(height: 10.h),
                  Chip(
                    avatar: Icon(Icons.admin_panel_settings_outlined, size: 18.sp),
                    label: Text('profile.admin_role'.tr()),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          _ProfileLink(icon: Icons.settings_outlined, label: 'profile.settings'.tr(), route: AppRoutes.settings),
          SizedBox(height: 10.h),
          _ProfileLink(icon: Icons.info_outline, label: 'profile.about'.tr(), route: AppRoutes.about),
          SizedBox(height: 10.h),
          _ProfileLink(icon: Icons.help_outline, label: 'profile.faq'.tr(), route: AppRoutes.faq),
          SizedBox(height: 10.h),
          _ProfileLink(icon: Icons.privacy_tip_outlined, label: 'profile.privacy'.tr(), route: AppRoutes.privacy),
          SizedBox(height: 18.h),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_outlined),
            label: Text('home.logout'.tr()),
            style: OutlinedButton.styleFrom(foregroundColor: context.colors.error, side: BorderSide(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('profile.logout_title'.tr()),
        content: Text('profile.logout_message'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text('common.cancel'.tr())),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text('home.logout'.tr())),
        ],
      ),
    );
    if (shouldLogout != true) return;
    await ref.read(appAuthProvider.notifier).logout();
    if (context.mounted) context.showSuccessSnackBar('profile.logout_success'.tr());
  }
}

class _ProfileLink extends StatelessWidget {
  const _ProfileLink({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return Card(
      color: cs.surfaceContainerLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppBorders.card,
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        leading: Icon(icon, color: cs.primary),
        title: Text(label, style: context.textTheme.titleSmall?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w800)),
        trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
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
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Card(
            color: context.colors.surfaceContainerLowest,
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
                  context.showSuccessSnackBar('settings.language_changed'.tr());
                },
              ),
              ChoiceChip(
                label: const Text('অসমীয়া'),
                selected: context.locale.languageCode == 'as',
                onSelected: (_) async {
                  await context.setLocale(const Locale('as'));
                  if (!context.mounted) return;
                  context.showSuccessSnackBar('settings.language_changed'.tr());
                },
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Text('settings.theme'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.system, label: Text('settings.theme_system'.tr()), icon: const Icon(Icons.phone_android_outlined)),
              ButtonSegment(value: ThemeMode.light, label: Text('settings.theme_light'.tr()), icon: const Icon(Icons.light_mode_outlined)),
              ButtonSegment(value: ThemeMode.dark, label: Text('settings.theme_dark'.tr()), icon: const Icon(Icons.dark_mode_outlined)),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (value) {
              ref.read(appSettingsProvider.notifier).setThemeMode(value.first);
              context.showSuccessSnackBar('settings.theme_updated'.tr());
            },
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            value: settings.notificationsEnabled,
            onChanged: (value) {
              ref.read(appSettingsProvider.notifier).setNotificationsEnabled(value);
              context.showSuccessSnackBar(value ? 'settings.notifications_enabled'.tr() : 'settings.notifications_disabled'.tr());
            },
            title: Text('settings.notifications'.tr()),
            subtitle: Text('settings.notification_subtitle'.tr()),
          ),
          SizedBox(height: 18.h),
          Card(
            color: context.colors.surfaceContainerLowest,
            child: ListTile(
              leading: const Icon(Icons.http_outlined),
              title: Text('settings.api_base_url'.tr()),
              subtitle: Text(dotenv.get('API_BASE_URL', fallback: '')),
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




