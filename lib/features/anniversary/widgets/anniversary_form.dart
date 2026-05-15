import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../l10n/app_localizations.dart';
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
  bool _showDateError = false;

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
    final loc = AppLocalizations.of(context)!;

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
                widget.target == null ? loc.addAnniversary : loc.editAnniversary,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.name,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.enterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: false, label: Text(loc.anniversary)),
                        ButtonSegment(value: true, label: Text(loc.birthday)),
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
                title: Text(loc.date),
                subtitle: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : loc.selectDate,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              if (_showDateError && _selectedDate == null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    loc.selectDate,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.recurring),
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
                  title: Text(loc.translate('lunarSuffix').replaceAll('(', '').replaceAll(')', '')),
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
                  title: Text(loc.zodiac),
                  subtitle: Text(
                    _selectedDate != null
                        ? CountdownUtils.calculateZodiac(_selectedDate!.year)
                        : loc.selectDateFirst,
                  ),
                ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.notification),
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
                    child: Text(loc.cancel),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _save,
                    child: Text(loc.save),
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
        _showDateError = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      setState(() => _showDateError = true);
      return;
    }

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