import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  final _nameController = TextEditingController();
  DateTime _date = DateTime(2026, 6, 8);
  String _time = '10:00 AM';
  String? _idFileName;

  static const _times = ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthProvider);
    final idLinked = auth.user?.idProofLinked ?? false;
    return Scaffold(
      appBar: AppBar(title: Text('appointment.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text('appointment.select_date'.tr(), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text('${_date.month}/${_date.day}/${_date.year}'),
          ),
          SizedBox(height: 20.h),
          Text('appointment.select_time'.tr(), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final time in _times)
                ChoiceChip(
                  label: Text(time),
                  selected: _time == time,
                  onSelected: (_) => setState(() => _time = time),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          AppTextField(
            controller: _nameController,
            label: 'appointment.full_name'.tr(),
            hint: 'appointment.full_name_hint'.tr(),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          SizedBox(height: 20.h),
          Text('appointment.id_proof'.tr(), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          _UploadBox(
            icon: idLinked ? Icons.verified_user_outlined : Icons.upload_file_outlined,
            title: idLinked ? 'appointment.id_saved'.tr() : (_idFileName ?? 'appointment.upload_id'.tr()),
            subtitle: idLinked ? 'Aadhaar / voter document linked to profile' : 'PNG, JPG up to 5MB',
            onTap: idLinked
                ? null
                : () async {
                    final result = await FilePicker.platform.pickFiles(type: FileType.image);
                    if (result == null) return;
                    setState(() => _idFileName = result.files.single.name);
                    await ref.read(appAuthProvider.notifier).markIdProofLinked();
                  },
          ),
          SizedBox(height: 26.h),
          FilledButton(
            onPressed: () async {
              final name = _nameController.text.trim().isEmpty ? (auth.user?.name ?? 'Verified Resident') : _nameController.text.trim();
              try {
                await ref.read(portalControllerProvider.notifier).bookAppointment(
                  AppointmentRequest(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    fullName: name,
                    withPerson: 'MLA Office',
                    date: _date,
                    time: _time,
                    reason: 'Personal appointment request',
                    status: AppointmentStatus.pending,
                    createdAt: DateTime.now(),
                  ),
                );
                if (!context.mounted) return;
                context.showSuccessSnackBar('appointment.success'.tr());
                context.pop();
              } catch (error) {
                if (context.mounted) context.showErrorSnackBar(error.toString());
              }
            },
            child: Text('appointment.book'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorders.card,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: AppBorders.card,
          border: Border.all(color: cs.outlineVariant, width: 1.2),
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 34.sp),
              SizedBox(height: 8.h),
              Text(title, textAlign: TextAlign.center, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 4.h),
              Text(subtitle, textAlign: TextAlign.center, style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
