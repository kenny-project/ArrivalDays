# Login Password Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a 6-digit PIN lock screen with optional biometric authentication, triggered on cold start.

**Architecture:** New `feature/auth` module with `AuthService` (secure storage + hashing) and `LockScreen` widget. Auth state managed via Riverpod `StateNotifier`. Lock screen wraps `MaterialApp` in `app.dart`, showing before main content when PIN is set.

**Tech Stack:** `flutter_secure_storage` (PIN hash storage), `local_auth` (biometric/device credential), `crypto` (SHA-256 hashing), Riverpod (state management)

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `lib/core/services/auth_service.dart` | PIN hash/verify, biometric check, secure storage CRUD, data reset |
| Create | `lib/features/auth/providers/auth_provider.dart` | Riverpod providers for auth state (isAuthenticated, hasPin, biometricEnabled) |
| Create | `lib/features/auth/screens/lock_screen.dart` | Lock screen UI: 6-digit PIN input + biometric button |
| Create | `lib/features/settings/screens/password_settings_screen.dart` | Password setup/change/disable UI |
| Modify | `pubspec.yaml` | Add `flutter_secure_storage`, `local_auth`, `crypto` |
| Modify | `lib/app.dart` | Wrap MaterialApp with lock screen gate |
| Modify | `lib/features/settings/screens/settings_screen.dart` | Add "登录密码" and "数据重置" entries |
| Modify | `lib/l10n/app_localizations.dart` | Add auth-related localization keys |
| Create | `test/core/services/auth_service_test.dart` | Unit tests for AuthService PIN logic |

---

### Task 1: Add Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add packages to pubspec.yaml**

```yaml
dependencies:
  # ... existing deps ...
  flutter_secure_storage: ^9.2.4
  local_auth: ^2.3.0
  crypto: ^3.0.6
```

- [ ] **Step 2: Install dependencies**

Run: `flutter pub get`
Expected: Dependencies resolved successfully.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add flutter_secure_storage, local_auth, crypto"
```

---

### Task 2: AuthService — PIN Hashing and Storage

**Files:**
- Create: `lib/core/services/auth_service.dart`
- Create: `test/core/services/auth_service_test.dart`

- [ ] **Step 1: Write failing tests for PIN hashing logic**

Create `test/core/services/auth_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// Test the hashing logic extracted as pure functions
String hashPin(String pin, List<int> salt) {
  final bytes = utf8.encode(pin) + salt;
  return sha256.convert(bytes).toString();
}

