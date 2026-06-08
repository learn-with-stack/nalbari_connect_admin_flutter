import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect/src/features/auth/data/models/app_session.dart';
import 'package:nalbari_connect/src/services/secure_storage_service.dart';
import 'package:nalbari_connect/src/utils/logger.dart';

final appAuthProvider = StateNotifierProvider<AppAuthController, AppAuthState>((ref) {
  return AppAuthController();
});

class AppAuthController extends StateNotifier<AppAuthState> {
  AppAuthController() : super(const AppAuthState());

  static const _idKey = 'session.id';
  static const _phoneKey = 'session.phone';
  static const _nameKey = 'session.name';
  static const _roleKey = 'session.role';
  static const _tokenKey = 'session.token';
  static const _idProofKey = 'session.idProofLinked';
  static const _languageSetupKey = 'app.languageSetupComplete';
  static const _lastOpenedAtKey = 'app.lastOpenedAt';

  Future<void> restoreSession() async {
    final storage = SecureStorageService.instance;
    final values = <String, String?>{};
    for (final key in [
      _idKey,
      _phoneKey,
      _nameKey,
      _roleKey,
      _tokenKey,
      _idProofKey,
      _languageSetupKey,
      _lastOpenedAtKey,
    ]) {
      final result = await storage.read(key);
      result.fold((_) => values[key] = null, (value) => values[key] = value);
    }

    final user = AppSessionUser.fromStorage({
      'id': values[_idKey],
      'phone': values[_phoneKey],
      'name': values[_nameKey],
      'role': values[_roleKey],
      'token': values[_tokenKey],
      'idProofLinked': values[_idProofKey],
    });

    final hasCompletedLanguageSetup = values[_languageSetupKey] == 'true';
    final lastOpenedAt = DateTime.tryParse(values[_lastOpenedAtKey] ?? '');
    await storage.write(_lastOpenedAtKey, DateTime.now().toIso8601String());

    state = AppAuthState(
      status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
      user: user,
      hasCompletedLanguageSetup: hasCompletedLanguageSetup,
      lastOpenedAt: lastOpenedAt,
    );
  }

  Future<bool> requestOtp(String phone) async {
    state = state.copyWith(isLoading: true);
    AppLogger.info('[FAKE API] POST /auth/request-otp -> $phone');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      pendingPhone: phone,
      isLoading: false,
    );
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    final phone = state.pendingPhone;
    if (phone == null || otp != '123456') return false;

    state = state.copyWith(isLoading: true);
    AppLogger.info('[FAKE API] POST /auth/verify-otp -> $phone');
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    final role = normalizedPhone == '9999999999' ? AppUserRole.admin : AppUserRole.citizen;
    final user = AppSessionUser(
      id: role == AppUserRole.admin ? 'admin-001' : 'citizen-001',
      phone: normalizedPhone,
      name: role == AppUserRole.admin ? 'Nalbari Office Admin' : 'Verified Resident',
      role: role,
      token: 'fake-jwt-token-$normalizedPhone',
      idProofLinked: false,
    );

    await _persist(user);
    AppLogger.success('[AUTH] Logged in as ${user.role.name}');
    state = AppAuthState(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
      hasCompletedLanguageSetup: state.hasCompletedLanguageSetup,
      lastOpenedAt: state.lastOpenedAt,
    );
    return true;
  }

  Future<void> completeLanguageSetup() async {
    await SecureStorageService.instance.write(_languageSetupKey, 'true');
    state = state.copyWith(hasCompletedLanguageSetup: true);
  }

  Future<void> markIdProofLinked() async {
    final user = state.user;
    if (user == null) return;
    final updated = user.copyWith(idProofLinked: true);
    await _persist(updated);
    state = state.copyWith(user: updated);
  }

  Future<void> logout() async {
    final storage = SecureStorageService.instance;
    await storage.delete(_idKey);
    await storage.delete(_phoneKey);
    await storage.delete(_nameKey);
    await storage.delete(_roleKey);
    await storage.delete(_tokenKey);
    await storage.delete(_idProofKey);
    state = const AppAuthState(
      status: AuthStatus.unauthenticated,
      hasCompletedLanguageSetup: true,
    );
  }

  Future<void> _persist(AppSessionUser user) async {
    final storage = SecureStorageService.instance;
    final data = user.toStorage();
    await storage.write(_idKey, data['id']!);
    await storage.write(_phoneKey, data['phone']!);
    await storage.write(_nameKey, data['name']!);
    await storage.write(_roleKey, data['role']!);
    await storage.write(_tokenKey, data['token']!);
    await storage.write(_idProofKey, data['idProofLinked']!);
  }
}
