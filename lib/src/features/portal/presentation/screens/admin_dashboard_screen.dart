import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AppointmentStatus? _filter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portalControllerProvider);
    final appointments = state.appointments.where((item) {
      final matchesFilter = _filter == null || item.status == _filter;
      final query = _search.toLowerCase();
      final matchesSearch = query.isEmpty ||
          item.fullName.toLowerCase().contains(query) ||
          item.reason.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
    final pending = state.appointments.where((item) => item.status == AppointmentStatus.pending).length;
    final approved = state.appointments.where((item) => item.status == AppointmentStatus.approved).length;
    final rejected = state.appointments.where((item) => item.status == AppointmentStatus.rejected).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('admin.dashboard'.tr()),
        leading: Padding(
          padding: EdgeInsets.all(10.w),
          child: AppLogoMark(size: 32.w),
        ),
        actions: [
          IconButton(onPressed: () => context.push(AppRoutes.profile), icon: const Icon(Icons.person_outline)),
          IconButton(
            onPressed: () async {
              await ref.read(appAuthProvider.notifier).logout();
              if (context.mounted) context.showSuccessSnackBar('Logged out successfully.');
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(portalControllerProvider.notifier).load(),
        child: state.isLoading
            ? ListView(
                children: [
                  SizedBox(height: 260.h),
                  const Center(child: CircularProgressIndicator()),
                ],
              )
            : state.error != null
                ? ListView(
                    padding: EdgeInsets.all(24.w),
                    children: [
                      AppErrorWidget(
                        message: state.error!,
                        onRetry: () => ref.read(portalControllerProvider.notifier).load(),
                      ),
                    ],
                  )
                : ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'admin.search'.tr(),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'admin.appointments'.tr(), value: state.appointments.length.toString(), color: const Color(0xFFEFF6FF))),
                SizedBox(width: 10.w),
                Expanded(child: _MetricCard(label: 'admin.complaints'.tr(), value: state.complaints.length.toString(), color: const Color(0xFFF0FDF4))),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'admin.pending'.tr(), value: pending.toString(), color: const Color(0xFFFFFBEB))),
                SizedBox(width: 10.w),
                Expanded(child: _MetricCard(label: 'admin.approved'.tr(), value: approved.toString(), color: const Color(0xFFECFDF5))),
                SizedBox(width: 10.w),
                Expanded(child: _MetricCard(label: 'admin.rejected'.tr(), value: rejected.toString(), color: const Color(0xFFFEF2F2))),
                SizedBox(width: 10.w),
                Expanded(child: _MetricCard(label: 'admin.total'.tr(), value: state.appointments.length.toString(), color: const Color(0xFFF8FAFC))),
              ],
            ),
            SizedBox(height: 16.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: '${'admin.all'.tr()} (${state.appointments.length})', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  _FilterChip(label: '${'admin.pending'.tr()} ($pending)', selected: _filter == AppointmentStatus.pending, onTap: () => setState(() => _filter = AppointmentStatus.pending)),
                  _FilterChip(label: '${'admin.approved'.tr()} ($approved)', selected: _filter == AppointmentStatus.approved, onTap: () => setState(() => _filter = AppointmentStatus.approved)),
                  _FilterChip(label: '${'admin.rejected'.tr()} ($rejected)', selected: _filter == AppointmentStatus.rejected, onTap: () => setState(() => _filter = AppointmentStatus.rejected)),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Text('${'admin.all_appointments'.tr()}  ${appointments.length} items', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            SizedBox(height: 10.h),
            if (appointments.isEmpty)
              const AppEmptyState(title: 'No requests found')
            else
              for (final appointment in appointments) ...[
                _AppointmentAdminCard(appointment: appointment),
                SizedBox(height: 12.h),
              ],
            SizedBox(height: 12.h),
            Text('admin.complaints'.tr(), style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            SizedBox(height: 10.h),
            for (final complaint in state.complaints) ...[
              _ComplaintAdminCard(complaint: complaint),
              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppBorders.card,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            SizedBox(height: 2.h),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}

class _AppointmentAdminCard extends ConsumerWidget {
  const _AppointmentAdminCard({required this.appointment});

  final AppointmentRequest appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAct = appointment.status == AppointmentStatus.pending;
    return Card(
      color: context.colors.surface,
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(appointment.fullName, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                _StatusBadge(status: appointment.status),
              ],
            ),
            SizedBox(height: 4.h),
            Text('with ${appointment.withPerson}', style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
            SizedBox(height: 10.h),
            Text('${_dateLabel(appointment.date)}  ${appointment.time}', style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 8.h),
            Text('Reason: ${appointment.reason}', style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
            if (canAct) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _updateAppointment(context, ref, AppointmentStatus.rejected),
                    child: Text('admin.reject'.tr()),
                  ),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: () => _updateAppointment(context, ref, AppointmentStatus.approved),
                    child: Text('admin.approve'.tr()),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateAppointment(BuildContext context, WidgetRef ref, AppointmentStatus status) async {
    try {
      await ref.read(portalControllerProvider.notifier).updateAppointmentStatus(appointment.id, status);
      if (context.mounted) context.showSuccessSnackBar('Appointment marked ${status.name}.');
    } catch (error) {
      if (context.mounted) context.showErrorSnackBar(error.toString());
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AppointmentStatus.pending => ('Pending', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
      AppointmentStatus.approved => ('Approved', const Color(0xFFD1FAE5), const Color(0xFF059669)),
      AppointmentStatus.rejected => ('Rejected', const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(color: bg, borderRadius: AppBorders.full),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        child: Text(label, style: context.textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _ComplaintAdminCard extends ConsumerWidget {
  const _ComplaintAdminCard({required this.complaint});

  final ComplaintRequest complaint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: context.colors.surface,
      child: ListTile(
        leading: const Icon(Icons.report_outlined),
        title: Text('${complaint.areaType.name} ${complaint.areaNumber}'),
        subtitle: Text(complaint.description),
        trailing: PopupMenuButton<ComplaintStatus>(
          onSelected: (status) => _updateComplaint(context, ref, status),
          itemBuilder: (context) => const [
            PopupMenuItem(value: ComplaintStatus.newRequest, child: Text('New')),
            PopupMenuItem(value: ComplaintStatus.inReview, child: Text('In review')),
            PopupMenuItem(value: ComplaintStatus.resolved, child: Text('Resolved')),
          ],
        ),
      ),
    );
  }

  Future<void> _updateComplaint(BuildContext context, WidgetRef ref, ComplaintStatus status) async {
    try {
      await ref.read(portalControllerProvider.notifier).updateComplaintStatus(complaint.id, status);
      if (context.mounted) context.showSuccessSnackBar('Complaint marked ${status.name}.');
    } catch (error) {
      if (context.mounted) context.showErrorSnackBar(error.toString());
    }
  }
}

String _dateLabel(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
