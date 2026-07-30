import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/datasources/admin_auth_datasource.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/models/app_session.dart';
import 'package:nalbari_connect_admin/src/services/secure_storage_service.dart';
import 'package:nalbari_connect_admin/src/utils/logger.dart';

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
  static const _adminPhone = '6207683772';

  final AdminAuthDatasource _authDatasource = AdminAuthDatasource();
  String? _verificationId;

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
    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (normalizedPhone != _adminPhone) {
      throw Exception('Only registered admin number can login.');
    }

    state = state.copyWith(isLoading: true, pendingPhone: normalizedPhone);
    try {
      final completer = Completer<bool>();
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$normalizedPhone',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (error) {
          AppLogger.error('[AUTH] Admin OTP request failed', error);
          if (!completer.isCompleted) completer.completeError(error);
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          if (!completer.isCompleted) completer.complete(true);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
      final sent = await completer.future.timeout(const Duration(seconds: 65));
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingPhone: normalizedPhone,
        isLoading: false,
      );
      return sent;
    } catch (error) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final phone = state.pendingPhone;
    final verificationId = _verificationId;
    if (phone == null || verificationId == null || otp.length != 6) return false;

    state = state.copyWith(isLoading: true);
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final firebaseUser = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseIdToken = await firebaseUser.user?.getIdToken();
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      final authResponse = await _authDatasource.otpLogin(firebaseIdToken: firebaseIdToken);
      if (authResponse.token.isEmpty) {
        await firebase_auth.FirebaseAuth.instance.signOut();
        await _clearStoredSession();
        state = state.copyWith(isLoading: false);
        throw Exception('Backend did not return a session token.');
      }
      final role = (authResponse.user?['role']?.toString() ?? '').toUpperCase();
      if (role != 'ADMIN') {
        await firebase_auth.FirebaseAuth.instance.signOut();
        await _clearStoredSession();
        throw Exception('This number is not allowed for admin login.');
      }

      final user = AppSessionUser(
        id: authResponse.user?['id']?.toString() ?? phone,
        phone: phone,
        name: 'Nalbari Office Admin',
        role: AppUserRole.admin,
        token: authResponse.token,
        idProofLinked: false,
      );

      await _persist(user);
      AppLogger.success('[AUTH] Admin logged in with backend JWT');
      state = AppAuthState(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        hasCompletedLanguageSetup: state.hasCompletedLanguageSetup,
        lastOpenedAt: state.lastOpenedAt,
      );
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
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
    await _clearStoredSession();
    await firebase_auth.FirebaseAuth.instance.signOut();
    state = const AppAuthState(
      status: AuthStatus.unauthenticated,
      hasCompletedLanguageSetup: true,
    );
  }

  Future<void> _clearStoredSession() async {
    final storage = SecureStorageService.instance;
    await storage.delete(_idKey);
    await storage.delete(_phoneKey);
    await storage.delete(_nameKey);
    await storage.delete(_roleKey);
    await storage.delete(_tokenKey);
    await storage.delete(_idProofKey);
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
