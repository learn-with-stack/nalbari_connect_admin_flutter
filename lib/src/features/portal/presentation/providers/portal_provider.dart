import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/services/admin_portal_repository.dart';
import 'package:nalbari_connect_admin/src/services/notification_service.dart';

final portalRepositoryProvider = Provider<AdminPortalRepository>((ref) {
  return AdminPortalRepository();
});

final newsProvider = FutureProvider<List<NewsItem>>((ref) {
  return ref.watch(portalRepositoryProvider).fetchNews();
});

final portalControllerProvider = StateNotifierProvider<PortalController, PortalState>((ref) {
  final controller = PortalController(ref.watch(portalRepositoryProvider));
  final subscription = NotificationService.instance.adminMessages.listen(controller.addNotification);
  ref.onDispose(subscription.cancel);
  return controller;
});

class PortalState {
  const PortalState({
    this.appointments = const [],
    this.complaints = const [],
    this.notifications = const [],
    this.appointmentPage = 0,
    this.complaintPage = 0,
    this.appointmentTotal = 0,
    this.complaintTotal = 0,
    this.hasMoreAppointments = true,
    this.hasMoreComplaints = true,
    this.isLoading = true,
    this.isMutating = false,
    this.isLoadingMoreAppointments = false,
    this.isLoadingMoreComplaints = false,
    this.error,
    this.lastMessage,
  });

  final List<AppointmentRequest> appointments;
  final List<ComplaintRequest> complaints;
  final List<AdminNotificationItem> notifications;
  final int appointmentPage;
  final int complaintPage;
  final int appointmentTotal;
  final int complaintTotal;
  final bool hasMoreAppointments;
  final bool hasMoreComplaints;
  final bool isLoading;
  final bool isMutating;
  final bool isLoadingMoreAppointments;
  final bool isLoadingMoreComplaints;
  final String? error;
  final String? lastMessage;

  int get unreadNotifications => notifications.where((item) => !item.isRead).length;

  PortalState copyWith({
    List<AppointmentRequest>? appointments,
    List<ComplaintRequest>? complaints,
    List<AdminNotificationItem>? notifications,
    int? appointmentPage,
    int? complaintPage,
    int? appointmentTotal,
    int? complaintTotal,
    bool? hasMoreAppointments,
    bool? hasMoreComplaints,
    bool? isLoading,
    bool? isMutating,
    bool? isLoadingMoreAppointments,
    bool? isLoadingMoreComplaints,
    String? error,
    String? lastMessage,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PortalState(
      appointments: appointments ?? this.appointments,
      complaints: complaints ?? this.complaints,
      notifications: notifications ?? this.notifications,
      appointmentPage: appointmentPage ?? this.appointmentPage,
      complaintPage: complaintPage ?? this.complaintPage,
      appointmentTotal: appointmentTotal ?? this.appointmentTotal,
      complaintTotal: complaintTotal ?? this.complaintTotal,
      hasMoreAppointments: hasMoreAppointments ?? this.hasMoreAppointments,
      hasMoreComplaints: hasMoreComplaints ?? this.hasMoreComplaints,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      isLoadingMoreAppointments: isLoadingMoreAppointments ?? this.isLoadingMoreAppointments,
      isLoadingMoreComplaints: isLoadingMoreComplaints ?? this.isLoadingMoreComplaints,
      error: clearError ? null : error ?? this.error,
      lastMessage: clearMessage ? null : lastMessage ?? this.lastMessage,
    );
  }
}

class PortalController extends StateNotifier<PortalState> {
  PortalController(this._repository) : super(const PortalState()) {
    load();
  }

  static const _pageLimit = 4;

  final AdminPortalRepository _repository;

