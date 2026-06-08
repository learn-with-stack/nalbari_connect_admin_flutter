import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

enum _AdminTab { appointments, complaints }

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  _AdminTab _tab = _AdminTab.appointments;
  AppointmentStatus? _appointmentFilter;
  ComplaintStatus? _complaintFilter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portalControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.read(portalControllerProvider.notifier).load(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 360) {
              if (_tab == _AdminTab.appointments) {
                ref.read(portalControllerProvider.notifier).loadMoreAppointments();
              } else {
                ref.read(portalControllerProvider.notifier).loadMoreComplaints();
              }
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              _AdminHeader(
                unreadCount: state.unreadNotifications,
                search: _search,
                onSearchChanged: (value) => setState(() => _search = value),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabsHeaderDelegate(
                  child: _TabStrip(
                    selected: _tab,
                    appointmentCount: state.appointmentTotal == 0 ? state.appointments.length : state.appointmentTotal,
                    complaintCount: state.complaintTotal == 0 ? state.complaints.length : state.complaintTotal,
                    onChanged: (tab) => setState(() => _tab = tab),
                  ),
                ),
              ),
              if (state.isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 170.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (state.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: AppErrorWidget(
                      message: state.error!,
                      onRetry: () => ref.read(portalControllerProvider.notifier).load(),
                    ),
                  ),
                )
              else if (_tab == _AdminTab.appointments)
                SliverToBoxAdapter(
                  child: _AppointmentsPanel(
                    appointments: state.appointments,
                    search: _search,
                    total: state.appointmentTotal,
                    hasMore: state.hasMoreAppointments,
                    isLoadingMore: state.isLoadingMoreAppointments,
                    selectedFilter: _appointmentFilter,
                    onFilterChanged: (filter) => setState(() => _appointmentFilter = filter),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _ComplaintsPanel(
                    complaints: state.complaints,
                    search: _search,
                    total: state.complaintTotal,
                    hasMore: state.hasMoreComplaints,
                    isLoadingMore: state.isLoadingMoreComplaints,
                    selectedFilter: _complaintFilter,
                    onFilterChanged: (filter) => setState(() => _complaintFilter = filter),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.unreadCount, required this.search, required this.onSearchChanged});

  final int unreadCount;
  final String search;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 154.h,
      backgroundColor: context.colors.onSurface,
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
              style: context.textTheme.titleMedium?.copyWith(color: context.colors.surfaceContainerLowest, fontWeight: FontWeight.w900),
            ),
          ),
          _NotificationButton(unreadCount: unreadCount),
          SizedBox(width: 2.w),
          const _ProfileButton(),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF334155), Color(0xFF475569)]),
          ),
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
                  fillColor: context.colors.surfaceContainerLowest.withValues(alpha: 0.12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: context.colors.surfaceContainerLowest.withValues(alpha: 0.22)),
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
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => oldDelegate.child != child;
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
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: context.textTheme.labelSmall?.copyWith(color: context.colors.surfaceContainerLowest, fontSize: 9.sp, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
      ],
    );
  }
}


