import 'package:flutter_riverpod/legacy.dart';
import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';

enum AdminDashboardTab { appointments, complaints }

final adminDashboardUiProvider = StateNotifierProvider<AdminDashboardUiController, AdminDashboardUiState>((ref) {
  return AdminDashboardUiController();
});

class AdminDashboardUiState {
  const AdminDashboardUiState({
    this.tab = AdminDashboardTab.appointments,
    this.appointmentFilter,
    this.complaintFilter,
    this.search = '',
  });

  final AdminDashboardTab tab;
  final AppointmentStatus? appointmentFilter;
  final ComplaintStatus? complaintFilter;
  final String search;

  AdminDashboardUiState copyWith({
    AdminDashboardTab? tab,
    AppointmentStatus? appointmentFilter,
    ComplaintStatus? complaintFilter,
    String? search,
    bool clearAppointmentFilter = false,
    bool clearComplaintFilter = false,
  }) {
    return AdminDashboardUiState(
      tab: tab ?? this.tab,
      appointmentFilter: clearAppointmentFilter ? null : appointmentFilter ?? this.appointmentFilter,
      complaintFilter: clearComplaintFilter ? null : complaintFilter ?? this.complaintFilter,
      search: search ?? this.search,
    );
  }
}

class AdminDashboardUiController extends StateNotifier<AdminDashboardUiState> {
  AdminDashboardUiController() : super(const AdminDashboardUiState());

  void setTab(AdminDashboardTab tab) => state = state.copyWith(tab: tab);

  void setSearch(String search) => state = state.copyWith(search: search);

  void setAppointmentFilter(AppointmentStatus? filter) {
    state = state.copyWith(appointmentFilter: filter, clearAppointmentFilter: filter == null);
  }

  void setComplaintFilter(ComplaintStatus? filter) {
    state = state.copyWith(complaintFilter: filter, clearComplaintFilter: filter == null);
  }
}
