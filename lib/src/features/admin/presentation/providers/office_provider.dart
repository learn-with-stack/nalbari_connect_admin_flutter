import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/office_repository.dart';

// Repository provider
final officeRepositoryProvider = Provider((ref) => OfficeRepositoryImpl());

// List offices provider
final officeListProvider = FutureProvider.family<
  List<OfficeModel>,
  ({int page, int size, List<String>? sort})
>((ref, params) async {
  final repository = ref.read(officeRepositoryProvider);
  final result = await repository.getOffices(
    page: params.page,
    size: params.size,
    sort: params.sort,
  );
  return result.fold(
    (failure) => throw failure,
    (offices) => offices,
  );
});

// Create office provider
final createOfficeProvider = FutureProvider.family<OfficeModel, CreateOfficeRequest>((ref, request) async {
  final repository = ref.read(officeRepositoryProvider);
  final result = await repository.createOffice(request);
  return result.fold(
    (failure) => throw failure,
    (office) {
      ref.invalidate(officeListProvider);
      return office;
    },
  );
});

// Update office provider
final updateOfficeProvider = FutureProvider.family<
  OfficeModel,
  ({int id, CreateOfficeRequest request})
>((ref, params) async {
  final repository = ref.read(officeRepositoryProvider);
  final result = await repository.updateOffice(params.id, params.request);
  return result.fold(
    (failure) => throw failure,
    (office) {
      ref.invalidate(officeListProvider);
      return office;
    },
  );
});

// Delete office provider
final deleteOfficeProvider = FutureProvider.family<void, int>((ref, id) async {
  final repository = ref.read(officeRepositoryProvider);
  final result = await repository.deleteOffice(id);
  return result.fold(
    (failure) => throw failure,
    (_) {
      ref.invalidate(officeListProvider);
      return;
    },
  );
});
