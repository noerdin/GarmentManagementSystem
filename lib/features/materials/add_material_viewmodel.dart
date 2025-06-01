import 'package:flutter/cupertino.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../models/material_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';

class AddMaterialViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  final String? materialId;
  AddMaterialViewModel({this.materialId});

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController supplierContactController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Form State
  bool get isEditing => materialId != null;
  MaterialModel? _existingMaterial;

  // Dropdown Options
  final List<String> materialTypes = [
    'Bahan', // Fabric
    'Aksesoris', // Accessories
  ];

  final List<String> unitOptions = [
    'meter',
    'yard',
    'roll',
    'piece',
    'kilogram',
    'gram',
    'box',
    'pack',
    'dozen',
  ];

  final List<String> storageLocations = [
    'Warehouse A',
    'Warehouse B',
    'Storage Room 1',
    'Storage Room 2',
    'Main Storage',
    'Temporary Storage',
  ];

  // Selected Values
  String? _selectedType;
  String? _selectedUnit;
  String? _selectedLocation;

  // Getters
  String? get selectedType => _selectedType;
  String? get selectedUnit => _selectedUnit;
  String? get selectedLocation => _selectedLocation;

  // Initialization
  Future<void> init() async {
    if (isEditing) {
      await _loadExistingMaterial();
    }
  }

  Future<void> _loadExistingMaterial() async {
    setBusy(true);
    try {
      final materials = await _firestoreService.getMaterials();
      _existingMaterial = materials.firstWhere(
            (m) => m.materialId == materialId,
        orElse: () => throw Exception('Material not found'),
      );
      _populateFormWithExistingData();
    } catch (e) {
      setError(AppError.generic('Failed to load material: $e'));
    } finally {
      setBusy(false);
    }
  }

  void _populateFormWithExistingData() {
    if (_existingMaterial == null) return;

    nameController.text = _existingMaterial!.nama;
    stockController.text = _existingMaterial!.stok.toString();
    minStockController.text = '10'; // Default minimum stock
    priceController.text = _existingMaterial!.hargaPerUnit.toString();

    _selectedType = _existingMaterial!.jenis;
    _selectedUnit = _existingMaterial!.satuan;
    _selectedLocation = _existingMaterial!.lokasi;

    notifyListeners();
  }

  // Form Actions
  void setSelectedType(String? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setSelectedUnit(String? unit) {
    _selectedUnit = unit;
    notifyListeners();
  }

  void setSelectedLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  // Validation
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock is required';
    }
    final stock = int.tryParse(value);
    if (stock == null || stock < 0) {
      return 'Please enter a valid stock number';
    }
    return null;
  }

  String? validateMinStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Minimum stock is required';
    }
    final minStock = int.tryParse(value);
    if (minStock == null || minStock < 0) {
      return 'Please enter a valid minimum stock number';
    }

    final currentStock = int.tryParse(stockController.text) ?? 0;
    if (minStock > currentStock) {
      return 'Minimum stock cannot be greater than current stock';
    }

    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  // Save Material
  Future<void> saveMaterial() async {
    if (!formKey.currentState!.validate()) {
      _snackbarService.showSnackbar(
        message: 'Please fill all required fields correctly',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_selectedType == null || _selectedUnit == null || _selectedLocation == null) {
      _snackbarService.showSnackbar(
        message: 'Please select all dropdown options',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setBusy(true);

    try {
      if (isEditing) {
        await _updateExistingMaterial();
      } else {
        await _createNewMaterial();
      }

      _snackbarService.showSnackbar(
        message: isEditing
            ? 'Material updated successfully!'
            : 'Material added successfully!',
        duration: const Duration(seconds: 3),
      );

      _navigationService.back(result: true);

    } catch (e) {
      setError(AppError.generic(
          isEditing
              ? 'Failed to update material: $e'
              : 'Failed to add material: $e'
      ));
    } finally {
      setBusy(false);
    }
  }

  Future<void> _createNewMaterial() async {
    final newMaterialId = _firestoreService.generateMaterialId();

    final material = MaterialModel(
      materialId: newMaterialId,
      nama: nameController.text.trim(),
      jenis: _selectedType!,
      satuan: _selectedUnit!,
      stok: int.parse(stockController.text),
      lokasi: _selectedLocation!,
      hargaPerUnit: double.parse(priceController.text),
      lastUpdated: DateTime.now(),
    );

    await _firestoreService.addMaterial(material);
  }

  Future<void> _updateExistingMaterial() async {
    final updatedMaterial = _existingMaterial!.copyWith(
      nama: nameController.text.trim(),
      jenis: _selectedType!,
      satuan: _selectedUnit!,
      stok: int.parse(stockController.text),
      lokasi: _selectedLocation!,
      hargaPerUnit: double.parse(priceController.text),
      lastUpdated: DateTime.now(),
    );

    await _firestoreService.updateMaterial(updatedMaterial);
  }

  // Delete Material
  Future<void> deleteMaterial() async {
    if (!isEditing) return;

    final result = await _dialogService.showDialog(
      title: 'Delete Material',
      description: 'Are you sure you want to delete this material? This action cannot be undone.',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (result?.confirmed ?? false) {
      setBusy(true);
      try {
        await _firestoreService.deleteMaterial(materialId!);

        _snackbarService.showSnackbar(
          message: 'Material deleted successfully',
          duration: const Duration(seconds: 3),
        );

        _navigationService.back(result: true);
      } catch (e) {
        setError(AppError.generic('Failed to delete material: $e'));
      } finally {
        setBusy(false);
      }
    }
  }

  // Quick Stock Actions
  Future<void> showStockInDialog() async {
    final result = await _dialogService.showDialog(
      title: 'Stock In',
      description: 'Enter the quantity to add to current stock',
      buttonTitle: 'Add Stock',
      cancelTitle: 'Cancel',
    );

    // Implementation would need a custom dialog for numeric input
    // For now, this is a placeholder
  }

  Future<void> showStockOutDialog() async {
    final result = await _dialogService.showDialog(
      title: 'Stock Out',
      description: 'Enter the quantity to remove from current stock',
      buttonTitle: 'Remove Stock',
      cancelTitle: 'Cancel',
    );

    // Implementation would need a custom dialog for numeric input
    // For now, this is a placeholder
  }

  @override
  void dispose() {
    nameController.dispose();
    stockController.dispose();
    minStockController.dispose();
    priceController.dispose();
    supplierController.dispose();
    supplierContactController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }
}