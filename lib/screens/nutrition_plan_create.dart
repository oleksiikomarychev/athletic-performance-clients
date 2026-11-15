import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/src/api/nutrition_api.dart';
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class NutritionPlanCreate extends StatefulWidget {
  final Map<String, dynamic>? initialPlan;

  const NutritionPlanCreate({super.key, this.initialPlan});

  @override
  State<NutritionPlanCreate> createState() => _NutritionPlanCreateState();
}

class _NutritionPlanCreateState extends State<NutritionPlanCreate> {
  final _formKey = GlobalKey<FormState>();
  final _sessionIdController = TextEditingController(
    text: DateTime.now().millisecondsSinceEpoch.toString(),
  );
  final _userIdController = TextEditingController(text: '1');
  final _workoutIdController = TextEditingController();
  final _appliedPlanWorkoutIdController = TextEditingController();

  List<Map<String, dynamic>> _foodList = [];
  List<Map<String, dynamic>> _supplementList = [];
  List<Map<String, dynamic>> _medicationList = [];
  List<Map<String, dynamic>> _selectedEntries = [];
  final Set<String> _expandedCategories = {'food'};

  bool _isLoading = false;
  bool _isLoadingItems = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadItems();
    if (widget.initialPlan != null) {
      _sessionIdController.text =
          widget.initialPlan!['session_id']?.toString() ?? '';
      _userIdController.text =
          widget.initialPlan!['user_id']?.toString() ?? '1';
      _workoutIdController.text =
          widget.initialPlan!['workout_id']?.toString() ?? '';
      _appliedPlanWorkoutIdController.text =
          widget.initialPlan!['applied_plan_workout_id']?.toString() ?? '';
      final rawDate = widget.initialPlan!['date']?.toString();
      if (rawDate != null && rawDate.isNotEmpty) {
        final parsed = DateTime.tryParse(rawDate);
        if (parsed != null) _selectedDate = parsed;
      }
      _selectedEntries = List<Map<String, dynamic>>.from(
        widget.initialPlan!['entries'] ?? const [],
      );
    }
  }

  @override
  void dispose() {
    _sessionIdController.dispose();
    _userIdController.dispose();
    _workoutIdController.dispose();
    _appliedPlanWorkoutIdController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoadingItems = true);

    try {
      final food = await NutritionApi.getAllFood();
      final supplements = await NutritionApi.getAllSupplements();
      final medications = await NutritionApi.getAllMedications();

      if (mounted) {
        setState(() {
          _foodList = food;
          _supplementList = supplements;
          _medicationList = medications;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingItems = false);
        showAppSnackBar(context, 'Error loading items: $e', isError: true);
      }
    }
  }

  Future<void> _addEntry(Map<String, dynamic> item, String type) async {
    final dosageController = TextEditingController(
      text: item['dosage']?.toString() ?? '',
    );

    final result = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: type.toUpperCase(),
      title: 'Add ${item['name'] ?? 'Item'}',
      content: TextField(
        controller: dosageController,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        decoration: InstrumentTheme.inputDecoration(
          context,
          labelText: 'Dosage (${item['unit'] ?? ''})',
          hintText: item['dosage']?.toString(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
      actions: [
        InstrumentActionButton(
          label: 'Cancel',
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.pop(context, false),
        ),
        InstrumentActionButton(
          label: 'Add',
          icon: Icons.add_rounded,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (result == true && mounted) {
      final newDosage = double.tryParse(
        dosageController.text.trim().replaceAll(',', '.'),
      );
      if (newDosage != null && newDosage > 0) {
        setState(() {
          _selectedEntries.add({...item, 'type': type, 'dosage': newDosage});
        });
      }
    }

    dosageController.dispose();
  }

  void _removeEntry(int index) {
    setState(() {
      _selectedEntries.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEntries.isEmpty) {
      showAppSnackBar(
        context,
        'Please add at least one entry',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = int.tryParse(_userIdController.text) ?? 1;
      final sessionId = _sessionIdController.text;
      final workoutId = int.tryParse(_workoutIdController.text);
      final appliedPlanWorkoutId = int.tryParse(
        _appliedPlanWorkoutIdController.text,
      );
      final date = _selectedDate.toIso8601String();

      final Map<String, dynamic>? result;
      if (widget.initialPlan != null) {
        result = await NutritionApi.updateSession(
          sessionId,
          userId: userId,
          entries: _selectedEntries,
          workoutId: workoutId,
          appliedPlanWorkoutId: appliedPlanWorkoutId,
          date: date,
        );
      } else {
        result = await NutritionApi.createSession(
          userId: userId,
          sessionId: sessionId,
          entries: _selectedEntries,
          workoutId: workoutId,
          appliedPlanWorkoutId: appliedPlanWorkoutId,
          date: date,
        );
      }

      if (!mounted) return;
      showAppSnackBar(
        context,
        widget.initialPlan != null
            ? 'Session updated successfully'
            : 'Session created successfully',
      );
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'nutrition_plan_create',
        'is_editing': widget.initialPlan != null,
        'entities': {'selected_entries_count': _selectedEntries.length},
      },
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);
        final tabularStyle = theme.textTheme.bodyLarge?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        );

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: widget.initialPlan != null
                ? 'Edit Nutrition Session'
                : 'Create Nutrition Session',
            onTitleTap: openChat,
            showBack: true,
            actions: [
              IconButton(
                onPressed: _isLoading ? null : _save,
                icon: const Icon(Icons.check_rounded),
                tooltip: 'Save',
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                topInset + 8,
                16,
                bottomInset + 28,
              ),
              children: [
                _NutritionFormCard(
                  eyebrow: '01 · SESSION CONFIG',
                  title: 'Session Configuration',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final sessionIdField = TextFormField(
                            controller: _sessionIdController,
                            style: tabularStyle,
                            decoration: InstrumentTheme.inputDecoration(
                              context,
                              labelText: 'Session ID',
                            ),
                            validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                          );
                          final userIdField = TextFormField(
                            controller: _userIdController,
                            style: tabularStyle,
                            decoration: InstrumentTheme.inputDecoration(
                              context,
                              labelText: 'User ID',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value?.isEmpty == true ? 'Required' : null,
                          );

                          if (constraints.maxWidth < 300) {
                            return Column(
                              children: [
                                sessionIdField,
                                const SizedBox(height: 12),
                                userIdField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: sessionIdField),
                              const SizedBox(width: 12),
                              Expanded(child: userIdField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _workoutIdController,
                        style: tabularStyle,
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: 'Workout ID (optional)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _appliedPlanWorkoutIdController,
                        style: tabularStyle,
                        decoration: InstrumentTheme.inputDecoration(
                          context,
                          labelText: 'Applied Plan Workout ID (optional)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: InputDecorator(
                            decoration: InstrumentTheme.inputDecoration(
                              context,
                              labelText: 'Date',
                              suffixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: instrument.workingAura,
                              ),
                            ),
                            child: Text(
                              _selectedDate.toLocal().toString().split(' ').first,
                              style: tabularStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _NutritionFormCard(
                  eyebrow: '02 · SELECTED INTAKE (${_selectedEntries.length})',
                  title: 'Selected Entries',
                  accentColor: instrument.deloadAura,
                  flushBody: true,
                  child: _selectedEntries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No entries selected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < _selectedEntries.length; i++) ...[
                              if (i > 0)
                                Container(
                                  height: 1,
                                  color: instrument.hairlineBorder,
                                ),
                              _SelectedEntryRow(
                                item: _selectedEntries[i],
                                onRemove: () => _removeEntry(i),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                _NutritionFormCard(
                  eyebrow: '03 · CATALOG',
                  title: 'Available Items',
                  flushBody: true,
                  child: _isLoadingItems
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: LoadingIndicator(),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCollapsibleCategory(
                              context,
                              title: 'Food',
                              items: _foodList,
                              type: 'food',
                              isFirst: true,
                            ),
                            _buildCollapsibleCategory(
                              context,
                              title: 'Supplements',
                              items: _supplementList,
                              type: 'supplement',
                            ),
                            _buildCollapsibleCategory(
                              context,
                              title: 'Medications',
                              items: _medicationList,
                              type: 'medication',
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                InstrumentActionButton(
                  label: widget.initialPlan != null
                      ? 'Update Session'
                      : 'Create Session',
                  icon: Icons.check_rounded,
                  expanded: true,
                  loading: _isLoading,
                  onPressed: _isLoading ? null : _save,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollapsibleCategory(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> items,
    required String type,
    bool isFirst = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final expanded = _expandedCategories.contains(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isFirst) Container(height: 1, color: instrument.hairlineBorder),
        InkWell(
          onTap: () {
            setState(() {
              if (expanded) {
                _expandedCategories.remove(type);
              } else {
                _expandedCategories.add(type);
              }
            });
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${items.length}',
                    style: InstrumentTheme.microLabel(context).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded) ...[
          Container(height: 1, color: instrument.hairlineBorder),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                'No items available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) Container(height: 1, color: instrument.hairlineBorder),
              _CatalogItemRow(
                item: items[i],
                onAdd: () => _addEntry(items[i], type),
              ),
            ],
        ],
      ],
    );
  }
}

class _NutritionFormCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;
  final Color? accentColor;
  final bool flushBody;

  const _NutritionFormCard({
    required this.eyebrow,
    required this.title,
    required this.child,
    this.accentColor,
    this.flushBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: accentColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: InstrumentTheme.microLabel(
                    context,
                    color: accentColor,
                  ).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: instrument.hairlineBorder),
          if (flushBody)
            child
          else
            Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _SelectedEntryRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  const _SelectedEntryRow({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['type']} · ${item['dosage']} ${item['unit'] ?? ''}'
                      .trim(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: IconButton(
              icon: Icon(
                Icons.remove_circle_outline_rounded,
                color: instrument.peakEffortColor,
              ),
              tooltip: 'Remove entry',
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;

  const _CatalogItemRow({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return InkWell(
      onTap: onAdd,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? 'Unknown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item['dosage'] ?? '—'} ${item['unit'] ?? ''}'.trim(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: instrument.workingAura,
                ),
                tooltip: 'Add entry',
                onPressed: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
