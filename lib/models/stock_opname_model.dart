import 'package:cloud_firestore/cloud_firestore.dart';

class StockOpnameModel {
  final String opnameId;
  final DateTime tanggal;
  final String materialId;
  final String lokasi;
  final int stokTercatat;
  final int stokFisik;
  final int selisih;
  final String status;
  final String keterangan;

  StockOpnameModel({
    required this.opnameId,
    required this.tanggal,
    required this.materialId,
    required this.lokasi,
    required this.stokTercatat,
    required this.stokFisik,
    required this.selisih,
    required this.status,
    this.keterangan = '',
  });

  factory StockOpnameModel.fromJson(Map<String, dynamic> json) {
    return StockOpnameModel(
      opnameId: json['opnameId'] as String,
      tanggal: (json['tanggal'] as Timestamp).toDate(),
      materialId: json['materialId'] as String,
      lokasi: json['lokasi'] as String,
      stokTercatat: json['stokTercatat'] as int,
      stokFisik: json['stokFisik'] as int,
      selisih: json['selisih'] as int,
      status: json['status'] as String,
      keterangan: json['keterangan'] as String? ?? '',
    );
  }

  factory StockOpnameModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StockOpnameModel(
      opnameId: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      materialId: data['materialId'] ?? '',
      lokasi: data['lokasi'] ?? '',
      stokTercatat: data['stokTercatat'] ?? 0,
      stokFisik: data['stokFisik'] ?? 0,
      selisih: data['selisih'] ?? 0,
      status: data['status'] ?? 'Selisih',
      keterangan: data['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opnameId': opnameId,
      'tanggal': Timestamp.fromDate(tanggal),
      'materialId': materialId,
      'lokasi': lokasi,
      'stokTercatat': stokTercatat,
      'stokFisik': stokFisik,
      'selisih': selisih,
      'status': status,
      'keterangan': keterangan,
    };
  }

  // Helper methods
  bool get isMatch => status == 'Cocok';
  bool get hasDifference => status == 'Selisih';

  StockOpnameModel copyWith({
    String? opnameId,
    DateTime? tanggal,
    String? materialId,
    String? lokasi,
    int? stokTercatat,
    int? stokFisik,
    int? selisih,
    String? status,
    String? keterangan,
  }) {
    return StockOpnameModel(
      opnameId: opnameId ?? this.opnameId,
      tanggal: tanggal ?? this.tanggal,
      materialId: materialId ?? this.materialId,
      lokasi: lokasi ?? this.lokasi,
      stokTercatat: stokTercatat ?? this.stokTercatat,
      stokFisik: stokFisik ?? this.stokFisik,
      selisih: selisih ?? this.selisih,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