  Future<void> load({
    AppointmentStatus? appointmentStatus,
    ComplaintStatus? complaintStatus,
    String? search,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearMessage: true);
    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchAppointments(
          page: 1,
          limit: _pageLimit,
          status: appointmentStatus,
          search: search,
        ),
        _repository.fetchComplaints(
          page: 1,
          limit: _pageLimit,
          status: complaintStatus,
          search: search,
        ),
        _repository.fetchNotifications(),
      ]);
      final appointmentPage = results[0] as PaginatedResponse<AppointmentRequest>;
      final complaintPage = results[1] as PaginatedResponse<ComplaintRequest>;
      state = PortalState(
        appointments: appointmentPage.items,
        complaints: complaintPage.items,
        notifications: results[2] as List<AdminNotificationItem>,
        appointmentPage: appointmentPage.page,
        complaintPage: complaintPage.page,
        appointmentTotal: appointmentPage.total,
        complaintTotal: complaintPage.total,
        hasMoreAppointments: appointmentPage.hasMore,
        hasMoreComplaints: complaintPage.hasMore,
        isLoading: false,
        lastMessage: 'Latest admin API data loaded.',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> loadMoreAppointments({
    AppointmentStatus? status,
    String? search,
  }) async {
    if (state.isLoading || state.isLoadingMoreAppointments || !state.hasMoreAppointments) return;
    state = state.copyWith(isLoadingMoreAppointments: true, clearError: true);
    try {
      final page = await _repository.fetchAppointments(
        page: state.appointmentPage + 1,
        limit: _pageLimit,
        status: status,
        search: search,
      );
      state = state.copyWith(
        appointments: [...state.appointments, ...page.items],
        appointmentPage: page.page,
        appointmentTotal: page.total,
        hasMoreAppointments: page.hasMore,
        isLoadingMoreAppointments: false,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMoreAppointments: false, error: error.toString());
    }
  }

  Future<void> loadMoreComplaints({
    ComplaintStatus? status,
    String? search,
  }) async {
    if (state.isLoading || state.isLoadingMoreComplaints || !state.hasMoreComplaints) return;
    state = state.copyWith(isLoadingMoreComplaints: true, clearError: true);
    try {
      final page = await _repository.fetchComplaints(
        page: state.complaintPage + 1,
        limit: _pageLimit,
        status: status,
        search: search,
      );
      state = state.copyWith(
        complaints: [...state.complaints, ...page.items],
        complaintPage: page.page,
        complaintTotal: page.total,
        hasMoreComplaints: page.hasMore,
        isLoadingMoreComplaints: false,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMoreComplaints: false, error: error.toString());
    }
  }

  Future<void> updateAppointmentStatus(
    String id,
    AppointmentStatus status, {
    required DateTime date,
    required String time,
    required String adminNote,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true, clearMessage: true);
    AppointmentRequest? existing;
    for (final item in state.appointments) {
      if (item.id == id) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      state = state.copyWith(isMutating: false, error: 'Appointment not found.');
      return;
    }
    try {
      final updated = await _repository.updateAppointmentStatus(existing, status, date: date, time: time, adminNote: adminNote);
      state = state.copyWith(
        appointments: [
          for (final appointment in state.appointments)
            appointment.id == id ? updated : appointment,
        ],
        isMutating: false,
        lastMessage: 'Appointment marked ${status.name}.',
      );
    } catch (error) {
      state = state.copyWith(isMutating: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> updateComplaintStatus(
    String id,
    ComplaintStatus status, {
    required String adminAction,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true, clearMessage: true);
    ComplaintRequest? existing;
    for (final item in state.complaints) {
      if (item.id == id) {
        existing = item;
        break;
      }
    }
    if (existing == null) {
      state = state.copyWith(isMutating: false, error: 'Complaint not found.');
      return;
    }
    try {
      final updated = await _repository.updateComplaintStatus(existing, status, adminAction: adminAction);
      state = state.copyWith(
        complaints: [
          for (final complaint in state.complaints)
            complaint.id == id ? updated : complaint,
        ],
        isMutating: false,
        lastMessage: 'Complaint marked ${status.name}.',
      );
    } catch (error) {
      state = state.copyWith(isMutating: false, error: error.toString());
      rethrow;
    }
  }

  void addNotification(AdminNotificationItem notification) {
    state = state.copyWith(notifications: [notification, ...state.notifications]);
  }

  void markNotificationRead(String id) {
    state = state.copyWith(
      notifications: [
        for (final notification in state.notifications)
          notification.id == id ? notification.copyWith(isRead: true) : notification,
      ],
    );
  }

  void markAllNotificationsRead() {
    state = state.copyWith(
      notifications: [for (final notification in state.notifications) notification.copyWith(isRead: true)],
    );
  }
}
