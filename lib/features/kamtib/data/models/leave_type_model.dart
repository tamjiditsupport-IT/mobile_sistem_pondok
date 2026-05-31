class LeaveTypeModel {
  final int id;
  final String name;
  final String? description;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['nama'] ?? '-',
      description: json['description'] ?? json['keterangan'],
    );
  }
}
