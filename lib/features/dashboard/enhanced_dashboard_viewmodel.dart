import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../app/app.router.dart';
import '../../models/material_model.dart';
import '../../models/order_model.dart';
import '../../models/production_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../shared/snackbar_helper.dart';

class EnhancedDashboardViewModel extends BaseViewModel {
  final FirestoreService _firestoreService = locator<FirestoreService>();
  final FirebaseAuthService _authService = locator<FirebaseAuthService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

  // User Information
  String _userName = 'User';
  String _userRole = 'Staff';

  String get userName => _userName;
  String get userRole => _userRole;

  // Dashboard Statistics
  int _totalOrders = 0;
  int _activeProductions = 0;
  int _completedToday = 0;
  int _pendingOrders = 0;
  int _inProductionOrders = 0;
  int _completedOrders = 0;
  int _overdueOrders = 0;

  // Performance Metrics
  int _orderGrowth = 15;
  int _productionEfficiency = 85;
  int _completionRate = 92;
  int _overallEfficiency = 87;
  int _qualityScore = 94;
  int _onTimeDelivery = 89;

  // Production Progress Data
  int _cuttingProgress = 25;
  int _sewingProgress = 45;
  int _finishingProgress = 30;

  // Daily Targets and Actuals
  int _todayCutting = 45;
  int _targetCutting = 60;
  int _todaySewing = 38;
  int _targetSewing = 50;
  int _todayFinishing = 22;
  int _targetFinishing = 30;
  int _todayWashing = 15;
  int _targetWashing = 20;

  // Weekly Production Data (for charts)
  List<int> _weeklyProductionData = [65, 78, 82, 70, 85, 90, 75];

  // Material Status
  int _totalMaterials = 0;
  int _lowStockCount = 0;
  int _outOfStockCount = 0;
  List<MaterialModel> _lowStockMaterials = [];

  // Recent Activities
  List<Map<String, dynamic>> _recentActivities = [];

  // Getters
  int get totalOrders => _totalOrders;
  int get activeProductions => _activeProductions;
  int get completedToday => _completedToday;
  int get pendingOrders => _pendingOrders;
  int get inProductionOrders => _inProductionOrders;
  int get completedOrders => _completedOrders;
  int get overdueOrders => _overdueOrders;

  int get orderGrowth => _orderGrowth;
  int get productionEfficiency => _productionEfficiency;
  int get completionRate => _completionRate;
  int get overallEfficiency => _overallEfficiency;
  int get qualityScore => _qualityScore;
  int get onTimeDelivery => _onTimeDelivery;

  int get cuttingProgress => _cuttingProgress;
  int get sewingProgress => _sewingProgress;
  int get finishingProgress => _finishingProgress;

  int get todayCutting => _todayCutting;
  int get targetCutting => _targetCutting;
  int get todaySewing => _todaySewing;
  int get targetSewing => _targetSewing;
  int get todayFinishing => _todayFinishing;
  int get targetFinishing => _targetFinishing;
  int get todayWashing => _todayWashing;
  int get targetWashing => _targetWashing;

  int get dailyTargetCompletion => _calculateDailyTargetCompletion();
  List<int> get weeklyProductionData => _weeklyProductionData;

  int get totalMaterials => _totalMaterials;
  int get lowStockCount => _lowStockCount;
  int get outOfStockCount => _outOfStockCount;
  List<MaterialModel> get lowStockMaterials => _lowStockMaterials;

  List<Map<String, dynamic>> get recentActivities => _recentActivities;

