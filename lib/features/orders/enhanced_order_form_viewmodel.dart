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
  final TextEditingController customerContactController =
      TextEditingController();
  final TextEditingController customerAddressController =
      TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productCategoryController =
      TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController materialTypeController = TextEditingController();
  final TextEditingController designSpecsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController estimatedPriceController =
      TextEditingController();

  // Form State
  bool get isEditing => orderId != null;
  OrderModel? _existingOrder;
  bool _isLoadingOrder = false;

  // Date selections
  DateTime? _selectedOrderDate = DateTime.now();
  DateTime? _selectedDeadline;

  // Size quantities
  final List<String> availableSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'XXXL'
  ];
  Map<String, int> _sizeQuantities = {};

  // Priority levels
  final List<String> priorityLevels = ['Low', 'Normal', 'High', 'Urgent'];
  String? _selectedPriority = 'Normal';

  // Getters
  DateTime? get selectedOrderDate => _selectedOrderDate;

  DateTime? get selectedDeadline => _selectedDeadline;

  String? get selectedPriority => _selectedPriority;

  bool get isLoadingOrder => _isLoadingOrder;

  OrderModel? get existingOrder => _existingOrder;

  int get totalQuantity {
    return _sizeQuantities.values.fold(0, (sum, qty) => sum + qty);
  }

  // Initialization
  Future<void> init() async {
    setBusy(true);
    try {
      if (isEditing) {
        await _loadExistingOrder();
      }
      _initializeSizeQuantities();
    } catch (e) {
      setError(AppError.generic('Failed to initialize: $e'));
    } finally {
      setBusy(false);
    }
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
    _isLoadingOrder = true;
    notifyListeners();

    try {
      print('Loading order with ID: $orderId');
      _existingOrder = await _firestoreService.getOrderById(orderId!);
      print('Order loaded successfully: ${_existingOrder?.orderId}');
      _populateFormWithExistingData();
    } catch (e) {
      print('Error loading order: $e');
      setError(AppError.generic('Failed to load order: $e'));

      // Show error dialog and navigate back
      SnackbarHelper.showError('Order not found or failed to load');
      _navigationService.back();
    } finally {
      _isLoadingOrder = false;
      notifyListeners();
    }
  }

  void _populateFormWithExistingData() {
    if (_existingOrder == null) return;

    print('Populating form with order data: ${_existingOrder!.orderId}');

    // Populate basic order info
    orderIdController.text = _existingOrder!.orderId;
    quantityController.text = _existingOrder!.jumlahTotal.toString();
    customerNameController.text = _existingOrder!.namaCustomer;
    customerContactController.text = _existingOrder!.kontak ?? '';
    customerAddressController.text = _existingOrder!.alamat ?? '';

    // Populate product info
    productNameController.text = _existingOrder!.namaProduk;
    productCategoryController.text = _existingOrder!.kategori ?? '';
    colorController.text = _existingOrder!.warna;
    materialTypeController.text = _existingOrder!.material ?? '';
    designSpecsController.text = _existingOrder!.spesifikasi ?? '';
    notesController.text = _existingOrder!.catatan;

    // Set estimated price if available
    if (_existingOrder!.estimasiMargin > 0) {
      estimatedPriceController.text = _existingOrder!.estimasiMargin.toString();
    }

    // Set dates
    _selectedOrderDate = _existingOrder!.tanggalOrder;
    _selectedDeadline = _existingOrder!.deadlineProduksi;

    // Set priority
    _selectedPriority = _existingOrder!.prioritas ?? 'Normal';

    // Set size quantities
    _sizeQuantities.clear();
    for (String size in availableSizes) {
      _sizeQuantities[size] = _existingOrder!.ukuran[size] ?? 0;
    }

    // Try to extract product category from product name if not available
    //if (productCategoryController.text.isEmpty) {
    //  _inferProductCategory(_existingOrder!.namaProduk);
    //}

    print('Form populated successfully');
    notifyListeners();
  }

  void _inferProductCategory(String productName) {
    final lowerName = productName.toLowerCase();

    if (lowerName.contains('t-shirt') || lowerName.contains('kaos')) {
      productCategoryController.text = 'T-Shirt';
    } else if (lowerName.contains('polo')) {
      productCategoryController.text = 'Polo Shirt';
    } else if (lowerName.contains('hoodie')) {
      productCategoryController.text = 'Hoodie';
    } else if (lowerName.contains('jacket') || lowerName.contains('jaket')) {
      productCategoryController.text = 'Jacket';
    } else if (lowerName.contains('dress')) {
      productCategoryController.text = 'Dress';
    } else if (lowerName.contains('pants') || lowerName.contains('celana')) {
      productCategoryController.text = 'Pants';
    } else {
      productCategoryController.text = 'Other';
    }
  }

  // Form Actions
  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  Future<void> selectOrderDate(BuildContext context) async {
    if (isEditing) return;

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
      initialDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 14)),
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
    if (quantity >= 0) { // Validasi agar tidak negatif
      _sizeQuantities[size] = quantity;

      // Auto-update total quantity
      quantityController.text = totalQuantity.toString();
      notifyListeners();
    }
  }

  // Get current size quantity for display
  int getSizeQuantity(String size) {
    return _sizeQuantities[size] ?? 0;
  }

  /// Menghitung persentase kelengkapan form berdasarkan field yang sudah diisi
  double getFormCompletionPercentage() {
    // Field-field yang wajib diisi
    final requiredFields = [
      orderIdController.text.trim().isNotEmpty, // Order ID
      selectedOrderDate != null, // Order Date
      customerNameController.text.trim().isNotEmpty, // Customer Name
      productNameController.text.trim().isNotEmpty, // Product Name
      productCategoryController.text.trim().isNotEmpty, // Product Category
      colorController.text.trim().isNotEmpty, // Color
      totalQuantity > 0, // Has quantity
      selectedDeadline != null, // Deadline
      selectedPriority != null && selectedPriority!.isNotEmpty, // Priority
    ];

    // Optional fields (menambah nilai completion)
    final optionalFields = [
      customerContactController.text.trim().isNotEmpty,
      customerAddressController.text.trim().isNotEmpty,
      materialTypeController.text.trim().isNotEmpty,
      estimatedPriceController.text.trim().isNotEmpty,
      designSpecsController.text.trim().isNotEmpty,
      notesController.text.trim().isNotEmpty,
    ];

    // Hitung required fields yang sudah diisi
    int completedRequired = requiredFields.where((field) => field).length;
    int totalRequired = requiredFields.length;

    // Hitung optional fields yang sudah diisi
    int completedOptional = optionalFields.where((field) => field).length;
    int totalOptional = optionalFields.length;

    // Hitung persentase: 85% dari required fields + 15% dari optional fields
    double requiredPercentage = (completedRequired / totalRequired) * 0.85;
    double optionalPercentage = (completedOptional / totalOptional) * 0.15;

    double totalPercentage = requiredPercentage + optionalPercentage;

    // Pastikan tidak melebihi 1.0 (100%)
    return totalPercentage.clamp(0.0, 1.0);
  }

  // Validation
  String? validateOrderId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Order ID is required';
    }

    // More flexible validation - just ensure it's not empty and reasonably formatted
    final trimmedValue = value.trim();

    // Minimum length check
    if (trimmedValue.length < 3) {
      return 'Order ID must be at least 3 characters long';
    }

    // Maximum length check
    if (trimmedValue.length > 20) {
      return 'Order ID cannot exceed 20 characters';
    }

    // Allow alphanumeric and common symbols
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(trimmedValue)) {
      return 'Order ID can only contain letters, numbers, hyphens, and underscores';
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
    if (isEditing && orderId == _existingOrder?.orderId) {
      return false; // Same order ID is allowed when editing
    }

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
      SnackbarHelper.showError(
          'Please specify at least one quantity for sizes');
      return;
    }

    // Check if Order ID already exists (only for new orders)
    if (!isEditing) {
      final orderExists =
          await _checkOrderIdExists(orderIdController.text.trim());
      if (orderExists) {
        SnackbarHelper.showError(
            'Order ID already exists. Please use a different ID.');
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

      SnackbarHelper.showSuccess(isEditing
          ? 'Order updated successfully!'
          : 'Order created successfully!');

      _navigationService.back(result: true);
    } catch (e) {
      SnackbarHelper.showError(isEditing
          ? 'Failed to update order: $e'
          : 'Failed to create order: $e');
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
      // Note: We don't update orderId, tanggalOrder, status, or progress in edit mode
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

      await _firestoreService.addData(
          'materialTemplates', order.orderId, materialTemplate);
    } catch (e) {
      print('Failed to create material planning entry: $e');
      // Don't throw error as this is supplementary
    }
  }

  // Delete Order
  Future<void> deleteOrder() async {
    if (!isEditing || _existingOrder == null) return;

    final result = await _dialogService.showDialog(
      title: 'Delete Order',
      description: 'Are you sure you want to delete this order?\n\n'
          'Order: ${orderIdController.text}\n'
          'Product: ${productNameController.text}\n'
          'Quantity: ${totalQuantity}\n\n'
          'This action cannot be undone.',
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
      final matchingOrders = orders
          .where((order) => order.namaCustomer
              .toLowerCase()
              .contains(customerName.toLowerCase()))
          .toList();

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
      final matchingProducts = orders
          .where((order) =>
              order.namaProduk.toLowerCase().contains(category.toLowerCase()))
          .map((order) => order.namaProduk)
          .toSet()
          .toList();

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
