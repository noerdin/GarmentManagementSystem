import 'package:csj/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../app/app.locator.dart';
import '../../services/firebase_auth_service.dart';

class AuthViewModel extends BaseViewModel {
  final _authService = locator<FirebaseAuthService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  String _email = '';
  String _password = '';
  String? _errorMessage;

  String get email => _email;
  String? get errorMessage => _errorMessage;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> login() async {
    if (_email.isEmpty || _password.isEmpty) {
      _errorMessage = 'Email dan password harus diisi';
      notifyListeners();
      return;
    }

    setBusy(true);
    try {
      final userCredential = await _authService.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      if (userCredential.user == null) {
        _errorMessage = 'Login gagal';
        notifyListeners();
        setBusy(false);
        return;
      }

      // Check if user is active
      final user = userCredential.user!;
      print('cek log ${user.uid}');
      final isActive =
      await _authService.isUserActive(user.uid);
      print('cek log $isActive');
      if (!isActive) {
        await _authService.signOut();
        _errorMessage = 'Akun tidak aktif. Hubungi administrator.';
        notifyListeners();
        setBusy(false);
        return;
      }

      // Get user data
      final userData = await _authService.getUserData(user.uid);

      // Memeriksa status dan peran pengguna menggunakan getter
      if (userData.isActive) {
        // Lakukan sesuatu jika pengguna aktif
        await _navigationService.navigateToEnhancedDashboardView();
      } else {
        _errorMessage = 'Akun Anda tidak aktif';
        notifyListeners();
      }

    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> resetPassword() async {
    if (_email.isEmpty) {
      _errorMessage = 'Masukkan email untuk reset password';
      notifyListeners();
      return;
    }

    setBusy(true);
    try {
      await _authService.resetPassword(_email);
      await _dialogService.showDialog(
        title: 'Reset Password',
        description: 'Link reset password telah dikirim ke email $_email',
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> logout() async {
    setBusy(true);
    try {
      await _authService.signOut();
      await _navigationService.replaceWithLoginView();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // Check if user is already logged in
  Future<bool> checkLoggedInUser() async {
    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      try {
        // Check if user is active
        final isActive = await _authService.isUserActive(currentUser.uid);
        return isActive;
      } catch (e) {
        return false;
      }
    }

    return false;
  }
}
