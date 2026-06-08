import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(seconds: 3));
      await ref.read(appAuthProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surface,
          image: const DecorationImage(
            image: AssetImage(AppAssets.logo),
            opacity: 0.025,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogoMark(size: 96.w),
              SizedBox(height: 20.h),
              Text(
                'app.name'.tr(),
                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6.h),
              Text(
                'Connecting Nalbari with Leadership',
                style: context.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
