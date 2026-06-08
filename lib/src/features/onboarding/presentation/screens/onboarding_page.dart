import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 36.h, 18.w, 22.h),
          children: [
            Center(child: AppLogoMark(size: 104.w)),
            SizedBox(height: 20.h),
            Text(
              'app.name'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8.h),
            Text(
              'onboarding.subtitle'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: 30.h),
            Text('onboarding.language'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: 12.h),
            const _LanguageCard(title: 'English', subtitle: 'English', locale: Locale('en')),
            SizedBox(height: 10.h),
            const _LanguageCard(title: '???????', subtitle: 'Assamese', locale: Locale('as')),
            SizedBox(height: 10.h),
            const _LanguageCard(title: '??????', subtitle: 'Hindi', locale: Locale('hi')),
            SizedBox(height: 28.h),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: Size.fromHeight(56.h)),
              onPressed: () async {
                await ref.read(appAuthProvider.notifier).completeLanguageSetup();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text('onboarding.start'.tr()),
            ),
            SizedBox(height: 20.h),
            Text(
              'auth.secured'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.title, required this.subtitle, required this.locale});

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
        if (context.mounted) context.showSuccessSnackBar('settings.language_changed'.tr());
      },
      borderRadius: AppBorders.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer.withValues(alpha: 0.22) : cs.surfaceContainerLowest,
          borderRadius: AppBorders.card,
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 2 : 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    SizedBox(height: 3.h),
                    Text(selected ? 'settings.selected'.tr() : subtitle, style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? cs.primary : cs.outlineVariant),
            ],
          ),
        ),
      ),
    );
  }
}
