import 'package:nalbari_connect_admin/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect_admin/src/features/portal/presentation/providers/fake_api_controls_provider.dart';
import 'package:nalbari_connect_admin/src/utils/logger.dart';

class FakePortalRepository {
  FakePortalRepository(this._controls);

  final FakeApiControls _controls;

  Future<List<NewsItem>> fetchNews() async {
    AppLogger.info('[FAKE API] GET /news');
    await _delay();
    _throwIfNeeded('/news');
    return [
      NewsItem(
        id: 'n1',
        title: 'New Digital Services Portal Launched',
        summary: 'Government introduces streamlined portal for citizen services with enhanced security features.',
        body: 'The constituency office has launched a simplified digital services flow for appointments, complaints, and official updates.',
        publishedAt: DateTime(2026, 6, 4),
      ),
    ];
  }

  Future<List<AppointmentRequest>> fetchAppointments() async {
    AppLogger.info('[FAKE API] GET /admin/appointments');
    await _delay();
    _throwIfNeeded('/admin/appointments');
    return [
      AppointmentRequest(
        id: 'a1',
        fullName: 'Sarah Johnson',
        withPerson: 'Michael Chen',
        date: DateTime(2026, 6, 8),
        time: '10:30 AM',
        reason: 'Annual checkup and blood pressure monitoring',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5, 9),
      ),
      AppointmentRequest(
        id: 'a2',
        fullName: 'David Martinez',
        withPerson: 'Emily Roberts',
        date: DateTime(2026, 6, 9),
        time: '02:00 PM',
        reason: 'Follow-up consultation for knee injury',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5, 12),
      ),
      AppointmentRequest(
        id: 'a3',
        fullName: 'Lisa Anderson',
        withPerson: 'James Wilson',
        date: DateTime(2026, 6, 7),
        time: '09:00 AM',
        reason: 'Dental cleaning and oral examination',
        status: AppointmentStatus.approved,
        createdAt: DateTime(2026, 6, 4, 16),
      ),
      AppointmentRequest(
        id: 'a4',
        fullName: 'Robert Taylor',
        withPerson: 'Sarah Kim',
        date: DateTime(2026, 6, 10),
        time: '03:30 PM',
        reason: 'Physical therapy session for back pain',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5, 17),
      ),
    ];
  }

  Future<List<ComplaintRequest>> fetchComplaints() async {
    AppLogger.info('[FAKE API] GET /admin/complaints');
    await _delay();
    _throwIfNeeded('/admin/complaints');
    return [
      ComplaintRequest(
        id: 'c1',
        reporterName: 'Jennifer Lee',
        areaType: AreaType.ward,
        areaNumber: '7',
        description: 'Long wait time in emergency room. Had to wait over 3 hours despite severe pain. Staff seemed overwhelmed and communication was poor.',
        status: ComplaintStatus.newRequest,
        priority: ComplaintPriority.high,
        createdAt: DateTime(2026, 6, 8, 8),
        latitude: 26.4446,
        longitude: 91.4411,
      ),
      ComplaintRequest(
        id: 'c2',
        reporterName: 'Mark Thompson',
        areaType: AreaType.panchayat,
        areaNumber: '2',
        description: 'Billing discrepancy and missing follow-up acknowledgement from the office helpdesk.',
        status: ComplaintStatus.inReview,
        priority: ComplaintPriority.medium,
        createdAt: DateTime(2026, 6, 8, 5),
        latitude: 26.4474,
        longitude: 91.4438,
      ),
      ComplaintRequest(
        id: 'c3',
        reporterName: 'Ananya Sharma',
        areaType: AreaType.ward,
        areaNumber: '4',
        description: 'Street light issue near school junction has been fixed after department follow-up.',
        status: ComplaintStatus.resolved,
        priority: ComplaintPriority.low,
        createdAt: DateTime(2026, 6, 7, 18),
        mediaName: 'streetlight.jpg',
      ),
    ];
  }

  Future<List<AdminNotificationItem>> fetchNotifications() async {
    AppLogger.info('[FAKE API] GET /admin/notifications');
    await _delay();
    _throwIfNeeded('/admin/notifications');
    return [
      AdminNotificationItem(
        id: 'n1',
        title: 'New appointment request',
        message: 'Sarah Johnson requested a meeting for June 8 at 10:30 AM.',
        type: AdminNotificationType.appointment,
        createdAt: DateTime(2026, 6, 8, 9, 10),
      ),
      AdminNotificationItem(
        id: 'n2',
        title: 'High priority complaint',
        message: 'Jennifer Lee raised a high priority complaint in Ward 7.',
        type: AdminNotificationType.complaint,
        createdAt: DateTime(2026, 6, 8, 8, 20),
      ),
      AdminNotificationItem(
        id: 'n3',
        title: 'Complaint moved to review',
        message: 'Mark Thompson complaint is now in review.',
        type: AdminNotificationType.complaint,
        createdAt: DateTime(2026, 6, 8, 7, 40),
        isRead: true,
      ),
      AdminNotificationItem(
        id: 'n4',
        title: 'Daily summary ready',
        message: '4 appointment requests and 3 complaints loaded from fake API.',
        type: AdminNotificationType.system,
        createdAt: DateTime(2026, 6, 8, 7),
      ),
    ];
  }

  Future<AppointmentRequest> createAppointment(AppointmentRequest appointment) async {
    AppLogger.info('[FAKE API] POST /appointments -> ${appointment.toJson()}');
    await _delay();
    _throwIfNeeded('/appointments');
    return appointment;
  }

  Future<ComplaintRequest> createComplaint(ComplaintRequest complaint) async {
    AppLogger.info('[FAKE API] POST /complaints -> ${complaint.toJson()}');
    await _delay();
    _throwIfNeeded('/complaints');
    return complaint;
  }

  Future<AppointmentRequest> updateAppointmentStatus(AppointmentRequest appointment, AppointmentStatus status) async {
    AppLogger.info('[FAKE API] PATCH /admin/appointments/${appointment.id}/status -> ${status.name}');
    await _delay();
    _throwIfNeeded('/admin/appointments/${appointment.id}/status');
    return appointment.copyWith(status: status);
  }

  Future<ComplaintRequest> updateComplaintStatus(ComplaintRequest complaint, ComplaintStatus status) async {
    AppLogger.info('[FAKE API] PATCH /admin/complaints/${complaint.id}/status -> ${status.name}');
    await _delay();
    _throwIfNeeded('/admin/complaints/${complaint.id}/status');
    return complaint.copyWith(status: status);
  }

  Future<void> _delay() => Future<void>.delayed(Duration(milliseconds: _controls.latencyMs));

  void _throwIfNeeded(String endpoint) {
    switch (_controls.failureMode) {
      case FakeApiFailureMode.none:
        return;
      case FakeApiFailureMode.offline:
        throw const FakeApiException(
          'You are offline. Please check your internet connection.',
          reason: 'No network connection available for this request.',
        );
      case FakeApiFailureMode.serverError:
        throw FakeApiException(
          'Server error while calling $endpoint.',
          reason: 'Backend returned a simulated 500 response.',
        );
    }
  }
}

