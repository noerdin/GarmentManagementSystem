import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String materialId;
  final String nama;
  final String jenis;
  final String satuan;
  final int stok;
  final String lokasi;
  final double hargaPerUnit;
  final DateTime lastUpdated;

  MaterialModel({
    required this.materialId,
    required this.nama,
    required this.jenis,
    required this.satuan,
    required this.stok,
    required this.lokasi,
    required this.hargaPerUnit,
    required this.lastUpdated,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      materialId: json['materialId'] as String,
      nama: json['nama'] as String,
      jenis: json['jenis'] as String,
      satuan: json['satuan'] as String,
      stok: json['stok'] as int,
      lokasi: json['lokasi'] as String,
      hargaPerUnit: (json['hargaPerUnit'] as num).toDouble(),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MaterialModel(
      materialId: doc.id,
      nama: data['nama'] ?? '',
      jenis: data['jenis'] ?? '',
      satuan: data['satuan'] ?? '',
      stok: data['stok'] ?? 0,
      lokasi: data['lokasi'] ?? '',
      hargaPerUnit: (data['hargaPerUnit'] as num?)?.toDouble() ?? 0.0,
      lastUpdated:
      (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materialId': materialId,
      'nama': nama,
      'jenis': jenis,
      'satuan': satuan,
      'stok': stok,
      'lokasi': lokasi,
      'hargaPerUnit': hargaPerUnit,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  // Helper methods
  bool get isBahan => jenis == 'Bahan';
  bool get isAksesoris => jenis == 'Aksesoris';
  bool get isLowStock => stok < 10; // Adjust threshold as needed

  MaterialModel copyWith({
    String? materialId,
    String? nama,
    String? jenis,
    String? satuan,
    int? stok,
    String? lokasi,
    double? hargaPerUnit,
    DateTime? lastUpdated,
  }) {
    return MaterialModel(
      materialId: materialId ?? this.materialId,
      nama: nama ?? this.nama,
      jenis: jenis ?? this.jenis,
      satuan: satuan ?? this.satuan,
      stok: stok ?? this.stok,
      lokasi: lokasi ?? this.lokasi,
      hargaPerUnit: hargaPerUnit ?? this.hargaPerUnit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