void main() {
  group('PIN hashing', () {
    test('same PIN and salt produces same hash', () {
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final hash1 = hashPin('123456', salt);
      final hash2 = hashPin('123456', salt);
      expect(hash1, equals(hash2));
    });

    test('different PINs produce different hashes', () {
      final salt = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final hash1 = hashPin('123456', salt);
      final hash2 = hashPin('654321', salt);
      expect(hash1, isNot(equals(hash2)));
    });

    test('different salts produce different hashes', () {
      final salt1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
      final salt2 = [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
      final hash1 = hashPin('123456', salt1);
      final hash2 = hashPin('123456', salt2);
      expect(hash1, isNot(equals(hash2)));
    });

    test('PIN must be exactly 6 digits', () {
      expect(RegExp(r'^\d{6}$').hasMatch('123456'), isTrue);
      expect(RegExp(r'^\d{6}$').hasMatch('12345'), isFalse);
      expect(RegExp(r'^\d{6}$').hasMatch('1234567'), isFalse);
      expect(RegExp(r'^\d{6}$').hasMatch('abcdef'), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/services/auth_service_test.dart`
Expected: PASS (these are pure function tests, no app code needed yet)

- [ ] **Step 3: Create AuthService**

Create `lib/core/services/auth_service.dart`:

```dart
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
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      Log.e(LogTag.settings, 'canCheckBiometrics error: $e');
      return false;
    }
  }

  /// Authenticate with biometric (fingerprint/face/device credential)
  Future<bool> authenticateWithBiometric({String reason = '验证身份以解锁应用'}) async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
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
```

- [ ] **Step 4: Run all tests**

Run: `flutter test test/core/services/auth_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/auth_service.dart test/core/services/auth_service_test.dart
git commit -m "feat: add AuthService with PIN hashing and biometric support"
```

---

### Task 3: Auth Riverpod Providers

**Files:**
- Create: `lib/features/auth/providers/auth_provider.dart`

- [ ] **Step 1: Create auth state notifier and providers**

Create `lib/features/auth/providers/auth_provider.dart`:

```dart
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
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/features/auth/providers/auth_provider.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/providers/auth_provider.dart
git commit -m "feat: add auth Riverpod providers"
```

---

### Task 4: Lock Screen Widget

**Files:**
- Create: `lib/features/auth/screens/lock_screen.dart`

- [ ] **Step 1: Create lock screen with PIN input and biometric button**

Create `lib/features/auth/screens/lock_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/logger.dart';
import '../providers/auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const LockScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final List<int> _pin = [];
  bool _isVerifying = false;
  String? _error;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final canCheck = await AuthService.instance.canCheckBiometrics();
    final enabled = await AuthService.instance.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricAvailable = canCheck;
        _biometricEnabled = enabled;
      });
      if (enabled && canCheck) {
        _tryBiometric();
      }
    }
  }

  Future<void> _tryBiometric() async {
    final success = await AuthService.instance.authenticateWithBiometric(
      reason: '验证身份以解锁应用',
    );
    if (success && mounted) {
      widget.onAuthenticated();
    }
  }

  void _onDigitPressed(int digit) {
    if (_isVerifying || _pin.length >= 6) return;

    setState(() {
      _pin.add(digit);
      _error = null;
    });

    HapticFeedback.lightImpact();

    if (_pin.length == 6) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isVerifying) {
      setState(() {
        _pin.removeLast();
        _error = null;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);

    final pin = _pin.join();
    final correct = await AuthService.instance.verifyPin(pin);

    if (correct) {
      if (mounted) widget.onAuthenticated();
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _pin.clear();
          _isVerifying = false;
          _error = '密码错误';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // App icon
            Icon(
              Icons.access_time,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '人生倒计时',
              style: theme.textTheme.headlineSmall,
            ),
            const Spacer(flex: 1),
            // PIN dots
            _buildPinDots(theme),
            const SizedBox(height: 12),
            // Error text
            SizedBox(
              height: 20,
              child: _error != null
                  ? Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    )
                  : null,
            ),
            const Spacer(flex: 1),
            // Number pad
            _buildNumberPad(theme),
            const SizedBox(height: 16),
            // Biometric button
            if (_biometricAvailable && _biometricEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: IconButton(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint, size: 40),
                  tooltip: '指纹/面容解锁',
                ),
              )
            else
              const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final filled = index < _pin.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? theme.colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: _error != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.outline,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          for (final row in [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [-1, 0, -2], // -1 = spacer, -2 = backspace
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: row.map((digit) {
                  if (digit == -1) return const SizedBox(width: 72);
                  if (digit == -2) {
                    return SizedBox(
                      width: 72,
                      height: 72,
                      child: IconButton(
                        onPressed: _onBackspace,
                        icon: const Icon(Icons.backspace_outlined),
                      ),
                    );
                  }
                  return SizedBox(
                    width: 72,
                    height: 72,
                    child: TextButton(
                      onPressed: () => _onDigitPressed(digit),
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                        textStyle: const TextStyle(fontSize: 24),
                      ),
                      child: Text('$digit'),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/features/auth/screens/lock_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/screens/lock_screen.dart
git commit -m "feat: add LockScreen with PIN input and biometric support"
```

---

### Task 5: Password Settings Screen

**Files:**
- Create: `lib/features/settings/screens/password_settings_screen.dart`

- [ ] **Step 1: Create password settings screen**

Create `lib/features/settings/screens/password_settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/logger.dart';
import '../../auth/providers/auth_provider.dart';

class PasswordSettingsScreen extends ConsumerStatefulWidget {
  const PasswordSettingsScreen({super.key});

  @override
  ConsumerState<PasswordSettingsScreen> createState() =>
      _PasswordSettingsScreenState();
}

class _PasswordSettingsScreenState
    extends ConsumerState<PasswordSettingsScreen> {
  bool _hasPin = false;
  bool _biometricEnabled = false;
  bool _canCheckBiometrics = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final hasPin = await AuthService.instance.hasPin();
    final biometricEnabled = await AuthService.instance.isBiometricEnabled();
    final canCheck = await AuthService.instance.canCheckBiometrics();
    if (mounted) {
      setState(() {
        _hasPin = hasPin;
        _biometricEnabled = biometricEnabled;
        _canCheckBiometrics = canCheck;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('登录密码')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (!_hasPin) ...[
                  // No PIN set - show setup
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('设置密码'),
                    subtitle: const Text('设置6位数字密码保护应用'),
                    onTap: _setupPin,
                  ),
                ] else ...[
                  // PIN is set - show management options
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('已设置密码'),
                    subtitle: const Text('应用将在冷启动时要求验证'),
                    trailing: Icon(Icons.check_circle,
                        color: theme.colorScheme.primary),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('修改密码'),
                    onTap: _changePin,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_open),
                    title: const Text('关闭密码'),
                    onTap: _disablePin,
                  ),
                  if (_canCheckBiometrics) ...[
                    const Divider(),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('指纹/面容解锁'),
                      subtitle: const Text('使用生物识别快速解锁'),
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
                    ),
                  ],
                ],
              ],
            ),
    );
  }

  Future<void> _setupPin() async {
    final pin = await _showPinInput('设置密码');
    if (pin == null) return;

    final confirm = await _showPinInput('确认密码');
    if (confirm == null) return;

    if (pin != confirm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次输入的密码不一致')),
        );
      }
      return;
    }

    await ref.read(authViewModelProvider).savePin(pin);

    if (mounted) {
      setState(() => _hasPin = true);
      _askEnableBiometric();
    }
  }

  Future<void> _changePin() async {
    // Verify old PIN first
    final oldPin = await _showPinInput('验证当前密码');
    if (oldPin == null) return;

    final correct = await AuthService.instance.verifyPin(oldPin);
    if (!correct) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('当前密码错误')),
        );
      }
      return;
    }

    final newPin = await _showPinInput('设置新密码');
    if (newPin == null) return;

    final confirm = await _showPinInput('确认新密码');
    if (confirm == null) return;

    if (newPin != confirm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('两次输入的密码不一致')),
        );
      }
      return;
    }

    await ref.read(authViewModelProvider).savePin(newPin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码已修改')),
      );
    }
  }

  Future<void> _disablePin() async {
    // Verify identity first
    final success = await _verifyIdentity();
    if (!success) return;

    await ref.read(authViewModelProvider).clearPin();

    if (mounted) {
      setState(() {
        _hasPin = false;
        _biometricEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码已关闭')),
      );
    }
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (enabled) {
      // Verify identity before enabling
      final success = await AuthService.instance.authenticateWithBiometric(
        reason: '验证身份以启用生物识别',
      );
      if (!success) return;
    }

    await ref.read(authViewModelProvider).setBiometricEnabled(enabled);

    if (mounted) {
      setState(() => _biometricEnabled = enabled);
    }
  }

  Future<bool> _verifyIdentity() async {
    // Try biometric first if enabled
    if (_biometricEnabled && _canCheckBiometrics) {
      final success = await AuthService.instance.authenticateWithBiometric(
        reason: '验证身份',
      );
      if (success) return true;
    }

    // Fall back to PIN
    final pin = await _showPinInput('验证密码');
    if (pin == null) return false;

    return await AuthService.instance.verifyPin(pin);
  }

  Future<void> _askEnableBiometric() async {
    if (!_canCheckBiometrics) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('启用生物识别？'),
        content: const Text('是否使用指纹/面容快速解锁应用？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('跳过'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('启用'),
          ),
        ],
      ),
    );

    if (enable == true) {
      await _toggleBiometric(true);
    }
  }

  /// Show a 6-digit PIN input dialog. Returns the PIN string or null if cancelled.
  Future<String?> _showPinInput(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          obscureText: true,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 12),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '······',
          ),
          onSubmitted: (value) {
            if (value.length == 6) Navigator.pop(context, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text;
              if (text.length == 6) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/features/settings/screens/password_settings_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/screens/password_settings_screen.dart
git commit -m "feat: add PasswordSettingsScreen for PIN setup/change/disable"
```

---

### Task 6: Integrate Lock Screen into App

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Update app.dart to wrap MaterialApp with lock screen gate**

In `lib/app.dart`, replace the entire file with:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'shared/providers/user_settings_provider.dart';
import 'features/clock/providers/clock_provider.dart';
import 'features/clock/screens/clock_screen.dart';
import 'features/anniversary/screens/anniversary_list_screen.dart';
import 'features/wish/screens/wish_list_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/auth/providers/auth_provider.dart';

class ArrivalDaysApp extends ConsumerWidget {
  const ArrivalDaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final isDarkMode = settings?.isDarkMode ?? false;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return MaterialApp(
      title: 'ArrivalDays',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      locale: Locale(settings?.language ?? 'zh'),
      home: isAuthenticated
          ? const MainScreen()
          : LockScreen(
              onAuthenticated: () {
                ref.read(isAuthenticatedProvider.notifier).state = true;
              },
            ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startTimerIfNeeded();
    } else if (state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }

  void _startTimerIfNeeded() {
    if (_currentIndex == 0) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(tickerProvider.notifier).state = DateTime.now();
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      _startTimerIfNeeded();
    } else {
      _stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ClockScreen(
            onNavigateToAnniversary: null,
            onNavigateToWish: null,
          ),
          const AnniversaryListScreen(),
          const WishListScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          _navigateToTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time),
            label: '时钟',
          ),
          NavigationDestination(
            icon: Icon(Icons.celebration),
            label: '纪念日',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: '心愿',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Update main.dart to handle initial auth state**

In `lib/main.dart`, replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/auth_service.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  // If no PIN set, start authenticated (no lock screen needed)
  final hasPin = await AuthService.instance.hasPin();

  runApp(
    ProviderScope(
      overrides: [
        isAuthenticatedProvider.overrideWith((ref) => !hasPin),
      ],
      child: const ArrivalDaysApp(),
    ),
  );
}
```

Note: `StateProvider.overrideWith` takes `(ref) => initialValue` in Riverpod 2.x, so `overrideWith((ref) => !hasPin)` correctly sets the initial state.

- [ ] **Step 3: Verify no analysis errors**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart lib/main.dart
git commit -m "feat: integrate lock screen into app startup flow"
```

---

### Task 7: Update Settings Screen

**Files:**
- Modify: `lib/features/settings/screens/settings_screen.dart`

- [ ] **Step 1: Add password and data reset entries to settings screen**

In `lib/features/settings/screens/settings_screen.dart`, add import and two new ListTiles.

Add import at the top:
```dart
import 'password_settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
```

In the `build` method, after the `语言` ListTile and before `const Divider(),`, add:

```dart
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('登录密码'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PasswordSettingsScreen(),
                      ),
                    );
                  },
                ),
