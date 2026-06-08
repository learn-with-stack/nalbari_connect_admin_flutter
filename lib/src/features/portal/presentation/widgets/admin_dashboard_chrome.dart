import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/admin_dashboard_ui_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class AdminSearchHeader extends StatelessWidget {
  const AdminSearchHeader({required this.unreadCount, required this.search, required this.onSearchChanged, super.key});

  final int unreadCount;
  final String search;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 154.h,
      backgroundColor: const Color(0xFF334155),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          AppLogoMark(size: 34.w, radius: 8.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'admin.dashboard'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
          _NotificationButton(unreadCount: unreadCount),
          SizedBox(width: 2.w),
          IconButton(
            tooltip: 'profile.title'.tr(),
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.person_outline, color: Colors.white),
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF334155), Color(0xFF475569)])),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12.w, 76.h, 12.w, 12.h),
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'admin.search'.tr(),
                  hintStyle: const TextStyle(color: Color(0xFFD8DEE9)),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFD8DEE9)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const AdminTabsHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant AdminTabsHeaderDelegate oldDelegate) => oldDelegate.child != child;
}

class AdminTabStrip extends StatelessWidget {
  const AdminTabStrip({required this.selected, required this.appointmentCount, required this.complaintCount, required this.onChanged, super.key});

  final AdminDashboardTab selected;
  final int appointmentCount;
  final int complaintCount;
  final ValueChanged<AdminDashboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.surface, border: Border(bottom: BorderSide(color: context.colors.outlineVariant))),
      child: Row(
        children: [
          _TabButton(
            icon: Icons.calendar_month_outlined,
            label: 'admin.appointments'.tr(),
            count: appointmentCount,
            selected: selected == AdminDashboardTab.appointments,
            onTap: () => onChanged(AdminDashboardTab.appointments),
          ),
          _TabButton(
            icon: Icons.chat_bubble_outline,
            label: 'admin.complaints'.tr(),
            count: complaintCount,
            selected: selected == AdminDashboardTab.complaints,
            onTap: () => onChanged(AdminDashboardTab.complaints),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'notifications.title'.tr(),
          onPressed: () => context.push(AppRoutes.notifications),
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 7,
            top: 5,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFFE11D48), shape: BoxShape.circle),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(unreadCount > 9 ? '9+' : '$unreadCount', style: context.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.icon, required this.label, required this.count, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.colors.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 14.h, 8.w, 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18.sp, color: color),
                  SizedBox(width: 7.w),
                  Text(label, style: context.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w800)),
                  SizedBox(width: 6.w),
                  DecoratedBox(
                    decoration: BoxDecoration(color: selected ? context.colors.primaryContainer : context.colors.surfaceContainerHighest, borderRadius: AppBorders.full),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      child: Text('$count', style: context.textTheme.labelSmall?.copyWith(color: selected ? context.colors.onPrimaryContainer : context.colors.onSurfaceVariant, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 11.h),
              SizedBox(height: 2.h, child: DecoratedBox(decoration: BoxDecoration(color: selected ? color : Colors.transparent))),
            ],
          ),
        ),
      ),
    );
  }
}
