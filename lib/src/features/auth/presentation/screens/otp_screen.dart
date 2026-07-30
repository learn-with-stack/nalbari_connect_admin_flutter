import 'package:nalbari_connect_admin/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController(text: '555555');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthProvider);
    final cs = context.colors;
    final phone = auth.pendingPhone ?? '6207683772';
    final masked = phone.length >= 3 ? '+91 ***** **${phone.substring(phone.length - 3)}' : '+91 ***** **892';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 24.h),
          children: [
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.arrow_back),
                  label: Text('auth.change_number'.tr()),
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                ),
                SizedBox(height: 30.h),
                Card(
                  color: cs.surface,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.h,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFFF9933),
                            borderRadius: AppBorders.full,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9933).withValues(alpha: 0.18),
                                  borderRadius: AppBorders.card,
                                  border: Border.all(color: const Color(0xFFFF9933)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(18.w),
                                  child: const Icon(Icons.shield_outlined, color: Color(0xFF8F4E00), size: 38),
                                ),
                              ),
                            ),
                            SizedBox(height: 26.h),
                            Text(
                              'auth.otp_title'.tr(),
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF8F4E00),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text('${'auth.otp_sent_to'.tr()} $masked', textAlign: TextAlign.center, style: context.textTheme.titleMedium),
                            SizedBox(height: 28.h),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              textAlign: TextAlign.center,
                              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 8),
                              decoration: const InputDecoration(counterText: '', hintText: '555555'),
                            ),
                            SizedBox(height: 20.h),
                            Text.rich(
                               TextSpan(
                                text: '${'auth.resend_in'.tr()} ',
                                children: const[
                                  TextSpan(
                                    text: '00:28',
                                    style: TextStyle(color: Color(0xFF8F4E00), fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: context.textTheme.titleSmall,
                            ),
                            TextButton(
                              onPressed: () => context.showSuccessSnackBar('auth.demo_otp'.tr()),
                              child: Text('auth.resend_otp'.tr()),
                            ),
                            SizedBox(height: 14.h),
                            FilledButton.icon(
                              onPressed: auth.isLoading ? null : _verifyOtp,
                              icon: auth.isLoading
                                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.lock_outline),
                              label: Text('auth.verify'.tr()),
                              style: FilledButton.styleFrom(
                                minimumSize: Size.fromHeight(58.h),
                                backgroundColor: const Color(0xFF9A5700),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Card(
                  color: cs.surface.withValues(alpha: 0.82),
                  child: ListTile(
                    leading: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF056E00).withValues(alpha: 0.12),
                        borderRadius: AppBorders.card,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: const Icon(Icons.security_outlined, color: Color(0xFF056E00)),
                      ),
                    ),
                    title: Text('auth.encrypted_title'.tr()),
                    subtitle: Text('auth.encrypted_body'.tr()),
                  ),
                ),
                SizedBox(height: 60.h),
                Text(
                  'auth.footer'.tr(),
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    try {
      final ok = await ref.read(appAuthProvider.notifier).verifyOtp(_otpController.text.trim());
      if (!ok && mounted) {
        context.showErrorSnackBar('auth.invalid_otp'.tr());
        return;
      }
      if (!mounted) return;
      context.showSuccessSnackBar('auth.login_success'.tr());
      context.go(AppRoutes.adminDashboard);
    } catch (error) {
      if (mounted) context.showErrorSnackBar('${'auth.login_failed'.tr()}: $error');
    }
  }
}