```

After the `数据导入` ListTile and before the final `const Divider(),`, add:

```dart
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('数据重置', style: TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetData(context),
                ),
```

Add the `_resetData` method to `_SettingsScreenState`:

```dart
  Future<void> _resetData(BuildContext context) async {
    // Verify identity if PIN is set
    final hasPin = await AuthService.instance.hasPin();
    if (hasPin) {
      final biometricEnabled = await AuthService.instance.isBiometricEnabled();
      bool verified = false;

      if (biometricEnabled) {
        verified = await AuthService.instance.authenticateWithBiometric(
          reason: '验证身份以重置数据',
        );
      }

      if (!verified) {
        if (!context.mounted) return;
        final controller = TextEditingController();
        final pin = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('验证密码'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              autofocus: true,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(counterText: ''),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('确定'),
              ),
            ],
          ),
        );
        controller.dispose();

        if (pin == null) return;
        verified = await AuthService.instance.verifyPin(pin);
        if (!verified) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('密码错误')),
            );
          }
          return;
        }
      }
    }

    // Second confirmation
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确定要清除所有数据吗？'),
        content: const Text('此操作不可恢复，所有设置和倒计时数据将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Reset all data
    await ref.read(authViewModelProvider).resetAllData();

    // Reset database
    final db = ref.read(databaseHelperProvider);
    await db.close();
    // Delete database file and reinitialize
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'arrival_days.db');
    await deleteDatabase(path);

    // Reload settings
    ref.invalidate(userSettingsProvider);
    ref.invalidate(countdownTargetsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据已重置')),
      );
    }
  }
