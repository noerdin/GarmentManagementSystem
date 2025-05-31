import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class OrdersViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();

  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  List<OrderModel> _displayedOrders = [];
  int _selectedTab = 0;
  bool _showOverdueOnly = false;

  List<OrderModel> get orders => _orders;
  List<OrderModel> get displayedOrders => _displayedOrders;
  bool get showOverdueOnly => _showOverdueOnly;

  // Stats
  int get pendingCount => _orders.where((o) => o.status == 'Pending').length;
  int get productionCount =>
      _orders.where((o) => o.status == 'Produksi').length;
  int get completedCount => _orders.where((o) => o.status == 'Selesai').length;
  int get overdueCount => _orders.where((o) => o.isOverdue).length;

  Future<void> init() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to load orders data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    final ordersData = await _firestoreService.ordersStream().first;
    _orders = ordersData;
    _filteredOrders = ordersData;
    _updateDisplayedOrders();
    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to refresh orders data: $e');
    } finally {
      setBusy(false);
    }
  }

  // Handle tab selection
  void setSelectedTab(int index) {
    _selectedTab = index;
    _updateDisplayedOrders();
    notifyListeners();
  }

  // Toggle overdue filter
  void toggleOverdueFilter() {
    _showOverdueOnly = !_showOverdueOnly;
    _updateDisplayedOrders();
    notifyListeners();
  }

  // Update displayed orders based on selected tab and filters
  void _updateDisplayedOrders() {
    List<OrderModel> result = _filteredOrders;

    // Apply tab filter
    switch (_selectedTab) {
      case 0: // All
        break;
      case 1: // Pending
        result = result.where((o) => o.status == 'Pending').toList();
        break;
      case 2: // Production
        result = result.where((o) => o.status == 'Produksi').toList();
        break;
      case 3: // Completed
        result = result.where((o) => o.status == 'Selesai').toList();
        break;
      default:
        break;
    }

    // Apply overdue filter if enabled
    if (_showOverdueOnly) {
      result = result.where((o) => o.isOverdue).toList();
    }

    _displayedOrders = result;
  }

  // Filter orders based on search text
  void filterOrders(String searchText) {
    if (searchText.isEmpty) {
      _filteredOrders = _orders;
    } else {
      final lowerCaseSearch = searchText.toLowerCase();
      _filteredOrders = _orders.where((order) {
        return order.orderId.toLowerCase().contains(lowerCaseSearch) ||
            order.namaCustomer.toLowerCase().contains(lowerCaseSearch) ||
            order.namaProduk.toLowerCase().contains(lowerCaseSearch);
      }).toList();
    }
    _updateDisplayedOrders();
    notifyListeners();
  }

  // Show order details dialog
  void showOrderDetails(OrderModel order) async {
    // Generate size text
    final sizeText =
    order.ukuran.entries.map((e) => '${e.key}: ${e.value}').join(', ');

    final result = await _dialogService.showDialog(
      title: 'Order Details',
      description: 'Order ID: ${order.orderId}\n'
          'Date: ${_formatDate(order.tanggalOrder)}\n'
          'Customer: ${order.namaCustomer}\n'
          'Product: ${order.namaProduk}\n'
          'Color: ${order.warna}\n'
          'Sizes: $sizeText\n'
          'Total Quantity: ${order.jumlahTotal}\n'
          'Deadline: ${_formatDate(order.deadlineProduksi)}\n'
          'Status: ${order.displayStatus}\n'
          'Progress: ${(order.progress * 100).toInt()}%\n'
          'Notes: ${order.catatan.isNotEmpty ? order.catatan : 'N/A'}',
      dialogPlatform: DialogPlatform.Material,
      buttonTitle: 'Update Status',
      cancelTitle: 'Close',
    );

    if (result != null && result.confirmed) {
      showUpdateStatusDialog(order);
    }
  }

  // Show update status dialog
  void showUpdateStatusDialog(OrderModel order) async {
    // Implementation would be needed here to:
    // 1. Show a dialog to choose a new status
    // 2. Update the order in Firestore
    // 3. Refresh the data

    await _dialogService.showDialog(
      title: 'Update Status',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Show add order dialog
  void showAddOrderDialog() async {
    // Implementation would be needed here to:
    // 1. Show a form dialog to collect order details
    // 2. Create a new OrderModel
    // 3. Save it to Firestore
    // 4. Refresh the data

    await _dialogService.showDialog(
      title: 'Add Order',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}