import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart' as admin;
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/appointment_repository.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/complaint_repository.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/news_repository.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';

class AdminPortalRepository {
  AdminPortalRepository({
    AppointmentRepository? appointmentRepository,
    ComplaintRepository? complaintRepository,
    NewsRepository? newsRepository,
  })  : _appointments = appointmentRepository ?? AppointmentRepositoryImpl(),
        _complaints = complaintRepository ?? ComplaintRepositoryImpl(),
        _news = newsRepository ?? NewsRepositoryImpl();

  final AppointmentRepository _appointments;
  final ComplaintRepository _complaints;
  final NewsRepository _news;

  Future<PaginatedResponse<AppointmentRequest>> fetchAppointments({
    required int page,
    int limit = 8,
    AppointmentStatus? status,
    String? search,
  }) async {
    final backendPage = page <= 0 ? 0 : page - 1;
    final result = await _appointments.getAppointments(
      name: _clean(search),
      status: status == null ? null : _appointmentStatusToApi(status).value,
      page: backendPage,
      size: limit,
      sort: const ['createdAt,desc'],
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => PaginatedResponse(
        items: items.map(_appointmentFromApi).toList(),
        page: page,
        limit: limit,
        total: page == 1 ? items.length : ((page - 1) * limit) + items.length,
        hasMore: items.length == limit,
      ),
    );
  }

  Future<PaginatedResponse<ComplaintRequest>> fetchComplaints({
    required int page,
    int limit = 8,
    ComplaintStatus? status,
    String? search,
  }) async {
    final backendPage = page <= 0 ? 0 : page - 1;
    final result = await _complaints.getComplaints(
      status: status == null ? null : _complaintStatusToApi(status).value,
      areaType: _areaTypeFromSearch(search),
      page: backendPage,
      size: limit,
      sort: const ['createdAt,desc'],
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => PaginatedResponse(
        items: items.map(_complaintFromApi).toList(),
        page: page,
        limit: limit,
        total: page == 1 ? items.length : ((page - 1) * limit) + items.length,
        hasMore: items.length == limit,
      ),
    );
  }

  Future<List<NewsItem>> fetchNews() async {
    final result = await _news.getNewsList(page: 0, size: 10, sort: const ['createdAt,desc']);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items.map(_newsFromApi).toList(),
    );
  }

  Future<List<AdminNotificationItem>> fetchNotifications() async {
    return const [];
  }

  Future<AppointmentRequest> updateAppointmentStatus(
    AppointmentRequest appointment,
    AppointmentStatus status, {
    required DateTime date,
    required String time,
    required String adminNote,
  }) async {
    final id = int.tryParse(appointment.id);
    if (id == null) throw Exception('Invalid appointment id.');

    final result = status == AppointmentStatus.approved
        ? await _appointments.acceptAppointment(id)
        : await _appointments.rejectAppointment(
            id,
            admin.RejectAppointmentRequest(reason: adminNote.isEmpty ? 'Rejected by admin' : adminNote),
          );

    return result.fold(
      (failure) => throw Exception(failure.message),
      _appointmentFromApi,
    );
  }

  Future<ComplaintRequest> updateComplaintStatus(
    ComplaintRequest complaint,
    ComplaintStatus status, {
    required String adminAction,
  }) async {
    final id = int.tryParse(complaint.id);
    if (id == null) throw Exception('Invalid complaint id.');

    final result = await _complaints.updateComplaintStatus(
      id,
      admin.UpdateComplaintStatusRequest(status: _complaintStatusToApi(status)),
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (updated) => _complaintFromApi(updated).copyWith(adminAction: adminAction),
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _areaTypeFromSearch(String? search) {
    final value = search?.trim().toUpperCase();
    if (value == 'WARD' || value == 'PANCHAYAT') return value;
    return null;
  }

  AppointmentRequest _appointmentFromApi(admin.AppointmentModel item) {
    return AppointmentRequest(
      id: item.id.toString(),
      fullName: item.name,
      withPerson: item.officeId == 0 ? 'Office' : 'Office #${item.officeId}',
      date: item.date,
      time: item.time.formattedTime,
      reason: item.purposeOrReason,
      status: _appointmentStatusFromApi(item.status),
      createdAt: item.createdAt,
      phoneNumber: item.mobile,
      idProofName: item.mobile.isEmpty ? null : 'Verified ID proof',
      adminNote: item.rejectionReason ?? item.rescheduledReason,
      updatedAt: item.updatedAt,
    );
  }

  ComplaintRequest _complaintFromApi(admin.ComplaintModel item) {
    return ComplaintRequest(
      id: item.id.toString(),
      reporterName: item.userName?.isNotEmpty == true ? item.userName! : 'Citizen',
      areaType: item.areaType == admin.AreaType.PANCHAYAT ? AreaType.panchayat : AreaType.ward,
      areaNumber: item.area ?? '-',
      description: item.description,
      status: _complaintStatusFromApi(item.status),
      priority: ComplaintPriority.medium,
      createdAt: item.createdAt,
      title: item.title,
      phoneNumber: item.userMobile,
      mediaName: item.mediaUrls?.isNotEmpty == true ? '${item.mediaUrls!.length} attachment(s)' : null,
      adminAction: null,
      updatedAt: item.updatedAt,
    );
  }

  NewsItem _newsFromApi(admin.NewsModel item) {
    return NewsItem(
      id: item.id.toString(),
      title: item.title,
      summary: item.description,
      body: item.description,
      publishedAt: item.createdAt,
    );
  }

  admin.AppointmentStatus _appointmentStatusToApi(AppointmentStatus status) {
    return switch (status) {
      AppointmentStatus.pending => admin.AppointmentStatus.PENDING,
      AppointmentStatus.approved => admin.AppointmentStatus.APPROVED,
      AppointmentStatus.rejected => admin.AppointmentStatus.REJECTED,
    };
  }

  AppointmentStatus _appointmentStatusFromApi(admin.AppointmentStatus status) {
    return switch (status) {
      admin.AppointmentStatus.PENDING => AppointmentStatus.pending,
      admin.AppointmentStatus.REJECTED => AppointmentStatus.rejected,
      _ => AppointmentStatus.approved,
    };
  }

  admin.ComplaintStatus _complaintStatusToApi(ComplaintStatus status) {
    return switch (status) {
      ComplaintStatus.newRequest => admin.ComplaintStatus.OPEN,
      ComplaintStatus.inReview => admin.ComplaintStatus.IN_PROGRESS,
      ComplaintStatus.resolved => admin.ComplaintStatus.RESOLVED,
    };
  }

  ComplaintStatus _complaintStatusFromApi(admin.ComplaintStatus status) {
    return switch (status) {
      admin.ComplaintStatus.OPEN => ComplaintStatus.newRequest,
      admin.ComplaintStatus.IN_PROGRESS => ComplaintStatus.inReview,
      _ => ComplaintStatus.resolved,
    };
  }
}

extension on admin.AppointmentModel {
  String get purposeOrReason => purpose.isEmpty ? rejectionReason ?? rescheduledReason ?? '-' : purpose;
}
