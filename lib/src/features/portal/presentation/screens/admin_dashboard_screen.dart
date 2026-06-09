import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/admin_dashboard_ui_provider.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/widgets/admin_dashboard_chrome.dart';
import 'package:nalbari_connect_admin/src/imports/imports.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portalControllerProvider);
    final ui = ref.watch(adminDashboardUiProvider);
    final uiController = ref.read(adminDashboardUiProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.read(portalControllerProvider.notifier).load(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 360) {
              if (ui.tab == AdminDashboardTab.appointments) {
                ref.read(portalControllerProvider.notifier).loadMoreAppointments();
              } else {
                ref.read(portalControllerProvider.notifier).loadMoreComplaints();
              }
            }
            return false;
          },
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              AdminSearchHeader(
                unreadCount: state.unreadNotifications,
                search: ui.search,
                onSearchChanged: uiController.setSearch,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: AdminTabsHeaderDelegate(
                  child: AdminTabStrip(
                    selected: ui.tab,
                    appointmentCount: state.appointmentTotal == 0 ? state.appointments.length : state.appointmentTotal,
                    complaintCount: state.complaintTotal == 0 ? state.complaints.length : state.complaintTotal,
                    onChanged: uiController.setTab,
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
              else if (ui.tab == AdminDashboardTab.appointments)
                SliverToBoxAdapter(
                  child: _AppointmentsPanel(
                    appointments: state.appointments,
                    search: ui.search,
                    total: state.appointmentTotal,
                    hasMore: state.hasMoreAppointments,
                    isLoadingMore: state.isLoadingMoreAppointments,
                    selectedFilter: ui.appointmentFilter,
                    onFilterChanged: uiController.setAppointmentFilter,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: _ComplaintsPanel(
                    complaints: state.complaints,
                    search: ui.search,
                    total: state.complaintTotal,
                    hasMore: state.hasMoreComplaints,
                    isLoadingMore: state.isLoadingMoreComplaints,
                    selectedFilter: ui.complaintFilter,
                    onFilterChanged: uiController.setComplaintFilter,
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
              _FilterPill(label: '${'admin.pending'.tr()} ($pending)', selected: selectedFilter == AppointmentStatus.pending, onTap: () => onFilterChanged(AppointmentStatus.pending)),
              _FilterPill(label: '${'admin.approved'.tr()} ($approved)', selected: selectedFilter == AppointmentStatus.approved, onTap: () => onFilterChanged(AppointmentStatus.approved)),
              _FilterPill(label: '${'admin.rejected'.tr()} ($rejected)', selected: selectedFilter == AppointmentStatus.rejected, onTap: () => onFilterChanged(AppointmentStatus.rejected)),
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
              _FilterPill(label: '${'admin.new'.tr()} ($newCount)', selected: selectedFilter == ComplaintStatus.newRequest, onTap: () => onFilterChanged(ComplaintStatus.newRequest)),
              _FilterPill(label: '${'admin.in_review'.tr()} ($reviewCount)', selected: selectedFilter == ComplaintStatus.inReview, onTap: () => onFilterChanged(ComplaintStatus.inReview)),
              _FilterPill(label: '${'admin.resolved'.tr()} ($resolvedCount)', selected: selectedFilter == ComplaintStatus.resolved, onTap: () => onFilterChanged(ComplaintStatus.resolved)),
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
      Text('admin.items_count'.tr(args: ['$count']), style: context.textTheme.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
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
    final selectedStatus = ValueNotifier<ComplaintStatus>(complaint.status);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 24.h + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [Expanded(child: Text('admin.complaint_details'.tr(), style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))), _ComplaintBadge(status: complaint.status)]),
            SizedBox(height: 12.h),
            _DetailRow(label: 'admin.name'.tr(), value: complaint.reporterName),
            _DetailRow(label: 'admin.phone'.tr(), value: complaint.phoneNumber ?? '-'),
            _DetailRow(label: 'admin.area'.tr(), value: '${_areaTypeLabel(complaint.areaType)} ${complaint.areaNumber}'),
            _DetailRow(label: 'admin.priority'.tr(), value: _priorityLabel(complaint.priority)),
            _DetailRow(label: 'admin.issue'.tr(), value: _complaintTitle(complaint)),
            _DetailRow(label: 'admin.description'.tr(), value: complaint.description),
            _DetailRow(label: 'admin.media'.tr(), value: complaint.mediaName ?? '-'),
            if (complaint.latitude != null && complaint.longitude != null) _DetailRow(label: 'admin.location'.tr(), value: '${complaint.latitude!.toStringAsFixed(4)}, ${complaint.longitude!.toStringAsFixed(4)}'),
            // SizedBox(height: 10.h),
            // ValueListenableBuilder<ComplaintStatus>(
            //   valueListenable: selectedStatus,
            //   builder: (context, value, _) => DropdownButtonFormField<ComplaintStatus>(
            //     initialValue: value,
            //     decoration: InputDecoration(labelText: 'admin.status'.tr()),
            //     items: ComplaintStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(_complaintStatusLabel(status)))).toList(),
            //     onChanged: (status) {
            //       if (status != null) selectedStatus.value = status;
            //     },
            //   ),
            // ),
            // SizedBox(height: 10.h),
            // TextField(controller: actionController, minLines: 3, maxLines: 5, decoration: InputDecoration(labelText: 'admin.action_taken'.tr())),
            //show action taken text actionController  if not null or empty
             if (complaint.adminAction != null && complaint.adminAction!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              _DetailRow(label: 'admin.action_taken'.tr(), value: complaint.adminAction!),
            ],
            


            SizedBox(height: 14.h),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(portalControllerProvider.notifier).updateComplaintStatus(
                        complaint.id,
                        selectedStatus.value,
                        adminAction: actionController.text.trim().isEmpty ? 'admin.reviewed_by_admin'.tr() : actionController.text.trim(),
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
      ComplaintPriority.high => ('admin.high_priority'.tr(), const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
      ComplaintPriority.medium => ('admin.medium_priority'.tr(), const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      ComplaintPriority.low => ('admin.low_priority'.tr(), const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
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
    AppointmentStatus.pending => 'admin.pending'.tr(),
    AppointmentStatus.approved => 'admin.approved'.tr(),
    AppointmentStatus.rejected => 'admin.rejected'.tr(),
  };
}

String _complaintStatusLabel(ComplaintStatus status) {
  return switch (status) {
    ComplaintStatus.newRequest => 'admin.new'.tr(),
    ComplaintStatus.inReview => 'admin.in_review'.tr(),
    ComplaintStatus.resolved => 'admin.resolved'.tr(),
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
  if (complaint.description.toLowerCase().contains('billing')) return 'admin.mock_billing_issue'.tr();
  if (complaint.description.toLowerCase().contains('wait')) return 'admin.mock_wait_issue'.tr();
  if (complaint.description.toLowerCase().contains('street')) return 'admin.mock_street_issue'.tr();
  return '${_areaTypeLabel(complaint.areaType)} ${complaint.areaNumber} ${'admin.complaint'.tr()}';
}

String _areaTypeLabel(AreaType type) => type == AreaType.ward ? 'complaint.ward'.tr() : 'complaint.panchayat'.tr();

String _dateLabel(DateTime date) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inHours < 1) return '${diff.inMinutes} ${'admin.minutes_ago'.tr()}';
  if (diff.inDays < 1) return '${diff.inHours} ${'admin.hours_ago'.tr()}';
  return '${diff.inDays} ${'admin.days_ago'.tr()}';
}














