import 'package:flutter/material.dart' as i10;
import 'package:flutter/material.dart';
import 'package:csj/features/auth/login_view.dart' as i4;
import 'package:csj/features/dashboard/dashboard_view.dart' as i5;
import 'package:csj/features/home/home_view.dart' as i2;
import 'package:csj/features/materials/materials_view.dart' as i7;
import 'package:csj/features/orders/orders_view.dart' as i6;
import 'package:csj/features/production/production_view.dart' as i8;
import 'package:csj/features/shipping/shipping_view.dart' as i9;
import 'package:csj/features/startup/startup_view.dart' as i3;
import 'package:stacked/stacked.dart' as i1;
import 'package:stacked_services/stacked_services.dart' as i11;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/';

  static const loginView = '/login-view';

  static const dashboardView = '/dashboard-view';

  static const ordersView = '/orders-view';

  static const materialsView = '/materials-view';

  static const productionView = '/production-view';

  static const shippingView = '/shipping-view';

  static const all = <String>{
    homeView,
    startupView,
    loginView,
    dashboardView,
    ordersView,
    materialsView,
    productionView,
    shippingView,
  };
}

class StackedRouter extends i1.RouterBase {
  final _routes = <i1.RouteDef>[
    i1.RouteDef(
      Routes.homeView,
      page: i2.HomeView,
    ),
    i1.RouteDef(
      Routes.startupView,
      page: i3.StartupView,
    ),
    i1.RouteDef(
      Routes.loginView,
      page: i4.LoginView,
    ),
    i1.RouteDef(
      Routes.dashboardView,
      page: i5.DashboardView,
    ),
    i1.RouteDef(
      Routes.ordersView,
      page: i6.OrdersView,
    ),
    i1.RouteDef(
      Routes.materialsView,
      page: i7.MaterialsView,
    ),
    i1.RouteDef(
      Routes.productionView,
      page: i8.ProductionView,
    ),
    i1.RouteDef(
      Routes.shippingView,
      page: i9.ShippingView,
    ),
  ];

  final _pagesMap = <Type, i1.StackedRouteFactory>{
    i2.HomeView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i2.HomeView(),
        settings: data,
      );
    },
    i3.StartupView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i3.StartupView(),
        settings: data,
      );
    },
    i4.LoginView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i4.LoginView(),
        settings: data,
      );
    },
    i5.DashboardView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i5.DashboardView(),
        settings: data,
      );
    },
    i6.OrdersView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i6.OrdersView(),
        settings: data,
      );
    },
    i7.MaterialsView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i7.MaterialsView(),
        settings: data,
      );
    },
    i8.ProductionView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i8.ProductionView(),
        settings: data,
      );
    },
    i9.ShippingView: (data) {
      return i10.MaterialPageRoute<dynamic>(
        builder: (context) => const i9.ShippingView(),
        settings: data,
      );
    },
  };

  @override
  List<i1.RouteDef> get routes => _routes;

  @override
  Map<Type, i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

extension NavigatorStateExtension on i11.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToOrdersView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.ordersView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMaterialsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.materialsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProductionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.productionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToShippingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return navigateTo<dynamic>(Routes.shippingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDashboardView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dashboardView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithOrdersView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.ordersView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMaterialsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.materialsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProductionView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.productionView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithShippingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
    transition,
  ]) async {
    return replaceWith<dynamic>(Routes.shippingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