class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'profile.title'.tr(),
      onPressed: () => context.push(AppRoutes.profile),
      icon: const Icon(Icons.person_outline, color: Colors.white),
    );
  }
}
class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.selected, required this.appointmentCount, required this.complaintCount, required this.onChanged});

  final _AdminTab selected;
  final int appointmentCount;
  final int complaintCount;
  final ValueChanged<_AdminTab> onChanged;

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
            selected: selected == _AdminTab.appointments,
            onTap: () => onChanged(_AdminTab.appointments),
          ),
          _TabButton(
            icon: Icons.chat_bubble_outline,
            label: 'admin.complaints'.tr(),
            count: complaintCount,
            selected: selected == _AdminTab.complaints,
            onTap: () => onChanged(_AdminTab.complaints),
          ),
        ],
      ),
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
                  _CountPill(count: count, selected: selected),
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

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: selected ? const Color(0xFFDBEAFE) : const Color(0xFFFEE2E2), borderRadius: AppBorders.full),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
        child: Text('$count', style: context.textTheme.labelSmall?.copyWith(color: selected ? const Color(0xFF2563EB) : const Color(0xFFEF4444), fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _AppointmentsPanel extends ConsumerWidget {
  const _AppointmentsPanel({required this.appointments, required this.search, required this.total, required this.hasMore, required this.isLoadingMore, required this.selectedFilter, required this.onFilterChanged});

  final List<AppointmentRequest> appointments;
  final String search;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final AppointmentStatus? selectedFilter;
  final ValueChanged<AppointmentStatus?> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = appointments.where((item) => item.status == AppointmentStatus.pending).length;
    final approved = appointments.where((item) => item.status == AppointmentStatus.approved).length;
    final rejected = appointments.where((item) => item.status == AppointmentStatus.rejected).length;
    final filtered = appointments.where((item) {
      final q = search.toLowerCase();
      final matchesStatus = selectedFilter == null || item.status == selectedFilter;
      final matchesSearch = q.isEmpty || item.fullName.toLowerCase().contains(q) || item.reason.toLowerCase().contains(q) || item.withPerson.toLowerCase().contains(q);
      return matchesStatus && matchesSearch;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _StatusStatCard(label: 'admin.pending'.tr(), value: pending, icon: Icons.schedule, color: const Color(0xFFEA580C), bg: const Color(0xFFFFF7ED), onTap: () => onFilterChanged(AppointmentStatus.pending))),
            SizedBox(width: 10.w),
            Expanded(child: _StatusStatCard(label: 'admin.approved'.tr(), value: approved, icon: Icons.check_circle_outline, color: const Color(0xFF16A34A), bg: const Color(0xFFF0FDF4), onTap: () => onFilterChanged(AppointmentStatus.approved))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(child: _StatusStatCard(label: 'admin.rejected'.tr(), value: rejected, icon: Icons.cancel_outlined, color: const Color(0xFFDC2626), bg: const Color(0xFFFEF2F2), onTap: () => onFilterChanged(AppointmentStatus.rejected))),
            SizedBox(width: 10.w),
            Expanded(child: _StatusStatCard(label: 'admin.total'.tr(), value: appointments.length, icon: Icons.calendar_month_outlined, color: const Color(0xFF2563EB), bg: const Color(0xFFEFF6FF), onTap: () => onFilterChanged(null))),
          ]),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterPill(label: 'admin.all'.tr(), selected: selectedFilter == null, onTap: () => onFilterChanged(null)),
              _FilterPill(label: 'Pending ($pending)', selected: selectedFilter == AppointmentStatus.pending, onTap: () => onFilterChanged(AppointmentStatus.pending)),
              _FilterPill(label: 'Approved ($approved)', selected: selectedFilter == AppointmentStatus.approved, onTap: () => onFilterChanged(AppointmentStatus.approved)),
              _FilterPill(label: 'Rejected ($rejected)', selected: selectedFilter == AppointmentStatus.rejected, onTap: () => onFilterChanged(AppointmentStatus.rejected)),
            ]),
          ),
          SizedBox(height: 14.h),
          _SectionTitle(title: selectedFilter == null ? 'admin.all_appointments'.tr() : '${_appointmentStatusLabel(selectedFilter!)} ${'admin.appointments'.tr()}', count: filtered.length, loaded: appointments.length, total: total),
          SizedBox(height: 10.h),
          if (filtered.isEmpty)
            AppEmptyState(title: 'admin.no_appointments'.tr())
          else
            for (final appointment in filtered) ...[
              _AppointmentCard(appointment: appointment),
              SizedBox(height: 10.h),
            ],
          _PaginationFooter(isLoading: isLoadingMore, hasMore: hasMore),
        ],
      ),
    );
  }
}

class _ComplaintsPanel extends ConsumerWidget {
  const _ComplaintsPanel({required this.complaints, required this.search, required this.total, required this.hasMore, required this.isLoadingMore, required this.selectedFilter, required this.onFilterChanged});

