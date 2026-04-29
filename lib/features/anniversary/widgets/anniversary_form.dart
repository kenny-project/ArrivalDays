import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';
import '../../../core/utils/countdown_utils.dart';

class AnniversaryForm extends StatefulWidget {
  final CountdownTarget? target;
  final Future<bool> Function(CountdownTarget) onSave;

  const AnniversaryForm({
    super.key,
    this.target,
    required this.onSave,
  });

  @override
  State<AnniversaryForm> createState() => _AnniversaryFormState();
}

class _AnniversaryFormState extends State<AnniversaryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _selectedDate;
  bool _isBirthday = false;
  bool _isRecurring = true;
  bool _isLunarCalendar = false;
  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target?.name ?? '');
    _selectedDate = widget.target?.useDate;
    _isBirthday = widget.target?.type == CountdownTargetType.birthday;
    _isRecurring = widget.target?.isRecurring ?? true;
    _isLunarCalendar = widget.target?.isLunarCalendar ?? false;
    _hasNotification = widget.target?.hasNotification ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.target == null ? '添加纪念日' : '编辑纪念日',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('纪念日')),
                        ButtonSegment(value: true, label: Text('生日')),
                      ],
                      selected: {_isBirthday},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _isBirthday = selected.first;
                          if (_isBirthday) {
                            _isRecurring = true;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日期'),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '请选择日期',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('每年重复'),
                value: _isRecurring,
                onChanged: _isBirthday
                    ? null
                    : (value) {
                        setState(() {
                          _isRecurring = value;
                        });
                      },
              ),
              if (_isBirthday) ...[
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('农历'),
                  value: _isLunarCalendar,
                  onChanged: (value) {
                    setState(() {
                      _isLunarCalendar = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
              if (_isLunarCalendar) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('生肖'),
                  subtitle: Text(
                    _selectedDate != null
                        ? '属${CountdownUtils.calculateZodiac(_selectedDate!.year)}'
                        : '选择日期后显示',
                  ),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('通知提醒'),
                value: _hasNotification,
                onChanged: (value) {
                  setState(() {
                    _hasNotification = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final target = CountdownTarget(
        id: widget.target?.id ?? const Uuid().v4(),
        name: _nameController.text,
        useDate: _selectedDate,
        type: _isBirthday ? CountdownTargetType.birthday : CountdownTargetType.anniversary,
        isRecurring: _isRecurring,
        isLunarCalendar: _isBirthday ? _isLunarCalendar : false,
        hasNotification: _hasNotification,
        createdAt: widget.target?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await widget.onSave(target);
    }
  }
}