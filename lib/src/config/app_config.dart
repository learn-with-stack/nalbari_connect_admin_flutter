import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/secure_storage_service.dart';
import '../utils/logger.dart';

class AppConfig {
  AppConfig._();

  static late final Dio dio;

  static String get baseUrl => dotenv.get('API_BASE_URL', fallback: '');
  static bool get useFakeApi => dotenv.get('USE_FAKE_API', fallback: 'true') == 'true';

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Source': 'nalbari-connect-mobile',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokenResult = await SecureStorageService.instance.read('session.token');
          tokenResult.fold(
            (_) {},
            (token) {
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            },
          );
          AppLogger.info('[API] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.success('[API] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          final statusCode = error.response?.statusCode?.toString() ?? 'ERR';
          AppLogger.error('[API] $statusCode ${error.requestOptions.path}', error);
          return handler.next(error);
        },
      ),
    );
  }
}
