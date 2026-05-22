// Auth model dari SMPT backend
class AuthUser {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? photo;
  final String? nis; // Untuk santri
  final String? nip; // Untuk staf
  final String token;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.photo,
    this.nis,
    this.nip,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json, {String token = ''}) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role']?['name'] ?? json['role'] ?? (json['roles'] != null && (json['roles'] as List).isNotEmpty ? json['roles'][0]['name'] : null),
      photo: json['photo'] ?? json['profile']?['photo'] ?? json['student']?['photo'] ?? json['staff']?['photo'],
      nis: json['nis'] ?? json['student']?['nis'] ?? json['profile']?['nis'],
      nip: json['nip'] ?? json['staff']?['nip'] ?? json['profile']?['nip'],
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'photo': photo,
    'nis': nis,
    'nip': nip,
    'token': token,
  };

  bool get isWaliSantri => role?.toLowerCase().contains('wali') ?? false;
  bool get isSantri => nis != null && nis!.isNotEmpty;
  bool get isStaff => nip != null && nip!.isNotEmpty;
  bool get isAdmin => role?.toLowerCase().contains('admin') ?? false;

  AuthUser copyWith({String? token, String? role, String? photo}) {
    return AuthUser(
      id: id,
      name: name,
      email: email,
      role: role ?? this.role,
      photo: photo ?? this.photo,
      nis: nis,
      nip: nip,
      token: token ?? this.token,
    );
  }
}
