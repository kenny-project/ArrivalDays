import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Standalone PIN input page — avoids showDialog widget tree issues on Android 16
class PinInputPage extends StatefulWidget {
  final String title;

  const PinInputPage({super.key, required this.title});

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  final List<int> _pin = [];

  void _onDigitPressed(int digit) {
    if (_pin.length >= 6) return;
    setState(() => _pin.add(digit));
    HapticFeedback.lightImpact();
    if (_pin.length == 6) {
      // Auto-submit after short delay so user sees the last dot
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.pop(context, _pin.join());
      });
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() => _pin.removeLast());
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                final filled = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const Spacer(flex: 1),
            // Number pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  for (final row in [
                    [1, 2, 3],
                    [4, 5, 6],
                    [7, 8, 9],
                    [-1, 0, -2],
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((digit) {
                          if (digit == -1) {
                            return const SizedBox(width: 72);
                          }
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Confirm dialog using showDialog — simpler, less likely to conflict
Future<bool> _showConfirmDialog(BuildContext context,
    {required String title, required String content}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  return result ?? false;
}

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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.loginPassword)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (!_hasPin) ...[
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(loc.setPassword),
                    subtitle: Text(loc.setPasswordDesc),
                    onTap: _setupPin,
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text(loc.passwordSetStatus),
                    subtitle: Text(loc.passwordVerifyDesc),
                    trailing: Icon(Icons.check_circle,
                        color: theme.colorScheme.primary),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text(loc.changePassword),
                    onTap: _changePin,
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_open),
                    title: Text(loc.disablePassword),
                    onTap: _disablePin,
                  ),
                  if (_canCheckBiometrics) ...[
                    const Divider(),
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: Text(loc.biometricUnlock),
                      subtitle: Text(loc.biometricUnlockDesc),
                      value: _biometricEnabled,
                      onChanged: _toggleBiometric,
                    ),
                  ],
                ],
              ],
            ),
    );
  }

  /// Navigate to PIN input page, returns the 6-digit PIN or null
  Future<String?> _navigateToPinInput(String title) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => PinInputPage(title: title)),
    );
    return result;
  }

  Future<void> _setupPin() async {
    final loc = AppLocalizations.of(context)!;
    final pin = await _navigateToPinInput(loc.setPassword);
    if (pin == null || !mounted) return;

    final confirmPin = await _navigateToPinInput(loc.confirmPassword);
    if (confirmPin == null || !mounted) return;

    if (pin != confirmPin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pinMismatch)),
        );
      }
      return;
    }

    await AuthService.instance.savePin(pin);

    if (mounted) {
      setState(() => _hasPin = true);
      await _askEnableBiometric();
      ref.invalidate(hasPinProvider);
    }
  }

  Future<void> _changePin() async {
    final loc = AppLocalizations.of(context)!;
    final oldPin = await _navigateToPinInput(loc.verifyCurrentPassword);
    if (oldPin == null || !mounted) return;

    final correct = await AuthService.instance.verifyPin(oldPin);
    if (!correct) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.currentPasswordIncorrect)),
        );
      }
      return;
    }

    final newPin = await _navigateToPinInput(loc.setNewPassword);
    if (newPin == null || !mounted) return;

    final confirmPin = await _navigateToPinInput(loc.confirmNewPassword);
    if (confirmPin == null || !mounted) return;

    if (newPin != confirmPin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.pinMismatch)),
        );
      }
      return;
    }

    await ref.read(authViewModelProvider).savePin(newPin);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.passwordChanged)),
      );
    }
  }

  Future<void> _disablePin() async {
    final loc = AppLocalizations.of(context)!;
    final success = await _verifyIdentity();
    if (!success || !mounted) return;

    await ref.read(authViewModelProvider).clearPin();

    if (mounted) {
      setState(() {
        _hasPin = false;
        _biometricEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.passwordDisabled)),
      );
    }
  }

  Future<void> _toggleBiometric(bool enabled) async {
    final loc = AppLocalizations.of(context)!;
    if (enabled) {
      final success = await AuthService.instance.authenticateWithBiometric(
        reason: loc.verifyIdentityForBiometric,
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.biometricVerifyFailed)),
          );
        }
        return;
      }
    }

    await ref.read(authViewModelProvider).setBiometricEnabled(enabled);

    if (mounted) {
      setState(() => _biometricEnabled = enabled);
    }
  }

  Future<bool> _verifyIdentity() async {
    final loc = AppLocalizations.of(context)!;
    if (_biometricEnabled && _canCheckBiometrics) {
      final success = await AuthService.instance.authenticateWithBiometric(
        reason: loc.verifyIdentity,
      );
      if (success) return true;
    }

    final pin = await _navigateToPinInput(loc.verifyPassword);
    if (pin == null) return false;

    return await AuthService.instance.verifyPin(pin);
  }

  Future<void> _askEnableBiometric() async {
    if (!_canCheckBiometrics || !mounted) return;
    final loc = AppLocalizations.of(context)!;

    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.enableBiometric),
        content: Text(loc.enableBiometricDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.skip),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.enable),
          ),
        ],
      ),
    );

    if (shouldEnable == true) {
      await _toggleBiometric(true);
    }
  }
}
