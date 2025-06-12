import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final DateTime tanggalOrder;

  // Customer Information
  final String namaCustomer;
  final String? kontak;
  final String? alamat;

  // Product Information
  final String namaProduk;
  final String? kategori;
  final String warna;
  final String? material;     // New field
  final String? spesifikasi; // New field for design specs
  final Map<String, int> ukuran;
  final int jumlahTotal;

  // Production Details
  final DateTime deadlineProduksi;
  final String? prioritas;    // New field
  final String catatan;
  final String status;
  final double progress;
  final double estimasiMargin;

  OrderModel({
    required this.orderId,
    required this.tanggalOrder,
    required this.namaCustomer,
    this.kontak,
    this.alamat,
    required this.namaProduk,
    this.kategori,
    required this.warna,
    this.material,
    this.spesifikasi,
    required this.ukuran,
    required this.jumlahTotal,
    required this.deadlineProduksi,
    this.prioritas = 'Normal',
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
      kontak: json['kontak'] as String?,
      alamat: json['alamat'] as String?,
      namaProduk: json['namaProduk'] as String,
      kategori: json['kategori'] as String?,
      warna: json['warna'] as String,
      material: json['material'] as String?,
      spesifikasi: json['spesifikasi'] as String?,
      ukuran: convertedUkuran,
      jumlahTotal: json['jumlahTotal'] as int,
      deadlineProduksi: (json['deadlineProduksi'] as Timestamp).toDate(),
      prioritas: json['prioritas'] as String? ?? 'Normal',
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
      kontak: data['kontak'],
      alamat: data['alamat'],
      namaProduk: data['namaProduk'] ?? '',
      kategori: data['kategori'],
      warna: data['warna'] ?? '',
      material: data['material'],
      spesifikasi: data['spesifikasi'],
      ukuran: convertedUkuran,
      jumlahTotal: data['jumlahTotal'] ?? 0,
      deadlineProduksi: (data['deadlineProduksi'] as Timestamp).toDate(),
      prioritas: data['prioritas'] ?? 'Normal',
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
      'kontak': kontak,
      'alamat': alamat,
      'namaProduk': namaProduk,
      'kategori': kategori,
      'warna': warna,
      'material': material,
      'spesifikasi': spesifikasi,
      'ukuran': ukuran,
      'jumlahTotal': jumlahTotal,
      'deadlineProduksi': Timestamp.fromDate(deadlineProduksi),
      'prioritas': prioritas,
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
    String? kontak,
    String? alamat,
    String? namaProduk,
    String? kategori,
    String? warna,
    String? material,
    String? spesifikasi,
    Map<String, int>? ukuran,
    int? jumlahTotal,
    DateTime? deadlineProduksi,
    String? prioritas,
    String? catatan,
    String? status,
    double? progress,
    double? estimasiMargin,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      tanggalOrder: tanggalOrder ?? this.tanggalOrder,
      namaCustomer: namaCustomer ?? this.namaCustomer,
      kontak: kontak ?? this.kontak,
      alamat: alamat ?? this.alamat,
      namaProduk: namaProduk ?? this.namaProduk,
      kategori: kategori ?? this.kategori,
      warna: warna ?? this.warna,
      material: material ?? this.material,
      spesifikasi: spesifikasi ?? this.spesifikasi,
      ukuran: ukuran ?? this.ukuran,
      jumlahTotal: jumlahTotal ?? this.jumlahTotal,
      deadlineProduksi: deadlineProduksi ?? this.deadlineProduksi,
      prioritas: prioritas ?? this.prioritas,
      catatan: catatan ?? this.catatan,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      estimasiMargin: estimasiMargin ?? this.estimasiMargin,
    );
  }
}
