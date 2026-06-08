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

  Future<PaginatedResponse<AppointmentRequest>> fetchAppointments({required int page, int limit = 8}) async {
    AppLogger.info('[FAKE API] GET /admin/appointments?page=$page&limit=$limit');
    await _delay();
    _throwIfNeeded('/admin/appointments');
    return _paginate(_appointmentSeed, page, limit);
  }

  Future<PaginatedResponse<ComplaintRequest>> fetchComplaints({required int page, int limit = 8}) async {
    AppLogger.info('[FAKE API] GET /admin/complaints?page=$page&limit=$limit');
    await _delay();
    _throwIfNeeded('/admin/complaints');
    return _paginate(_complaintSeed, page, limit);
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
        message: 'New admin API data is ready for review.',
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

  Future<AppointmentRequest> updateAppointmentStatus(
    AppointmentRequest appointment,
    AppointmentStatus status, {
    required DateTime date,
    required String time,
    required String adminNote,
  }) async {
    AppLogger.info('[FAKE API] PATCH /admin/appointments/${appointment.id}/status -> {status: ${status.name}, date: ${date.toIso8601String()}, time: $time}');
    await _delay();
    _throwIfNeeded('/admin/appointments/${appointment.id}/status');
    return appointment.copyWith(status: status, date: date, time: time, adminNote: adminNote, updatedAt: DateTime.now());
  }

  Future<ComplaintRequest> updateComplaintStatus(
    ComplaintRequest complaint,
    ComplaintStatus status, {
    required String adminAction,
  }) async {
    AppLogger.info('[FAKE API] PATCH /admin/complaints/${complaint.id}/status -> {status: ${status.name}, action: $adminAction}');
    await _delay();
    _throwIfNeeded('/admin/complaints/${complaint.id}/status');
    return complaint.copyWith(status: status, adminAction: adminAction, updatedAt: DateTime.now());
  }

  PaginatedResponse<T> _paginate<T>(List<T> source, int page, int limit) {
    final safePage = page < 1 ? 1 : page;
    final start = (safePage - 1) * limit;
    final end = (start + limit).clamp(0, source.length);
    final items = start >= source.length ? <T>[] : source.sublist(start, end);
    return PaginatedResponse<T>(
      items: items,
      page: safePage,
      limit: limit,
      total: source.length,
      hasMore: end < source.length,
    );
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

final _appointmentSeed = <AppointmentRequest>[
  AppointmentRequest(id: 'a1', fullName: 'Sarah Johnson', withPerson: 'Michael Chen', date: DateTime(2026, 6, 8), time: '10:30 AM', reason: 'Annual checkup and blood pressure monitoring', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 5, 9), phoneNumber: '9876543210', idProofName: 'aadhaar_sarah.jpg'),
  AppointmentRequest(id: 'a2', fullName: 'David Martinez', withPerson: 'Emily Roberts', date: DateTime(2026, 6, 9), time: '02:00 PM', reason: 'Follow-up consultation for knee injury', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 5, 12), phoneNumber: '9988776655', idProofName: 'voter_david.jpg'),
  AppointmentRequest(id: 'a3', fullName: 'Lisa Anderson', withPerson: 'James Wilson', date: DateTime(2026, 6, 7), time: '09:00 AM', reason: 'Dental cleaning and oral examination', status: AppointmentStatus.approved, createdAt: DateTime(2026, 6, 4, 16), phoneNumber: '9001122334', idProofName: 'id_lisa.png'),
  AppointmentRequest(id: 'a4', fullName: 'Robert Taylor', withPerson: 'Sarah Kim', date: DateTime(2026, 6, 10), time: '03:30 PM', reason: 'Physical therapy session for back pain', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 5, 17), phoneNumber: '9123456780'),
  AppointmentRequest(id: 'a5', fullName: 'Anup Baishya', withPerson: 'MLA PA', date: DateTime(2026, 6, 11), time: '11:00 AM', reason: 'Group meeting for ward drainage issue', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 6, 10), phoneNumber: '9864012345'),
  AppointmentRequest(id: 'a6', fullName: 'Rima Devi', withPerson: 'MLA Office', date: DateTime(2026, 6, 12), time: '04:00 PM', reason: 'School scholarship support request', status: AppointmentStatus.approved, createdAt: DateTime(2026, 6, 6, 15), phoneNumber: '9700011122'),
  AppointmentRequest(id: 'a7', fullName: 'Kamal Das', withPerson: 'MLA PA', date: DateTime(2026, 6, 13), time: '12:00 PM', reason: 'Road repair delegation request', status: AppointmentStatus.rejected, createdAt: DateTime(2026, 6, 7, 8), phoneNumber: '9700011133', adminNote: 'Duplicate request already scheduled.'),
  AppointmentRequest(id: 'a8', fullName: 'Puja Kalita', withPerson: 'MLA Office', date: DateTime(2026, 6, 14), time: '05:00 PM', reason: 'Women self-help group discussion', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 7, 11), phoneNumber: '9700011144'),
  AppointmentRequest(id: 'a9', fullName: 'Bikash Bora', withPerson: 'MLA PA', date: DateTime(2026, 6, 15), time: '09:30 AM', reason: 'Medical support verification', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 7, 14), phoneNumber: '9700011155'),
  AppointmentRequest(id: 'a10', fullName: 'Mitali Saikia', withPerson: 'MLA Office', date: DateTime(2026, 6, 16), time: '10:00 AM', reason: 'Local event permission discussion', status: AppointmentStatus.approved, createdAt: DateTime(2026, 6, 8, 7), phoneNumber: '9700011166'),
  AppointmentRequest(id: 'a11', fullName: 'Rahul Sharma', withPerson: 'MLA PA', date: DateTime(2026, 6, 17), time: '02:30 PM', reason: 'Youth club sports ground request', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 8, 9), phoneNumber: '9700011177'),
  AppointmentRequest(id: 'a12', fullName: 'Juri Nath', withPerson: 'MLA Office', date: DateTime(2026, 6, 18), time: '03:00 PM', reason: 'Water supply issue meeting', status: AppointmentStatus.pending, createdAt: DateTime(2026, 6, 8, 12), phoneNumber: '9700011188'),
];

