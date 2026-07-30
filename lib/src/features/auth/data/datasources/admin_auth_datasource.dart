import 'package:nalbari_connect_admin/src/config/admin_api_routes.dart';
import 'package:nalbari_connect_admin/src/services/dio_service.dart';
import '../models/admin_login_model.dart';

class AdminAuthDatasource {
  final DioService _dioService = DioService.instance;

  Future<AuthResponse> adminLogin({
    required String username,
    required String password,
  }) async {
    final request = AdminLoginRequest(username: username, password: password);

    final response = await _dioService.post(
      AdminApiRoutes.adminLogin,
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? json;
        return AuthResponse.fromJson(data);
      },
    );
  }

  Future<AuthResponse> otpLogin({
    required String firebaseIdToken,
  }) async {
    final response = await _dioService.post(
      AdminApiRoutes.otpLogin,
      data: OtpLoginRequest(firebaseIdToken: firebaseIdToken).toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>? ?? json;
        return AuthResponse.fromJson(data);
      },
    );
  }
}
