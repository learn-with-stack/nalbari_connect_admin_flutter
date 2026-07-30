import 'package:nalbari_connect_admin/src/imports/core_imports.dart';
import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/datasources/admin_api_datasource.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';

abstract class NewsRepository {
  FutureEither<List<NewsModel>> getNewsList({
    int page = 0,
    int size = 20,
    List<String>? sort,
  });

  FutureEither<NewsModel> getNewsById(int id);
  FutureEither<NewsModel> createNews(CreateNewsRequest request);
  FutureEither<NewsModel> updateNews(int id, CreateNewsRequest request);
  FutureEither<void> deleteNews(int id);
}

class NewsRepositoryImpl implements NewsRepository {
  final AdminApiDatasource _datasource = AdminApiDatasource();

  @override
  FutureEither<List<NewsModel>> getNewsList({
    int page = 0,
    int size = 20,
    List<String>? sort,
  }) async {
    try {
      final response = await _datasource.getNewsList(page: page, size: size, sort: sort);
      if (response.isSuccess && response.data != null) {
        final newsList = (response.data as List).cast<NewsModel>();
        return right(newsList);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<NewsModel> getNewsById(int id) async {
    try {
      final response = await _datasource.getNewsById(id);
      if (response.isSuccess && response.data != null) {
        return right(response.data as NewsModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<NewsModel> createNews(CreateNewsRequest request) async {
    try {
      final response = await _datasource.createNews(request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as NewsModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<NewsModel> updateNews(int id, CreateNewsRequest request) async {
    try {
      final response = await _datasource.updateNews(id, request);
      if (response.isSuccess && response.data != null) {
        return right(response.data as NewsModel);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> deleteNews(int id) async {
    try {
      final response = await _datasource.deleteNews(id);
      if (response.isSuccess) {
        return right(null);
      }
      return left(ServerFailure(response.message));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
