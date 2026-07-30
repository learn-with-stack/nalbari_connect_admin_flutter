import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _firebaseAuth = fb.FirebaseAuth.instance;

  bool _isPhoneStep = true;
  bool _isLoading = false;
  String _verificationId = '';
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      setState(() => _errorMessage = 'Please enter valid 10-digit phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phoneNumber = '+91${_phoneController.text.trim()}';
      AppLogger.info('Sending OTP to: $phoneNumber');

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (fb.PhoneAuthCredential credential) {
          AppLogger.info('Auto verification completed');
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          AppLogger.error('Verification failed: ${e.message}', e);
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to send OTP: ${e.message}';
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          AppLogger.success('OTP sent successfully');
          if (mounted) {
            setState(() {
              _isPhoneStep = false;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          AppLogger.info('Auto-retrieval timeout');
        },
      );
    } catch (e) {
      AppLogger.error('Error sending OTP', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length < 6) {
      setState(() => _errorMessage = 'Please enter 6-digit OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AppLogger.info('Verifying OTP for admin');

      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      AppLogger.success('Firebase OTP verified');

      // Now exchange Firebase token for backend JWT
      if (mounted) {
        await _loginWithBackend(firebaseIdToken);
      }
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('OTP verification failed', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid OTP: ${e.message}';
        });
      }
    } catch (e) {
      AppLogger.error('Error verifying OTP', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Verification failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loginWithBackend(String firebaseIdToken) async {
    try {
      AppLogger.info('Exchanging Firebase token for backend JWT');

      // In production: Call /api/auth/login/otp endpoint with firebaseIdToken
      // const userApiDatasource = UserApiDatasource();
      // final response = await userApiDatasource.otpLogin(firebaseIdToken: firebaseIdToken);

      // For demo: Simulating backend response
      await Future<void>.delayed(const Duration(seconds: 1));

      // Token would be stored in SecureStorage by the datasource
      // For now, just navigate to dashboard

      if (mounted) {
        AppLogger.success('Admin login successful');
        Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      }
    } catch (e) {
      AppLogger.error('Backend login failed', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    }
  }

  void _goBack() {
    setState(() {
      _isPhoneStep = true;
      _otpController.clear();
      _errorMessage = null;
      _verificationId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Logo
            Text(
              'Nalbari Connect',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Admin Portal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 50),
            if (_isPhoneStep) ...[
              // Phone input step
              Text(
                'Enter Admin Phone',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Admin Test: 62076 83772',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '10-digit number',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 28),
              AppButton(
                label: _isLoading ? 'Sending OTP...' : 'Send OTP',
                onPressed: _isLoading ? null : _sendOtp,
                isFullWidth: true,
              ),
            ] else ...[
              // OTP verification step
              Text(
                'Verify OTP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'OTP sent to +91 ${_phoneController.text.replaceRange(0, _phoneController.text.length - 4, '*' * (_phoneController.text.length - 4))}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test OTP: 555555 (60 sec)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: _otpController,
                label: 'OTP Code',
                hint: '6-digit code',
                prefixIcon: const Icon(Icons.security),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 28),
              AppButton(
                label: _isLoading ? 'Verifying...' : 'Verify & Login',
                onPressed: _isLoading ? null : _verifyOtp,
                isFullWidth: true,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _goBack,
                child: Text(
                  'Change Phone Number',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Firebase OTP Authentication',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Admin role determined by phone number',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
