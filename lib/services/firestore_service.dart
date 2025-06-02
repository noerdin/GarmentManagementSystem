import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enhanced_production_model.dart';
import '../models/material_model.dart';
import '../models/material_requirement_model.dart';
import '../models/order_model.dart';
import '../models/production_model.dart';
import '../models/purchase_model.dart';
import '../models/shipping_model.dart';
import '../models/stock_opname_model.dart';
import '../models/user_model.dart';
import '../models/warehouse_transfer_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _ordersCollection = 'orders';
  static const String _materialsCollection = 'materials';
  static const String _productionCollection = 'produksi';
  static const String _purchaseCollection = 'pembelian';
  static const String _shippingCollection = 'pengiriman';
  static const String _stockOpnameCollection = 'stockOpname';
  static const String _warehouseTransferCollection = 'mutasiGudang';
  static const String _usersCollection = 'users';

  // Generic function to add data to Firestore
  Future<void> addData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw 'Failed to add data to $collection: $e';
    }
  }

  // Generic function to update data in Firestore
  Future<void> updateData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw 'Failed to update data in $collection: $e';
    }
  }


  // Orders
  Stream<List<OrderModel>> ordersStream() {
    return _firestore
        .collection(_ordersCollection)
        .orderBy('tanggalOrder', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final snapshot = await _firestore.collection(_ordersCollection).get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw 'Unable to load orders: $e';
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final doc =
      await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (!doc.exists) {
        throw 'Order not found';
      }
      return OrderModel.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to retrieve order: $e';
    }
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(order.orderId)
          .set(order.toJson());
    } catch (e) {
      throw 'Failed to add order: $e';
    }
  }

  Future<void> updateOrder(OrderModel order) async {
    try {
      await _firestore
          .collection(_ordersCollection)
          .doc(order.orderId)
          .update(order.toJson());
    } catch (e) {
      throw 'Failed to update order: $e';
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).delete();
    } catch (e) {
      throw 'Failed to delete order: $e';
    }
  }

  Future<void> deleteData(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw 'Failed to delete data from $collection: $e';
    }
  }

  // Materials
  Stream<List<MaterialModel>> materialsStream() {
    return _firestore.collection(_materialsCollection).snapshots().map(
            (snapshot) => snapshot.docs
            .map((doc) => MaterialModel.fromFirestore(doc))
            .toList());
  }

  Future<List<MaterialModel>> getMaterials() async {
    try {
      final snapshot = await _firestore.collection(_materialsCollection).get();
      return snapshot.docs
          .map((doc) => MaterialModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Unable to load materials: $e';
    }
  }

  Future<void> addMaterial(MaterialModel material) async {
    try {
      await _firestore
          .collection(_materialsCollection)
          .doc(material.materialId)
          .set(material.toJson());
    } catch (e) {
      throw 'Failed to add material: $e';
    }
  }

  Future<void> updateMaterial(MaterialModel material) async {
    try {
      await _firestore
          .collection(_materialsCollection)
          .doc(material.materialId)
          .update(material.toJson());
    } catch (e) {
      throw 'Failed to update material: $e';
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await _firestore.collection(_materialsCollection).doc(materialId).delete();
    } catch (e) {
      throw 'Failed to delete material: $e';
    }
  }

  Future<List<OrderMaterialTemplate>> getMaterialTemplates() async {
    try {
      final snapshot = await _firestore.collection('materialTemplates').get();
      return snapshot.docs
          .map((doc) => OrderMaterialTemplate.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to load material templates: $e';
    }
  }

  Future<void> saveMaterialTemplate(OrderMaterialTemplate template) async {
    try {
      await _firestore
          .collection('materialTemplates')
          .doc(template.orderId)
          .set(template.toJson());
    } catch (e) {
      throw 'Failed to save material template: $e';
    }
  }

  // Enhanced Production
  Future<EnhancedProductionModel> getProductionById(String produksiId) async {
    try {
      final doc = await _firestore.collection('produksi').doc(produksiId).get();
      if (!doc.exists) throw 'Production not found';
      return EnhancedProductionModel.fromFirestore(doc);
    } catch (e) {
      throw 'Failed to retrieve production: $e';
    }
  }

  // Production
  Stream<List<ProductionModel>> productionStream() {
    return _firestore
        .collection(_productionCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductionModel.fromFirestore(doc))
        .toList());
  }

  Future<List<ProductionModel>> getProductionsByOrderId(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_productionCollection)
          .where('orderId', isEqualTo: orderId)
          .get();
      return snapshot.docs
          .map((doc) => ProductionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to load production data: $e';
    }
  }

  Future<void> addProduction(ProductionModel production) async {
    try {
      await _firestore
          .collection(_productionCollection)
          .doc(production.produksiId)
          .set(production.toJson());
    } catch (e) {
      throw 'Failed to add production record: $e';
    }
  }

  // Purchases
  Stream<List<PurchaseModel>> purchasesStream() {
    return _firestore
        .collection(_purchaseCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PurchaseModel.fromFirestore(doc))
        .toList());
  }

  Future<void> addPurchase(PurchaseModel purchase) async {
    try {
      await _firestore
          .collection(_purchaseCollection)
          .doc(purchase.purchaseId)
          .set(purchase.toJson());
    } catch (e) {
      throw 'Failed to add purchase: $e';
    }
  }

  // Shipping
  Stream<List<ShippingModel>> shippingStream() {
    return _firestore
        .collection(_shippingCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ShippingModel.fromFirestore(doc))
        .toList());
  }

  Future<List<ShippingModel>> getShippingsByOrderId(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection(_shippingCollection)
          .where('orderId', isEqualTo: orderId)
          .get();
      return snapshot.docs
          .map((doc) => ShippingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to load shipping data: $e';
    }
  }

  Future<void> addShipping(ShippingModel shipping) async {
    try {
      await _firestore
          .collection(_shippingCollection)
          .doc(shipping.shippingId)
          .set(shipping.toJson());
    } catch (e) {
      throw 'Failed to add shipping record: $e';
    }
  }

  // Stock Opname
  Future<List<StockOpnameModel>> getStockOpnameRecords() async {
    try {
      final snapshot = await _firestore
          .collection(_stockOpnameCollection)
          .orderBy('tanggal', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => StockOpnameModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw 'Failed to load stock opname records: $e';
    }
  }

  Future<void> addStockOpnameRecord(StockOpnameModel record) async {
    try {
      await _firestore
          .collection(_stockOpnameCollection)
          .doc(record.opnameId)
          .set(record.toJson());
    } catch (e) {
      throw 'Failed to add stock opname record: $e';
    }
  }

  // Warehouse Transfers
  Stream<List<WarehouseTransferModel>> warehouseTransfersStream() {
    return _firestore
        .collection(_warehouseTransferCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => WarehouseTransferModel.fromFirestore(doc))
        .toList());
  }

  Future<void> addWarehouseTransfer(WarehouseTransferModel transfer) async {
    try {
      await _firestore
          .collection(_warehouseTransferCollection)
          .doc(transfer.mutasiId)
          .set(transfer.toJson());
    } catch (e) {
      throw 'Failed to add warehouse transfer: $e';
    }
  }

  // --- Users ---
  Future<void> addUser(UserModel user) async {
    try {
      // Menggunakan UID dari Firebase Auth sebagai ID dokumen pengguna di Firestore
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid) // Asumsi UserModel memiliki properti uid
          .set(user.toJson()); // Asumsi UserModel memiliki metode toJson()
    } catch (e) {
      throw 'Failed to add user: $e';
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc =
      await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc); // Asumsi UserModel memiliki factory fromFirestore
      }
      return null; // Kembalikan null jika pengguna tidak ditemukan
    } catch (e) {
      throw 'Failed to retrieve user: $e';
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid) // Asumsi UserModel memiliki properti uid
          .update(user.toJson()); // Asumsi UserModel memiliki metode toJson()
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  Stream<List<UserModel>> usersStream() {
    return _firestore
        .collection(_usersCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList());
  }

  // Dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // Get orders
      final ordersSnapshot =
      await _firestore.collection(_ordersCollection).get();
      final List<OrderModel> orders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();

      // Get materials with low stock
      final materialsSnapshot =
      await _firestore.collection(_materialsCollection).get();
      final List<MaterialModel> materials = materialsSnapshot.docs
          .map((doc) => MaterialModel.fromFirestore(doc))
          .toList();
      final List<MaterialModel> lowStockMaterials =
      materials.where((m) => m.isLowStock).toList();

      // Get recent production records
      final productionSnapshot = await _firestore
          .collection(_productionCollection)
          .orderBy('tanggal', descending: true)
          .limit(10)
          .get();
      final List<ProductionModel> recentProduction = productionSnapshot.docs
          .map((doc) => ProductionModel.fromFirestore(doc))
          .toList();

      // Get shipping records
      final shippingSnapshot = await _firestore
          .collection(_shippingCollection)
          .orderBy('tanggal', descending: true)
          .limit(5)
          .get();
      final List<ShippingModel> recentShipping = shippingSnapshot.docs
          .map((doc) => ShippingModel.fromFirestore(doc))
          .toList();

      return {
        'totalOrders': orders.length,
        'pendingOrders': orders.where((o) => o.status == 'Pending').length,
        'productionOrders': orders.where((o) => o.status == 'Produksi').length,
        'completedOrders': orders.where((o) => o.status == 'Selesai').length,
        'overdueOrders': orders.where((o) => o.isOverdue).length,
        'lowStockMaterials': lowStockMaterials,
        'recentProduction': recentProduction,
        'recentShipping': recentShipping,
      };
    } catch (e) {
      throw 'Failed to load dashboard data: $e';
    }
  }

  // Generate IDs
  String generateOrderId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'ORD${now.year}${now.month.toString().padLeft(2, '0')}$timestamp';
  }

  String generateMaterialId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'MAT$timestamp';
  }

  String generateProductionId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'PRD$timestamp';
  }

  String generatePurchaseId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'PUR$timestamp';
  }

  String generateShippingId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'SHP$timestamp';
  }

  String generateStockOpnameId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'OPN$timestamp';
  }

  String generateWarehouseTransferId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5, 10);
    return 'MUT$timestamp';
  }
}
