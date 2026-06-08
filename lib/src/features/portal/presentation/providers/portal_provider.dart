import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/services/fake_portal_repository.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/fake_api_controls_provider.dart';
import 'package:nalbari_connect_admin/src/services/notification_service.dart';

final portalRepositoryProvider = Provider<FakePortalRepository>((ref) {
  return FakePortalRepository(ref.watch(fakeApiControlsProvider));
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
    this.isLoading = true,
    this.isMutating = false,
    this.error,
    this.lastMessage,
  });

  final List<AppointmentRequest> appointments;
  final List<ComplaintRequest> complaints;
  final List<AdminNotificationItem> notifications;
  final bool isLoading;
  final bool isMutating;
  final String? error;
  final String? lastMessage;

  int get unreadNotifications => notifications.where((item) => !item.isRead).length;

  PortalState copyWith({
    List<AppointmentRequest>? appointments,
    List<ComplaintRequest>? complaints,
    List<AdminNotificationItem>? notifications,
    bool? isLoading,
    bool? isMutating,
    String? error,
    String? lastMessage,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PortalState(
      appointments: appointments ?? this.appointments,
      complaints: complaints ?? this.complaints,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      error: clearError ? null : error ?? this.error,
      lastMessage: clearMessage ? null : lastMessage ?? this.lastMessage,
    );
  }
}

class PortalController extends StateNotifier<PortalState> {
  PortalController(this._repository) : super(const PortalState()) {
    load();
  }

  final FakePortalRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true, clearMessage: true);
    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchAppointments(),
        _repository.fetchComplaints(),
        _repository.fetchNotifications(),
      ]);
      state = PortalState(
        appointments: results[0] as List<AppointmentRequest>,
        complaints: results[1] as List<ComplaintRequest>,
        notifications: results[2] as List<AdminNotificationItem>,
        isLoading: false,
        lastMessage: 'Latest fake admin API data loaded.',
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> bookAppointment(AppointmentRequest appointment) async {
    state = state.copyWith(isMutating: true, clearError: true, clearMessage: true);
    try {
      final created = await _repository.createAppointment(appointment);
      state = state.copyWith(
        appointments: [created, ...state.appointments],
        isMutating: false,
        lastMessage: 'Appointment request submitted.',
      );
    } catch (error) {
      state = state.copyWith(isMutating: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> submitComplaint(ComplaintRequest complaint) async {
    state = state.copyWith(isMutating: true, clearError: true, clearMessage: true);
    try {
      final created = await _repository.createComplaint(complaint);
      state = state.copyWith(
        complaints: [created, ...state.complaints],
        isMutating: false,
        lastMessage: 'Complaint submitted for review.',
      );
    } catch (error) {
      state = state.copyWith(isMutating: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String id, AppointmentStatus status) async {
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
      final updated = await _repository.updateAppointmentStatus(existing, status);
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

  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
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
      final updated = await _repository.updateComplaintStatus(existing, status);
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


