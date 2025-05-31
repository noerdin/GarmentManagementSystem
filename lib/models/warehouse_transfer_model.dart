import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseTransferModel {
  final String mutasiId;
  final DateTime tanggal;
  final String materialId;
  final int jumlah;
  final String dariGudang;
  final String keGudang;
  final String keterangan;

  WarehouseTransferModel({
    required this.mutasiId,
    required this.tanggal,
    required this.materialId,
    required this.jumlah,
    required this.dariGudang,
    required this.keGudang,
    this.keterangan = '',
  });

  factory WarehouseTransferModel.fromJson(Map<String, dynamic> json) {
    return WarehouseTransferModel(
      mutasiId: json['mutasiId'] as String,
      tanggal: (json['tanggal'] as Timestamp).toDate(),
      materialId: json['materialId'] as String,
      jumlah: json['jumlah'] as int,
      dariGudang: json['dariGudang'] as String,
      keGudang: json['keGudang'] as String,
      keterangan: json['keterangan'] as String? ?? '',
    );
  }

  factory WarehouseTransferModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WarehouseTransferModel(
      mutasiId: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      materialId: data['materialId'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      dariGudang: data['dariGudang'] ?? '',
      keGudang: data['keGudang'] ?? '',
      keterangan: data['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mutasiId': mutasiId,
      'tanggal': Timestamp.fromDate(tanggal),
      'materialId': materialId,
      'jumlah': jumlah,
      'dariGudang': dariGudang,
      'keGudang': keGudang,
      'keterangan': keterangan,
    };
  }

  WarehouseTransferModel copyWith({
    String? mutasiId,
    DateTime? tanggal,
    String? materialId,
    int? jumlah,
    String? dariGudang,
    String? keGudang,
    String? keterangan,
  }) {
    return WarehouseTransferModel(
      mutasiId: mutasiId ?? this.mutasiId,
      tanggal: tanggal ?? this.tanggal,
      materialId: materialId ?? this.materialId,
      jumlah: jumlah ?? this.jumlah,
      dariGudang: dariGudang ?? this.dariGudang,
      keGudang: keGudang ?? this.keGudang,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
