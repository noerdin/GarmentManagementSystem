import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../models/order_model.dart';
import '../../models/production_model.dart';
import '../../services/firestore_service.dart';

class ProductionViewModel extends BaseViewModel {
  final _firestoreService = locator<FirestoreService>();
  final _dialogService = locator<DialogService>();

  List<ProductionModel> _productions = [];
  List<ProductionModel> _filteredProductions = [];
  List<ProductionModel> _displayedProductions = [];
  List<OrderModel> _orders = [];
  int _selectedTab = 0;

  List<ProductionModel> get productions => _productions;
  List<ProductionModel> get displayedProductions => _displayedProductions;

  // Stats
  int get cuttingTotal => _productions
      .where((p) => p.tahap == 'Cutting')
      .fold(0, (sum, p) => sum + p.jumlah);
  int get sewingTotal => _productions
      .where((p) => p.tahap == 'Sewing')
      .fold(0, (sum, p) => sum + p.jumlah);
  int get packingTotal => _productions
      .where((p) => p.tahap == 'Packing')
      .fold(0, (sum, p) => sum + p.jumlah);

  Future<void> init() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to load production data: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadData() async {
    final productionData = await _firestoreService.productionStream().first;
    _productions = productionData;
    _filteredProductions = productionData;
    _updateDisplayedProductions();

    // Load orders for reference
    _orders = await _firestoreService.getOrders();

    notifyListeners();
  }

  Future<void> refreshData() async {
    setBusy(true);
    try {
      await loadData();
    } catch (e) {
      setError('Failed to refresh production data: $e');
    } finally {
      setBusy(false);
    }
  }

  // Handle tab selection
  void setSelectedTab(int index) {
    _selectedTab = index;
    _updateDisplayedProductions();
    notifyListeners();
  }

  // Update displayed productions based on selected tab
  void _updateDisplayedProductions() {
    switch (_selectedTab) {
      case 0: // All
        _displayedProductions = _filteredProductions;
        break;
      case 1: // Cutting
        _displayedProductions =
            _filteredProductions.where((p) => p.tahap == 'Cutting').toList();
        break;
      case 2: // Sewing
        _displayedProductions =
            _filteredProductions.where((p) => p.tahap == 'Sewing').toList();
        break;
      case 3: // Packing
        _displayedProductions =
            _filteredProductions.where((p) => p.tahap == 'Packing').toList();
        break;
      default:
        _displayedProductions = _filteredProductions;
    }
  }

  // Filter productions based on search text
  void filterProductions(String searchText) {
    if (searchText.isEmpty) {
      _filteredProductions = _productions;
    } else {
      final lowerCaseSearch = searchText.toLowerCase();
      _filteredProductions = _productions.where((production) {
        return production.orderId.toLowerCase().contains(lowerCaseSearch) ||
            production.operator.toLowerCase().contains(lowerCaseSearch) ||
            production.subTahap.toLowerCase().contains(lowerCaseSearch);
      }).toList();
    }
    _updateDisplayedProductions();
    notifyListeners();
  }

  // Show production details dialog
  void showProductionDetails(ProductionModel production) async {
    // Find the associated order
    final order = _orders.firstWhere(
          (order) => order.orderId == production.orderId,
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
      title: 'Production Details',
      description: 'Production ID: ${production.produksiId}\n'
          'Date: ${_formatDate(production.tanggal)}\n'
          'Stage: ${production.tahap}\n'
          'Sub-stage: ${production.subTahap.isNotEmpty ? production.subTahap : 'N/A'}\n'
          'Order ID: ${production.orderId}\n'
          'Product: ${order.namaProduk}\n'
          'Customer: ${order.namaCustomer}\n'
          'Operator: ${production.operator}\n'
          'Quantity: ${production.jumlah}\n'
          'Notes: ${production.keterangan.isNotEmpty ? production.keterangan : 'N/A'}',
      dialogPlatform: DialogPlatform.Material,
    );
  }

  // Show add production dialog
  void showAddProductionDialog() async {
    // Get orders that are in production or pending
    final availableOrders =
    _orders.where((order) => order.status != 'Selesai').toList();

    if (availableOrders.isEmpty) {
      await _dialogService.showDialog(
        title: 'No Available Orders',
        description:
        'There are no active orders available for production. Create a new order first.',
        buttonTitle: 'OK',
      );
      return;
    }

    // Additional implementation would be needed here to:
    // 1. Show a form dialog to collect production details
    // 2. Create a new ProductionModel
    // 3. Save it to Firestore
    // 4. Refresh the data

    await _dialogService.showDialog(
      title: 'Add Production Record',
      description: 'This feature will be implemented soon',
      buttonTitle: 'OK',
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
