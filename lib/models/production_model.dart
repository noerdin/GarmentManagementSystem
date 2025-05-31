import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionModel {
  final String produksiId;
  final DateTime tanggal;
  final String orderId;
  final String tahap;
  final String subTahap;
  final int jumlah;
  final String operator;
  final String keterangan;

  ProductionModel({
    required this.produksiId,
    required this.tanggal,
    required this.orderId,
    required this.tahap,
    required this.subTahap,
    required this.jumlah,
    required this.operator,
    this.keterangan = '',
  });

  factory ProductionModel.fromJson(Map<String, dynamic> json) {
    return ProductionModel(
      produksiId: json['produksiId'] as String,
      tanggal: (json['tanggal'] as Timestamp).toDate(),
      orderId: json['orderId'] as String,
      tahap: json['tahap'] as String,
      subTahap: json['subTahap'] as String,
      jumlah: json['jumlah'] as int,
      operator: json['operator'] as String,
      keterangan: json['keterangan'] as String? ?? '',
    );
  }

  factory ProductionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductionModel(
      produksiId: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      orderId: data['orderId'] ?? '',
      tahap: data['tahap'] ?? '',
      subTahap: data['subTahap'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      operator: data['operator'] ?? '',
      keterangan: data['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'produksiId': produksiId,
      'tanggal': Timestamp.fromDate(tanggal),
      'orderId': orderId,
      'tahap': tahap,
      'subTahap': subTahap,
      'jumlah': jumlah,
      'operator': operator,
      'keterangan': keterangan,
    };
  }

  // Helper methods
  bool get isCutting => tahap == 'Cutting';
  bool get isSewing => tahap == 'Sewing';
  bool get isPacking => tahap == 'Packing';

  ProductionModel copyWith({
    String? produksiId,
    DateTime? tanggal,
    String? orderId,
    String? tahap,
    String? subTahap,
    int? jumlah,
    String? operator,
    String? keterangan,
  }) {
    return ProductionModel(
      produksiId: produksiId ?? this.produksiId,
      tanggal: tanggal ?? this.tanggal,
      orderId: orderId ?? this.orderId,
      tahap: tahap ?? this.tahap,
      subTahap: subTahap ?? this.subTahap,
      jumlah: jumlah ?? this.jumlah,
      operator: operator ?? this.operator,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
