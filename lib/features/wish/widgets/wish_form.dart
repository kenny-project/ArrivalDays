import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/countdown_target.dart';

class WishForm extends StatefulWidget {
  final CountdownTarget? target;
  final Function(CountdownTarget) onSave;

  const WishForm({
    super.key,
    this.target,
    required this.onSave,
  });

  @override
  State<WishForm> createState() => _WishFormState();
}

class _WishFormState extends State<WishForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _selectedDate;
  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target?.name ?? '');
    _selectedDate = widget.target?.targetDate;
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
                widget.target == null ? '添加心愿' : '编辑心愿',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '心愿名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入心愿名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('目标日期（可选）'),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : '无日期',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final target = CountdownTarget(
        id: widget.target?.id ?? const Uuid().v4(),
        name: _nameController.text,
        targetDate: _selectedDate,
        type: CountdownTargetType.wish,
        isCompleted: widget.target?.isCompleted ?? false,
        completedAt: widget.target?.completedAt,
        hasNotification: _hasNotification,
        createdAt: widget.target?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(target);
    }
  }
}