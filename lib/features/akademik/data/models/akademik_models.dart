class JadwalModel {
  final int id;
  final String hari;
  final String mapel;
  final String jamMulai;
  final String jamSelesai;
  final String namaGuru;

  JadwalModel({
    required this.id,
    required this.hari,
    required this.mapel,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaGuru,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] ?? 0,
      hari: json['day'] ?? json['hari'] ?? '-',
      mapel: json['subject']?['name'] ?? json['mapel'] ?? '-',
      jamMulai: json['start_time'] ?? '-',
      jamSelesai: json['end_time'] ?? '-',
      namaGuru: json['teacher']?['name'] ?? json['guru'] ?? '-',
    );
  }
}

class NilaiModel {
  final int id;
  final String semester;
  final String mapel;
  final num nilai;

  NilaiModel({
    required this.id,
    required this.semester,
    required this.mapel,
    required this.nilai,
  });

  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    return NilaiModel(
      id: json['id'] ?? 0,
      semester: json['semester']?['name'] ?? json['semester'] ?? '-',
      mapel: json['subject']?['name'] ?? json['mapel'] ?? '-',
      nilai: json['score'] ?? json['nilai'] ?? 0,
    );
  }
}

class AbsensiModel {
  final String bulan;
  final int hadir;
  final int izin;
  final int sakit;
  final int alfa;

  AbsensiModel({
    required this.bulan,
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alfa,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      bulan: json['month'] ?? json['bulan'] ?? '-',
      hadir: json['present'] ?? json['hadir'] ?? 0,
      izin: json['permission'] ?? json['izin'] ?? 0,
      sakit: json['sick'] ?? json['sakit'] ?? 0,
      alfa: json['absent'] ?? json['alfa'] ?? 0,
    );
  }
}

class AbsensiStatistikModel {
  final int hadir;
  final int izin;
  final int sakit;
  final int alpha;
  final int total;
  final double pctHadir;

  AbsensiStatistikModel({
    required this.hadir,
    required this.izin,
    required this.sakit,
    required this.alpha,
    required this.total,
    required this.pctHadir,
  });

  factory AbsensiStatistikModel.fromJson(Map<String, dynamic> json) {
    final hadir = json['hadir'] ?? 0;
    final izin = json['izin'] ?? 0;
    final sakit = json['sakit'] ?? 0;
    final alpha = json['alpha'] ?? json['alfa'] ?? 0;
    final total = json['total'] ?? (hadir + izin + sakit + alpha);
    return AbsensiStatistikModel(
      hadir: hadir,
      izin: izin,
      sakit: sakit,
      alpha: alpha,
      total: total,
      pctHadir: (json['percentages']?['hadir'] ?? (total > 0 ? (hadir / total * 100) : 0.0)).toDouble(),
    );
  }
}
