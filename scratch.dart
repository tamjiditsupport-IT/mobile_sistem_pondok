import 'dart:convert';
void main() {
  final jsonStr = '''{
    "id": 1,
    "name": "superadmin",
    "email": "superadmin@mail.com",
    "roles": [
      {
        "id": 1,
        "name": "superadmin"
      }
    ]
  }''';
  final json = jsonDecode(jsonStr);
  final role = json['role']?['name'] ?? json['role'] ?? (json['roles'] != null && (json['roles'] as List).isNotEmpty ? json['roles'][0]['name'] : null);
  print('Role is: $role');
}
