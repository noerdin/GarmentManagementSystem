import 'package:csj/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../app/app.locator.dart';
import '../../services/firebase_auth_service.dart';

class StartupViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<FirebaseAuthService>();

  Future runStartupLogic() async {
    // Simulate a delay for splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is already logged in
    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      try {
        // Check if user is active
        final isActive = await _authService.isUserActive(currentUser.uid);

        if (isActive) {
          // Navigate to dashboard if user is logged in and active
          await _navigationService.replaceWithDashboardView();
          return;
        } else {
          // User is not active, log them out and send to login
          await _authService.signOut();
          await _navigationService.replaceWithLoginView();
          return;
        }
      } catch (e) {
        // Handle any errors by navigating to login
        await _navigationService.replaceWithLoginView();
        return;
      }
    }

    // Navigate to login if no user is logged in
    await _navigationService.replaceWithLoginView();
  }
}
