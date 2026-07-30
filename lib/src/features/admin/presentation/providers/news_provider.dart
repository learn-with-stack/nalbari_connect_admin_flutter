import 'package:nalbari_connect_admin/src/imports/packages_imports.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/models/models.dart';
import 'package:nalbari_connect_admin/src/features/admin/data/repositories/news_repository.dart';

// Repository provider
final newsRepositoryProvider = Provider((ref) => NewsRepositoryImpl());

// List news provider
final newsListProvider = FutureProvider.family<
  List<NewsModel>,
  ({int page, int size, List<String>? sort})
>((ref, params) async {
  final repository = ref.read(newsRepositoryProvider);
  final result = await repository.getNewsList(
    page: params.page,
    size: params.size,
    sort: params.sort,
  );
  return result.fold(
    (failure) => throw failure,
    (newsList) => newsList,
  );
});

// Get single news provider
final newsDetailProvider = FutureProvider.family<NewsModel, int>((ref, id) async {
  final repository = ref.read(newsRepositoryProvider);
  final result = await repository.getNewsById(id);
  return result.fold(
    (failure) => throw failure,
    (news) => news,
  );
});

// Create news provider
final createNewsProvider = FutureProvider.family<NewsModel, CreateNewsRequest>((ref, request) async {
  final repository = ref.read(newsRepositoryProvider);
  final result = await repository.createNews(request);
  return result.fold(
    (failure) => throw failure,
    (news) {
      ref.invalidate(newsListProvider);
      return news;
    },
  );
});

// Update news provider
final updateNewsProvider = FutureProvider.family<
  NewsModel,
  ({int id, CreateNewsRequest request})
>((ref, params) async {
  final repository = ref.read(newsRepositoryProvider);
  final result = await repository.updateNews(params.id, params.request);
  return result.fold(
    (failure) => throw failure,
    (news) {
      ref.invalidate(newsListProvider);
      ref.invalidate(newsDetailProvider);
      return news;
    },
  );
});

// Delete news provider
final deleteNewsProvider = FutureProvider.family<void, int>((ref, id) async {
  final repository = ref.read(newsRepositoryProvider);
  final result = await repository.deleteNews(id);
  return result.fold(
    (failure) => throw failure,
    (_) {
      ref.invalidate(newsListProvider);
      return;
    },
  );
});