final _complaintSeed = <ComplaintRequest>[
  ComplaintRequest(id: 'c1', reporterName: 'Jennifer Lee', areaType: AreaType.ward, areaNumber: '7', title: 'Long wait time in emergency room', description: 'Had to wait over 3 hours despite severe pain. Staff seemed overwhelmed and communication was poor.', status: ComplaintStatus.newRequest, priority: ComplaintPriority.high, createdAt: DateTime(2026, 6, 8, 8), phoneNumber: '9876500011', latitude: 26.4446, longitude: 91.4411, mediaName: 'complaint_er_wait.jpg'),
  ComplaintRequest(id: 'c2', reporterName: 'Mark Thompson', areaType: AreaType.panchayat, areaNumber: '2', title: 'Billing discrepancy', description: 'Billing discrepancy and missing follow-up acknowledgement from the office helpdesk.', status: ComplaintStatus.inReview, priority: ComplaintPriority.medium, createdAt: DateTime(2026, 6, 8, 5), phoneNumber: '9876500012', latitude: 26.4474, longitude: 91.4438, adminAction: 'Assigned to helpdesk lead for verification.'),
  ComplaintRequest(id: 'c3', reporterName: 'Ananya Sharma', areaType: AreaType.ward, areaNumber: '4', title: 'Street light issue resolved', description: 'Street light issue near school junction has been fixed after department follow-up.', status: ComplaintStatus.resolved, priority: ComplaintPriority.low, createdAt: DateTime(2026, 6, 7, 18), phoneNumber: '9876500013', mediaName: 'streetlight.jpg', adminAction: 'Resolved by electricity department.'),
  ComplaintRequest(id: 'c4', reporterName: 'Rohan Borah', areaType: AreaType.ward, areaNumber: '9', title: 'Drain blocked near market', description: 'Water logging near main market during rain. Needs urgent drain cleaning.', status: ComplaintStatus.newRequest, priority: ComplaintPriority.high, createdAt: DateTime(2026, 6, 7, 12), phoneNumber: '9876500014', latitude: 26.45, longitude: 91.44),
  ComplaintRequest(id: 'c5', reporterName: 'Pallabi Das', areaType: AreaType.panchayat, areaNumber: '5', title: 'School boundary wall damage', description: 'Boundary wall near primary school is damaged and unsafe for children.', status: ComplaintStatus.inReview, priority: ComplaintPriority.medium, createdAt: DateTime(2026, 6, 6, 17), phoneNumber: '9876500015'),
  ComplaintRequest(id: 'c6', reporterName: 'Nirmal Deka', areaType: AreaType.ward, areaNumber: '3', title: 'Garbage collection missed', description: 'Garbage vehicle did not arrive for the last four days.', status: ComplaintStatus.newRequest, priority: ComplaintPriority.medium, createdAt: DateTime(2026, 6, 6, 10), phoneNumber: '9876500016'),
  ComplaintRequest(id: 'c7', reporterName: 'Kiran Kalita', areaType: AreaType.panchayat, areaNumber: '1', title: 'Tube well repair needed', description: 'Public tube well is not working and residents are depending on nearby village.', status: ComplaintStatus.resolved, priority: ComplaintPriority.high, createdAt: DateTime(2026, 6, 5, 9), phoneNumber: '9876500017', adminAction: 'Repair team visited and restored supply.'),
  ComplaintRequest(id: 'c8', reporterName: 'Sanjay Pathak', areaType: AreaType.ward, areaNumber: '11', title: 'Roadside tree trimming', description: 'Branches are touching electric wires near the road.', status: ComplaintStatus.inReview, priority: ComplaintPriority.low, createdAt: DateTime(2026, 6, 5, 14), phoneNumber: '9876500018'),
  ComplaintRequest(id: 'c9', reporterName: 'Meghna Devi', areaType: AreaType.ward, areaNumber: '6', title: 'Water leakage', description: 'Pipe leakage causing water loss near residential lane.', status: ComplaintStatus.newRequest, priority: ComplaintPriority.medium, createdAt: DateTime(2026, 6, 4, 13), phoneNumber: '9876500019'),
];
