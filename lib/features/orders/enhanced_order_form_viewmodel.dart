import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';
import '../../shared/snackbar_helper.dart';

class EnhancedOrderFormViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  final String? orderId;
  EnhancedOrderFormViewModel({this.orderId});

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerContactController = TextEditingController();
  final TextEditingController customerAddressController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productCategoryController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController materialTypeController = TextEditingController();
  final TextEditingController designSpecsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController estimatedPriceController = TextEditingController();

  // Form State
  bool get isEditing => orderId != null;
  OrderModel? _existingOrder;

  // Date selections
  DateTime? _selectedOrderDate = DateTime.now();
  DateTime? _selectedDeadline;

  // Size quantities
  final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
  Map<String, int> _sizeQuantities = {};

  // Priority levels
  final List<String> priorityLevels = ['Low', 'Normal', 'High', 'Urgent'];
  String? _selectedPriority = 'Normal';

  // Getters
  DateTime? get selectedOrderDate => _selectedOrderDate;
  DateTime? get selectedDeadline => _selectedDeadline;
  String? get selectedPriority => _selectedPriority;

  int get totalQuantity {
    return _sizeQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  // Initialization
  Future<void> init() async {
    if (isEditing) {
      await _loadExistingOrder();
    } else {
      // Generate new order ID suggestion
      _generateOrderIdSuggestion();
    }
    _initializeSizeQuantities();
  }

  void _generateOrderIdSuggestion() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    // Format: ORD2025MMDD### (you can adjust this format)
    final suggestion = 'ORD$year$month$day';
    orderIdController.text = suggestion;
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

    orderIdController.text = _existingOrder!.orderId;
    quantityController.text = _existingOrder!.jumlahTotal.toString();
    customerNameController.text = _existingOrder!.namaCustomer;
    productNameController.text = _existingOrder!.namaProduk;
    colorController.text = _existingOrder!.warna;
    notesController.text = _existingOrder!.catatan;

    // Set dates
    _selectedOrderDate = _existingOrder!.tanggalOrder;
    _selectedDeadline = _existingOrder!.deadlineProduksi;

    // Set estimated price if available
    if (_existingOrder!.estimasiMargin > 0) {
      estimatedPriceController.text = _existingOrder!.estimasiMargin.toString();
    }

    notifyListeners();
  }

  // Form Actions
  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  Future<void> selectOrderDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedOrderDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Select Order Date',
    );

    if (picked != null) {
      _selectedOrderDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Production Deadline',
    );

    if (picked != null) {
      _selectedDeadline = picked;
      notifyListeners();
    }
  }

  void updateSizeQuantity(String size, String value) {
    final quantity = int.tryParse(value) ?? 0;
    _sizeQuantities[size] = quantity;

    // Auto-update total quantity
    quantityController.text = totalQuantity.toString();
    notifyListeners();
  }

  // Validation
  String? validateOrderId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Order ID is required';
    }

    // Check format (optional - adjust according to your requirements)
    if (!RegExp(r'^ORD\d{8,}').hasMatch(value.trim())) {
      return 'Order ID should start with "ORD" followed by numbers (e.g., ORD20250101)';
    }

    return null;
  }

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

  // Check if Order ID already exists
  Future<bool> _checkOrderIdExists(String orderId) async {
    try {
      await _firestoreService.getOrderById(orderId);
      return true; // Order exists
    } catch (e) {
      return false; // Order doesn't exist
    }
  }

  // Save Order
  Future<void> saveOrder() async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Please fill all required fields correctly');
      return;
    }

    if (_selectedDeadline == null) {
      SnackbarHelper.showError('Please select a production deadline');
      return;
    }

    if (totalQuantity == 0) {
      SnackbarHelper.showError('Please specify at least one quantity for sizes');
      return;
    }

    // Check if Order ID already exists (only for new orders)
    if (!isEditing) {
      final orderExists = await _checkOrderIdExists(orderIdController.text.trim());
      if (orderExists) {
        SnackbarHelper.showError('Order ID already exists. Please use a different ID.');
        return;
      }
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

      SnackbarHelper.showSuccess(
          isEditing
              ? 'Order updated successfully!'
              : 'Order created successfully!'
      );

      _navigationService.back(result: true);

    } catch (e) {
      SnackbarHelper.showError(
          isEditing
              ? 'Failed to update order: $e'
              : 'Failed to create order: $e'
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> _createNewOrder(Map<String, int> sizes) async {
    final order = OrderModel(
      orderId: orderIdController.text.trim(),
      tanggalOrder: _selectedOrderDate!,
      namaCustomer: customerNameController.text.trim(),
      namaProduk: productNameController.text.trim(),
      warna: colorController.text.trim(),
      ukuran: sizes,
      jumlahTotal: totalQuantity,
      deadlineProduksi: _selectedDeadline!,
      catatan: notesController.text.trim(),
      status: 'Pending',
      progress: 0.0,
      estimasiMargin: double.tryParse(estimatedPriceController.text) ?? 0.0,
    );

    await _firestoreService.addOrder(order);

    // Create material planning entry automatically
    await _createMaterialPlanningEntry(order);
  }

  Future<void> _updateExistingOrder(Map<String, int> sizes) async {
    final updatedOrder = _existingOrder!.copyWith(
      namaCustomer: customerNameController.text.trim(),
      namaProduk: productNameController.text.trim(),
      warna: colorController.text.trim(),
      ukuran: sizes,
      jumlahTotal: totalQuantity,
      deadlineProduksi: _selectedDeadline!,
      catatan: notesController.text.trim(),
      estimasiMargin: double.tryParse(estimatedPriceController.text) ?? 0.0,
    );

    await _firestoreService.updateOrder(updatedOrder);
  }

  // Create initial material planning entry
  Future<void> _createMaterialPlanningEntry(OrderModel order) async {
    // This creates a placeholder material planning entry
    // that can be filled later in the material planning screen
    try {
      final materialTemplate = {
        'orderId': order.orderId,
        'productName': order.namaProduk,
        'productCategory': productCategoryController.text.trim(),
        'color': order.warna,
        'quantityProduced': order.jumlahTotal,
        'materialRequirements': [], // Empty array to be filled later
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'createdBy': 'system', // or current user ID
        'status': 'planning', // planning, confirmed, used
      };

      await _firestoreService.addData('materialTemplates', order.orderId, materialTemplate);
    } catch (e) {
      print('Failed to create material planning entry: $e');
      // Don't throw error as this is supplementary
    }
  }

  // Delete Order
  Future<void> deleteOrder() async {
    if (!isEditing) return;

    final result = await _dialogService.showDialog(
      title: 'Delete Order',
      description: 'Are you sure you want to delete this order?\n\nOrder: ${orderIdController.text}\nCustomer: ${customerNameController.text}\n\nThis action cannot be undone.',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      setBusy(true);
      try {
        await _firestoreService.deleteOrder(orderId!);

        SnackbarHelper.showSuccess('Order deleted successfully');
        _navigationService.back(result: true);
      } catch (e) {
        SnackbarHelper.showError('Failed to delete order: $e');
      } finally {
        setBusy(false);
      }
    }
  }

  // Auto-fill suggestions based on previous orders
  Future<void> getCustomerSuggestions(String customerName) async {
    if (customerName.length < 3) return;

    try {
      final orders = await _firestoreService.ordersStream().first;
      final matchingOrders = orders.where((order) =>
          order.namaCustomer.toLowerCase().contains(customerName.toLowerCase())
      ).toList();

      if (matchingOrders.isNotEmpty) {
        final lastOrder = matchingOrders.first;
        // You can implement an auto-suggest dropdown here
        print('Found similar customer: ${lastOrder.namaCustomer}');
      }
    } catch (e) {
      print('Error getting customer suggestions: $e');
    }
  }

  // Product suggestions based on category
  Future<void> getProductSuggestions(String category) async {
    if (category.length < 2) return;

    try {
      final orders = await _firestoreService.ordersStream().first;
      final matchingProducts = orders.where((order) =>
          order.namaProduk.toLowerCase().contains(category.toLowerCase())
      ).map((order) => order.namaProduk).toSet().toList();

      if (matchingProducts.isNotEmpty) {
        print('Found similar products: $matchingProducts');
        // You can implement product suggestions here
      }
    } catch (e) {
      print('Error getting product suggestions: $e');
    }
  }

  // Calculate estimated delivery date
  String getEstimatedDeliveryDate() {
    if (_selectedDeadline == null) return 'Select deadline first';

    // Add buffer time for shipping (e.g., 3 days)
    final deliveryDate = _selectedDeadline!.add(const Duration(days: 3));
    return '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}';
  }

  // Export order details
  Future<void> exportOrderDetails() async {
    SnackbarHelper.showSnackbar(
      message: 'Export feature will be implemented soon',
    );
  }

  @override
  void dispose() {
    orderIdController.dispose();
    quantityController.dispose();
    customerNameController.dispose();
    customerContactController.dispose();
    customerAddressController.dispose();
    productNameController.dispose();
    productCategoryController.dispose();
    colorController.dispose();
    materialTypeController.dispose();
    designSpecsController.dispose();
    notesController.dispose();
    estimatedPriceController.dispose();
    super.dispose();
  }
}