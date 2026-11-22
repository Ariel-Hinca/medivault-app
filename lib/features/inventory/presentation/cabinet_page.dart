import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_draft.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_providers.dart';
import 'package:medivault/features/inventory/presentation/medicine_form_page.dart';
import 'package:medivault/features/notifications/infrastructure/local_reminders.dart';
import 'package:medivault/features/scanning/presentation/scan_page.dart';

const _check = Color(0xFF6B3E00);

final cabinetQueryProvider = NotifierProvider<CabinetQuery, String>(
  CabinetQuery.new,
);

class CabinetQuery extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;
}

final cabinetFilterProvider =
    NotifierProvider<CabinetFilterSelection, CabinetFilter>(
      CabinetFilterSelection.new,
    );

class CabinetFilterSelection extends Notifier<CabinetFilter> {
  @override
  CabinetFilter build() => CabinetFilter.all;

  void update(CabinetFilter filter) => state = filter;
}

final cabinetListProvider = AsyncNotifierProvider<CabinetList, List<Medicine>>(
  CabinetList.new,
);

class CabinetList extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    final query = ref.watch(cabinetQueryProvider);
    final filter = ref.watch(cabinetFilterProvider);
    final repository = await ref.watch(medicineRepositoryProvider.future);
    final medicines = await repository.findAll();
    return filterCabinet(
      medicines,
      query: query,
      filter: filter,
      today: DateTime.now(),
    );
  }
}

class CabinetPage extends ConsumerStatefulWidget {
  const CabinetPage({super.key});

  @override
  ConsumerState<CabinetPage> createState() => _CabinetPageState();
}

class _CabinetPageState extends ConsumerState<CabinetPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cabinet = ref.watch(cabinetListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('MediVault')),
      body: cabinet.when(
        loading: () => const _Opening(),
        error: (error, _) => _OpenError(
          message: _openMessage(error),
          onTryAgain: () {
            ref.invalidate(medicineRepositoryProvider);
            _reloadCabinet();
          },
        ),
        data: (medicines) => _CabinetBody(
          medicines: medicines,
          search: _search,
          onSearch: (value) {
            ref.read(cabinetQueryProvider.notifier).update(value);
          },
          onFilter: (filter) {
            ref.read(cabinetFilterProvider.notifier).update(filter);
          },
          filter: ref.watch(cabinetFilterProvider),
          onOpen: _openMedicine,
          onScan: _openScan,
          onAdd: () => _openMedicine(null),
        ),
      ),
    );
  }

  Future<void> _openMedicine(Medicine? medicine) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => MedicineFormPage(
          medicineId: medicine?.id,
          draft: medicine == null
              ? const MedicineDraft()
              : draftFromMedicine(medicine),
        ),
      ),
    );
    if (saved == true) {
      _reloadCabinet();
    }
  }

  Future<void> _openScan() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const ScanPage()),
    );
    if (saved == true) {
      _reloadCabinet();
    }
  }

  void _reloadCabinet() {
    ref.invalidate(cabinetListProvider);
    ref.invalidate(reminderSyncProvider);
  }
}

String _openMessage(Object error) {
  if (error is Failure && error.code == 'device_credential_required') {
    return 'Use your fingerprint, face, or PIN to open the cabinet.';
  }
  return 'The cabinet could not be opened.';
}

class _Opening extends StatelessWidget {
  const _Opening();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(semanticsLabel: 'Opening the cabinet'),
          SizedBox(height: 24),
          Text('Opening the cabinet.'),
        ],
      ),
    );
  }
}

class _OpenError extends StatelessWidget {
  const _OpenError({required this.message, required this.onTryAgain});

  final String message;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: onTryAgain,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinetBody extends StatelessWidget {
  const _CabinetBody({
    required this.medicines,
    required this.search,
    required this.onSearch,
    required this.onFilter,
    required this.filter,
    required this.onOpen,
    required this.onScan,
    required this.onAdd,
  });

  final List<Medicine> medicines;
  final TextEditingController search;
  final ValueChanged<String> onSearch;
  final ValueChanged<CabinetFilter> onFilter;
  final CabinetFilter filter;
  final ValueChanged<Medicine> onOpen;
  final VoidCallback onScan;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searching =
        search.text.trim().isNotEmpty || filter != CabinetFilter.all;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            controller: search,
            onChanged: onSearch,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Search medicines',
              border: OutlineInputBorder(),
            ),
            style: theme.textTheme.bodyLarge,
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            children: [
              for (final item in CabinetFilter.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filterLabel(item)),
                    selected: filter == item,
                    onSelected: (_) => onFilter(item),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: medicines.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      searching ? 'No medicines match.' : 'Your cabinet is empty. Scan a pack or add a medicine.',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: medicines.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return _MedicineRow(
                      medicine: medicine,
                      onOpen: () => onOpen(medicine),
                    );
                  },
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
                  onPressed: onScan,
                  child: const Text('Scan a pack'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: onAdd,
                  child: const Text('Add a medicine'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({required this.medicine, required this.onOpen});

  final Medicine medicine;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = medicine.strength;
    final amount = strength == null
        ? null
        : '${formatMilliUnits(strength.milli)} ${strength.unit.name}';
    final quantity =
        '${formatMilliUnits(medicine.quantity.milli)} ${_quantityLabel(medicine.quantity.unit)}';
    final expiry = _expiry(medicine.expiration);
    final warning = _warning(
      expirationBand(medicine.expiration, DateTime.now()),
    );
    final summary = [
      medicine.name,
      ?amount,
      quantity,
      expiry,
      ?warning,
      if (medicine.keptFor != null) 'For ${medicine.keptFor}',
    ].join('. ');

    return Semantics(
      button: true,
      label: summary,
      excludeSemantics: true,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicine.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                amount == null ? quantity : '$amount · $quantity',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(expiry, style: theme.textTheme.bodyLarge),
              if (warning != null)
                Text(
                  warning,
                  style: theme.textTheme.bodyLarge?.copyWith(color: _check),
                ),
              if (medicine.keptFor != null)
                Text(
                  'For ${medicine.keptFor}',
                  style: theme.textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _filterLabel(CabinetFilter filter) {
  return switch (filter) {
    CabinetFilter.all => 'All',
    CabinetFilter.expired => 'Expired',
    CabinetFilter.next7Days => 'Within 7 days',
    CabinetFilter.next30Days => 'Within 30 days',
    CabinetFilter.next90Days => 'Within 90 days',
  };
}

String _quantityLabel(QuantityUnit unit) {
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

String _expiry(ExpirationDate date) {
  final month = date.month.toString().padLeft(2, '0');
  if (date.day == null) {
    return '$month/${date.year}';
  }
  final day = date.day!.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String? _warning(ExpirationBand band) {
  return switch (band) {
    ExpirationBand.expired => 'Expired',
    ExpirationBand.within7Days => 'Use within 7 days',
    ExpirationBand.within30Days => 'Use within 30 days',
    ExpirationBand.within90Days => 'Use within 90 days',
    ExpirationBand.later => null,
  };
}
