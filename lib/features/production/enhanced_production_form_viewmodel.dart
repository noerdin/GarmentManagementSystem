import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../models/enhanced_production_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/snackbar_helper.dart';

class EnhancedProductionFormViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  final String? productionId;
  EnhancedProductionFormViewModel({this.productionId});

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controllers for all production stages
  final TextEditingController operatorController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  // Stage-specific controllers
  final TextEditingController bartekController = TextEditingController();
  final TextEditingController hasilCuttingController = TextEditingController();
  final TextEditingController numberingController = TextEditingController();
  final TextEditingController pressController = TextEditingController();
  final TextEditingController qcPanelController = TextEditingController();
  final TextEditingController sewingController = TextEditingController();
  final TextEditingController finishingController = TextEditingController();
  final TextEditingController washingController = TextEditingController();

  // Form State
  bool get isEditing => productionId != null;
  EnhancedProductionModel? _existingProduction;

  // Available orders
  List<OrderModel> _availableOrders = [];
  List<OrderModel> get availableOrders => _availableOrders;

  // Selected values
  String? _selectedOrderId;
  OrderModel? _selectedOrder;
  DateTime? _selectedDate = DateTime.now();

  // Getters
  String? get selectedOrderId => _selectedOrderId;
  OrderModel? get selectedOrder => _selectedOrder;
  DateTime? get selectedDate => _selectedDate;

  int get totalQuantity {
    int total = 0;
    total += int.tryParse(bartekController.text) ?? 0;
    total += int.tryParse(hasilCuttingController.text) ?? 0;
    total += int.tryParse(numberingController.text) ?? 0;
    total += int.tryParse(pressController.text) ?? 0;
    total += int.tryParse(qcPanelController.text) ?? 0;
    total += int.tryParse(sewingController.text) ?? 0;
    total += int.tryParse(finishingController.text) ?? 0;
    total += int.tryParse(washingController.text) ?? 0;
    return total;
  }

  // Initialization
  Future<void> init() async {
    setBusy(true);
    try {
      await _loadAvailableOrders();
      if (isEditing) {
        await _loadExistingProduction();
      }
    } catch (e) {
      setError('Failed to initialize: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadAvailableOrders() async {
    final orders = await _firestoreService.ordersStream().first;
    // Filter orders that are not completed and have some production activity
    _availableOrders = orders.where((order) =>
    order.status == 'Pending' || order.status == 'Produksi'
    ).toList();
    notifyListeners();
  }

  Future<void> _loadExistingProduction() async {
    try {
      // Load existing production data
      // Note: You'll need to implement this in FirestoreService
      // _existingProduction = await _firestoreService.getProductionById(productionId!);
      // _populateFormWithExistingData();
    } catch (e) {
      setError('Failed to load production data: $e');
    }
  }

  // Form Actions
  void setSelectedOrder(String? orderId) {
    _selectedOrderId = orderId;
    _selectedOrder = _availableOrders.firstWhere(
          (order) => order.orderId == orderId,
      orElse: () => _availableOrders.first,
    );
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      helpText: 'Select Production Date',
    );

    if (picked != null) {
      _selectedDate = picked;
      notifyListeners();
    }
  }

  // Validation
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Save Production
  Future<void> saveProduction() async {
    if (!formKey.currentState!.validate()) {
      SnackbarHelper.showError('Please fill all required fields');
      return;
    }

    if (_selectedOrderId == null) {
      SnackbarHelper.showError('Please select an order');
      return;
    }

    if (totalQuantity == 0) {
      SnackbarHelper.showError('Please enter at least one production quantity');
      return;
    }

    setBusy(true);

    try {
      final productionStage = ProductionStage(
        bartek: int.tryParse(bartekController.text) ?? 0,
        cutting: CuttingDetails(
          hasilCutting: int.tryParse(hasilCuttingController.text) ?? 0,
          numbering: int.tryParse(numberingController.text) ?? 0,
          press: int.tryParse(pressController.text) ?? 0,
          qcPanel: int.tryParse(qcPanelController.text) ?? 0,
        ),
        finishing: int.tryParse(finishingController.text) ?? 0,
        sewing: int.tryParse(sewingController.text) ?? 0,
        washing: int.tryParse(washingController.text) ?? 0,
      );

      final production = EnhancedProductionModel(
        produksiId: isEditing ? productionId! : _firestoreService.generateProductionId(),
        createdAt: DateTime.now(),
        createdBy: 'current_user_id', // Replace with actual user ID
        jumlah: totalQuantity,
        keterangan: keteranganController.text.trim(),
        operator: operatorController.text.trim(),
        orderId: _selectedOrderId!,
        tahap: productionStage,
        tanggal: _selectedDate!,
      );

      if (isEditing) {
        await _updateExistingProduction(production);
      } else {
        await _createNewProduction(production);
      }

      // Update order progress
      await _updateOrderProgress();

      SnackbarHelper.showSuccess(
          isEditing
              ? 'Production updated successfully!'
              : 'Production record created successfully!'
      );

      _navigationService.back(result: true);

    } catch (e) {
      SnackbarHelper.showError('Failed to save production: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _createNewProduction(EnhancedProductionModel production) async {
    await _firestoreService.addData('produksi', production.produksiId, production.toJson());
  }

  Future<void> _updateExistingProduction(EnhancedProductionModel production) async {
    await _firestoreService.updateData('produksi', production.produksiId, production.toJson());
  }

  // Update order progress based on production data
  Future<void> _updateOrderProgress() async {
    if (_selectedOrder == null) return;

    try {
      // Get all production records for this order
      final productions = await _firestoreService.productionStream().first;
      final orderProductions = productions.where((p) => p.orderId == _selectedOrderId).toList();

      // Calculate progress based on total production vs order quantity
      int totalProduced = 0;
      for (final prod in orderProductions) {
        totalProduced += prod.jumlah;
      }

      double progress = totalProduced / _selectedOrder!.jumlahTotal;
      progress = progress.clamp(0.0, 1.0);

      // Update order status based on progress
      String newStatus = _selectedOrder!.status;
      if (progress > 0 && _selectedOrder!.status == 'Pending') {
        newStatus = 'Produksi';
      } else if (progress >= 1.0) {
        newStatus = 'Selesai';
      }

      final updatedOrder = _selectedOrder!.copyWith(
        progress: progress,
        status: newStatus,
      );

      await _firestoreService.updateOrder(updatedOrder);

    } catch (e) {
      print('Failed to update order progress: $e');
    }
  }

  @override
  void dispose() {
    operatorController.dispose();
    keteranganController.dispose();
    bartekController.dispose();
    hasilCuttingController.dispose();
    numberingController.dispose();
    pressController.dispose();
    qcPanelController.dispose();
    sewingController.dispose();
    finishingController.dispose();
    washingController.dispose();
    super.dispose();
  }
}