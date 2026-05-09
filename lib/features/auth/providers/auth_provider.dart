import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/logger.dart';

/// Whether the user has a PIN set
final hasPinProvider = FutureProvider<bool>((ref) async {
  return AuthService.instance.hasPin();
});

/// Whether biometric unlock is enabled
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  return AuthService.instance.isBiometricEnabled();
});

/// Whether the device supports biometric
final canCheckBiometricsProvider = FutureProvider<bool>((ref) async {
  return AuthService.instance.canCheckBiometrics();
});

/// Auth state: whether the user is authenticated in this session
final isAuthenticatedProvider = StateProvider<bool>((ref) => false);

/// ViewModel for password settings screen
final authViewModelProvider = Provider<AuthViewModel>((ref) {
  return AuthViewModel(ref);
});

class AuthViewModel {
  final Ref _ref;

  AuthViewModel(this._ref);

  Future<bool> hasPin() => AuthService.instance.hasPin();

  Future<void> savePin(String pin) async {
    await AuthService.instance.savePin(pin);
    _ref.invalidate(hasPinProvider);
    Log.i(LogTag.settings, 'PIN saved via ViewModel');
  }

  Future<bool> verifyPin(String pin) => AuthService.instance.verifyPin(pin);

  Future<void> clearPin() async {
    await AuthService.instance.clearPin();
    _ref.invalidate(hasPinProvider);
    _ref.invalidate(biometricEnabledProvider);
    Log.i(LogTag.settings, 'PIN cleared via ViewModel');
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await AuthService.instance.setBiometricEnabled(enabled);
    _ref.invalidate(biometricEnabledProvider);
  }

  Future<bool> authenticateWithBiometric({String reason = '验证身份以解锁应用'}) {
    return AuthService.instance.authenticateWithBiometric(reason: reason);
  }

  Future<void> resetAllData() async {
    await AuthService.instance.resetAllData();
    _ref.invalidate(hasPinProvider);
    _ref.invalidate(biometricEnabledProvider);
    _ref.read(isAuthenticatedProvider.notifier).state = true;
    Log.i(LogTag.settings, 'all data reset via ViewModel');
  }
}
