import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_draft.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_providers.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';

const _check = Color(0xFF6B3E00);

MedicineDraft draftFromReading(LabelReading reading) {
  final expiration = reading.expiration?.value;
  final strength = reading.strength?.value;
  return MedicineDraft(
    name: reading.name?.value ?? '',
    strengthAmount: strength == null ? '' : formatMilliUnits(strength.milli),
    strengthUnit: strength?.unit,
    dosage: reading.dosage?.value ?? '',
    year: expiration == null ? '' : '${expiration.year}',
    month: expiration == null ? '' : '${expiration.month}',
    day: expiration?.day?.toString() ?? '',
    batch: reading.batchNumber?.value ?? '',
  );
}

class MedicineFormPage extends ConsumerStatefulWidget {
  const MedicineFormPage({required this.draft, this.medicineId, super.key});

  final MedicineDraft draft;
  final String? medicineId;

  @override
  ConsumerState<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends ConsumerState<MedicineFormPage> {
  late final TextEditingController _name;
  late final TextEditingController _strength;
  late final TextEditingController _dosage;
  late final TextEditingController _year;
  late final TextEditingController _day;
  late final TextEditingController _batch;
  late final TextEditingController _quantity;
  late final TextEditingController _keptFor;
  late StrengthUnit? _strengthUnit;
  late int? _month;
  late QuantityUnit _quantityUnit;
  var _invalid = <DraftField>{};
  var _message = '';
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draft;
    _name = TextEditingController(text: draft.name);
    _strength = TextEditingController(text: draft.strengthAmount);
    _dosage = TextEditingController(text: draft.dosage);
    _year = TextEditingController(text: draft.year);
    _day = TextEditingController(text: draft.day);
    _batch = TextEditingController(text: draft.batch);
    _quantity = TextEditingController(text: draft.quantityAmount);
    _keptFor = TextEditingController(text: draft.keptFor);
    _strengthUnit = draft.strengthUnit;
    _month = int.tryParse(draft.month);
    _quantityUnit = draft.quantityUnit;
  }

  @override
  void dispose() {
    _name.dispose();
    _strength.dispose();
    _dosage.dispose();
    _year.dispose();
    _day.dispose();
    _batch.dispose();
    _quantity.dispose();
    _keptFor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.medicineId != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit medicine' : 'Add a medicine')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (_message.isNotEmpty) ...[
                  Text(
                    _message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                _text(
                  label: 'Medicine name',
                  controller: _name,
                  field: DraftField.name,
                  capitalization: TextCapitalization.words,
                ),
                _text(
                  label: 'Strength',
                  controller: _strength,
                  field: DraftField.strength,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _unit<StrengthUnit>(
                  label: 'Strength unit',
                  value: _strengthUnit,
                  values: StrengthUnit.values,
                  labelOf: _strengthUnitLabel,
                  none: 'No strength',
                  onChanged: (value) => setState(() => _strengthUnit = value),
                ),
                _text(
                  label: 'Dosage',
                  controller: _dosage,
                  field: DraftField.dosage,
                ),
                _monthField(),
                _text(
                  label: 'Expiry year',
                  controller: _year,
                  field: DraftField.expiration,
                  keyboard: TextInputType.number,
                ),
                _text(
                  label: 'Expiry day',
                  controller: _day,
                  field: DraftField.expiration,
                  keyboard: TextInputType.number,
                  helper: 'Leave this empty if the pack only shows a month.',
                ),
                _text(
                  label: 'Batch number',
                  controller: _batch,
                  field: DraftField.batch,
                ),
                _text(
                  fieldKey: const Key('quantity'),
                  label: 'Quantity',
                  controller: _quantity,
                  field: DraftField.quantity,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _unit<QuantityUnit>(
                  label: 'Quantity unit',
                  value: _quantityUnit,
                  values: QuantityUnit.values,
                  labelOf: _quantityUnitLabel,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _quantityUnit = value);
                    }
                  },
                ),
                _text(
                  label: 'Who is this for?',
                  controller: _keptFor,
                  field: DraftField.keptFor,
                  capitalization: TextCapitalization.words,
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving' : 'Save'),
                  ),
                  if (editing) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      onPressed: _saving ? null : _remove,
                      child: const Text('Remove from cabinet'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _text({
    Key? fieldKey,
    required String label,
    required TextEditingController controller,
    required DraftField field,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    String? helper,
  }) {
    final marked = _invalid.contains(field);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        key: fieldKey,
        controller: controller,
        keyboardType: keyboard,
        textCapitalization: capitalization,
        autocorrect: false,
        enableSuggestions: false,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          helperText: marked ? 'Check this' : helper,
          helperStyle: marked
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: _check)
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _monthField() {
    final marked = _invalid.contains(DraftField.expiration);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        key: const Key('expiry-month'),
        initialValue: _month,
        decoration: InputDecoration(
          labelText: 'Expiry month',
          helperText: marked ? 'Check this' : null,
          helperStyle: marked
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(color: _check)
              : null,
          border: const OutlineInputBorder(),
        ),
        items: [
          for (var month = 1; month <= 12; month++)
            DropdownMenuItem(value: month, child: Text(_monthLabel(month))),
        ],
        onChanged: (value) => setState(() => _month = value),
      ),
    );
  }

  Widget _unit<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T value) labelOf,
    required ValueChanged<T?> onChanged,
    String? none,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T?>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: [
          if (none != null) DropdownMenuItem(value: null, child: Text(none)),
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(labelOf(item))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _save() async {
    final result = compileDraft(
      MedicineDraft(
        name: _name.text,
        strengthAmount: _strength.text,
        strengthUnit: _strengthUnit,
        dosage: _dosage.text,
        year: _year.text,
        month: _month == null ? '' : '$_month',
        day: _day.text,
        batch: _batch.text,
        quantityAmount: _quantity.text,
        quantityUnit: _quantityUnit,
        keptFor: _keptFor.text,
      ),
      id: widget.medicineId,
      updatedAt: DateTime.now(),
    );
    if (result.medicine == null) {
      setState(() {
        _invalid = result.invalid;
        _message = 'Some details need a correction before this can be saved.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _invalid = {};
      _message = '';
    });
    try {
      final repository = await ref.read(medicineRepositoryProvider.future);
      await repository.save(result.medicine!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _message = 'This medicine could not be saved.';
      });
    }
  }

  Future<void> _remove() async {
    final name = _name.text.trim();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove this medicine?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name.isEmpty
                    ? 'It will leave the cabinet. This cannot be undone.'
                    : '$name will leave the cabinet. This cannot be undone.',
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep it'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = await ref.read(medicineRepositoryProvider.future);
      await repository.delete(widget.medicineId!);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _message = 'This medicine could not be removed.';
      });
    }
  }
}

String _monthLabel(int month) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${month.toString().padLeft(2, '0')} ${names[month - 1]}';
}

String _strengthUnitLabel(StrengthUnit unit) {
  return switch (unit) {
    StrengthUnit.mg => 'mg',
    StrengthUnit.g => 'g',
    StrengthUnit.mcg => 'mcg',
    StrengthUnit.ml => 'ml',
    StrengthUnit.iu => 'IU',
  };
}

String _quantityUnitLabel(QuantityUnit unit) {
  return switch (unit) {
    QuantityUnit.tablet => 'tablets',
    QuantityUnit.capsule => 'capsules',
    QuantityUnit.ml => 'ml',
    QuantityUnit.g => 'g',
    QuantityUnit.piece => 'pieces',
    QuantityUnit.dose => 'doses',
    QuantityUnit.other => 'other',
  };
}
