import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/material_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';
import '../../shared/result_state.dart';
import '../../shared/stock_update_dialog.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import 'add_material_view.dart';

class MaterialsViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  // State Management
  ResultState<List<MaterialModel>> _materialsState = const Loading();
  ResultState<List<MaterialModel>> get materialsState => _materialsState;

  List<MaterialModel> _materials = [];
  List<MaterialModel> _filteredMaterials = [];
  List<MaterialModel> _displayedMaterials = [];
  int _selectedTab = 0;
  bool _showLowStockOnly = false;

  List<MaterialModel> get materials => _materials;
  List<MaterialModel> get displayedMaterials => _displayedMaterials;
  bool get showLowStockOnly => _showLowStockOnly;

  // Stats
  int get totalBahan => _materials.where((m) => m.jenis == 'Bahan').length;
  int get totalAksesoris =>
      _materials.where((m) => m.jenis == 'Aksesoris').length;
  int get lowStockCount => _materials.where((m) => m.isLowStock).length;

  Future<void> init() async {
    await loadData();
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

  Future<void> refreshData() async {
    await loadData();
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
          'Last Updated: ${_formatDate(material.lastUpdated)}',
      dialogPlatform: DialogPlatform.Material,
      buttonTitle: 'Edit Material',
      cancelTitle: 'Close',
    );

    if (result?.confirmed ?? false) {
      await _showMaterialActions(material);
    }
  }

  // Add this helper method
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
  Future<void> showAddMaterialDialog() async {
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

      // Log stock transaction (if you have a stock transaction model)
      // await _firestoreService.addStockTransaction(material.materialId, reason, newStock - material.stok);

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

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Retry mechanism for failed operations
  Future<void> retryLastOperation() async {
    await loadData();
  }
}