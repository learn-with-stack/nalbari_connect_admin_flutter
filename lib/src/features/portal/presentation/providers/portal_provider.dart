import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/data/services/fake_portal_repository.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/fake_api_controls_provider.dart';

final portalRepositoryProvider = Provider<FakePortalRepository>((ref) {
  return FakePortalRepository(ref.watch(fakeApiControlsProvider));
});

final newsProvider = FutureProvider<List<NewsItem>>((ref) {
  return ref.watch(portalRepositoryProvider).fetchNews();
});

final portalControllerProvider = StateNotifierProvider<PortalController, PortalState>((ref) {
  return PortalController(ref.watch(portalRepositoryProvider));
});

class PortalState {
  const PortalState({
    this.appointments = const [],
    this.complaints = const [],
    this.isLoading = true,
    this.isMutating = false,
    this.error,
    this.lastMessage,
  });

  final List<AppointmentRequest> appointments;
  final List<ComplaintRequest> complaints;
  final bool isLoading;
  final bool isMutating;
  final String? error;
  final String? lastMessage;

  PortalState copyWith({
    List<AppointmentRequest>? appointments,
    List<ComplaintRequest>? complaints,
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
      final appointments = await _repository.fetchAppointments();
      final complaints = await _repository.fetchComplaints();
      state = PortalState(
        appointments: appointments,
        complaints: complaints,
        isLoading: false,
        lastMessage: 'Latest fake API data loaded.',
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
    for (final appointment in state.appointments) {
      if (appointment.id == id) {
        existing = appointment;
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
    for (final complaint in state.complaints) {
      if (complaint.id == id) {
        existing = complaint;
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
}
