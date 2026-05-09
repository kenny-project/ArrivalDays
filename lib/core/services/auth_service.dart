import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../utils/logger.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const _keyPinHash = 'auth_pin_hash';
  static const _keyPinSalt = 'auth_pin_salt';
  static const _keyBiometricEnabled = 'auth_biometric_enabled';

  AuthService._init();

  /// Check if a PIN has been set
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null;
  }

  /// Check if biometric unlock is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// Set biometric enabled/disabled
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled.toString());
    Log.i(LogTag.settings, 'biometric enabled: $enabled');
  }

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      final result = await _localAuth.canCheckBiometrics;
      Log.i(LogTag.settings, 'canCheckBiometrics: $result');
      return result;
    } catch (e) {
      Log.e(LogTag.settings, 'canCheckBiometrics error: $e');
      return false;
    }
  }

  /// Authenticate with biometric (fingerprint/face/device credential)
  Future<bool> authenticateWithBiometric({String reason = '验证身份以解锁应用'}) async {
    if (kIsWeb) return false;
    try {
      Log.i(LogTag.settings, 'authenticateWithBiometric: starting, reason=$reason');
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      Log.i(LogTag.settings, 'authenticateWithBiometric: result=$result');
      return result;
    } catch (e) {
      Log.e(LogTag.settings, 'biometric auth error: $e');
      return false;
    }
  }

  /// Save a new PIN (hashes it before storing)
  Future<void> savePin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _storage.write(key: _keyPinHash, value: hash);
    await _storage.write(key: _keyPinSalt, value: base64Encode(salt));
    Log.i(LogTag.settings, 'PIN saved');
  }

  /// Verify a PIN against stored hash
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _keyPinHash);
    final storedSaltBase64 = await _storage.read(key: _keyPinSalt);

    if (storedHash == null || storedSaltBase64 == null) return false;

    final salt = base64Decode(storedSaltBase64);
    final hash = _hashPin(pin, salt);

    return hash == storedHash;
  }

  /// Remove PIN and biometric settings
  Future<void> clearPin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
    await _storage.delete(key: _keyBiometricEnabled);
    Log.i(LogTag.settings, 'PIN cleared');
  }

  /// Reset all app data (PIN + secure storage)
  Future<void> resetAllData() async {
    await _storage.deleteAll();
    Log.i(LogTag.settings, 'all secure storage cleared');
  }

  String _hashPin(String pin, List<int> salt) {
    final bytes = utf8.encode(pin) + salt;
    return sha256.convert(bytes).toString();
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }
}
