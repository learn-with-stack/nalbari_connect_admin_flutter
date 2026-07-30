import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/complaint_repository.dart';

// Repository provider
final complaintRepositoryProvider = Provider((ref) => ComplaintRepositoryImpl());

// List complaints provider
final complaintListProvider = FutureProvider.family<
  List<ComplaintModel>,
  ({String? status, String? areaType, int page, int size, List<String>? sort})
>((ref, params) async {
  final repository = ref.read(complaintRepositoryProvider);
  final result = await repository.getComplaints(
    status: params.status,
    areaType: params.areaType,
    page: params.page,
    size: params.size,
    sort: params.sort,
  );
  return result.fold(
    (failure) => throw failure,
    (complaints) => complaints,
  );
});

// Get single complaint provider
final complaintDetailProvider = FutureProvider.family<ComplaintModel, int>((ref, id) async {
  final repository = ref.read(complaintRepositoryProvider);
  final result = await repository.getComplaintById(id);
  return result.fold(
    (failure) => throw failure,
    (complaint) => complaint,
  );
});

// Update complaint status provider
final updateComplaintStatusProvider = FutureProvider.family<
  ComplaintModel,
  ({int id, UpdateComplaintStatusRequest request})
>((ref, params) async {
  final repository = ref.read(complaintRepositoryProvider);
  final result = await repository.updateComplaintStatus(params.id, params.request);
  return result.fold(
    (failure) => throw failure,
    (complaint) {
      ref.invalidate(complaintListProvider);
      ref.invalidate(complaintDetailProvider);
      return complaint;
    },
  );
});
