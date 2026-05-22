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
    return SantriModel(
      id: json['id'] ?? 0,
      nama: json['name'] ?? json['nama'] ?? '',
      nis: json['nis'] ?? '',
      kelas: json['kelas']?['name'] ?? json['class_name'] ?? '-',
      kamar: json['kamar']?['name'] ?? json['room_name'] ?? '-',
      namaWali: json['wali']?['name'] ?? json['parent_name'] ?? '-',
      status: json['status'] ?? 'Aktif',
      photoUrl: json['photo_url'] ?? json['photo'],
    );
  }
}
