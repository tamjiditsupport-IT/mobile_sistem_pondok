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
    return PelanggaranModel(
      id: json['id'] ?? 0,
      namaSantri: json['santri']?['name'] ?? json['santri_name'] ?? '-',
      namaPelanggaran: json['pelanggaran']?['name'] ?? json['pelanggaran_name'] ?? '-',
      poin: int.tryParse(json['poin']?.toString() ?? '0') ?? 0,
      kategori: json['pelanggaran']?['kategori'] ?? json['kategori'] ?? '-',
      tanggal: json['tanggal'] ?? json['created_at'] ?? '',
    );
  }
}