  final List<ComplaintRequest> complaints;
  final String search;
  final int total;
  final bool hasMore;
  final bool isLoadingMore;
  final ComplaintStatus? selectedFilter;
  final ValueChanged<ComplaintStatus?> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newCount = complaints.where((item) => item.status == ComplaintStatus.newRequest).length;
    final reviewCount = complaints.where((item) => item.status == ComplaintStatus.inReview).length;
    final resolvedCount = complaints.where((item) => item.status == ComplaintStatus.resolved).length;
    final filtered = complaints.where((item) {
      final q = search.toLowerCase();
      final matchesStatus = selectedFilter == null || item.status == selectedFilter;
      final matchesSearch = q.isEmpty || item.reporterName.toLowerCase().contains(q) || item.description.toLowerCase().contains(q) || '${item.areaType.name} ${item.areaNumber}'.contains(q);
      return matchesStatus && matchesSearch;
    }).toList();

    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          Row(children: [
            Expanded(child: _CompactStat(label: 'admin.new'.tr(), value: newCount, bg: const Color(0xFFFAF5FF), fg: const Color(0xFF9333EA))),
            SizedBox(width: 10.w),
            Expanded(child: _CompactStat(label: 'admin.in_review'.tr(), value: reviewCount, bg: const Color(0xFFEFF6FF), fg: const Color(0xFF2563EB))),
            SizedBox(width: 10.w),
            Expanded(child: _CompactStat(label: 'admin.resolved'.tr(), value: resolvedCount, bg: const Color(0xFFF0FDF4), fg: const Color(0xFF16A34A))),
          ]),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterPill(label: 'admin.all'.tr(), selected: selectedFilter == null, onTap: () => onFilterChanged(null)),
              _FilterPill(label: 'New ($newCount)', selected: selectedFilter == ComplaintStatus.newRequest, onTap: () => onFilterChanged(ComplaintStatus.newRequest)),
              _FilterPill(label: 'In Review ($reviewCount)', selected: selectedFilter == ComplaintStatus.inReview, onTap: () => onFilterChanged(ComplaintStatus.inReview)),
              _FilterPill(label: 'Resolved ($resolvedCount)', selected: selectedFilter == ComplaintStatus.resolved, onTap: () => onFilterChanged(ComplaintStatus.resolved)),
            ]),
          ),
          SizedBox(height: 14.h),
          _SectionTitle(title: 'admin.complaints_title'.tr(), count: filtered.length, loaded: complaints.length, total: total),
          SizedBox(height: 10.h),
          if (filtered.isEmpty)
            AppEmptyState(title: 'admin.no_complaints'.tr())
          else
            for (final complaint in filtered) ...[
              _ComplaintCard(complaint: complaint),
              SizedBox(height: 10.h),
            ],
          _PaginationFooter(isLoading: isLoadingMore, hasMore: hasMore),
        ],
      ),
    );
  }
}

class _StatusStatCard extends StatelessWidget {
  const _StatusStatCard({required this.label, required this.value, required this.icon, required this.color, required this.bg, required this.onTap});

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.card,
      child: DecoratedBox(
        decoration: BoxDecoration(color: bg, borderRadius: AppBorders.card, border: Border.all(color: color.withValues(alpha: 0.18)), boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 3))]),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: context.textTheme.labelMedium?.copyWith(color: color)),
                  SizedBox(height: 5.h),
                  Text('$value', style: context.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w900)),
                ]),
              ),
              DecoratedBox(
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
                child: Padding(padding: EdgeInsets.all(10.w), child: Icon(icon, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({required this.label, required this.value, required this.bg, required this.fg});

  final String label;
  final int value;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppBorders.card, border: Border.all(color: fg.withValues(alpha: 0.14)), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 3))]),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.labelSmall?.copyWith(color: fg)),
          SizedBox(height: 8.h),
          Text('$value', style: context.textTheme.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.full,
        child: DecoratedBox(
          decoration: BoxDecoration(color: selected ? context.colors.primary : context.colors.surfaceContainerHigh, borderRadius: AppBorders.full),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
            child: Text(label, style: context.textTheme.labelMedium?.copyWith(color: selected ? context.colors.onPrimary : context.colors.onSurfaceVariant, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count, required this.loaded, required this.total});

  final String title;
  final int count;
  final int loaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(title, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))),
      Text('$count items', style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
    ]);
  }
}


