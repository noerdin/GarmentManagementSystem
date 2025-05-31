import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseItem {
  final String nama;
  final int quantity;
  final double harga;
  final String lokasi;

  PurchaseItem({
    required this.nama,
    required this.quantity,
    required this.harga,
    required this.lokasi,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      nama: json['nama'] as String,
      quantity: json['quantity'] as int,
      harga: (json['harga'] as num).toDouble(),
      lokasi: json['lokasi'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'quantity': quantity,
      'harga': harga,
      'lokasi': lokasi,
    };
  }
}

class PurchaseModel {
  final String purchaseId;
  final DateTime tanggal;
  final String supplier;
  final List<PurchaseItem> itemList;

  PurchaseModel({
    required this.purchaseId,
    required this.tanggal,
    required this.supplier,
    required this.itemList,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseId: json['purchaseId'] as String,
      tanggal: (json['tanggal'] as Timestamp).toDate(),
      supplier: json['supplier'] as String,
      itemList: (json['itemList'] as List)
          .map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  factory PurchaseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<PurchaseItem> items = [];
    if (data['itemList'] != null) {
      items = (data['itemList'] as List)
          .map((item) => PurchaseItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PurchaseModel(
      purchaseId: doc.id,
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      supplier: data['supplier'] ?? '',
      itemList: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchaseId': purchaseId,
      'tanggal': Timestamp.fromDate(tanggal),
      'supplier': supplier,
      'itemList': itemList.map((item) => item.toJson()).toList(),
    };
  }

  double get totalAmount {
    return itemList.fold(
        0, (total, item) => total + (item.quantity * item.harga));
  }

  int get totalItems {
    return itemList.fold(0, (total, item) => total + item.quantity);
  }

  PurchaseModel copyWith({
    String? purchaseId,
    DateTime? tanggal,
    String? supplier,
    List<PurchaseItem>? itemList,
  }) {
    return PurchaseModel(
      purchaseId: purchaseId ?? this.purchaseId,
      tanggal: tanggal ?? this.tanggal,
      supplier: supplier ?? this.supplier,
      itemList: itemList ?? this.itemList,
    );
  }
}
