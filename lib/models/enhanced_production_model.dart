import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionStage {
  final int bartek;
  final CuttingDetails cutting;
  final int finishing;
  final int sewing;
  final int washing;

  ProductionStage({
    required this.bartek,
    required this.cutting,
    required this.finishing,
    required this.sewing,
    required this.washing,
  });

  factory ProductionStage.fromMap(Map<String, dynamic> map) {
    return ProductionStage(
      bartek: map['bartek'] ?? 0,
      cutting: CuttingDetails.fromMap(map['cutting'] ?? {}),
      finishing: map['finishing'] ?? 0,
      sewing: map['sewing'] ?? 0,
      washing: map['washing'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bartek': bartek,
      'cutting': cutting.toMap(),
      'finishing': finishing,
      'sewing': sewing,
      'washing': washing,
    };
  }
}

class CuttingDetails {
  final int hasilCutting;
  final int numbering;
  final int press;
  final int qcPanel;

  CuttingDetails({
    required this.hasilCutting,
    required this.numbering,
    required this.press,
    required this.qcPanel,
  });

  factory CuttingDetails.fromMap(Map<String, dynamic> map) {
    return CuttingDetails(
      hasilCutting: map['hasilCutting'] ?? 0,
      numbering: map['numbering'] ?? 0,
      press: map['press'] ?? 0,
      qcPanel: map['qcPanel'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hasilCutting': hasilCutting,
      'numbering': numbering,
      'press': press,
      'qcPanel': qcPanel,
    };
  }
}

class EnhancedProductionModel {
  final String produksiId;
  final DateTime createdAt;
  final String createdBy;
  final int jumlah;
  final String keterangan;
  final String operator;
  final String orderId;
  final ProductionStage tahap;
  final DateTime tanggal;

  EnhancedProductionModel({
    required this.produksiId,
    required this.createdAt,
    required this.createdBy,
    required this.jumlah,
    required this.keterangan,
    required this.operator,
    required this.orderId,
    required this.tahap,
    required this.tanggal,
  });

  factory EnhancedProductionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EnhancedProductionModel(
      produksiId: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      keterangan: data['keterangan'] ?? '',
      operator: data['operator'] ?? '',
      orderId: data['orderId'] ?? '',
      tahap: ProductionStage.fromMap(data['tahap'] ?? {}),
      tanggal: (data['tanggal'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'operator': operator,
      'orderId': orderId,
      'tahap': tahap.toMap(),
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}