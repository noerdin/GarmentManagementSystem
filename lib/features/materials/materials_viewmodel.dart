import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/material_model.dart';
import '../../services/firestore_service.dart';

class MaterialsViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();

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
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to load materials data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    final materialsData = await _firestoreService.materialsStream().first;
    _materials = materialsData;
    _filteredMaterials = materialsData;
    _updateDisplayedMaterials();
    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to refresh materials data: $e');
    } finally {
      setBusy(false);
    }
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
  void showMaterialDetails(MaterialModel material) async {
    await _dialogService
        .showDialog(
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
      buttonTitle: 'Update Stock',
      cancelTitle: 'Close',
    )
        .then((response) {
      if (response != null && response.confirmed) {
        showUpdateStockDialog(material);
      }
    });
  }

  // Show update stock dialog
  void showUpdateStockDialog(MaterialModel material) async {
    // Implementation would be needed here to:
    // 1. Show a dialog to input new stock quantity
    // 2. Update the material in Firestore
    // 3. Refresh the data

    await _dialogService.showDialog(
      title: 'Update Stock',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Show add material dialog
  void showAddMaterialDialog() async {
    // Implementation would be needed here to:
    // 1. Show a form dialog to collect material details
    // 2. Create a new MaterialModel
    // 3. Save it to Firestore
    // 4. Refresh the data

    await _dialogService.showDialog(
      title: 'Add Material',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}