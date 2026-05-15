import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';

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
      reason: AppLocalizations.of(context)?.verifyIdentityToUnlock ?? 'Verify identity to unlock',
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
          _error = AppLocalizations.of(context)?.pinIncorrect ?? 'Incorrect PIN';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

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
              loc.appTitle,
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
                  tooltip: loc.biometricUnlock,
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