class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.isLoading, required this.hasMore});

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text('admin.end_of_list'.tr(), textAlign: TextAlign.center, style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
      );
    }
    return SizedBox(height: 8.h);
  }
}
class _AppointmentCard extends ConsumerWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentRequest appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAct = appointment.status == AppointmentStatus.pending;
    return InkWell(
      onTap: () => _showAppointmentDetails(context, ref),
      borderRadius: AppBorders.card,
      child: Card(
        color: context.colors.surfaceContainerLowest,
        child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: AppBorders.full),
              child: Padding(padding: EdgeInsets.all(12.w), child: const Icon(Icons.person_outline, color: Color(0xFF475569))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(appointment.fullName, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
              SizedBox(height: 2.h),
              Text('${'admin.with'.tr()} ${appointment.withPerson}', style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
            ])),
            _AppointmentBadge(status: appointment.status),
          ]),
          SizedBox(height: 12.h),
          _MetaRow(icon: Icons.calendar_month_outlined, text: _dateLabel(appointment.date)),
          SizedBox(height: 5.h),
          _MetaRow(icon: Icons.schedule, text: appointment.time),
          SizedBox(height: 12.h),
          Text('${'admin.reason'.tr()}: ${appointment.reason}', style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurface)),
          if (canAct) ...[
            SizedBox(height: 14.h),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _showAppointmentAction(context, ref, AppointmentStatus.rejected), icon: const Icon(Icons.close, size: 16), label: Text('admin.reject'.tr()))),
              SizedBox(width: 10.w),
              Expanded(child: FilledButton.icon(onPressed: () => _showAppointmentAction(context, ref, AppointmentStatus.approved), icon: const Icon(Icons.check, size: 16), label: Text('admin.approve'.tr()), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF16A34A)))),
            ]),
          ],
        ]),
      ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, WidgetRef ref) {
    final canAct = appointment.status == AppointmentStatus.pending;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [Expanded(child: Text('admin.appointment_details'.tr(), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))), _AppointmentBadge(status: appointment.status)]),
          SizedBox(height: 12.h),
          _DetailRow(label: 'admin.name'.tr(), value: appointment.fullName),
          _DetailRow(label: 'admin.phone'.tr(), value: appointment.phoneNumber ?? '-'),
          _DetailRow(label: 'admin.with_person'.tr(), value: appointment.withPerson),
          _DetailRow(label: 'admin.date'.tr(), value: _dateLabel(appointment.date)),
          _DetailRow(label: 'admin.time'.tr(), value: appointment.time),
          _DetailRow(label: 'admin.id_proof'.tr(), value: appointment.idProofName ?? '-'),
          _DetailRow(label: 'admin.reason'.tr(), value: appointment.reason),
          if (appointment.adminNote?.isNotEmpty ?? false) _DetailRow(label: 'admin.admin_note'.tr(), value: appointment.adminNote!),
          if (canAct) ...[
            SizedBox(height: 12.h),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _showAppointmentAction(context, ref, AppointmentStatus.rejected); }, icon: const Icon(Icons.close), label: Text('admin.reject'.tr()))),
              SizedBox(width: 10.w),
              Expanded(child: FilledButton.icon(onPressed: () { Navigator.pop(context); _showAppointmentAction(context, ref, AppointmentStatus.approved); }, icon: const Icon(Icons.check), label: Text('admin.approve'.tr()))),
            ]),
          ],
        ]),
      ),
    );
  }

  void _showAppointmentAction(BuildContext context, WidgetRef ref, AppointmentStatus status) {
    final dateController = TextEditingController(text: appointment.date.toIso8601String().split('T').first);
    final timeController = TextEditingController(text: appointment.time);
    final noteController = TextEditingController(text: appointment.adminNote ?? (status == AppointmentStatus.approved ? 'Approved by admin.' : 'Rejected by admin.'));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(status == AppointmentStatus.approved ? 'admin.approve_appointment'.tr() : 'admin.reject_appointment'.tr(), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          SizedBox(height: 12.h),
          TextField(controller: dateController, decoration: InputDecoration(labelText: 'admin.date'.tr(), prefixIcon: const Icon(Icons.calendar_month_outlined))),
          SizedBox(height: 10.h),
          TextField(controller: timeController, decoration: InputDecoration(labelText: 'admin.time'.tr(), prefixIcon: const Icon(Icons.schedule))),
          SizedBox(height: 10.h),
          TextField(controller: noteController, minLines: 2, maxLines: 4, decoration: InputDecoration(labelText: 'admin.admin_note'.tr())),
          SizedBox(height: 14.h),
          FilledButton(
            onPressed: () async {
              final parsedDate = DateTime.tryParse(dateController.text.trim());
              if (parsedDate == null || timeController.text.trim().isEmpty) {
                context.showErrorSnackBar('admin.invalid_schedule'.tr());
                return;
              }
              try {
                await ref.read(portalControllerProvider.notifier).updateAppointmentStatus(appointment.id, status, date: parsedDate, time: timeController.text.trim(), adminNote: noteController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSuccessSnackBar('admin.appointment_updated'.tr());
                }
              } catch (error) {
                if (context.mounted) context.showErrorSnackBar(error.toString());
              }
            },
            child: Text('admin.save_changes'.tr()),
          ),
        ]),
      ),
    );
  }
}

