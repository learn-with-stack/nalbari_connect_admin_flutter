import 'package:equatable/equatable.dart';

class BaseResponse<T> extends Equatable {
  final T? data;
  final ApiResult result;
  final Map<String, dynamic>? errorFields;

  const BaseResponse({
    required this.data,
    required this.result,
    this.errorFields,
  });

  bool get isSuccess => result.responseCode == 0 || result.responseCode == 200;
  String get message => result.responseDescription ?? 'Unknown error';

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResponse(
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
      result: ApiResult.fromJson(json['result'] ?? {}),
      errorFields: json['errorFields'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [data, result, errorFields];
}

class ApiResult extends Equatable {
  final int? responseCode;
  final String? responseDescription;

  const ApiResult({
    this.responseCode,
    this.responseDescription,
  });

  factory ApiResult.fromJson(Map<String, dynamic> json) {
    return ApiResult(
      responseCode: json['responseCode'] as int?,
      responseDescription: json['responseDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'responseCode': responseCode,
      'responseDescription': responseDescription,
    };
  }

  @override
  List<Object?> get props => [responseCode, responseDescription];
}
