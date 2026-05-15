import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/user_settings.dart';
import '../../../shared/providers/user_settings_provider.dart';
import '../../../core/services/export_service.dart';
import '../providers/settings_provider.dart';
import 'notification_settings_screen.dart';
import 'password_settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import '../../../shared/providers/countdown_targets_provider.dart' hide databaseHelperProvider;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // debug: Log.i(LogTag.ui, 'SettingsScreen initState');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final settings = ref.watch(userSettingsProvider);
    // debug: Log.i(LogTag.ui, 'SettingsScreen settings: ${settings?.birthDate}');

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader(loc.basicInfo),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: Text(loc.birthDate),
                  subtitle: Text(_formatDate(settings.birthDate)),
                  onTap: () => _selectBirthDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: Text(loc.retirementDate),
                  subtitle: Text(
                    settings.retirementDate != null
                        ? _formatDate(settings.retirementDate!)
                        : loc.notSet,
                  ),
                  onTap: () => _selectRetirementDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: Text(loc.lifeExpectancy),
                  subtitle: Text('${settings.lifeExpectancy} ${loc.age}'),
                  onTap: () => _selectLifeExpectancy(settings),
                ),
                const Divider(),
                _buildSectionHeader(loc.appearance),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: Text(loc.darkMode),
                  value: settings.isDarkMode,
                  onChanged: (_) {
                    ref.read(settingsViewModelProvider).toggleDarkMode();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(loc.language),
                  subtitle: Text(
                    settings.language == 'system'
                        ? loc.followSystem
                        : settings.language == 'zh'
                            ? loc.chinese
                            : 'English',
                  ),
                  onTap: _selectLanguage,
                ),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(loc.loginPassword),
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
                const Divider(),
                _buildSectionHeader(loc.features),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(loc.notificationSettings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: Text(loc.dataSync),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.dataSyncPlaceholder)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: Text(loc.dataExport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await ExportService.instance.shareExport();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: Text(loc.dataImport),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final success = await ExportService.instance.importFromFile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? loc.importSuccess : loc.importFail),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(loc.dataReset, style: const TextStyle(color: Colors.red)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _resetData(context),
                ),
                const Divider(),
                _buildSectionHeader(loc.about),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(loc.version),
                  subtitle: const Text('v1.0.0'),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectBirthDate(UserSettings settings) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      ref.read(settingsViewModelProvider).updateBirthDate(date);
    }
  }

  Future<void> _selectRetirementDate(UserSettings settings) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.retirementDate ?? DateTime.now().add(const Duration(days: 365 * 20)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      ref.read(settingsViewModelProvider).updateRetirementDate(date);
    }
  }

  Future<void> _selectLifeExpectancy(UserSettings settings) async {
    final loc = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: settings.lifeExpectancy.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.lifeExpectancy),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.ageHint,
            hintText: loc.enterLifeExpectancy,
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      ref.read(settingsViewModelProvider).updateLifeExpectancy(result);
    }
  }

  Future<void> _selectLanguage() async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(loc.selectLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'system'),
            child: Text(loc.followSystem),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'zh'),
            child: Text(loc.chinese),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'en'),
            child: const Text('English'),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(settingsViewModelProvider).updateLanguage(result);
    }
  }

  Future<void> _resetData(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    // Verify identity if PIN is set
    final hasPin = await AuthService.instance.hasPin();
    if (hasPin) {
      final biometricEnabled = await AuthService.instance.isBiometricEnabled();
      bool verified = false;

      if (biometricEnabled) {
        verified = await AuthService.instance.authenticateWithBiometric(
          reason: loc.verifyIdentityToReset,
        );
      }

      if (!verified) {
        if (!context.mounted) return;
        final controller = TextEditingController();
        final pin = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.verifyPassword),
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
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(loc.confirm),
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
              SnackBar(content: Text(loc.pinIncorrect)),
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
        title: Text(loc.resetConfirmTitle),
        content: Text(loc.resetConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.confirm, style: const TextStyle(color: Colors.red)),
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
        SnackBar(content: Text(loc.dataResetDone)),
      );
    }
  }
}