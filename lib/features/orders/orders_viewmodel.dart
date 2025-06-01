import 'dart:ui';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.dialogs.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';
import '../../shared/result_state.dart';
import 'add_order_view.dart';

class OrdersViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();

  // State Management
  ResultState<List<OrderModel>> _ordersState = const Loading();
  ResultState<List<OrderModel>> get ordersState => _ordersState;

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
    await loadData();
  }

  Future<void> loadData() async {
    _ordersState = const Loading(message: 'Loading orders...');
    notifyListeners();

    try {
      final ordersData = await _firestoreService.ordersStream().first;
      _orders = ordersData;
      _filteredOrders = ordersData;
      _updateDisplayedOrders();

      _ordersState = Success(_orders);
      notifyListeners();
    } catch (e) {
      _ordersState = Error(AppError.generic('Failed to load orders: $e'));
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadData();
    _snackbarService.showSnackbar(
      message: 'Orders refreshed',
      duration: const Duration(seconds: 2),
    );
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
  Future<void> showOrderDetails(OrderModel order) async {
    final sizeText = order.ukuran.entries.map((e) => '${e.key}: ${e.value}').join(', ');

    final statusColor = _getStatusColor(order.status);
    final progressText = '${(order.progress * 100).toInt()}%';

    final result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
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
          'Progress: $progressText\n'
          'Notes: ${order.catatan.isNotEmpty ? order.catatan : 'N/A'}',
      data: {
        'primaryButtonText': 'Edit Order',
        'secondaryButtonText': 'Update Status',
        'cancelButtonText': 'Close',
      },
    );

    if (result?.data == 'primary') {
      await editOrder(order.orderId);
    } else if (result?.data == 'secondary') {
      await showUpdateStatusDialog(order);
    }
  }

  // Navigate to add order form
  Future<void> showAddOrderDialog() async {
    final result = await _navigationService.navigateToView(AddOrderView());
    if (result == true) {
      await refreshData();
    }
  }

  // Navigate to edit order form
  Future<void> editOrder(String orderId) async {
    final result = await _navigationService.navigateToView(
        AddOrderView(orderId: orderId)
    );
    if (result == true) {
      await refreshData();
    }
  }

  // Show update status dialog
  Future<void> showUpdateStatusDialog(OrderModel order) async {
    final availableStatuses = ['Pending', 'Produksi', 'Selesai'];
    final currentStatusIndex = availableStatuses.indexOf(order.status);

    String? selectedStatus = order.status;
    double? selectedProgress = order.progress;

    final result = await _dialogService.showCustomDialog(
      variant: DialogType.form,
      title: 'Update Order Status',
      description: 'Order: ${order.orderId}',
      data: {
        'currentStatus': order.status,
        'currentProgress': order.progress,
        'availableStatuses': availableStatuses,
      },
    );

    if (result?.confirmed ?? false) {
      await updateOrderStatus(
        order,
        result?.data['status'] ?? order.status,
        result?.data['progress']?.toDouble() ?? order.progress,
      );
    }
  }

  // Update order status
  Future<void> updateOrderStatus(OrderModel order, String newStatus, double newProgress) async {
    setBusy(true);

    try {
      final updatedOrder = order.copyWith(
        status: newStatus,
        progress: newProgress,
      );

      await _firestoreService.updateOrder(updatedOrder);

      _snackbarService.showSnackbar(
        message: 'Order status updated successfully',
        duration: const Duration(seconds: 3),
      );

      await refreshData();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to update order status: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Delete order with confirmation
  Future<void> deleteOrder(OrderModel order) async {
    final result = await _dialogService.showDialog(
      title: 'Delete Order',
      description: 'Are you sure you want to delete order ${order.orderId}? This action cannot be undone.\n\nCustomer: ${order.namaCustomer}\nProduct: ${order.namaProduk}',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
      dialogPlatform: DialogPlatform.Material,
    );

    if (result?.confirmed ?? false) {
      setBusy(true);

      try {
        await _firestoreService.deleteOrder(order.orderId);

        _snackbarService.showSnackbar(
          message: 'Order deleted successfully',
          duration: const Duration(seconds: 3),
        );

        await refreshData();
      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Failed to delete order: $e',
          duration: const Duration(seconds: 3),
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Bulk operations
  Future<void> bulkUpdateStatus(List<OrderModel> orders, String newStatus) async {
    setBusy(true);

    try {
      for (final order in orders) {
        final updatedOrder = order.copyWith(status: newStatus);
        await _firestoreService.updateOrder(updatedOrder);
      }

      _snackbarService.showSnackbar(
        message: '${orders.length} orders updated successfully',
        duration: const Duration(seconds: 3),
      );

      await refreshData();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to update orders: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Export orders (placeholder for future implementation)
  Future<void> exportOrders() async {
    _snackbarService.showSnackbar(
      message: 'Export feature will be implemented soon',
      duration: const Duration(seconds: 2),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFF9800); // Orange
      case 'Produksi':
        return const Color(0xFF2196F3); // Blue
      case 'Selesai':
        return const Color(0xFF4CAF50); // Green
      default:
        return const Color(0xFF6A1B9A); // Purple
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Retry mechanism for failed operations
  Future<void> retryLastOperation() async {
    await loadData();
  }
}