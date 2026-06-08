import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(newsProvider);
    final auth = ref.watch(appAuthProvider);
    final cs = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Row(
                children: [
                  AppLogoMark(size: 38.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('app.name'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        Text(auth.user?.phone ?? '', style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'home.profile'.tr(),
                    onPressed: () => context.push(AppRoutes.profile),
                    icon: const Icon(Icons.person_outline),
                  ),
                  IconButton(
                    tooltip: 'home.logout'.tr(),
                    onPressed: () async {
                      await ref.read(appAuthProvider.notifier).logout();
                      if (context.mounted) context.showSuccessSnackBar('Logged out successfully.');
                    },
                    icon: const Icon(Icons.logout_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: news.when(
                data: (items) => ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text('home.latest_news'.tr(), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800));
                    }
                    final item = items[index - 1];
                    return _NewsCard(item: item);
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Padding(
                  padding: EdgeInsets.all(24.w),
                  child: AppErrorWidget(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(newsProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.bookAppointment),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text('home.book_appointment'.tr()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.raiseComplaint),
                    icon: const Icon(Icons.report_problem_outlined),
                    label: Text('home.raise_complaint'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Card(
      color: cs.surface,
      child: InkWell(
        onTap: () => context.push(AppRoutes.newsDetail, extra: item),
        borderRadius: AppBorders.card,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: AppBorders.sm,
                ),
                child: SizedBox(
                  width: 76.w,
                  height: 76.w,
                  child: Icon(Icons.article_outlined, color: cs.primary),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateLabel(item.publishedAt), style: context.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                    SizedBox(height: 5.h),
                    Text(item.title, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    SizedBox(height: 5.h),
                    Text(item.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text('home.latest_news'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.55),
              borderRadius: AppBorders.card,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Icon(Icons.newspaper_outlined, size: 64.sp, color: cs.primary),
            ),
          ),
          SizedBox(height: 18.h),
          Text(_dateLabel(item.publishedAt), style: context.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          SizedBox(height: 8.h),
          Text(item.title, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 14.h),
          Text(item.body, style: context.textTheme.bodyLarge?.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}

String _dateLabel(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
