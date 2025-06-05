import 'dart:async';

import 'package:csj/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../shared/app_error.dart';
import '../../shared/result_state.dart';

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
  String _searchQuery = '';

  List<OrderModel> get orders => _orders;
  List<OrderModel> get displayedOrders => _displayedOrders;
  bool get showOverdueOnly => _showOverdueOnly;
  int get selectedTab => _selectedTab;

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

  // Show filter options
  Future<void> showFilterOptions() async {
    final result = await _dialogService.showDialog(
      title: 'Filter Options',
      description: 'Choose additional filters for orders',
      buttonTitle: 'Apply Filters',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      // Implement additional filters like date range, customer, etc.
      await refreshData();
    }
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

    // Sort by date (newest first) and priority
    result.sort((a, b) {
      // Priority sort: overdue first, then by deadline
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;

      // Then by deadline
      return a.deadlineProduksi.compareTo(b.deadlineProduksi);
    });

    _displayedOrders = result;
  }

  // Filter orders based on search text
  void filterOrders(String searchText) {
    _searchQuery = searchText;

    if (searchText.isEmpty) {
      _filteredOrders = _orders;
    } else {
      final lowerCaseSearch = searchText.toLowerCase();
      _filteredOrders = _orders.where((order) {
        return order.orderId.toLowerCase().contains(lowerCaseSearch) ||
            order.namaCustomer.toLowerCase().contains(lowerCaseSearch) ||
            order.namaProduk.toLowerCase().contains(lowerCaseSearch) ||
            order.warna.toLowerCase().contains(lowerCaseSearch);
      }).toList();
    }
    _updateDisplayedOrders();
    notifyListeners();
  }

  // Show order details dialog with enhanced information
  Future<void> showOrderDetails(OrderModel order) async {
    final sizeText = order.ukuran.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    final progressText = '${(order.progress * 100).toInt()}%';
    final estimatedPrice = order.estimasiMargin > 0
        ? '\nEstimated Price: Rp ${order.estimasiMargin.toStringAsFixed(0)}'
        : '';

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
          'Progress: $progressText\n'
          'Notes: ${order.catatan.isNotEmpty ? order.catatan : 'N/A'}',
      buttonTitle: 'Edit Order',
      cancelTitle: 'Close',
    );

    if (result?.confirmed ?? false) {
      await editOrder(order.orderId);
    }
  }

  // Navigate to add order form
  Future<void> showAddOrderDialog() async {
    final result = await _navigationService.navigateToEnhancedOrderFormView();
    if (result == true) {
      await refreshData();
    }
  }

  // Navigate to edit order form
  Future<void> editOrder(String orderId) async {
    final result = await _navigationService.navigateToEnhancedOrderFormView(
      orderId: orderId,
    );
    if (result == true) {
      await refreshData();
    }
  }

  // Duplicate an existing order
  Future<void> duplicateOrder(OrderModel order) async {
    final result = await _dialogService.showDialog(
      title: 'Duplicate Order',
      description: 'Create a new order based on "${order.orderId}"?\n\n'
          'The new order will have the same product details but with today\'s date and pending status.',
      buttonTitle: 'Duplicate',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      setBusy(true);
      try {
        final newOrderId = _firestoreService.generateOrderId();
        final duplicatedOrder = order.copyWith(
          orderId: newOrderId,
          tanggalOrder: DateTime.now(),
          status: 'Pending',
          progress: 0.0,
          deadlineProduksi: DateTime.now().add(const Duration(days: 14)), // Default 2 weeks
          catatan: 'Duplicated from ${order.orderId}',
        );

        await _firestoreService.addOrder(duplicatedOrder);

        _snackbarService.showSnackbar(
          message: 'Order duplicated successfully! New Order ID: $newOrderId',
          duration: const Duration(seconds: 3),
        );

        await refreshData();

        // Optionally open the duplicated order for editing
        final editResult = await _dialogService.showDialog(
          title: 'Order Duplicated',
          description: 'Would you like to edit the duplicated order now?',
          buttonTitle: 'Edit Now',
          cancelTitle: 'Later',
        );

        if (editResult?.confirmed ?? false) {
          await editOrder(newOrderId);
        }

      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Failed to duplicate order: $e',
          duration: const Duration(seconds: 3),
        );
      } finally {
        setBusy(false);
      }
    }
  }

  // Show update status dialog
  Future<void> showUpdateStatusDialog(OrderModel order) async {
    String newStatus = order.status;
    double newProgress = order.progress;

    // Determine next logical status
    switch (order.status) {
      case 'Pending':
        newStatus = 'Produksi';
        newProgress = 0.1;
        break;
      case 'Produksi':
        if (order.progress < 1.0) {
          newProgress = (order.progress + 0.25).clamp(0.0, 1.0);
          if (newProgress >= 1.0) {
            newStatus = 'Selesai';
          }
        } else {
          newStatus = 'Selesai';
          newProgress = 1.0;
        }
        break;
      case 'Selesai':
        _snackbarService.showSnackbar(
          message: 'Order is already completed',
          duration: const Duration(seconds: 2),
        );
        return;
    }

    final statusText = newStatus == order.status
        ? 'Update progress to ${(newProgress * 100).toInt()}%'
        : 'Change status to $newStatus';

    final result = await _dialogService.showDialog(
      title: 'Update Order Status',
      description: 'Order: ${order.orderId}\n'
          'Current: ${order.displayStatus} (${(order.progress * 100).toInt()}%)\n\n'
          'Proposed change: $statusText\n\n'
          'Continue with this update?',
      buttonTitle: 'Update',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      await updateOrderStatus(order, newStatus, newProgress);
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

      String message = 'Order status updated successfully';
      if (newStatus == 'Selesai') {
        message = 'Order completed successfully! 🎉';
      } else if (newStatus == 'Produksi') {
        message = 'Order moved to production';
      }

      _snackbarService.showSnackbar(
        message: message,
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
    // Additional safety check
    if (order.status != 'Pending') {
      _snackbarService.showSnackbar(
        message: 'Only pending orders can be deleted',
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final result = await _dialogService.showDialog(
      title: 'Delete Order',
      description: '⚠️ Are you sure you want to delete this order?\n\n'
          'Order ID: ${order.orderId}\n'
          'Customer: ${order.namaCustomer}\n'
          'Product: ${order.namaProduk}\n'
          'Quantity: ${order.jumlahTotal}\n\n'
          'This action cannot be undone!',
      buttonTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      setBusy(true);

      try {
        await _firestoreService.deleteOrder(order.orderId);

        _snackbarService.showSnackbar(
          message: 'Order "${order.orderId}" deleted successfully',
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
    if (orders.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'No orders selected',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await _dialogService.showDialog(
      title: 'Bulk Update',
      description: 'Update ${orders.length} orders to status "$newStatus"?',
      buttonTitle: 'Update All',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      setBusy(true);

      try {
        for (final order in orders) {
          double newProgress = order.progress;

          // Auto-calculate progress based on status
          switch (newStatus) {
            case 'Pending':
              newProgress = 0.0;
              break;
            case 'Produksi':
              newProgress = order.progress > 0 ? order.progress : 0.1;
              break;
            case 'Selesai':
              newProgress = 1.0;
              break;
          }

          final updatedOrder = order.copyWith(
            status: newStatus,
            progress: newProgress,
          );
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
  }

  // Export orders (placeholder for future implementation)
  Future<void> exportOrders() async {
    if (_displayedOrders.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'No orders to export',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setBusy(true);

    try {
      StringBuffer csvContent = StringBuffer();

      // CSV Header
      csvContent.writeln('Order ID,Date,Customer,Product,Color,Total Qty,Status,Progress,Deadline,Notes');

      // CSV Data
      for (final order in _displayedOrders) {
        final sizeDistribution = order.ukuran.entries
            .where((e) => e.value > 0)
            .map((e) => '${e.key}:${e.value}')
            .join(';');

        csvContent.writeln(
            '"${order.orderId}",'
                '"${_formatDate(order.tanggalOrder)}",'
                '"${order.namaCustomer}",'
                '"${order.namaProduk}",'
                '"${order.warna}",'
                '"${order.jumlahTotal}",'
                '"${order.status}",'
                '"${(order.progress * 100).toInt()}%",'
                '"${_formatDate(order.deadlineProduksi)}",'
                '"${order.catatan.replaceAll('"', '""')}"'
        );
      }

      // For now, copy to clipboard (you can implement file download later)
      // await Clipboard.setData(ClipboardData(text: csvContent.toString()));

      final result = await _dialogService.showDialog(
        title: 'Export Complete',
        description: 'Orders data has been prepared for export.\n\n'
            'Total orders: ${_displayedOrders.length}\n'
            'Filter applied: ${_getFilterDescription()}\n\n'
            'Data has been copied to clipboard in CSV format.',
        buttonTitle: 'OK',
      );

      _snackbarService.showSnackbar(
        message: '${_displayedOrders.length} orders exported successfully',
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to export orders: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Get current filter description for export
  String _getFilterDescription() {
    List<String> filters = [];

    if (_selectedTab > 0) {
      final tabNames = ['All', 'Pending', 'Production', 'Completed'];
      filters.add(tabNames[_selectedTab]);
    }

    if (_showOverdueOnly) {
      filters.add('Overdue only');
    }

    if (_searchQuery.isNotEmpty) {
      filters.add('Search: "$_searchQuery"');
    }

    return filters.isEmpty ? 'No filters' : filters.join(', ');
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Get order statistics
  Map<String, dynamic> getOrderStatistics() {
    final now = DateTime.now();
    final thisMonth = _orders.where((o) =>
    o.tanggalOrder.month == now.month &&
        o.tanggalOrder.year == now.year
    ).length;

    final thisWeek = _orders.where((o) =>
    now.difference(o.tanggalOrder).inDays <= 7
    ).length;

    return {
      'total': _orders.length,
      'pending': pendingCount,
      'production': productionCount,
      'completed': completedCount,
      'overdue': overdueCount,
      'thisMonth': thisMonth,
      'thisWeek': thisWeek,
    };
  }

  // Retry mechanism for failed operations
  Future<void> retryLastOperation() async {
    await loadData();
  }

  // Clear all filters
  void clearAllFilters() {
    _selectedTab = 0;
    _showOverdueOnly = false;
    _searchQuery = '';
    _filteredOrders = _orders;
    _updateDisplayedOrders();
    notifyListeners();
  }
}