  Future<void> init() async {
    setBusy(true);

    try {
      // Get user info
      if (_authService.currentUser != null) {
        final userData = await _authService.getUserData(_authService.currentUser!.uid);
        _userName = userData.nama;
        _userRole = userData.role;
      }

      // Load dashboard data
      await refreshData();
    } catch (e) {
      setError('Failed to load dashboard: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> refreshData() async {
    setBusy(true);

    try {
      // Load all data concurrently
      await Future.wait([
        _loadOrderStatistics(),
        _loadProductionData(),
        _loadMaterialData(),
        _loadRecentActivities(),
      ]);

      notifyListeners();
    } catch (e) {
      setError('Failed to refresh data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadOrderStatistics() async {
    try {
      final orders = await _firestoreService.ordersStream().first;

      _totalOrders = orders.length;
      _pendingOrders = orders.where((o) => o.status == 'Pending').length;
      _inProductionOrders = orders.where((o) => o.status == 'Produksi').length;
      _completedOrders = orders.where((o) => o.status == 'Selesai').length;
      _overdueOrders = orders.where((o) => o.isOverdue).length;

      // Calculate completed today
      final today = DateTime.now();
      _completedToday = orders.where((o) =>
      o.status == 'Selesai' &&
          o.tanggalOrder.day == today.day &&
          o.tanggalOrder.month == today.month &&
          o.tanggalOrder.year == today.year
      ).length;

      // Calculate growth (mock calculation - you can implement real logic)
      _orderGrowth = _calculateOrderGrowth(orders);

    } catch (e) {
      print('Error loading order statistics: $e');
    }
  }

  Future<void> _loadProductionData() async {
    try {
      final productions = await _firestoreService.productionStream().first;

      _activeProductions = productions.length;

      // Calculate weekly production data (last 7 days)
      _weeklyProductionData = _calculateWeeklyProduction(productions);

    } catch (e) {
      print('Error loading production data: $e');
    }
  }

  Future<void> _loadMaterialData() async {
    try {
      final materials = await _firestoreService.materialsStream().first;

      _totalMaterials = materials.length;
      _lowStockMaterials = materials.where((m) => m.isLowStock).toList();
      _lowStockCount = _lowStockMaterials.length;
      _outOfStockCount = materials.where((m) => m.stok == 0).length;

    } catch (e) {
      print('Error loading material data: $e');
    }
  }

  Future<void> _loadRecentActivities() async {
    try {
      _recentActivities = [
        {
          'type': 'order',
          'description': 'New order created',
          'time': '2 hours ago',
        },
        {
          'type': 'production',
          'description': 'Cutting stage completed',
          'time': '3 hours ago',
        },
        {
          'type': 'shipping',
          'description': 'Order shipped to Jakarta',
          'time': '5 hours ago',
        },
        {
          'type': 'material',
          'description': 'Cotton fabric stock updated',
          'time': '6 hours ago',
        },
        {
          'type': 'production',
          'description': 'Sewing started',
          'time': '8 hours ago',
        },
      ];
    } catch (e) {
      print('Error loading recent activities: $e');
    }
  }

  // Helper methods for calculations
  int _calculateOrderGrowth(List<OrderModel> orders) {
    // Mock calculation - implement your logic
    final thisMonth = orders.where((o) => o.tanggalOrder.month == DateTime.now().month).length;
    final lastMonth = orders.where((o) => o.tanggalOrder.month == DateTime.now().month - 1).length;

    if (lastMonth == 0) return 0;
    return ((thisMonth - lastMonth) / lastMonth * 100).round();
  }

  List<int> _calculateWeeklyProduction(List<ProductionModel> productions) {
    final List<int> weeklyData = [0, 0, 0, 0, 0, 0, 0]; // Last 7 days
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final targetDate = now.subtract(Duration(days: 6 - i));
      final dayProductions = productions.where((p) =>
      p.tanggal.day == targetDate.day &&
          p.tanggal.month == targetDate.month &&
          p.tanggal.year == targetDate.year
      );

      weeklyData[i] = dayProductions.fold(0, (sum, p) => sum + p.jumlah);
    }

    return weeklyData;
  }

  int _calculateDailyTargetCompletion() {
    final totalActual = _todayCutting + _todaySewing + _todayFinishing + _todayWashing;
    final totalTarget = _targetCutting + _targetSewing + _targetFinishing + _targetWashing;

    if (totalTarget == 0) return 0;
    return ((totalActual / totalTarget) * 100).round();
  }

  // Navigation methods
  void navigateToOrders() {
    _navigationService.navigateToOrdersView();
  }

  void navigateToMaterials() {
    _navigationService.navigateToMaterialPlanningView();
  }

  void navigateToProduction() {
    _navigationService.navigateToEnhancedProductionFormView();
  }

  void navigateToShipping() {
    _navigationService.navigateToShippingView();
  }

  // Show history dialog - FIXED
  Future<void> showHistoryDialog() async {
    final result = await _dialogService.showDialog(
      title: 'Production History',
      description: 'View production history and reports',
      buttonTitle: 'View History',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      // Navigate to history - you'll need to implement this route
      // _navigationService.navigateToHistoryView();
      SnackbarHelper.showSnackbar(message: 'History view will be implemented');
    }
  }

  // Logout method
  Future<void> logout() async {
    final result = await _dialogService.showDialog(
      title: 'Logout',
      description: 'Are you sure you want to logout?',
      buttonTitle: 'Logout',
      cancelTitle: 'Cancel',
    );

    if (result?.confirmed ?? false) {
      try {
        await _authService.signOut();
        await _navigationService.replaceWithLoginView();
      } catch (e) {
        SnackbarHelper.showError('Failed to logout: $e');
      }
    }
  }

  // Alerts and notifications - FIXED
  Future<void> showLowStockAlert() async {
    if (_lowStockMaterials.isEmpty) {
      SnackbarHelper.showSuccess('All materials are sufficiently stocked');
      return;
    }

    final materialNames = _lowStockMaterials.take(5).map((m) => '• ${m.nama}').join('\n');
    final moreText = _lowStockMaterials.length > 5 ?
    '\n...and ${_lowStockMaterials.length - 5} more materials' : '';

    await _dialogService.showDialog(
      title: 'Low Stock Alert',
      description: 'The following materials are running low:\n\n$materialNames$moreText\n\nConsider restocking these materials soon.',
      buttonTitle: 'View Materials',
      cancelTitle: 'Close',
    );
  }

  Future<void> showOverdueOrdersAlert() async {
    if (_overdueOrders == 0) {
      SnackbarHelper.showSuccess('No overdue orders found');
      return;
    }

    await _dialogService.showDialog(
      title: 'Overdue Orders Alert',
      description: 'You have $_overdueOrders orders that are past their deadline.\n\nPlease review these orders and update their production status.',
      buttonTitle: 'View Orders',
      cancelTitle: 'Close',
    );
  }
}