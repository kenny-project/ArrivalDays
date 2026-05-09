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
