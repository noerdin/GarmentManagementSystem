import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';

class AddOrderViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  final String? orderId;
  AddOrderViewModel({this.orderId});

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerAddressController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Form State
  bool get isEditing => orderId != null;
  OrderModel? _existingOrder;

  // Dropdown Options
  final List<String> productCategories = [
    'T-Shirt',
    'Polo Shirt',
    'Hoodie',
    'Jacket',
    'Pants',
    'Dress',
    'Skirt',
    'Other'
  ];

  final List<String> availableColors = [
    'White',
    'Black',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Gray',
    'Navy',
    'Maroon'
  ];

  final List<String> availableSizes = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'
  ];

  final List<String> priorityLevels = [
    'Low',
    'Normal',
    'High',
    'Urgent'
  ];

  // Selected Values
  String? _selectedCategory;
  String? _selectedColor;
  String? _selectedPriority = 'Normal';
  DateTime? _selectedDeadline;
  Map<String, int> _sizeQuantities = {};

  // Getters
  String? get selectedCategory => _selectedCategory;
  String? get selectedColor => _selectedColor;
  String? get selectedPriority => _selectedPriority;
  DateTime? get selectedDeadline => _selectedDeadline;

  int get totalQuantity {
    return _sizeQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  // Initialization
  Future<void> init() async {
    if (isEditing) {
      await _loadExistingOrder();
    }
    _initializeSizeQuantities();
  }

  void _initializeSizeQuantities() {
    for (String size in availableSizes) {
      _sizeQuantities[size] = 0;
    }
    if (_existingOrder != null) {
      _sizeQuantities.addAll(_existingOrder!.ukuran);
    }
    notifyListeners();
  }

  Future<void> _loadExistingOrder() async {
    setBusy(true);
    try {
      _existingOrder = await _firestoreService.getOrderById(orderId!);
      _populateFormWithExistingData();
    } catch (e) {
      setError(AppError.generic('Failed to load order: $e'));
    } finally {
      setBusy(false);
    }
  }

  void _populateFormWithExistingData() {
    if (_existingOrder == null) return;

    customerNameController.text = _existingOrder!.namaCustomer;
    productNameController.text = _existingOrder!.namaProduk;
    notesController.text = _existingOrder!.catatan;

    _selectedColor = _existingOrder!.warna;
    _selectedDeadline = _existingOrder!.deadlineProduksi;

    // Set priority based on existing data or default
    _selectedPriority = 'Normal'; // You might want to add priority field to OrderModel

    notifyListeners();
  }

  // Form Actions
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  Future<void> selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Production Deadline',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );

    if (picked != null) {
      _selectedDeadline = picked;
      notifyListeners();
    }
  }

  void updateSizeQuantity(String size, String value) {
    final quantity = int.tryParse(value) ?? 0;
    _sizeQuantities[size] = quantity;
    notifyListeners();
  }

  // Validation
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateDeadline(String? value) {
    if (_selectedDeadline == null) {
      return 'Please select a deadline';
    }
    if (_selectedDeadline!.isBefore(DateTime.now())) {
      return 'Deadline cannot be in the past';
    }
    return null;
  }

  // Save Order
  Future<void> saveOrder() async {
    if (!formKey.currentState!.validate()) {
      _snackbarService.showSnackbar(
        message: 'Please fill all required fields correctly',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_selectedColor == null) {
      _snackbarService.showSnackbar(
        message: 'Please select a color',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (totalQuantity == 0) {
      _snackbarService.showSnackbar(
        message: 'Please specify at least one quantity',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setBusy(true);

    try {
      // Filter out sizes with 0 quantity
      final Map<String, int> finalSizes = {};
      _sizeQuantities.forEach((size, qty) {
        if (qty > 0) {
          finalSizes[size] = qty;
        }
      });

      if (isEditing) {
        await _updateExistingOrder(finalSizes);
      } else {
        await _createNewOrder(finalSizes);
      }

      _snackbarService.showSnackbar(
        message: isEditing
            ? 'Order updated successfully!'
            : 'Order created successfully!',
        duration: const Duration(seconds: 3),
      );

      _navigationService.back();

    } catch (e) {
      setError(AppError.generic(
          isEditing
              ? 'Failed to update order: $e'
              : 'Failed to create order: $e'
      ));
    } finally {
      setBusy(false);
    }
  }

  Future<void> _createNewOrder(Map<String, int> sizes) async {
    final newOrderId = _firestoreService.generateOrderId();

    final order = OrderModel(
      orderId: newOrderId,
      tanggalOrder: DateTime.now(),
      namaCustomer: customerNameController.text.trim(),
      namaProduk: productNameController.text.trim(),
      warna: _selectedColor!,
      ukuran: sizes,
      jumlahTotal: totalQuantity,
      deadlineProduksi: _selectedDeadline!,
      catatan: notesController.text.trim(),
      status: 'Pending',
      progress: 0.0,
      estimasiMargin: 0.0,
    );

    await _firestoreService.addOrder(order);
  }

  Future<void> _updateExistingOrder(Map<String, int> sizes) async {
    final updatedOrder = _existingOrder!.copyWith(
      namaCustomer: customerNameController.text.trim(),
      namaProduk: productNameController.text.trim(),
      warna: _selectedColor!,
      ukuran: sizes,
      jumlahTotal: totalQuantity,
      deadlineProduksi: _selectedDeadline!,
      catatan: notesController.text.trim(),
    );

    await _firestoreService.updateOrder(updatedOrder);
  }

  // Delete Order
  Future<void> deleteOrder() async {
    if (!isEditing) return;

    final result = await _dialogService.showDialog(
      title: 'Delete Order',
      description: 'Are you sure you want to delete this order? This action cannot be undone.',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (result?.confirmed ?? false) {
      setBusy(true);
      try {
        await _firestoreService.deleteOrder(orderId!);

        _snackbarService.showSnackbar(
          message: 'Order deleted successfully',
          duration: const Duration(seconds: 3),
        );

        _navigationService.back();
      } catch (e) {
        setError(AppError.generic('Failed to delete order: $e'));
      } finally {
        setBusy(false);
      }
    }
  }

  @override
  void dispose() {
    customerNameController.dispose();
    customerAddressController.dispose();
    productNameController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
