import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import '../features/auth/login_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/home/home_view.dart';
import '../features/materials/materials_view.dart';
import '../features/orders/orders_view.dart';
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
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
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
