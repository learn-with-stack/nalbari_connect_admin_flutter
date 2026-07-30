import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/datasources/admin_api_datasource.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';

abstract class AppointmentRepository {
  FutureEither<List<AppointmentModel>> getAppointments({
    String? name,
    String? mobile,
    int? officeId,
    String? status,
    int page = 0,
    int size = 20,
    List<String>? sort,
  });

  FutureEither<AppointmentModel> acceptAppointment(int id);
  FutureEither<AppointmentModel> rejectAppointment(int id, RejectAppointmentRequest request);
  FutureEither<AppointmentModel> rescheduleAppointment(int id, RescheduleAppointmentRequest request);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AdminApiDatasource _datasource = AdminApiDatasource();

  @override
  FutureEither<List<AppointmentModel>> getAppointments({
    String? name,
    String? mobile,
    int? officeId,
    String? status,
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    try {
      final response = await _datasource.getAppointments(
        name: name,
        mobile: mobile,
        officeId: officeId,
        status: status,
        page: page,
        size: size,
        sort: sort,
      );
      if (response.isSuccess && response.data != null) {
        final appointments = (response.data as List).cast<AppointmentModel>();
        return right(appointments);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppointmentModel> acceptAppointment(int id) async {
    try {
      final response = await _datasource.acceptAppointment(id);
      if (response.isSuccess && response.data != null) {
        return right(response.data as AppointmentModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppointmentModel> rejectAppointment(
    int id,
    RejectAppointmentRequest request,
  ) async {
    try {
      final response = await _datasource.rejectAppointment(id, request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as AppointmentModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppointmentModel> rescheduleAppointment(
    int id,
    RescheduleAppointmentRequest request,
  ) async {
    try {
      final response = await _datasource.rescheduleAppointment(id, request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as AppointmentModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
