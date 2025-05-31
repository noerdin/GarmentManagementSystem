import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingModel {
  final String shippingId;
  final DateTime tanggal;
  final String orderId;
  final String tujuan;
  final int jumlahDikirim;
  final String resi;
  final String keterangan;

  ShippingModel({
    required this.shippingId,
    required this.tanggal,
    required this.orderId,
    required this.tujuan,
    required this.jumlahDikirim,
    this.resi = '',
    this.keterangan = '',
  });

  factory ShippingModel.fromJson(Map<String, dynamic> json) {
    return ShippingModel(
      shippingId: json['shippingId'] as String,
      tanggal: (json['tanggal'] as Timestamp).toDate(),
      orderId: json['orderId'] as String,
      tujuan: json['tujuan'] as String,
      jumlahDikirim: json['jumlahDikirim'] as int,
      resi: json['resi'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
    );
  }

  factory ShippingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShippingModel(
      shippingId: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      orderId: data['orderId'] ?? '',
      tujuan: data['tujuan'] ?? '',
      jumlahDikirim: data['jumlahDikirim'] ?? 0,
      resi: data['resi'] ?? '',
      keterangan: data['keterangan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shippingId': shippingId,
      'tanggal': Timestamp.fromDate(tanggal),
      'orderId': orderId,
      'tujuan': tujuan,
      'jumlahDikirim': jumlahDikirim,
      'resi': resi,
      'keterangan': keterangan,
    };
  }

  bool get hasTrackingNumber => resi.isNotEmpty;

  ShippingModel copyWith({
    String? shippingId,
    DateTime? tanggal,
    String? orderId,
    String? tujuan,
    int? jumlahDikirim,
    String? resi,
    String? keterangan,
  }) {
    return ShippingModel(
      shippingId: shippingId ?? this.shippingId,
      tanggal: tanggal ?? this.tanggal,
      orderId: orderId ?? this.orderId,
      tujuan: tujuan ?? this.tujuan,
      jumlahDikirim: jumlahDikirim ?? this.jumlahDikirim,
      resi: resi ?? this.resi,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
