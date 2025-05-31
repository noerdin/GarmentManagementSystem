import 'package:csj/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

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

  void navigateToDashboard() {
    _navigationService.navigateToDashboardView();
  }
}