class _ComplaintCard extends ConsumerWidget {
  const _ComplaintCard({required this.complaint});

  final ComplaintRequest complaint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showComplaintActions(context, ref),
      borderRadius: AppBorders.card,
      child: Card(
        color: context.colors.surfaceContainerLowest,
        child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: AppBorders.full),
              child: Padding(padding: EdgeInsets.all(12.w), child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF475569))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(complaint.reporterName, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
              SizedBox(height: 2.h),
              Text('${_timeAgo(complaint.createdAt)} • ${complaint.areaType.name} ${complaint.areaNumber}', style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _PriorityBadge(priority: complaint.priority),
              SizedBox(height: 6.h),
              _ComplaintBadge(status: complaint.status),
            ]),
          ]),
          SizedBox(height: 14.h),
          Text(_complaintTitle(complaint), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          SizedBox(height: 8.h),
          Text(complaint.description, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurface)),
          if (complaint.latitude != null && complaint.longitude != null) ...[
            SizedBox(height: 8.h),
            _MetaRow(icon: Icons.location_on_outlined, text: '${complaint.latitude!.toStringAsFixed(4)}, ${complaint.longitude!.toStringAsFixed(4)}'),
          ],
          SizedBox(height: 12.h),
          FilledButton(
            onPressed: () => _showComplaintActions(context, ref),
            style: FilledButton.styleFrom(backgroundColor: context.colors.onSurfaceVariant, minimumSize: Size.fromHeight(46.h)),
            child: Text('admin.view_details'.tr()),
          ),
        ]),
      ),
      ),
    );
  }

  void _showComplaintActions(BuildContext context, WidgetRef ref) {
    final actionController = TextEditingController(text: complaint.adminAction ?? '');
    var selectedStatus = complaint.status;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [Expanded(child: Text('admin.complaint_details'.tr(), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))), _ComplaintBadge(status: complaint.status)]),
              SizedBox(height: 12.h),
              _DetailRow(label: 'admin.name'.tr(), value: complaint.reporterName),
              _DetailRow(label: 'admin.phone'.tr(), value: complaint.phoneNumber ?? '-'),
              _DetailRow(label: 'admin.area'.tr(), value: '${complaint.areaType.name} ${complaint.areaNumber}'),
              _DetailRow(label: 'admin.priority'.tr(), value: _priorityLabel(complaint.priority)),
              _DetailRow(label: 'admin.issue'.tr(), value: _complaintTitle(complaint)),
              _DetailRow(label: 'admin.description'.tr(), value: complaint.description),
              _DetailRow(label: 'admin.media'.tr(), value: complaint.mediaName ?? '-'),
              if (complaint.latitude != null && complaint.longitude != null) _DetailRow(label: 'admin.location'.tr(), value: '${complaint.latitude!.toStringAsFixed(4)}, ${complaint.longitude!.toStringAsFixed(4)}'),
              SizedBox(height: 10.h),
              DropdownButtonFormField<ComplaintStatus>(
                initialValue: selectedStatus,
                decoration: InputDecoration(labelText: 'admin.status'.tr()),
                items: ComplaintStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(_complaintStatusLabel(status)))).toList(),
                onChanged: (status) => setSheetState(() => selectedStatus = status ?? selectedStatus),
              ),
              SizedBox(height: 10.h),
              TextField(controller: actionController, minLines: 3, maxLines: 5, decoration: InputDecoration(labelText: 'admin.action_taken'.tr())),
              SizedBox(height: 14.h),
              FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(portalControllerProvider.notifier).updateComplaintStatus(
                          complaint.id,
                          selectedStatus,
                          adminAction: actionController.text.trim().isEmpty ? 'Reviewed by admin.' : actionController.text.trim(),
                        );
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSuccessSnackBar('admin.complaint_updated'.tr());
                    }
                  } catch (error) {
                    if (context.mounted) context.showErrorSnackBar(error.toString());
                  }
                },
                child: Text('admin.save_changes'.tr()),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w800)),
        SizedBox(height: 2.h),
        Text(value, style: context.textTheme.bodyMedium),
      ]),
    );
  }
}
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon, size: 15.sp, color: context.colors.onSurfaceVariant), SizedBox(width: 6.w), Text(text, style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant))]);
  }
}

