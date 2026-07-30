import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/appointment_repository.dart';

// Repository provider
final appointmentRepositoryProvider = Provider((ref) => AppointmentRepositoryImpl());

// List appointments provider
final appointmentListProvider = FutureProvider.family<
  List<AppointmentModel>,
  ({
    String? name,
    String? mobile,
    int? officeId,
    String? status,
    int page,
    int size,
    List<String>? sort
  })
>((ref, params) async {
  final repository = ref.read(appointmentRepositoryProvider);
  final result = await repository.getAppointments(
    name: params.name,
    mobile: params.mobile,
    officeId: params.officeId,
    status: params.status,
    page: params.page,
    size: params.size,
    sort: params.sort,
  );
  return result.fold(
    (failure) => throw failure,
    (appointments) => appointments,
  );
});

// Accept appointment provider
final acceptAppointmentProvider = FutureProvider.family<AppointmentModel, int>((ref, id) async {
  final repository = ref.read(appointmentRepositoryProvider);
  final result = await repository.acceptAppointment(id);
  return result.fold(
    (failure) => throw failure,
    (appointment) {
      ref.invalidate(appointmentListProvider);
      return appointment;
    },
  );
});

// Reject appointment provider
final rejectAppointmentProvider = FutureProvider.family<
  AppointmentModel,
  ({int id, RejectAppointmentRequest request})
>((ref, params) async {
  final repository = ref.read(appointmentRepositoryProvider);
  final result = await repository.rejectAppointment(params.id, params.request);
  return result.fold(
    (failure) => throw failure,
    (appointment) {
      ref.invalidate(appointmentListProvider);
      return appointment;
    },
  );
});

// Reschedule appointment provider
final rescheduleAppointmentProvider = FutureProvider.family<
  AppointmentModel,
  ({int id, RescheduleAppointmentRequest request})
>((ref, params) async {
  final repository = ref.read(appointmentRepositoryProvider);
  final result = await repository.rescheduleAppointment(params.id, params.request);
  return result.fold(
    (failure) => throw failure,
    (appointment) {
      ref.invalidate(appointmentListProvider);
      return appointment;
    },
  );
});
