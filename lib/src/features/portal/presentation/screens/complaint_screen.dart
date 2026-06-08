import 'package:nalbari_connect/src/features/auth/presentation/providers/app_auth_provider.dart';
import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/portal_provider.dart';
import 'package:nalbari_connect/src/imports/imports.dart';

class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  final _areaController = TextEditingController();
  final _detailsController = TextEditingController();
  AreaType _areaType = AreaType.ward;
  String? _mediaName;
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  @override
  void dispose() {
    _areaController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(appAuthProvider);
    return Scaffold(
      appBar: AppBar(title: Text('complaint.title'.tr())),
      body: ListView(
        padding: EdgeInsets.all(20.w),
        children: [
          Text('complaint.area_type'.tr(), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          SegmentedButton<AreaType>(
            segments: [
              ButtonSegment(value: AreaType.ward, label: Text('complaint.ward'.tr())),
              ButtonSegment(value: AreaType.panchayat, label: Text('complaint.panchayat'.tr())),
            ],
            selected: {_areaType},
            onSelectionChanged: (value) => setState(() => _areaType = value.first),
          ),
          SizedBox(height: 16.h),
          AppTextField(
            controller: _areaController,
            label: _areaType == AreaType.ward ? 'complaint.ward_number'.tr() : 'complaint.panchayat_number'.tr(),
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
          SizedBox(height: 18.h),
          AppTextField(
            controller: _detailsController,
            label: 'complaint.describe'.tr(),
            hint: 'complaint.describe_hint'.tr(),
            minLines: 5,
            maxLines: 7,
          ),
          SizedBox(height: 18.h),
          Text('complaint.media'.tr(), style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          _ComplaintUploadBox(
            title: _mediaName ?? 'complaint.upload_media'.tr(),
            onTap: _showMediaPicker,
          ),
          SizedBox(height: 18.h),
          _LocationBox(
            latitude: _latitude,
            longitude: _longitude,
            isLoading: _isLocating,
            onTap: _captureLocation,
          ),
          SizedBox(height: 26.h),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(portalControllerProvider.notifier).submitComplaint(
                  ComplaintRequest(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    reporterName: auth.user?.name ?? 'Verified Resident',
                    areaType: _areaType,
                    areaNumber: _areaController.text.trim().isEmpty ? 'Not provided' : _areaController.text.trim(),
                    description: _detailsController.text.trim().isEmpty ? 'Local issue reported by citizen.' : _detailsController.text.trim(),
                    status: ComplaintStatus.newRequest,
                    priority: ComplaintPriority.medium,
                    createdAt: DateTime.now(),
                    mediaName: _mediaName,
                    latitude: _latitude,
                    longitude: _longitude,
                  ),
                );
                if (!context.mounted) return;
                context.showSuccessSnackBar('complaint.success'.tr());
                context.pop();
              } catch (error) {
                if (context.mounted) context.showErrorSnackBar(error.toString());
              }
            },
            child: Text('complaint.submit'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _showMediaPicker() async {
    final source = await showModalBottomSheet<_MediaPickSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, _MediaPickSource.cameraPhoto),
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Record video'),
              onTap: () => Navigator.pop(context, _MediaPickSource.cameraVideo),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose image from gallery'),
              onTap: () => Navigator.pop(context, _MediaPickSource.galleryImage),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_outlined),
              title: const Text('Choose file'),
              onTap: () => Navigator.pop(context, _MediaPickSource.file),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      switch (source) {
        case _MediaPickSource.cameraPhoto:
          final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
          if (file != null) setState(() => _mediaName = file.name);
        case _MediaPickSource.cameraVideo:
          final file = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
          if (file != null) setState(() => _mediaName = file.name);
        case _MediaPickSource.galleryImage:
          final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
          if (file != null) setState(() => _mediaName = file.name);
        case _MediaPickSource.file:
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4'],
          );
          if (result != null) setState(() => _mediaName = result.files.single.name);
      }
    } catch (error) {
      if (mounted) context.showErrorSnackBar('Could not pick media: $error');
    }
  }

  Future<void> _captureLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) context.showErrorSnackBar('Please enable location services.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) context.showErrorSnackBar('Location permission is required to tag complaint area.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (error) {
      if (mounted) context.showErrorSnackBar('Could not get location: $error');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }
}

enum _MediaPickSource { cameraPhoto, cameraVideo, galleryImage, file }

class _ComplaintUploadBox extends StatelessWidget {
  const _ComplaintUploadBox({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

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
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            children: [
              Icon(Icons.perm_media_outlined, color: cs.primary, size: 34.sp),
              SizedBox(height: 8.h),
              Text(title, textAlign: TextAlign.center, style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 4.h),
              Text('PNG, JPG, MP4 up to 10MB each', textAlign: TextAlign.center, style: context.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  const _LocationBox({
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.onTap,
  });

  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasLocation = latitude != null && longitude != null;
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(hasLocation ? Icons.my_location : Icons.location_on_outlined),
      label: Text(
        hasLocation
            ? 'Location tagged: ${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}'
            : 'Tag current location',
        style: TextStyle(color: hasLocation ? cs.primary : null),
      ),
    );
  }
}
