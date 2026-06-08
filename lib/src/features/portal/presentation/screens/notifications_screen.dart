import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portalControllerProvider);
    final notifications = state.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty ? null : () => ref.read(portalControllerProvider.notifier).markAllNotificationsRead(),
            child: const Text('Mark all'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const AppEmptyState(title: 'No notifications yet')
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return InkWell(
                  onTap: () => ref.read(portalControllerProvider.notifier).markNotificationRead(item.id),
                  borderRadius: AppBorders.card,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(14.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NotificationIcon(type: item.type),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    if (!item.isRead)
                                      SizedBox.square(
                                        dimension: 8.w,
                                        child: const DecoratedBox(
                                          decoration: BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(item.message, style: context.textTheme.bodySmall?.copyWith(color: const Color(0xFF475569))),
                                SizedBox(height: 8.h),
                                Text(_timeAgo(item.createdAt), style: context.textTheme.labelSmall?.copyWith(color: const Color(0xFF94A3B8))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type});

  final AdminNotificationType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (type) {
      AdminNotificationType.appointment => (Icons.calendar_month_outlined, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
      AdminNotificationType.complaint => (Icons.chat_bubble_outline, const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
      AdminNotificationType.system => (Icons.notifications_outlined, const Color(0xFF475569), const Color(0xFFF1F5F9)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppBorders.full),
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}