class _AppointmentBadge extends StatelessWidget {
  const _AppointmentBadge({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      AppointmentStatus.pending => (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      AppointmentStatus.approved => (const Color(0xFFECFDF5), const Color(0xFF059669)),
      AppointmentStatus.rejected => (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
    };
    return _SmallBadge(label: _appointmentStatusLabel(status), bg: bg, fg: fg);
  }
}

class _ComplaintBadge extends StatelessWidget {
  const _ComplaintBadge({required this.status});

  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      ComplaintStatus.newRequest => (const Color(0xFFFAF5FF), const Color(0xFF9333EA)),
      ComplaintStatus.inReview => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
      ComplaintStatus.resolved => (const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
    };
    return _SmallBadge(label: _complaintStatusLabel(status), bg: bg, fg: fg);
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final ComplaintPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (priority) {
      ComplaintPriority.high => ('High Priority', const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
      ComplaintPriority.medium => ('Medium Priority', const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      ComplaintPriority.low => ('Low Priority', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
    };
    return _SmallBadge(label: label, bg: bg, fg: fg);
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppBorders.full, border: Border.all(color: fg.withValues(alpha: 0.24))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        child: Text(label, style: context.textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

String _appointmentStatusLabel(AppointmentStatus status) {
  return switch (status) {
    AppointmentStatus.pending => 'Pending',
    AppointmentStatus.approved => 'Approved',
    AppointmentStatus.rejected => 'Rejected',
  };
}

String _complaintStatusLabel(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.newRequest => 'New',
    ComplaintStatus.inReview => 'In Review',
    ComplaintStatus.resolved => 'Resolved',
  };
}


String _priorityLabel(ComplaintPriority priority) {
  return switch (priority) {
    ComplaintPriority.high => 'admin.high_priority'.tr(),
    ComplaintPriority.medium => 'admin.medium_priority'.tr(),
    ComplaintPriority.low => 'admin.low_priority'.tr(),
  };
}

String _complaintTitle(ComplaintRequest complaint) {
  if (complaint.description.toLowerCase().contains('billing')) return 'Billing discrepancy';
  if (complaint.description.toLowerCase().contains('wait')) return 'Long wait time in emergency room';
  if (complaint.description.toLowerCase().contains('street')) return 'Street light issue resolved';
  return '${complaint.areaType.name} ${complaint.areaNumber} complaint';
}

String _dateLabel(DateTime date) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}














