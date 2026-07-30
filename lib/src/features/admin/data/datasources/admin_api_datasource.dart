import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/config/admin_api_routes.dart';
import 'package:nalbari_connect_admin/src/services/dio_service.dart';
import '../models/models.dart';

class AdminApiDatasource {
  final DioService _dioService = DioService.instance;

  // ============ OFFICES ============

  Future<BaseResponse<List<dynamic>>> getOffices({
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    final response = await _dioService.get(
      AdminApiRoutes.adminOffices,
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(
          json,
          (data) => _content(data).map((e) => OfficeModel.fromJson(e)).toList(),
        );
      },
    );
  }

  Future<BaseResponse<OfficeModel>> createOffice(CreateOfficeRequest request) async {
    final response = await _dioService.post(
      AdminApiRoutes.adminOffices,
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => OfficeModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<OfficeModel>> updateOffice(int id, CreateOfficeRequest request) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminOfficeById(id),
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => OfficeModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<void>> deleteOffice(int id) async {
    final response = await _dioService.delete(AdminApiRoutes.adminOfficeById(id));

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (_) => null);
      },
    );
  }

  // ============ APPOINTMENTS ============

  Future<BaseResponse<List<dynamic>>> getAppointments({
    String? name,
    String? mobile,
    int? officeId,
    String? status,
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    final response = await _dioService.get(
      AdminApiRoutes.adminAppointments,
      queryParameters: {
        if (name != null) 'name': name,
        if (mobile != null) 'mobile': mobile,
        if (officeId != null) 'officeId': officeId,
        if (status != null) 'status': status,
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(
          json,
          (data) => _content(data).map((e) => AppointmentModel.fromJson(e)).toList(),
        );
      },
    );
  }

  Future<BaseResponse<AppointmentModel>> acceptAppointment(int id) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminAppointmentAccept(id),
      data: const AcceptAppointmentRequest().toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => AppointmentModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<AppointmentModel>> rejectAppointment(
    int id,
    RejectAppointmentRequest request,
  ) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminAppointmentReject(id),
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => AppointmentModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<AppointmentModel>> rescheduleAppointment(
    int id,
    RescheduleAppointmentRequest request,
  ) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminAppointmentReschedule(id),
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => AppointmentModel.fromJson(data));
      },
    );
  }

  // ============ COMPLAINTS ============

  Future<BaseResponse<List<dynamic>>> getComplaints({
    String? status,
    String? areaType,
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    final response = await _dioService.get(
      AdminApiRoutes.adminComplaints,
      queryParameters: {
        if (status != null) 'status': status,
        if (areaType != null) 'areaType': areaType,
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(
          json,
          (data) => _content(data).map((e) => ComplaintModel.fromJson(e)).toList(),
        );
      },
    );
  }

  Future<BaseResponse<ComplaintModel>> getComplaintById(int id) async {
    final response = await _dioService.get(AdminApiRoutes.adminComplaintDetail(id));

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => ComplaintModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<ComplaintModel>> updateComplaintStatus(
    int id,
    UpdateComplaintStatusRequest request,
  ) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminComplaintStatus(id),
      data: request.toJson(),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => ComplaintModel.fromJson(data));
      },
    );
  }

  // ============ NEWS ============

  Future<BaseResponse<List<dynamic>>> getNewsList({
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    final response = await _dioService.get(
      AdminApiRoutes.adminNews,
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
      },
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(
          json,
          (data) => _content(data).map((e) => NewsModel.fromJson(e)).toList(),
        );
      },
    );
  }

  Future<BaseResponse<NewsModel>> getNewsById(int id) async {
    final response = await _dioService.get(AdminApiRoutes.adminNewsDetail(id));

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => NewsModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<NewsModel>> createNews(CreateNewsRequest request) async {
    final response = await _dioService.post(
      AdminApiRoutes.adminNews,
      data: FormData.fromMap({
        'data': jsonEncode(request.toJson()),
      }),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => NewsModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<NewsModel>> updateNews(int id, CreateNewsRequest request) async {
    final response = await _dioService.put(
      AdminApiRoutes.adminNewsDetail(id),
      data: FormData.fromMap({
        'data': jsonEncode(request.toJson()),
      }),
    );

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (data) => NewsModel.fromJson(data));
      },
    );
  }

  Future<BaseResponse<void>> deleteNews(int id) async {
    final response = await _dioService.delete(AdminApiRoutes.adminNewsDetail(id));

    return response.fold(
      (failure) => throw failure,
      (response) {
        final json = response.data as Map<String, dynamic>;
        return BaseResponse.fromJson(json, (_) => null);
      },
    );
  }

  List<Map<String, dynamic>> _content(dynamic data) {
    final source = data is Map<String, dynamic> ? data['content'] : data;
    if (source is! List) return const [];
    return source.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
