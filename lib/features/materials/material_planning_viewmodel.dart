import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.dialogs.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../models/material_requirement_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/add_material_dialog.dart';
import '../../shared/snackbar_helper.dart';

class MaterialPlanningViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final String? orderId;
  MaterialPlanningViewModel({this.orderId});

  // Available orders
  List<OrderModel> _availableOrders = [];
  List<OrderModel> get availableOrders => _availableOrders;

  // Selected order
  String? _selectedOrderId;
  OrderModel? _selectedOrder;

  String? get selectedOrderId => _selectedOrderId;
  OrderModel? get selectedOrder => _selectedOrder;

  // Material requirements
  List<MaterialRequirement> _materialRequirements = [];
  List<MaterialRequirement> get materialRequirements => _materialRequirements;

  // Similar templates
  List<OrderMaterialTemplate> _similarTemplates = [];
  List<OrderMaterialTemplate> get similarTemplates => _similarTemplates;

  // Material types and units for dropdown
  final List<String> materialTypes = ['Bahan', 'Aksesoris'];
  final List<String> unitOptions = [
    'meter', 'yard', 'roll', 'piece', 'kilogram',
    'gram', 'box', 'pack', 'dozen'
  ];

  // Calculated totals
  double get totalEstimatedCost {
    return _materialRequirements.fold(0.0, (sum, req) =>
    sum + (req.quantityNeeded * req.estimatedPrice));
  }

  Future<void> init() async {
    setBusy(true);
    try {
      await _loadAvailableOrders();

      if (orderId != null) {
        _selectedOrderId = orderId;
        _selectedOrder = _availableOrders.firstWhere(
              (order) => order.orderId == orderId,
          orElse: () => _availableOrders.first,
        );
        await _findSimilarTemplates();
      }
    } catch (e) {
      setError('Failed to initialize: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadAvailableOrders() async {
    final orders = await _firestoreService.ordersStream().first;
    _availableOrders = orders.where((order) =>
    order.status == 'Pending' || order.status == 'Produksi'
    ).toList();
    notifyListeners();
  }

  void setSelectedOrder(String? orderId) async {
    _selectedOrderId = orderId;
    _selectedOrder = _availableOrders.firstWhere(
          (order) => order.orderId == orderId,
      orElse: () => _availableOrders.first,
    );

    // Clear existing materials and find similar templates
    _materialRequirements.clear();
    await _findSimilarTemplates();
    notifyListeners();
  }

  Future<void> _findSimilarTemplates() async {
    if (_selectedOrder == null) return;

    try {
      // Query material templates for similar products
      final templates = await _firestoreService.getMaterialTemplates();

      _similarTemplates = templates.where((template) =>
      template.productName.toLowerCase().contains(_selectedOrder!.namaProduk.toLowerCase()) ||
          template.productCategory.toLowerCase().contains(_selectedOrder!.namaProduk.toLowerCase()) ||
          template.color.toLowerCase() == _selectedOrder!.warna.toLowerCase()
      ).toList();

      notifyListeners();
    } catch (e) {
      print('Error finding similar templates: $e');
    }
  }

  Future<void> addNewMaterial() async {
    final result = await _showAddMaterialDialog();

    if (result != null) {
      final material = MaterialRequirement(
        materialId: _generateMaterialId(),
        materialName: result['name'] ?? '',
        materialType: result['type'] ?? 'Bahan',
        quantityNeeded: double.tryParse(result['quantity'] ?? '0') ?? 0.0,
        unit: result['unit'] ?? 'meter',
        estimatedPrice: double.tryParse(result['price'] ?? '0') ?? 0.0,
        supplier: result['supplier'] ?? '',
        notes: result['notes'] ?? '',
      );

      _materialRequirements.add(material);
      notifyListeners();

      SnackbarHelper.showSuccess('Material requirement added');
    }
  }

  Future<Map<String, dynamic>?> _showAddMaterialDialog() async {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context == null) return null;

    // Import the dialog widget (you'll need to add this import)
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddMaterialDialog(
        materialTypes: materialTypes,
        unitOptions: unitOptions,
        productType: _selectedOrder?.namaProduk,
      ),
    );

    return result;
  }

  void removeMaterial(int index) {
    if (index >= 0 && index < _materialRequirements.length) {
      final material = _materialRequirements[index];
      _materialRequirements.removeAt(index);
      notifyListeners();

      SnackbarHelper.showSuccess('Removed ${material.materialName}');
    }
  }

  Future<void> showCopyFromTemplate() async {
    if (_similarTemplates.isEmpty) {
      SnackbarHelper.showSnackbar(message: 'No similar templates found');
      return;
    }

    // Show selection dialog for templates
    String? selectedTemplateId = await _showTemplateSelectionDialog();

    if (selectedTemplateId != null) {
      await _copyFromTemplate(selectedTemplateId);
    }
  }

  Future<String?> _showTemplateSelectionDialog() async {
    return await showDialog<String>(
      context: _navigationService.navigatorKey!.currentContext!,
      builder: (context) => AlertDialog(
        title: Text('Copy from Template'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _similarTemplates.length,
            itemBuilder: (context, index) {
              final template = _similarTemplates[index];
              return ListTile(
                title: Text('${template.productName} (${template.color})'),
                subtitle: Text('Order: ${template.orderId} | Qty: ${template.quantityProduced}'),
                onTap: () => Navigator.pop(context, template.orderId),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyFromTemplate(String templateId) async {
    try {
      final template = _similarTemplates.firstWhere(
            (t) => t.orderId == templateId,
      );

      // Calculate scaling factor based on quantity
      final scaleFactor = _selectedOrder!.jumlahTotal / template.quantityProduced;

      // Copy and scale material requirements
      final scaledRequirements = template.materialRequirements.map((req) =>
          MaterialRequirement(
            materialId: _generateMaterialId(),
            materialName: req.materialName,
            materialType: req.materialType,
            quantityNeeded: req.quantityNeeded * scaleFactor,
            unit: req.unit,
            estimatedPrice: req.estimatedPrice,
            supplier: req.supplier,
            notes: 'Scaled from ${template.orderId} (${scaleFactor.toStringAsFixed(2)}x)',
          )
      ).toList();

      _materialRequirements.addAll(scaledRequirements);
      notifyListeners();

      SnackbarHelper.showSuccess(
          'Copied ${scaledRequirements.length} materials from template'
      );

    } catch (e) {
      SnackbarHelper.showError('Failed to copy template: $e');
    }
  }

  Future<void> showTemplateHistory() async {
    try {
      final allTemplates = await _firestoreService.getMaterialTemplates();

      await _dialogService.showCustomDialog(
        variant: DialogType.info,
        title: 'Material Templates History',
        description: 'Found ${allTemplates.length} saved templates.\n\n'
            'Templates help you reuse material requirements for similar orders.\n\n'
            'Recent templates:\n${allTemplates.take(5).map((t) =>
        '• ${t.productName} (${t.orderId})'
        ).join('\n')}',
        data: {'buttonText': 'OK'},
      );
    } catch (e) {
      SnackbarHelper.showError('Failed to load template history: $e');
    }
  }

  Future<void> saveMaterialTemplate() async {
    if (_selectedOrder == null || _materialRequirements.isEmpty) {
      SnackbarHelper.showError('Please select an order and add material requirements');
      return;
    }

    setBusy(true);

    try {
      final template = OrderMaterialTemplate(
        orderId: _selectedOrder!.orderId,
        productName: _selectedOrder!.namaProduk,
        productCategory: _selectedOrder!.namaProduk, // You might want to extract category
        color: _selectedOrder!.warna,
        quantityProduced: _selectedOrder!.jumlahTotal,
        materialRequirements: _materialRequirements,
        createdAt: DateTime.now(),
        createdBy: 'current_user_id', // Replace with actual user ID
      );

      await _firestoreService.saveMaterialTemplate(template);

      SnackbarHelper.showSuccess('Material template saved successfully!');
      _navigationService.back(result: true);

    } catch (e) {
      SnackbarHelper.showError('Failed to save template: $e');
    } finally {
      setBusy(false);
    }
  }

  String _generateMaterialId() {
    return 'MAT_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Auto-suggest materials based on product type
  Future<List<String>> getMaterialSuggestions(String productType) async {
    final suggestions = <String>[];

    // Basic material suggestions based on product type
    switch (productType.toLowerCase()) {
      case 't-shirt':
      case 'kaos':
        suggestions.addAll([
          'Cotton Fabric',
          'Thread - Various Colors',
          'Label - Size',
          'Label - Brand',
          'Plastic Packaging',
        ]);
        break;
      case 'polo':
      case 'polo shirt':
        suggestions.addAll([
          'Polo Cotton Fabric',
          'Collar Fabric',
          'Buttons',
          'Thread - Various Colors',
          'Label - Size',
          'Plastic Packaging',
        ]);
        break;
      case 'jacket':
      case 'jaket':
        suggestions.addAll([
          'Outer Fabric',
          'Lining Fabric',
          'Zipper',
          'Thread - Various Colors',
          'Velcro',
          'Label - Care Instructions',
          'Hangtag',
        ]);
        break;
      default:
        suggestions.addAll([
          'Fabric',
          'Thread',
          'Labels',
          'Packaging',
        ]);
    }

    return suggestions;
  }

  // Calculate material cost per unit
  double calculateCostPerUnit() {
    if (_selectedOrder == null || _selectedOrder!.jumlahTotal == 0) return 0.0;
    return totalEstimatedCost / _selectedOrder!.jumlahTotal;
  }

  // Generate material shopping list
  Future<void> generateShoppingList() async {
    if (_materialRequirements.isEmpty) {
      SnackbarHelper.showSnackbar(message: 'No materials to generate shopping list');
      return;
    }

    String shoppingList = 'Material Shopping List\n';
    shoppingList += 'Order: ${_selectedOrder?.orderId}\n';
    shoppingList += 'Product: ${_selectedOrder?.namaProduk}\n';
    shoppingList += 'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n\n';

    // Group by supplier
    final supplierGroups = <String, List<MaterialRequirement>>{};
    for (final req in _materialRequirements) {
      final supplier = req.supplier.isEmpty ? 'General Supplier' : req.supplier;
      supplierGroups.putIfAbsent(supplier, () => []).add(req);
    }

    double totalCost = 0.0;

    for (final entry in supplierGroups.entries) {
      shoppingList += '${entry.key}:\n';
      double supplierTotal = 0.0;

      for (final req in entry.value) {
        final itemTotal = req.quantityNeeded * req.estimatedPrice;
        shoppingList += '  • ${req.materialName}: ${req.quantityNeeded} ${req.unit} @ Rp${req.estimatedPrice.toStringAsFixed(0)} = Rp${itemTotal.toStringAsFixed(0)}\n';
        supplierTotal += itemTotal;
        totalCost += itemTotal;
      }

      shoppingList += '  Subtotal: Rp${supplierTotal.toStringAsFixed(0)}\n\n';
    }

    shoppingList += 'TOTAL ESTIMATED COST: Rp${totalCost.toStringAsFixed(0)}\n';
    shoppingList += 'Cost per unit: Rp${calculateCostPerUnit().toStringAsFixed(0)}';

    await _dialogService.showDialog(
      title: 'Shopping List Generated',
      description: shoppingList,
      buttonTitle: 'OK',
    );

    // You can also save this to device storage or send via email
    SnackbarHelper.showSuccess('Shopping list copied to clipboard');
  }
}