import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/datasources/admin_auth_datasource.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/models/admin_login_model.dart';
import 'package:nalbari_connect_admin/src/features/auth/domain/entities/user.dart';

abstract class AdminAuthRepository {
  FutureEither<AppUser> adminLogin({
    required String username,
    required String password,
  });

  FutureEither<AppUser> otpLogin({required String firebaseIdToken});
}

class AdminAuthRepositoryImpl implements AdminAuthRepository {
  final AdminAuthDatasource _datasource = AdminAuthDatasource();

  @override
  FutureEither<AppUser> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _datasource.adminLogin(
        username: username,
        password: password,
      );

      // Store token in secure storage
      await _storeToken(response.token);

      final user = AppUser(
        id: response.user?['id']?.toString() ?? '',
        email: response.user?['email'] ?? username,
        name: response.user?['name'],
      );

      return right(user);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppUser> otpLogin({required String firebaseIdToken}) async {
    try {
      final response = await _datasource.otpLogin(firebaseIdToken: firebaseIdToken);

      // Store token in secure storage
      await _storeToken(response.token);

      final user = AppUser(
        id: response.user?['id']?.toString() ?? '',
        email: response.user?['email'] ?? '',
        name: response.user?['name'],
      );

      return right(user);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  Future<void> _storeToken(String token) async {
    try {
      final secureStorage = SecureStorageService.instance;
      await secureStorage.write('session.token', token);
    } catch (e) {
      AppLogger.error('Failed to store token', e);
    }
  }
}
