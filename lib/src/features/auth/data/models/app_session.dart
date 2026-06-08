enum AppUserRole { citizen, admin }

enum AuthStatus { unknown, unauthenticated, authenticated }

class AppSessionUser {
  const AppSessionUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.token,
    this.idProofLinked = false,
  });

  final String id;
  final String phone;
  final String name;
  final AppUserRole role;
  final String token;
  final bool idProofLinked;

  AppSessionUser copyWith({
    String? id,
    String? phone,
    String? name,
    AppUserRole? role,
    String? token,
    bool? idProofLinked,
  }) {
    return AppSessionUser(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      role: role ?? this.role,
      token: token ?? this.token,
      idProofLinked: idProofLinked ?? this.idProofLinked,
    );
  }

  Map<String, String> toStorage() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role.name,
      'token': token,
      'idProofLinked': idProofLinked.toString(),
    };
  }

  static AppSessionUser? fromStorage(Map<String, String?> data) {
    final id = data['id'];
    final phone = data['phone'];
    final name = data['name'];
    final role = data['role'];
    final token = data['token'];
    if ([id, phone, name, role, token].any((value) => value == null || value.isEmpty)) {
      return null;
    }

    return AppSessionUser(
      id: id!,
      phone: phone!,
      name: name!,
      role: role == AppUserRole.admin.name ? AppUserRole.admin : AppUserRole.citizen,
      token: token!,
      idProofLinked: data['idProofLinked'] == 'true',
    );
  }
}

class AppAuthState {
  const AppAuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.pendingPhone,
    this.isLoading = false,
    this.hasCompletedLanguageSetup = false,
    this.lastOpenedAt,
  });

  final AuthStatus status;
  final AppSessionUser? user;
  final String? pendingPhone;
  final bool isLoading;
  final bool hasCompletedLanguageSetup;
  final DateTime? lastOpenedAt;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isAdmin => user?.role == AppUserRole.admin;

  AppAuthState copyWith({
    AuthStatus? status,
    AppSessionUser? user,
    String? pendingPhone,
    bool? isLoading,
    bool? hasCompletedLanguageSetup,
    DateTime? lastOpenedAt,
    bool clearUser = false,
    bool clearPendingPhone = false,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      pendingPhone: clearPendingPhone ? null : pendingPhone ?? this.pendingPhone,
      isLoading: isLoading ?? this.isLoading,
      hasCompletedLanguageSetup: hasCompletedLanguageSetup ?? this.hasCompletedLanguageSetup,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    );
  }
}
