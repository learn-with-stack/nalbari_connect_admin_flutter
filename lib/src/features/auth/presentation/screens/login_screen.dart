import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '9876543210');

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
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(color: cs.outlineVariant.withValues(alpha: 0.32)),
              ),
            ),
            ListView(
              padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 22.h),
              children: [
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.onboarding),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Home'),
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                ),
                SizedBox(height: 16.h),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(child: AppLogoMark(size: 84.w)),
                              SizedBox(height: 18.h),
                              Text(
                                'app.name'.tr(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineSmall?.copyWith(
                                  color: const Color(0xFF8F4E00),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'app.tagline'.tr(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              ),
                              SizedBox(height: 26.h),
                              _DemoLoginCard(onPick: (phone) => _phoneController.text = phone),
                              SizedBox(height: 22.h),
                              Text(
                                'auth.phone_number'.tr(),
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                validator: (value) {
                                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                                  if (digits.length != 10) return 'Please enter a valid 10-digit number';
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
                                        Text('IN', style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900)),
                                        SizedBox(width: 8.w),
                                        Text('+91', style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800)),
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
                                  Icon(Icons.verified_user_outlined, size: 15.sp, color: cs.onSurfaceVariant),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Text(
                                      'A 6-digit OTP will be sent for verification',
                                      style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              FilledButton.icon(
                                onPressed: auth.isLoading ? null : _requestOtp,
                                icon: auth.isLoading
                                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.send_outlined),
                                label: Text('auth.continue'.tr()),
                                style: FilledButton.styleFrom(
                                  minimumSize: Size.fromHeight(52.h),
                                  backgroundColor: const Color(0xFF8F4E00),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                'auth.demo_hint'.tr(),
                                textAlign: TextAlign.center,
                                style: context.textTheme.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Expanded(child: _InfoTile(icon: Icons.security_outlined, title: 'Secure Gateway', body: '256-bit encryption for all constituency data.')),
                    SizedBox(width: 10.w),
                    const Expanded(child: _InfoTile(icon: Icons.verified_outlined, title: 'Govt. Verified', body: 'Official services for Nalbari, Assam.')),
                  ],
                ),
                SizedBox(height: 30.h),
                Text(
                  'Privacy Policy   |   Support\nCopyright 2024 Nalbari Connect | Secure Gateway',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
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
      context.showSuccessSnackBar('OTP sent. Use 123456 for this demo.');
      context.go(AppRoutes.verifyOtp);
    } catch (error) {
      if (mounted) context.showErrorSnackBar('Could not send OTP: $error');
    }
  }
}

class _DemoLoginCard extends StatelessWidget {
  const _DemoLoginCard({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.primaryContainer.withValues(alpha: 0.18),
        borderRadius: AppBorders.card,
        border: Border.all(color: context.colors.primary.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo accounts', style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onPick('9876543210');
                      context.showSuccessSnackBar('Citizen demo number selected.');
                    },
                    icon: const Icon(Icons.person_outline),
                    label: const Text('User'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      onPick('9999999999');
                      context.showSuccessSnackBar('Admin demo number selected.');
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: const Text('Admin'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text('User: 9876543210 | Admin: 9999999999', style: context.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: AppBorders.card,
        border: Border.all(color: context.colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF056E00)),
            SizedBox(height: 8.h),
            Text(title, style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: 4.h),
            Text(body, style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    for (double x = -size.height; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) => oldDelegate.color != color;
}
