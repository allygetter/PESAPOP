// lib/features/auth/domain/auth_models.dart

enum UserRole { owner, cashier, manager, accountant, inventoryOfficer }
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class PPUser {
  const PPUser({
    required this.id, required this.name, required this.phone, required this.role,
    this.email, this.businessName, this.businessId, this.branchId, this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? email;
  final String? businessName;
  final String? businessId;
  final String? branchId;
  final String? avatarUrl;

  factory PPUser.fromJson(Map<String, dynamic> json) {
    final roleStr = (json['role'] as String? ?? 'cashier').toLowerCase();
    final role = UserRole.values.firstWhere(
      (r) => r.name.toLowerCase() == roleStr.replaceAll('_', ''),
      orElse: () => UserRole.cashier,
    );
    final business = json['business'] as Map<String, dynamic>?;
    final branch = json['branch'] as Map<String, dynamic>?;
    return PPUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: role,
      email: json['email'] as String?,
      businessId: json['businessId'] as String? ?? business?['id'] as String?,
      businessName: business?['name'] as String?,
      branchId: json['branchId'] as String? ?? branch?['id'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone, 'role': role.name,
    'email': email, 'businessId': businessId, 'businessName': businessName,
    'branchId': branchId, 'avatarUrl': avatarUrl,
  };
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial, this.user, this.errorMessage,
    this.isFirstLaunch = true, this.pendingPhone,
  });

  final AuthStatus status;
  final PPUser? user;
  final String? errorMessage;
  final bool isFirstLaunch;
  final String? pendingPhone;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  UserRole get userRole => user?.role ?? UserRole.cashier;

  AuthState copyWith({
    AuthStatus? status, PPUser? user, String? errorMessage,
    bool? isFirstLaunch, String? pendingPhone,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    pendingPhone: pendingPhone ?? this.pendingPhone,
  );
}
