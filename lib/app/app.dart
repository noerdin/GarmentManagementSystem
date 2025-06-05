import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import '../features/auth/login_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/dashboard/enhanced_dashboard_view.dart';
import '../features/history/history_view.dart';
import '../features/home/home_view.dart';
import '../features/materials/add_material_view.dart';
import '../features/materials/material_planning_view.dart';
import '../features/materials/materials_view.dart';
import '../features/orders/add_order_view.dart';
import '../features/orders/enhanced_order_form_view.dart';
import '../features/orders/orders_view.dart';
import '../features/production/enhanced_production_form_view.dart';
import '../features/production/production_view.dart';
import '../features/shipping/shipping_view.dart';
import '../features/startup/startup_view.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../shared/info_alert_dialog.dart';
import '../shared/notice_sheet.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: DashboardView),
    MaterialRoute(page: OrdersView),
    MaterialRoute(page: MaterialsView),
    MaterialRoute(page: ProductionView),
    MaterialRoute(page: ShippingView),
    MaterialRoute(page: EnhancedDashboardView),
    MaterialRoute(page: EnhancedOrderFormView),
    MaterialRoute(page: EnhancedProductionFormView),
    MaterialRoute(page: MaterialPlanningView),
    MaterialRoute(page: HistoryView),
    MaterialRoute(page: AddOrderView),
    MaterialRoute(page: AddMaterialView),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: FirestoreService),
    LazySingleton(classType: FirebaseAuthService),
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {}
