import 'package:nalbari_connect/src/features/portal/data/models/portal_models.dart';
import 'package:nalbari_connect/src/features/portal/presentation/providers/fake_api_controls_provider.dart';
import 'package:nalbari_connect/src/utils/logger.dart';

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
        body: 'The constituency office has launched a simplified digital services flow for appointments, complaints, and official updates. Citizens can now submit requests digitally and track the progress from their profile.',
        publishedAt: DateTime(2026, 6, 4),
      ),
      NewsItem(
        id: 'n2',
        title: 'Healthcare Appointment System Update',
        summary: 'Enhanced booking system now supports faster appointment review and citizen notifications.',
        body: 'The appointment queue has been improved so office staff can approve, reject, or reschedule requests with clear remarks. Citizens will receive status updates after review.',
        publishedAt: DateTime(2026, 6, 3),
      ),
      NewsItem(
        id: 'n3',
        title: 'Citizen Feedback Initiative Results',
        summary: 'Recent complaint resolution rate reaches 85% as governance focuses on responsive action.',
        body: 'Public feedback from ward and panchayat areas is being reviewed weekly to understand the most common local issues and route them to the correct departments.',
        publishedAt: DateTime(2026, 6, 2),
      ),
    ];
  }

  Future<List<AppointmentRequest>> fetchAppointments() async {
    AppLogger.info('[FAKE API] GET /appointments');
    await _delay();
    _throwIfNeeded('/appointments');
    return [
      AppointmentRequest(
        id: 'a1',
        fullName: 'Sarah Johnson',
        withPerson: 'MLA Office',
        date: DateTime(2026, 6, 8),
        time: '10:30 AM',
        reason: 'Annual checkup and blood pressure monitoring',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5),
      ),
      AppointmentRequest(
        id: 'a2',
        fullName: 'David Martinez',
        withPerson: 'MLA PA',
        date: DateTime(2026, 6, 9),
        time: '02:00 PM',
        reason: 'Follow-up consultation for knee injury',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5),
      ),
      AppointmentRequest(
        id: 'a3',
        fullName: 'Lisa Anderson',
        withPerson: 'MLA Office',
        date: DateTime(2026, 6, 7),
        time: '09:00 AM',
        reason: 'Dental cleaning and oral examination',
        status: AppointmentStatus.approved,
        createdAt: DateTime(2026, 6, 4),
      ),
      AppointmentRequest(
        id: 'a4',
        fullName: 'Robert Taylor',
        withPerson: 'MLA PA',
        date: DateTime(2026, 6, 10),
        time: '03:30 PM',
        reason: 'Physical therapy session for back pain',
        status: AppointmentStatus.pending,
        createdAt: DateTime(2026, 6, 5),
      ),
    ];
  }

  Future<List<ComplaintRequest>> fetchComplaints() async {
    AppLogger.info('[FAKE API] GET /complaints');
    await _delay();
    _throwIfNeeded('/complaints');
    return [
      ComplaintRequest(
        id: 'c1',
        reporterName: 'Verified Resident',
        areaType: AreaType.ward,
        areaNumber: '4',
        description: 'Street light not working near the school junction for four days.',
        status: ComplaintStatus.newRequest,
        priority: ComplaintPriority.medium,
        createdAt: DateTime(2026, 6, 5),
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

  Future<AppointmentRequest> updateAppointmentStatus(
    AppointmentRequest appointment,
    AppointmentStatus status,
  ) async {
    AppLogger.info('[FAKE API] PATCH /appointments/${appointment.id}/status -> ${status.name}');
    await _delay();
    _throwIfNeeded('/appointments/${appointment.id}/status');
    return appointment.copyWith(status: status);
  }

  Future<ComplaintRequest> updateComplaintStatus(
    ComplaintRequest complaint,
    ComplaintStatus status,
  ) async {
    AppLogger.info('[FAKE API] PATCH /complaints/${complaint.id}/status -> ${status.name}');
    await _delay();
    _throwIfNeeded('/complaints/${complaint.id}/status');
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
