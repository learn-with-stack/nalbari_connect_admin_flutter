import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '9999999999');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthProvider);
    final cs = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18.w, 42.h, 18.w, 24.h),
          children: [
            Center(child: AppLogoMark(size: 92.w)),
            SizedBox(height: 20.h),
            Text('auth.welcome'.tr(), textAlign: TextAlign.center, style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: 6.h),
            Text('auth.phone_title'.tr(), textAlign: TextAlign.center, style: context.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            SizedBox(height: 28.h),
            Card(
              color: cs.surfaceContainerLowest,
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('auth.phone_number'.tr(), style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                          if (digits.length != 10) return 'auth.invalid_phone'.tr();
                          return null;
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'auth.phone_hint'.tr(),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(left: 14.w, right: 12.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('+91', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w900)),
                                SizedBox(width: 10.w),
                                SizedBox(height: 24.h, child: VerticalDivider(color: cs.outlineVariant)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 16.sp, color: cs.onSurfaceVariant),
                          SizedBox(width: 6.w),
                          Expanded(child: Text('auth.otp_help'.tr(), style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))),
                        ],
                      ),
                      SizedBox(height: 22.h),
                      FilledButton.icon(
                        onPressed: auth.isLoading ? null : _requestOtp,
                        icon: auth.isLoading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_outlined),
                        label: Text('auth.continue'.tr()),
                        style: FilledButton.styleFrom(minimumSize: Size.fromHeight(54.h)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text('auth.demo_hint'.tr(), textAlign: TextAlign.center, style: context.textTheme.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w800)),
            SizedBox(height: 28.h),
            Text('auth.secured'.tr(), textAlign: TextAlign.center, style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Future<void> _requestOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    try {
      await ref.read(appAuthProvider.notifier).requestOtp(phone);
      if (!mounted) return;
      context.showSuccessSnackBar('auth.otp_sent'.tr());
      context.go(AppRoutes.verifyOtp);
    } catch (error) {
      if (mounted) context.showErrorSnackBar('${'auth.otp_failed'.tr()}: $error');
    }
  }
}
