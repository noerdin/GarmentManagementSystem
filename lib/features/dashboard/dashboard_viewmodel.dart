import 'package:csj/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/material_model.dart';
import '../../models/production_model.dart';
import '../../models/shipping_model.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';

class DashboardViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _authService = locator<FirebaseAuthService>();
  final _navigationService = locator<NavigationService>();

  // User information
  String _userName = 'User';
  String _userRole = 'Staff';

  String get userName => _userName;
  String get userRole => _userRole;

  // Dashboard statistics
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _inProductionOrders = 0;
  int _completedOrders = 0;
  int _overdueOrders = 0;

  int get totalOrders => _totalOrders;
  int get pendingOrders => _pendingOrders;
  int get inProductionOrders => _inProductionOrders;
  int get completedOrders => _completedOrders;
  int get overdueOrders => _overdueOrders;

  // Alert information
  List<MaterialModel> _lowStockMaterials = [];
  List<MaterialModel> get lowStockMaterials => _lowStockMaterials;

  // Recent activities
  List<ProductionModel> _recentProductions = [];
  List<ShippingModel> _recentShipments = [];

  List<ProductionModel> get recentProductions => _recentProductions;
  List<ShippingModel> get recentShipments => _recentShipments;

  Future<void> init() async {
    setBusy(true);

    try {
      // Get user info
      if (_authService.currentUser != null) {
        final userData =
        await _authService.getUserData(_authService.currentUser!.uid);
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
      final dashboardData = await _firestoreService.getDashboardData();

      // Update statistics
      _totalOrders = dashboardData['totalOrders'] ?? 0;
      _pendingOrders = dashboardData['pendingOrders'] ?? 0;
      _inProductionOrders = dashboardData['productionOrders'] ?? 0;
      _completedOrders = dashboardData['completedOrders'] ?? 0;
      _overdueOrders = dashboardData['overdueOrders'] ?? 0;

      // Update alerts
      _lowStockMaterials = dashboardData['lowStockMaterials'] ?? [];

      // Update recent activities
      _recentProductions = dashboardData['recentProduction'] ?? [];
      _recentShipments = dashboardData['recentShipping'] ?? [];

      notifyListeners();
    } catch (e) {
      setError('Failed to refresh data: $e');
    } finally {
      setBusy(false);
    }
  }

  // Navigation methods
  void navigateToOrders() {
    _navigationService.navigateToOrdersView();
  }

  void navigateToMaterials() {
    _navigationService.navigateToMaterialsView();
  }

  void navigateToProduction() {
    _navigationService.navigateToProductionView();
  }

  void navigateToShipping() {
    _navigationService.navigateToShippingView();
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _authService.signOut();
      await _navigationService.replaceWithLoginView();
    } catch (e) {
      setError('Failed to logout: $e');
    }
  }
}
