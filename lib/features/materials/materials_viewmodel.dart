import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/material_model.dart';
import '../../models/material_requirement_model.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';
import '../../shared/result_state.dart';
import '../../shared/snackbar_helper.dart';
import '../../shared/stock_update_dialog.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import 'add_material_view.dart';
import 'material_planning_view.dart';

class MaterialsViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  // Constructor with orderId parameter
  final String? orderId;
  MaterialsViewModel({this.orderId});

  // State Management
  ResultState<List<MaterialModel>> _materialsState = const Loading();
  ResultState<List<MaterialModel>> get materialsState => _materialsState;

  List<MaterialModel> _materials = [];
  List<MaterialModel> _filteredMaterials = [];
  List<MaterialModel> _displayedMaterials = [];
  int _selectedTab = 0;
  bool _showLowStockOnly = false;
  bool _showOrderRelevantOnly = false;

  // Order context
  OrderModel? _selectedOrder;
  List<OrderModel> _availableOrders = [];
  List<MaterialRequirement> _orderMaterialRequirements = [];

  List<MaterialModel> get materials => _materials;
  List<MaterialModel> get displayedMaterials => _displayedMaterials;
  bool get showLowStockOnly => _showLowStockOnly;
  bool get showOrderRelevantOnly => _showOrderRelevantOnly;
  OrderModel? get selectedOrder => _selectedOrder;

  // Stats
  int get totalBahan => _materials.where((m) => m.jenis == 'Bahan').length;
  int get totalAksesoris =>
      _materials.where((m) => m.jenis == 'Aksesoris').length;
  int get lowStockCount => _materials.where((m) => m.isLowStock).length;
  int get orderRelevantCount => orderId != null
      ? _materials.where((m) => isMaterialRelevantToOrder(m)).length
      : 0;

  Future<void> init() async {
    setBusy(true);
    try {
      await loadData();

      if (orderId != null) {
        await _loadOrderContext();
      }
    } catch (e) {
      setError(AppError.generic('Failed to initialize: $e'));
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    _materialsState = const Loading(message: 'Loading materials...');
    notifyListeners();

    try {
      final materialsData = await _firestoreService.materialsStream().first;
      _materials = materialsData;
      _filteredMaterials = materialsData;
      _updateDisplayedMaterials();

      _materialsState = Success(_materials);
      notifyListeners();
    } catch (e) {
      _materialsState = Error(AppError.generic('Failed to load materials: $e'));
      notifyListeners();
    }
  }

  Future<void> _loadOrderContext() async {
    try {
      final orders = await _firestoreService.ordersStream().first;
      _availableOrders = orders;

      _selectedOrder = orders.firstWhere(
            (order) => order.orderId == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      // Load material requirements for this order if they exist
      await _loadOrderMaterialRequirements();

      notifyListeners();
    } catch (e) {
      print('Error loading order context: $e');
    }
  }

  Future<void> _loadOrderMaterialRequirements() async {
    try {
      final templates = await _firestoreService.getMaterialTemplates();
      final orderTemplate = templates.firstWhere(
            (template) => template.orderId == orderId,
        orElse: () => throw Exception('No template found'),
      );

      _orderMaterialRequirements = orderTemplate.materialRequirements;
    } catch (e) {
      // No existing template found, which is okay
      _orderMaterialRequirements = [];
    }
  }

  Future<void> refreshData() async {
    await loadData();
    if (orderId != null) {
      await _loadOrderContext();
    }
    _snackbarService.showSnackbar(
      message: 'Materials refreshed',
      duration: const Duration(seconds: 2),
    );
  }

  // Handle tab selection
  void setSelectedTab(int index) {
    _selectedTab = index;
    _updateDisplayedMaterials();
    notifyListeners();
  }

  // Toggle low stock filter
  void toggleLowStockFilter() {
    _showLowStockOnly = !_showLowStockOnly;
    if (_showLowStockOnly) {
      _showOrderRelevantOnly = false; // Can't have both filters active
    }
    _updateDisplayedMaterials();
    notifyListeners();
  }

  // Toggle order relevant filter
  void toggleOrderRelevantFilter() {
    _showOrderRelevantOnly = !_showOrderRelevantOnly;
    if (_showOrderRelevantOnly) {
      _showLowStockOnly = false; // Can't have both filters active
    }
    _updateDisplayedMaterials();
    notifyListeners();
  }

  // Update displayed materials based on selected tab and filters
  void _updateDisplayedMaterials() {
    List<MaterialModel> result = _filteredMaterials;

    // Apply tab filter
    switch (_selectedTab) {
      case 0: // All
        break;
      case 1: // Bahan
        result = result.where((m) => m.jenis == 'Bahan').toList();
        break;
      case 2: // Aksesoris
        result = result.where((m) => m.jenis == 'Aksesoris').toList();
        break;
      default:
        break;
    }

    // Apply low stock filter if enabled
    if (_showLowStockOnly) {
      result = result.where((m) => m.isLowStock).toList();
    }

    // Apply order relevant filter if enabled
    if (_showOrderRelevantOnly && orderId != null) {
      result = result.where((m) => isMaterialRelevantToOrder(m)).toList();
    }

    _displayedMaterials = result;
  }

  // Filter materials based on search text
  void filterMaterials(String searchText) {
    if (searchText.isEmpty) {
      _filteredMaterials = _materials;
    } else {
      final lowerCaseSearch = searchText.toLowerCase();
      _filteredMaterials = _materials.where((material) {
        return material.nama.toLowerCase().contains(lowerCaseSearch) ||
            material.materialId.toLowerCase().contains(lowerCaseSearch) ||
            material.lokasi.toLowerCase().contains(lowerCaseSearch);
      }).toList();
    }
    _updateDisplayedMaterials();
    notifyListeners();
  }

  // Check if material is relevant to current order
  bool isMaterialRelevantToOrder(MaterialModel material) {
    if (_selectedOrder == null) return false;

    // Check if material is in the order's requirements
    final isInRequirements = _orderMaterialRequirements.any(
            (req) => req.materialName.toLowerCase().contains(material.nama.toLowerCase())
    );

    if (isInRequirements) return true;

    // Check by product type and common materials
    final productName = _selectedOrder!.namaProduk.toLowerCase();
    final materialName = material.nama.toLowerCase();

    // Common fabric materials for clothing
    if (material.jenis == 'Bahan') {
      if (productName.contains('t-shirt') || productName.contains('kaos')) {
        return materialName.contains('cotton') ||
            materialName.contains('katun') ||
            materialName.contains('fabric');
      }
      if (productName.contains('polo')) {
        return materialName.contains('polo') ||
            materialName.contains('cotton') ||
            materialName.contains('pique');
      }
      if (productName.contains('jacket') || productName.contains('jaket')) {
        return materialName.contains('outer') ||
            materialName.contains('lining') ||
            materialName.contains('jacket');
      }
    }

    // Common accessories
    if (material.jenis == 'Aksesoris') {
      return materialName.contains('thread') ||
          materialName.contains('benang') ||
          materialName.contains('label') ||
          materialName.contains('button') ||
          materialName.contains('kancing') ||
          materialName.contains('zipper') ||
          materialName.contains('resleting');
    }

    return false;
  }

  // Show material details dialog
  Future<void> showMaterialDetails(MaterialModel material) async {
    final result = await _dialogService.showDialog(
      title: 'Material Details',
      description: 'Material ID: ${material.materialId}\n'
          'Name: ${material.nama}\n'
          'Type: ${material.jenis}\n'
          'Unit: ${material.satuan}\n'
          'Stock: ${material.stok} ${material.satuan}\n'
          'Location: ${material.lokasi}\n'
          'Price: Rp ${material.hargaPerUnit.toStringAsFixed(0)}/${material.satuan}\n'
          'Last Updated: ${_formatDate(material.lastUpdated)}'
          '${orderId != null && isMaterialRelevantToOrder(material) ? '\n\n✓ Relevant to current order' : ''}',
      dialogPlatform: DialogPlatform.Material,
      buttonTitle: 'Edit Material',
      cancelTitle: 'Close',
    );

    if (result?.confirmed ?? false) {
      await _showMaterialActions(material);
    }
  }

  // Show material actions bottom sheet
  Future<void> _showMaterialActions(MaterialModel material) async {
    final BuildContext? context = StackedService.navigatorKey?.currentContext;

    if (context == null) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Material Actions',
                style: heading3Style(context),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.edit, color: kcPrimaryColor),
                title: const Text('Edit Material'),
                subtitle: const Text('Modify material information'),
                onTap: () {
                  Navigator.pop(context);
                  editMaterial(material.materialId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory, color: kcInfoColor),
                title: const Text('Update Stock'),
                subtitle: Text('Current: ${material.stok} ${material.satuan}'),
                onTap: () {
                  Navigator.pop(context);
                  showUpdateStockDialog(material);
                },
              ),
              if (orderId != null) ...[
                ListTile(
                  leading: const Icon(Icons.add_circle, color: kcSuccessColor),
                  title: const Text('Add to Order Requirements'),
                  subtitle: const Text('Include in material planning'),
                  onTap: () {
                    Navigator.pop(context);
                    addMaterialToOrderRequirements(material);
                  },
                ),
              ],
              if (material.stok == 0) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: kcErrorColor),
                  title: const Text('Delete Material'),
                  subtitle: const Text('Remove from inventory'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMaterial(material);
                  },
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Navigate to add material form
  Future<void> showAddMaterialDialog({String? orderContext}) async {
    final result = await _navigationService.navigateToView(const AddMaterialView());
    if (result == true) {
      await refreshData();
    }
  }

  // Navigate to edit material form
  Future<void> editMaterial(String materialId) async {
    final result = await _navigationService.navigateToView(
        AddMaterialView(materialId: materialId)
    );
    if (result == true) {
      await refreshData();
    }
  }

  // Navigate to material planning
  Future<void> navigateToMaterialPlanning() async {
    if (orderId == null) {
      _snackbarService.showSnackbar(
          message: 'No order context available',
          duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await _navigationService.navigateToView(
        MaterialPlanningView(orderId: orderId)
    );

    if (result == true) {
      await refreshData();
    }
  }

  // Add material to order requirements
  Future<void> addMaterialToOrderRequirements(MaterialModel material) async {
    if (orderId == null || _selectedOrder == null) {
      _snackbarService.showSnackbar(
        message: 'No order context available',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Create a simple material requirement
    final requirement = MaterialRequirement(
      materialId: material.materialId,
      materialName: material.nama,
      materialType: material.jenis,
      quantityNeeded: 1.0, // Default quantity
      unit: material.satuan,
      estimatedPrice: material.hargaPerUnit,
      supplier: '',
      notes: 'Added from inventory',
    );

    _orderMaterialRequirements.add(requirement);

    _snackbarService.showSnackbar(
      message: '${material.nama} added to order requirements',
      duration: const Duration(seconds: 3),
    );

    // Optionally navigate to material planning to edit the requirement
    final shouldNavigate = await _dialogService.showDialog(
      title: 'Material Added',
      description: 'Would you like to go to Material Planning to adjust quantities and details?',
      buttonTitle: 'Go to Planning',
      cancelTitle: 'Stay Here',
    );

    if (shouldNavigate?.confirmed ?? false) {
      await navigateToMaterialPlanning();
    }
  }

  // Check material requirements for order
  Future<void> checkMaterialRequirements() async {
    if (orderId == null || _selectedOrder == null) {
      _snackbarService.showSnackbar(
        message: 'No order context available',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setBusy(true);

    try {
      final requiredMaterials = await _getMaterialRequirementsForOrder();
      final availabilityReport = _generateAvailabilityReport(requiredMaterials);

      await _dialogService.showDialog(
        title: 'Material Requirements Check',
        description: availabilityReport,
        buttonTitle: 'OK',
      );

    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to check requirements: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<List<MaterialRequirement>> _getMaterialRequirementsForOrder() async {
    // Try to get from existing template first
    if (_orderMaterialRequirements.isNotEmpty) {
      return _orderMaterialRequirements;
    }

    // Generate basic requirements based on product type
    final suggestions = await _generateMaterialSuggestions();
    return suggestions;
  }

  Future<List<MaterialRequirement>> _generateMaterialSuggestions() async {
    final suggestions = <MaterialRequirement>[];
    final productName = _selectedOrder!.namaProduk.toLowerCase();
    final quantity = _selectedOrder!.jumlahTotal;

    // Basic suggestions based on product type
    if (productName.contains('t-shirt') || productName.contains('kaos')) {
      suggestions.addAll([
        MaterialRequirement(
          materialId: 'FABRIC_${DateTime.now().millisecondsSinceEpoch}',
          materialName: 'Cotton Fabric',
          materialType: 'Bahan',
          quantityNeeded: quantity * 0.5, // 0.5 meter per piece
          unit: 'meter',
          estimatedPrice: 25000,
          supplier: '',
          notes: 'Main fabric for T-shirt',
        ),
        MaterialRequirement(
          materialId: 'THREAD_${DateTime.now().millisecondsSinceEpoch}',
          materialName: 'Thread',
          materialType: 'Aksesoris',
          quantityNeeded: quantity * 0.1, // 0.1 meter per piece
          unit: 'meter',
          estimatedPrice: 5000,
          supplier: '',
          notes: 'Sewing thread',
        ),
      ]);
    }

    return suggestions;
  }

  String _generateAvailabilityReport(List<MaterialRequirement> requirements) {
    if (requirements.isEmpty) {
      return 'No material requirements found. Consider planning materials for this order.';
    }

    final report = StringBuffer();
    report.writeln('Material Availability Report for Order ${_selectedOrder!.orderId}\n');

    int availableCount = 0;
    int insufficientCount = 0;
    int missingCount = 0;

    for (final req in requirements) {
      final availableMaterial = _materials.where((m) =>
          m.nama.toLowerCase().contains(req.materialName.toLowerCase())
      ).firstOrNull;

      if (availableMaterial == null) {
        report.writeln('❌ ${req.materialName}: Not in inventory');
        missingCount++;
      } else if (availableMaterial.stok < req.quantityNeeded) {
        report.writeln('⚠️ ${req.materialName}: ${availableMaterial.stok}/${req.quantityNeeded} ${req.unit} (Insufficient)');
        insufficientCount++;
      } else {
        report.writeln('✅ ${req.materialName}: ${availableMaterial.stok}/${req.quantityNeeded} ${req.unit} (Available)');
        availableCount++;
      }
    }

    report.writeln('\nSummary:');
    report.writeln('Available: $availableCount');
    report.writeln('Insufficient: $insufficientCount');
    report.writeln('Missing: $missingCount');

    return report.toString();
  }

  // Generate shopping list
  Future<void> generateShoppingList() async {
    if (orderId == null || _selectedOrder == null) {
      _snackbarService.showSnackbar(
        message: 'No order context available',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setBusy(true);

    try {
      final requirements = await _getMaterialRequirementsForOrder();
      final shoppingList = _generateShoppingListText(requirements);

      await _dialogService.showDialog(
        title: 'Shopping List Generated',
        description: shoppingList,
        buttonTitle: 'OK',
      );

      _snackbarService.showSnackbar(
        message: 'Shopping list generated',
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to generate shopping list: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  String _generateShoppingListText(List<MaterialRequirement> requirements) {
    final shoppingList = StringBuffer();
    shoppingList.writeln('SHOPPING LIST');
    shoppingList.writeln('Order: ${_selectedOrder!.orderId}');
    shoppingList.writeln('Product: ${_selectedOrder!.namaProduk}');
    shoppingList.writeln('Quantity: ${_selectedOrder!.jumlahTotal}');
    shoppingList.writeln('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}\n');

    double totalCost = 0;

    shoppingList.writeln('MATERIALS TO PURCHASE:\n');

    for (final req in requirements) {
      final availableMaterial = _materials.where((m) =>
          m.nama.toLowerCase().contains(req.materialName.toLowerCase())
      ).firstOrNull;

      if (availableMaterial == null || availableMaterial.stok < req.quantityNeeded) {
        final neededQuantity = availableMaterial == null
            ? req.quantityNeeded
            : req.quantityNeeded - availableMaterial.stok;

        final itemCost = neededQuantity * req.estimatedPrice;
        totalCost += itemCost;

        shoppingList.writeln('• ${req.materialName}');
        shoppingList.writeln('  Quantity: $neededQuantity ${req.unit}');
        shoppingList.writeln('  Est. Price: Rp ${req.estimatedPrice.toStringAsFixed(0)}/${req.unit}');
        shoppingList.writeln('  Total: Rp ${itemCost.toStringAsFixed(0)}');
        if (req.supplier.isNotEmpty) {
          shoppingList.writeln('  Supplier: ${req.supplier}');
        }
        shoppingList.writeln('');
      }
    }

    shoppingList.writeln('TOTAL ESTIMATED COST: Rp ${totalCost.toStringAsFixed(0)}');

    return shoppingList.toString();
  }

  // Show update stock dialog
  Future<void> showUpdateStockDialog(MaterialModel material) async {
    final BuildContext? context = StackedService.navigatorKey?.currentContext;

    if (context == null) {
      _snackbarService.showSnackbar(
        message: 'Unable to show stock update dialog',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StockUpdateDialog(
          materialName: material.nama,
          currentStock: material.stok,
          unit: material.satuan,
          onStockUpdate: (int newStock, String reason) async {
            await _updateMaterialStock(material, newStock, reason);
          },
        );
      },
    );
  }

  // Update material stock
  Future<void> _updateMaterialStock(MaterialModel material, int newStock, String reason) async {
    setBusy(true);

    try {
      final updatedMaterial = material.copyWith(
        stok: newStock,
        lastUpdated: DateTime.now(),
      );

      await _firestoreService.updateMaterial(updatedMaterial);

      _snackbarService.showSnackbar(
        message: 'Stock updated successfully: ${material.nama} now has $newStock ${material.satuan}',
        duration: const Duration(seconds: 3),
      );

      await refreshData();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to update stock: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Delete material with confirmation
  Future<void> deleteMaterial(MaterialModel material) async {
    final result = await _dialogService.showDialog(
      title: 'Delete Material',
      description: 'Are you sure you want to delete "${material.nama}"? This action cannot be undone.\n\nCurrent Stock: ${material.stok} ${material.satuan}',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (result?.confirmed ?? false) {
      setBusy(true);

      try {
        await _firestoreService.deleteMaterial(material.materialId);

        _snackbarService.showSnackbar(
          message: 'Material "${material.nama}" deleted successfully',
          duration: const Duration(seconds: 3),
        );

        await refreshData();
      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Failed to delete material: $e',
          duration: const Duration(seconds: 3),
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Bulk stock operations
  Future<void> bulkStockUpdate(List<MaterialModel> materials, int adjustment, String reason) async {
    setBusy(true);

    try {
      for (final material in materials) {
        final newStock = material.stok + adjustment;
        if (newStock >= 0) {
          final updatedMaterial = material.copyWith(
            stok: newStock,
            lastUpdated: DateTime.now(),
          );
          await _firestoreService.updateMaterial(updatedMaterial);
        }
      }

      _snackbarService.showSnackbar(
        message: '${materials.length} materials updated successfully',
        duration: const Duration(seconds: 3),
      );

      await refreshData();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to update materials: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Export materials (placeholder for future implementation)
  Future<void> exportMaterials() async {
    _snackbarService.showSnackbar(
      message: 'Export feature will be implemented soon',
      duration: const Duration(seconds: 2),
    );
  }

  // Generate low stock report
  Future<void> generateLowStockReport() async {
    final lowStockMaterials = _materials.where((m) => m.isLowStock).toList();

    if (lowStockMaterials.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'No materials with low stock found',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final reportText = lowStockMaterials.map((material) {
      return '• ${material.nama}: ${material.stok} ${material.satuan} (Location: ${material.lokasi})';
    }).join('\n');

    await _dialogService.showDialog(
      title: 'Low Stock Report',
      description: 'Materials with low stock (${lowStockMaterials.length} items):\n\n$reportText',
      buttonTitle: 'OK',
    );
  }

  // Retry mechanism for failed operations
  Future<void> retryLastOperation() async {
    await loadData();
  }
}