```

This requires additional imports at the top of settings_screen.dart:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../shared/providers/countdown_targets_provider.dart';
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/features/settings/screens/settings_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/screens/settings_screen.dart
git commit -m "feat: add password settings and data reset entries to settings"
```

---

### Task 8: Update Localization

**Files:**
- Modify: `lib/l10n/app_localizations.dart`

- [ ] **Step 1: Add auth-related localization keys**

In `lib/l10n/app_localizations.dart`, add to the English `_localizedValues['en']` map:

```dart
      'loginPassword': 'Login Password',
      'dataReset': 'Reset Data',
      'setPassword': 'Set Password',
      'changePassword': 'Change Password',
      'disablePassword': 'Disable Password',
      'biometricUnlock': 'Biometric Unlock',
      'pinMismatch': 'PINs do not match',
      'pinIncorrect': 'Incorrect PIN',
      'passwordSet': 'Password set',
      'passwordChanged': 'Password changed',
      'passwordDisabled': 'Password disabled',
      'verifyIdentity': 'Verify Identity',
      'enableBiometric': 'Enable Biometric?',
      'enableBiometricDesc': 'Use fingerprint/face to quickly unlock?',
      'skip': 'Skip',
      'enable': 'Enable',
      'resetConfirmTitle': 'Delete all data?',
      'resetConfirmDesc': 'This cannot be undone. All settings and countdown data will be deleted.',
      'dataResetDone': 'Data has been reset',
```

