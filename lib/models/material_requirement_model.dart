import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialRequirement {
  final String materialId;
  final String materialName;
  final String materialType; // Bahan, Aksesoris
  final double quantityNeeded;
  final String unit;
  final double estimatedPrice;
  final String supplier;
  final String notes;

  MaterialRequirement({
    required this.materialId,
    required this.materialName,
    required this.materialType,
    required this.quantityNeeded,
    required this.unit,
    required this.estimatedPrice,
    required this.supplier,
    this.notes = '',
  });

  factory MaterialRequirement.fromMap(Map<String, dynamic> map) {
    return MaterialRequirement(
      materialId: map['materialId'] ?? '',
      materialName: map['materialName'] ?? '',
      materialType: map['materialType'] ?? '',
      quantityNeeded: (map['quantityNeeded'] ?? 0).toDouble(),
      unit: map['unit'] ?? '',
      estimatedPrice: (map['estimatedPrice'] ?? 0).toDouble(),
      supplier: map['supplier'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'materialType': materialType,
      'quantityNeeded': quantityNeeded,
      'unit': unit,
      'estimatedPrice': estimatedPrice,
      'supplier': supplier,
      'notes': notes,
    };
  }
}

class OrderMaterialTemplate {
  final String orderId;
  final String productName;
  final String productCategory;
  final String color;
  final int quantityProduced;
  final List<MaterialRequirement> materialRequirements;
  final DateTime createdAt;
  final String createdBy;

  OrderMaterialTemplate({
    required this.orderId,
    required this.productName,
    required this.productCategory,
    required this.color,
    required this.quantityProduced,
    required this.materialRequirements,
    required this.createdAt,
    required this.createdBy,
  });

  factory OrderMaterialTemplate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<MaterialRequirement> requirements = [];
    if (data['materialRequirements'] != null) {
      requirements = (data['materialRequirements'] as List)
          .map((item) => MaterialRequirement.fromMap(item))
          .toList();
    }

    return OrderMaterialTemplate(
      orderId: doc.id,
      productName: data['productName'] ?? '',
      productCategory: data['productCategory'] ?? '',
      color: data['color'] ?? '',
      quantityProduced: data['quantityProduced'] ?? 0,
      materialRequirements: requirements,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productCategory': productCategory,
      'color': color,
      'quantityProduced': quantityProduced,
      'materialRequirements': materialRequirements.map((req) => req.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }
}