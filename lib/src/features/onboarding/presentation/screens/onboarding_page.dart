import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 5.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [cs.primary, const Color(0xFF056E00), cs.primary]),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10.h),
                    Center(child: AppLogoMark(size: 126.w)),
                    SizedBox(height: 22.h),
                    Text(
                      'app.name'.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'onboarding.title'.tr(),
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Connecting Nalbari with Leadership',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'à¦¨à¦²à¦¬à¦¾à§°à§€à¦• à¦¨à§‡à¦¤à§ƒà¦¤à§à¦¬à§° à¦¸à§ˆà¦¤à§‡ à¦¸à¦‚à¦¯à§‹à¦— à¦•à§°à¦¾',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'à¤¨à¤²à¤¬à¤¾à¤¡à¤¼à¥€ à¤•à¥‹ à¤¨à¥‡à¤¤à¥ƒà¤¤à¥à¤µ à¤¸à¥‡ à¤œà¥‹à¤¡à¤¼à¤¨à¤¾',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: 34.h),
                    const _SectionLabel(),
                    SizedBox(height: 14.h),
                    const _LanguageCard(
                      title: 'à¦…à¦¸à¦®à§€à¦¯à¦¼à¦¾',
                      subtitle: 'Assamese',
                      locale: Locale('as'),
                    ),
                    SizedBox(height: 10.h),
                    const _LanguageCard(
                      title: 'English',
                      subtitle: 'English',
                      locale: Locale('en'),
                    ),
                    SizedBox(height: 10.h),
                    const _LanguageCard(
                      title: 'à¤¹à¤¿à¤¨à¥à¤¦à¥€',
                      subtitle: 'Hindi',
                      locale: Locale('hi'),
                    ),
                    SizedBox(height: 26.h),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9933),
                        foregroundColor: const Color(0xFF2E1500),
                        minimumSize: Size.fromHeight(58.h),
                      ),
                      onPressed: () async {
                        await ref.read(appAuthProvider.notifier).completeLanguageSetup();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('onboarding.start'.tr()),
                              SizedBox(width: 8.w),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'à¦†à§°à¦®à§à¦­ à¦•à§°à¦•  |  à¤¶à¥à¤°à¥‚ à¤•à¤°à¥‡à¤‚',
                            style: context.textTheme.labelSmall?.copyWith(color: const Color(0xFF2E1500).withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _TrustChip(icon: Icons.verified_user_outlined, label: 'High Trust'),
                        SizedBox(width: 14.w),
                        const _TrustChip(icon: Icons.security_outlined, label: 'Encrypted'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
              child: Text(
                'Copyright 2024 Nalbari Constituency | à¦¨à¦²à¦¬à¦¾à§°à§€ à¦¬à¦¿à¦§à¦¾à¦¨à¦¸à¦­à¦¾ à¦¸à¦®à¦·à§à¦Ÿà¦¿',
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.outlineVariant)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            'Language / à¦­à¦¾à¦·à¦¾ / à¤­à¤¾à¤·à¤¾',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colors.outlineVariant)),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.locale,
  });

  final String title;
  final String subtitle;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final selected = context.locale.languageCode == locale.languageCode;
    final cs = context.colors;

    return InkWell(
      onTap: () async {
        await context.setLocale(locale);
        if (context.mounted) context.showSuccessSnackBar('Language changed.');
      },
      borderRadius: AppBorders.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: AppBorders.card,
          border: Border.all(
            color: selected ? const Color(0xFFFF9933) : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9933).withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    SizedBox(height: 3.h),
                    Text(
                      selected ? 'Selected' : subtitle,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: selected ? const Color(0xFFFF9933) : cs.onSurfaceVariant,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? const Color(0xFFFF9933) : cs.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF056E00), size: 18.sp),
        SizedBox(width: 5.w),
        Text(label, style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