Note: English map values are English; Chinese map values are Chinese (see below).

Add to the Chinese `_localizedValues['zh']` map:

```dart
      'loginPassword': '登录密码',
      'dataReset': '数据重置',
      'setPassword': '设置密码',
      'changePassword': '修改密码',
      'disablePassword': '关闭密码',
      'biometricUnlock': '指纹/面容解锁',
      'pinMismatch': '两次输入的密码不一致',
      'pinIncorrect': '密码错误',
      'passwordSet': '密码已设置',
      'passwordChanged': '密码已修改',
      'passwordDisabled': '密码已关闭',
      'verifyIdentity': '验证身份',
      'enableBiometric': '启用生物识别？',
      'enableBiometricDesc': '是否使用指纹/面容快速解锁应用？',
      'skip': '跳过',
      'enable': '启用',
      'resetConfirmTitle': '确定要清除所有数据吗？',
      'resetConfirmDesc': '此操作不可恢复，所有设置和倒计时数据将被删除。',
      'dataResetDone': '数据已重置',
```

Add convenience getters after the existing getters:

```dart
  String get loginPassword => translate('loginPassword');
  String get dataReset => translate('dataReset');
  String get setPassword => translate('setPassword');
  String get changePassword => translate('changePassword');
  String get disablePassword => translate('disablePassword');
  String get biometricUnlock => translate('biometricUnlock');
  String get pinMismatch => translate('pinMismatch');
  String get pinIncorrect => translate('pinIncorrect');
  String get passwordSet => translate('passwordSet');
  String get passwordChanged => translate('passwordChanged');
  String get passwordDisabled => translate('passwordDisabled');
  String get verifyIdentity => translate('verifyIdentity');
  String get enableBiometric => translate('enableBiometric');
  String get enableBiometricDesc => translate('enableBiometricDesc');
  String get skip => translate('skip');
  String get enable => translate('enable');
  String get resetConfirmTitle => translate('resetConfirmTitle');
  String get resetConfirmDesc => translate('resetConfirmDesc');
  String get dataResetDone => translate('dataResetDone');
```

- [ ] **Step 2: Verify no analysis errors**

Run: `flutter analyze lib/l10n/app_localizations.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/l10n/app_localizations.dart
git commit -m "feat: add auth-related localization strings"
```

---

### Task 9: Final Integration Test

- [ ] **Step 1: Run full analysis**

Run: `flutter analyze`
Expected: No issues found.

- [ ] **Step 2: Run all existing tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Verify the app builds**

Run: `flutter build apk --debug`
Expected: Build succeeds.

- [ ] **Step 4: Commit any fixes if needed**

If any fixes were needed:
```bash
git add -A
git commit -m "fix: address analysis/test issues from login password feature"
```
