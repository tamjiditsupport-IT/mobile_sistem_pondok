class SantriModel {
  final int id;
  final String nama;
  final String nis;
  final String? kelas;
  final String? kamar;
  final String? namaWali;
  final String status;
  final String? photoUrl;

  const SantriModel({
    required this.id,
    required this.nama,
    required this.nis,
    this.kelas,
    this.kamar,
    this.namaWali,
    required this.status,
    this.photoUrl,
  });

  factory SantriModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'] ?? '';
    final lastName = json['last_name'] ?? '';
    final fullName = json['name'] ?? json['nama'] ?? '$firstName $lastName'.trim();

    return SantriModel(
      id: json['id'] ?? 0,
      nama: fullName,
      nis: json['nis'] ?? '',
      kelas: json['kelas']?['name'] ?? json['program']?['name'] ?? json['class_name'] ?? '-',
      kamar: json['current_room']?['hostel_name'] ?? json['hostel']?['name'] ?? json['current_room']?['room_name'] ?? json['room_name'] ?? '-',
      namaWali: json['parents']?['first_name'] ?? json['wali']?['name'] ?? json['parent_name'] ?? '-',
      status: json['status'] ?? 'Aktif',
      photoUrl: json['photo_url'] ?? json['photo'],
    );
  }
}
