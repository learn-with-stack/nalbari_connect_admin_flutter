import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/datasources/admin_api_datasource.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';

abstract class OfficeRepository {
  FutureEither<List<OfficeModel>> getOffices({
    int page = 0,
    int size = 20,
    List<String>? sort,
  });

  FutureEither<OfficeModel> createOffice(CreateOfficeRequest request);
  FutureEither<OfficeModel> updateOffice(int id, CreateOfficeRequest request);
  FutureEither<void> deleteOffice(int id);
}

class OfficeRepositoryImpl implements OfficeRepository {
  final AdminApiDatasource _datasource = AdminApiDatasource();

  @override
  FutureEither<List<OfficeModel>> getOffices({
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    try {
      final response = await _datasource.getOffices(page: page, size: size, sort: sort);
      if (response.isSuccess && response.data != null) {
        final offices = (response.data as List).cast<OfficeModel>();
        return right(offices);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<OfficeModel> createOffice(CreateOfficeRequest request) async {
    try {
      final response = await _datasource.createOffice(request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as OfficeModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<OfficeModel> updateOffice(int id, CreateOfficeRequest request) async {
    try {
      final response = await _datasource.updateOffice(id, request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as OfficeModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteOffice(int id) async {
    try {
      final response = await _datasource.deleteOffice(id);
      if (response.isSuccess) {
        return right(null);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
