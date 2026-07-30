import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/auth/data/repositories/admin_auth_repository.dart';
import 'package:nalbari_connect_admin/src/features/auth/domain/entities/user.dart';

final adminAuthRepositoryProvider = Provider<AdminAuthRepository>(
  (ref) => AdminAuthRepositoryImpl(),
);

final adminLoginProvider = FutureProvider.family<
  AppUser,
  ({String username, String password})
>((ref, params) async {
  final repository = ref.watch(adminAuthRepositoryProvider);
  final result = await repository.adminLogin(
    username: params.username,
    password: params.password,
  );

  return result.fold(
    (failure) => throw failure,
    (user) => user,
  );
});

final adminOtpLoginProvider = FutureProvider.family<AppUser, String>(
  (ref, firebaseIdToken) async {
    final repository = ref.watch(adminAuthRepositoryProvider);
    final result = await repository.otpLogin(firebaseIdToken: firebaseIdToken);

    return result.fold(
      (failure) => throw failure,
      (user) => user,
    );
  },
);
