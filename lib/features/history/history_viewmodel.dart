import 'package:csj/models/production_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../models/enhanced_production_model.dart';
import '../../models/shipping_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/snackbar_helper.dart';

class HistoryViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final DialogService _dialogService = locator<DialogService>();

  // Date Range
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Selected Tab
  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  // Data Lists
  List<OrderModel> _allOrders = [];
  List<ProductionModel> _allProductions = [];
  List<ShippingModel> _allShipments = [];
  List<Map<String, dynamic>> _allMaterialTransactions = [];

  // Filtered Data
  List<OrderModel> _filteredOrders = [];
  List<ProductionModel> _filteredProductions = [];
  List<ShippingModel> _filteredShipments = [];
  List<Map<String, dynamic>> _filteredMaterialTransactions = [];

  // Getters
  List<OrderModel> get filteredOrders => _filteredOrders;
  List<ProductionModel> get filteredProductions => _filteredProductions;
  List<ShippingModel> get filteredShipments => _filteredShipments;
  List<Map<String, dynamic>> get filteredMaterialTransactions => _filteredMaterialTransactions;

  // Summary Statistics
  int get totalOrdersInPeriod => _filteredOrders.length;
  int get completedOrdersInPeriod => _filteredOrders.where((o) => o.status == 'Selesai').length;
  int get totalProductionRecords => _filteredProductions.length;
  int get totalShipments => _filteredShipments.length;

  Future<void> init() async {
    setBusy(true);
    try {
      await loadAllData();
      await filterDataByDateRange();
    } catch (e) {
      setError('Failed to load history data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadAllData() async {
    final futures = await Future.wait([
      _firestoreService.ordersStream().first,
      _firestoreService.productionStream().first,
      _firestoreService.shippingStream().first,
    ]);

    _allOrders = futures[0] as List<OrderModel>;
    _allProductions = futures[1] as List<ProductionModel>;
    _allShipments = futures[2] as List<ShippingModel>;

    // Generate mock material transactions for demo
    _generateMockMaterialTransactions();
  }

  void _generateMockMaterialTransactions() {
    _allMaterialTransactions = [
      {
        'materialName': 'Cotton Fabric',
        'type': 'in',
        'quantity': 100,
        'newStock': 500,
        'reason': 'Purchase from supplier',
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'materialName': 'Thread - Blue',
        'type': 'out',
        'quantity': 50,
        'newStock': 150,
        'reason': 'Used for ORD2025001',
        'date': DateTime.now().subtract(const Duration(days: 5)),
      },
    ];
  }

  Future<void> filterDataByDateRange() async {
    _filteredOrders = _allOrders.where((order) =>
    order.tanggalOrder.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        order.tanggalOrder.isBefore(_endDate.add(const Duration(days: 1)))
    ).toList();

    _filteredProductions = _allProductions.where((production) =>
    production.tanggal.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        production.tanggal.isBefore(_endDate.add(const Duration(days: 1)))
    ).toList();

    _filteredShipments = _allShipments.where((shipment) =>
    shipment.tanggal.isAfter(_startDate.subtract(const Duration(days: 1))) &&
        shipment.tanggal.isBefore(_endDate.add(const Duration(days: 1)))
    ).toList();

    _filteredMaterialTransactions = _allMaterialTransactions.where((transaction) {
      final date = transaction['date'] as DateTime;
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();

    notifyListeners();
  }

  void setSelectedTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    filterDataByDateRange();
  }

  Future<void> selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      helpText: 'Select Date Range',
      confirmText: 'APPLY',
      cancelText: 'CANCEL',
    );

    if (picked != null) {
      setDateRange(picked.start, picked.end);
    }
  }

  Future<void> copyTrackingNumber(String trackingNumber) async {
    await Clipboard.setData(ClipboardData(text: trackingNumber));
    SnackbarHelper.showSuccess('Tracking number copied to clipboard');
  }

  Future<void> exportReport() async {
    final result = await _dialogService.showDialog(
      title: 'Export Report',
      description: 'Export current view data to clipboard?',
      buttonTitle: 'Export',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      await _exportCurrentView();
    }
  }

  Future<void> _exportCurrentView() async {
    String exportData = '';

    switch (_selectedTab) {
      case 0: // Orders
        exportData = 'Orders Report\n';
        exportData += 'Period: ${formatDate(_startDate)} - ${formatDate(_endDate)}\n\n';
        for (final order in _filteredOrders) {
          exportData += 'Order ID: ${order.orderId}\n';
          exportData += 'Customer: ${order.namaCustomer}\n';
          exportData += 'Product: ${order.namaProduk}\n';
          exportData += 'Status: ${order.status}\n';
          exportData += 'Date: ${formatDate(order.tanggalOrder)}\n\n';
        }
        break;
      case 1: // Production
        exportData = 'Production Report\n';
        exportData += 'Period: ${formatDate(_startDate)} - ${formatDate(_endDate)}\n\n';
        for (final production in _filteredProductions) {
          exportData += 'Order ID: ${production.orderId}\n';
          exportData += 'Operator: ${production.operator}\n';
          exportData += 'Date: ${formatDate(production.tanggal)}\n';
          exportData += 'Notes: ${production.keterangan}\n\n';
        }
        break;
      case 2: // Shipping
        exportData = 'Shipping Report\n';
        exportData += 'Period: ${formatDate(_startDate)} - ${formatDate(_endDate)}\n\n';
        for (final shipment in _filteredShipments) {
          exportData += 'Order ID: ${shipment.orderId}\n';
          exportData += 'Destination: ${shipment.tujuan}\n';
          exportData += 'Quantity: ${shipment.jumlahDikirim}\n';
          exportData += 'Tracking: ${shipment.resi}\n';
          exportData += 'Date: ${formatDate(shipment.tanggal)}\n\n';
        }
        break;
      case 3: // Materials
        exportData = 'Material Transactions Report\n';
        exportData += 'Period: ${formatDate(_startDate)} - ${formatDate(_endDate)}\n\n';
        for (final transaction in _filteredMaterialTransactions) {
          exportData += 'Material: ${transaction['materialName']}\n';
          exportData += 'Type: ${transaction['type']}\n';
          exportData += 'Quantity: ${transaction['quantity']}\n';
          exportData += 'New Stock: ${transaction['newStock']}\n';
          exportData += 'Date: ${formatDate(transaction['date'])}\n\n';
        }
        break;
    }

    await Clipboard.setData(ClipboardData(text: exportData));
    SnackbarHelper.showSuccess('Report data copied to clipboard');
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}