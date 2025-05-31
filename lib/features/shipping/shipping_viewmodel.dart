import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../models/shipping_model.dart';
import '../../services/firestore_service.dart';

class ShippingViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();

  List<ShippingModel> _shipments = [];
  List<ShippingModel> _filteredShipments = [];
  List<OrderModel> _orders = [];

  List<ShippingModel> get shipments => _shipments;
  List<ShippingModel> get filteredShipments => _filteredShipments;

  Future<void> init() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to load shipping data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    final shippingData = await _firestoreService.shippingStream().first;
    _shipments = shippingData;
    _filteredShipments = shippingData;

    // Load orders for reference
    _orders = await _firestoreService.getOrders();

    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to refresh shipping data: $e');
    } finally {
      setBusy(false);
    }
  }

  // Filter shipments based on search text
  void filterShipments(String searchText) {
    if (searchText.isEmpty) {
      _filteredShipments = _shipments;
    } else {
      final lowerCaseSearch = searchText.toLowerCase();
      _filteredShipments = _shipments.where((shipping) {
        return shipping.orderId.toLowerCase().contains(lowerCaseSearch) ||
            shipping.tujuan.toLowerCase().contains(lowerCaseSearch) ||
            shipping.resi.toLowerCase().contains(lowerCaseSearch);
      }).toList();
    }
    notifyListeners();
  }

  // Show filter options dialog
  void showFilterOptions() async {
    final result = await _dialogService.showDialog(
      title: 'Filter Shipments',
      description: 'Select filter options:',
      buttonTitle: 'Apply',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      // Apply filters (would implement specific filter logic here)
      refreshData();
    }
  }

  // Show shipment details
  void showShipmentDetails(ShippingModel shipment) async {
    // Find the associated order
    final order = _orders.firstWhere(
          (order) => order.orderId == shipment.orderId,
      orElse: () => OrderModel(
        orderId: 'Unknown',
        tanggalOrder: DateTime.now(),
        namaCustomer: 'Unknown',
        namaProduk: 'Unknown',
        warna: 'Unknown',
        ukuran: {},
        jumlahTotal: 0,
        deadlineProduksi: DateTime.now(),
      ),
    );

    await _dialogService.showDialog(
      title: 'Shipment Details',
      description: 'Shipment ID: ${shipment.shippingId}\n'
          'Date: ${_formatDate(shipment.tanggal)}\n'
          'Order ID: ${shipment.orderId}\n'
          'Product: ${order.namaProduk}\n'
          'Customer: ${order.namaCustomer}\n'
          'Destination: ${shipment.tujuan}\n'
          'Quantity: ${shipment.jumlahDikirim}\n'
          'Tracking Number: ${shipment.resi.isNotEmpty ? shipment.resi : 'N/A'}\n'
          'Notes: ${shipment.keterangan.isNotEmpty ? shipment.keterangan : 'N/A'}',
      dialogPlatform: DialogPlatform.Material,
      buttonTitle: 'Close',
    );
  }

  // Copy tracking number to clipboard
  void copyTrackingNumber(String trackingNumber) {
    Clipboard.setData(ClipboardData(text: trackingNumber));
    _snackbarService.showSnackbar(
      message: 'Tracking number copied to clipboard',
      duration: const Duration(seconds: 2),
    );
  }

  // Show add shipping dialog
  void showAddShippingDialog() async {
    // Get orders that are in production or pending
    final availableOrders =
    _orders.where((order) => order.status != 'Selesai').toList();

    if (availableOrders.isEmpty) {
      await _dialogService.showDialog(
        title: 'No Available Orders',
        description:
        'There are no orders available for shipping. Create a new order first.',
        buttonTitle: 'OK',
      );
      return;
    }

    // Additional implementation would be needed here to:
    // 1. Show a form dialog to collect shipping details
    // 2. Create a new ShippingModel
    // 3. Save it to Firestore
    // 4. Refresh the data

    await _dialogService.showDialog(
      title: 'Add Shipping Record',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}