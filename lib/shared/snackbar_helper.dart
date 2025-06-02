import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../app/app.locator.dart';

class SnackbarHelper {
  static final NavigationService _navigationService = locator<NavigationService>();

  static void showSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final context = _navigationService.navigatorKey?.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  static void showSuccess(String message) {
    showSnackbar(
      message: message,
      duration: const Duration(seconds: 2),
    );
  }

  static void showError(String message) {
    showSnackbar(
      message: message,
      duration: const Duration(seconds: 4),
    );
  }
}