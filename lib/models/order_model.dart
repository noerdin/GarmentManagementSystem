import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final DateTime tanggalOrder;
  final String namaCustomer;
  final String namaProduk;
  final String warna;
  final Map<String, int> ukuran;
  final int jumlahTotal;
  final DateTime deadlineProduksi;
  final String catatan;
  final String status;
  final double progress;
  final double estimasiMargin;

  OrderModel({
    required this.orderId,
    required this.tanggalOrder,
    required this.namaCustomer,
    required this.namaProduk,
    required this.warna,
    required this.ukuran,
    required this.jumlahTotal,
    required this.deadlineProduksi,
    this.catatan = '',
    this.status = 'Pending',
    this.progress = 0.0,
    this.estimasiMargin = 0.0,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> ukuranMap = json['ukuran'] as Map<String, dynamic>;
    Map<String, int> convertedUkuran = {};

    ukuranMap.forEach((key, value) {
      convertedUkuran[key] = (value is int) ? value : 0;
    });

    return OrderModel(
      orderId: json['orderId'] as String,
      tanggalOrder: (json['tanggalOrder'] as Timestamp).toDate(),
      namaCustomer: json['namaCustomer'] as String,
      namaProduk: json['namaProduk'] as String,
      warna: json['warna'] as String,
      ukuran: convertedUkuran,
      jumlahTotal: json['jumlahTotal'] as int,
      deadlineProduksi: (json['deadlineProduksi'] as Timestamp).toDate(),
      catatan: json['catatan'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      estimasiMargin: (json['estimasiMargin'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle ukuran map conversion
    Map<String, dynamic> ukuranMap = data['ukuran'] ?? {};
    Map<String, int> convertedUkuran = {};

    ukuranMap.forEach((key, value) {
      convertedUkuran[key] = (value is int) ? value : 0;
    });

    return OrderModel(
      orderId: doc.id,
      tanggalOrder: (data['tanggalOrder'] as Timestamp).toDate(),
      namaCustomer: data['namaCustomer'] ?? '',
      namaProduk: data['namaProduk'] ?? '',
      warna: data['warna'] ?? '',
      ukuran: convertedUkuran,
      jumlahTotal: data['jumlahTotal'] ?? 0,
      deadlineProduksi: (data['deadlineProduksi'] as Timestamp).toDate(),
      catatan: data['catatan'] ?? '',
      status: data['status'] ?? 'Pending',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      estimasiMargin: (data['estimasiMargin'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'tanggalOrder': Timestamp.fromDate(tanggalOrder),
      'namaCustomer': namaCustomer,
      'namaProduk': namaProduk,
      'warna': warna,
      'ukuran': ukuran,
      'jumlahTotal': jumlahTotal,
      'deadlineProduksi': Timestamp.fromDate(deadlineProduksi),
      'catatan': catatan,
      'status': status,
      'progress': progress,
      'estimasiMargin': estimasiMargin,
    };
  }

  // Helper method to get days remaining until deadline
  int get daysRemaining {
    final now = DateTime.now();
    return deadlineProduksi.difference(now).inDays;
  }

  // Helper method to check if deadline is passed
  bool get isOverdue {
    final now = DateTime.now();
    return now.isAfter(deadlineProduksi) && status != 'Selesai';
  }

  // Helper method to get display-friendly status
  String get displayStatus {
    switch (status) {
      case 'Pending':
        return 'Menunggu';
      case 'Produksi':
        return 'Dalam Produksi';
      case 'Selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  OrderModel copyWith({
    String? orderId,
    DateTime? tanggalOrder,
    String? namaCustomer,
    String? namaProduk,
    String? warna,
    Map<String, int>? ukuran,
    int? jumlahTotal,
    DateTime? deadlineProduksi,
    String? catatan,
    String? status,
    double? progress,
    double? estimasiMargin,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      tanggalOrder: tanggalOrder ?? this.tanggalOrder,
      namaCustomer: namaCustomer ?? this.namaCustomer,
      namaProduk: namaProduk ?? this.namaProduk,
      warna: warna ?? this.warna,
      ukuran: ukuran ?? this.ukuran,
      jumlahTotal: jumlahTotal ?? this.jumlahTotal,
      deadlineProduksi: deadlineProduksi ?? this.deadlineProduksi,
      catatan: catatan ?? this.catatan,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      estimasiMargin: estimasiMargin ?? this.estimasiMargin,
    );
  }
}
