import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_settings.dart';
import '../../../shared/providers/database_providers.dart';
import '../../../core/services/export_service.dart';
import '../providers/settings_provider.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSettings();
    });
  }

  Future<void> _initSettings() async {
    if (_initialized) return;
    final settings = ref.read(userSettingsProvider);
    if (settings == null) {
      final defaultSettings = UserSettings(
        id: 'default',
        birthDate: DateTime(1990, 1, 1),
        lifeExpectancy: 80,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref.read(userSettingsProvider.notifier).saveSettings(defaultSettings);
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSectionHeader('基本信息'),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text('出生日期'),
                  subtitle: Text(_formatDate(settings.birthDate)),
                  onTap: () => _selectBirthDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('计划退休日'),
                  subtitle: Text(
                    settings.retirementDate != null
                        ? _formatDate(settings.retirementDate!)
                        : '未设置',
                  ),
                  onTap: () => _selectRetirementDate(settings),
                ),
                ListTile(
                  leading: const Icon(Icons.timeline),
                  title: const Text('预期寿命'),
                  subtitle: Text('${settings.lifeExpectancy} 岁'),
                  onTap: () => _selectLifeExpectancy(settings),
                ),
                const Divider(),
                _buildSectionHeader('外观'),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('深色主题'),
                  value: settings.isDarkMode,
                  onChanged: (_) {
                    ref.read(settingsViewModelProvider).toggleDarkMode();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('语言'),
                  subtitle: Text(settings.language == 'zh' ? '中文' : 'English'),
                  onTap: _selectLanguage,
                ),
                const Divider(),
                _buildSectionHeader('功能'),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('提醒设置'),
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
                  title: const Text('数据同步'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('数据同步功能（预留接口）')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('数据导出'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await ExportService.instance.shareExport();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('数据导入'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final success = await ExportService.instance.importFromFile();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? '导入成功' : '导入失败'),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
                _buildSectionHeader('关于'),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('版本'),
                  subtitle: Text('v1.0.0'),
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
    final controller = TextEditingController(text: settings.lifeExpectancy.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('预期寿命'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '年龄',
            hintText: '请输入预期寿命',
          ),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      ref.read(settingsViewModelProvider).updateLifeExpectancy(result);
    }
  }

  Future<void> _selectLanguage() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('选择语言'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'zh'),
            child: const Text('中文'),
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
}