import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/datasources/admin_api_datasource.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';

abstract class ComplaintRepository {
  FutureEither<List<ComplaintModel>> getComplaints({
    String? status,
    String? areaType,
    int page = 0,
    int size = 20,
    List<String>? sort,
  });

  FutureEither<ComplaintModel> getComplaintById(int id);
  FutureEither<ComplaintModel> updateComplaintStatus(int id, UpdateComplaintStatusRequest request);
}

class ComplaintRepositoryImpl implements ComplaintRepository {
  final AdminApiDatasource _datasource = AdminApiDatasource();

  @override
  FutureEither<List<ComplaintModel>> getComplaints({
    String? status,
    String? areaType,
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    try {
      final response = await _datasource.getComplaints(
        status: status,
        areaType: areaType,
        page: page,
        size: size,
        sort: sort,
      );
      if (response.isSuccess && response.data != null) {
        final complaints = (response.data as List).cast<ComplaintModel>();
        return right(complaints);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<ComplaintModel> getComplaintById(int id) async {
    try {
      final response = await _datasource.getComplaintById(id);
      if (response.isSuccess && response.data != null) {
        return right(response.data as ComplaintModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<ComplaintModel> updateComplaintStatus(
    int id,
    UpdateComplaintStatusRequest request,
  ) async {
    try {
      final response = await _datasource.updateComplaintStatus(id, request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as ComplaintModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
