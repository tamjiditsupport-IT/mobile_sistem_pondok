class PelanggaranModel {
  final int id;
  final String namaSantri;
  final String namaPelanggaran;
  final int poin;
  final String kategori;
  final String tanggal;

  PelanggaranModel({
    required this.id,
    required this.namaSantri,
    required this.namaPelanggaran,
    required this.poin,
    required this.kategori,
    required this.tanggal,
  });

  factory PelanggaranModel.fromJson(Map<String, dynamic> json) {
    // Parsing nama santri
    final santri = json['student'] ?? json['santri'];
    String fullName = '-';
    if (santri != null) {
      final firstName = santri['first_name'] ?? '';
      final lastName = santri['last_name'] ?? '';
      fullName = santri['name'] ?? santri['nama'] ?? '$firstName $lastName'.trim();
    }

    // Parsing detail pelanggaran
    final violation = json['violation'] ?? json['pelanggaran'];
    final namaPelanggaran = violation?['name'] ?? violation?['nama'] ?? '-';
    final poin = violation?['point'] ?? violation?['poin'] ?? 0;
    final kategori = violation?['category']?['name'] ?? violation?['kategori'] ?? '-';

    return PelanggaranModel(
      id: json['id'] ?? 0,
      namaSantri: fullName,
      namaPelanggaran: namaPelanggaran,
      poin: int.tryParse(poin.toString()) ?? 0,
      kategori: kategori,
      tanggal: json['violation_date'] ?? json['tanggal'] ?? json['created_at'] ?? '',
    );
  }
}
