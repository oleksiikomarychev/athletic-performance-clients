import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_summary.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/public_user_profile_screen.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/coach_rating_display.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

class AllUsersScreen extends ConsumerStatefulWidget {
  const AllUsersScreen({super.key});

  @override
  ConsumerState<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends ConsumerState<AllUsersScreen> {
  bool _filterCoaches = false;
  UserFilters _filters = const UserFilters();

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(
      filteredUsersProvider(_filters.copyWith(coach: _filterCoaches)),
    );
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    final hasExtraFilters =
        (_filters.specializations?.isNotEmpty ?? false) ||
        (_filters.languages?.isNotEmpty ?? false) ||
        _filters.minRate != null ||
        _filters.maxRate != null ||
        (_filters.sortBy != null && _filters.sortBy != 'created_at');

    return AssistantChatHost(
      initialMessage:
          'Opening assistant from AllUsersScreen. Helping select a coach or find a profile in the user directory.',
      contextBuilder: () async => <String, dynamic>{
        'v': 1,
        'app': 'WorkoutApp',
        'screen': 'all_users',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'selection': <String, dynamic>{
          'coaches_only': _filterCoaches,
          'sort_by': _filters.sortBy ?? 'created_at',
          'specializations': _filters.specializations,
          'languages': _filters.languages,
        },
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: l10n.allUsersTitle,
            onTitleTap: openChat,
            actions: [
              if (_filterCoaches)
                IconButton(
                  icon: const Icon(Icons.tune),
                  tooltip: l10n.filterCoachesLabel,
                  onPressed: _showFilterBottomSheet,
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(filteredUsersProvider);
            },
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(dims.pagePadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 40,
                        color: instrument.peakEffortColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.failedToLoadData('$error'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      InstrumentActionButton(
                        label: l10n.retry,
                        icon: Icons.refresh,
                        variant: InstrumentActionVariant.primary,
                        onPressed: () => ref.invalidate(filteredUsersProvider),
                      ),
                    ],
                  ),
                ),
              ),
              data: (users) => _buildContent(users, hasExtraFilters),
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    final l10n = AppLocalizations.of(context);
    showInstrumentBottomSheet<void>(
      context: context,
      eyebrow: l10n.coachDirectoryEyebrow,
      title: l10n.filterCoachesTitle,
      builder: (sheetCtx) => _FilterBottomSheet(
        filters: _filters,
        onApply: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          Navigator.of(sheetCtx).pop();
        },
        onClear: () {
          setState(() {
            _filters = const UserFilters();
          });
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }

  Widget _buildContent(List<UserSummary> users, bool hasExtraFilters) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    final publicCount = users.where((u) => u.isPublic).length;
    final coachCount = users.where((u) => u.coachingEnabled == true).length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        0,
        AmbientScaffoldShell.topContentInset(context),
        0,
        AmbientScaffoldShell.bottomContentInset(context),
      ),
      children: [
        CanvasPillStrip(
          padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
          items: [
            CanvasPillItem(
              key: const ValueKey('role_all'),
              label: AppLocalizations.of(context).allUsersPillLabel,
              icon: Icons.people_outline,
              selected: !_filterCoaches,
              onTap: () {
                setState(() {
                  _filterCoaches = false;
                  _filters = const UserFilters();
                });
              },
            ),
            CanvasPillItem(
              key: const ValueKey('role_coaches'),
              label: AppLocalizations.of(context).coachesOnlyPillLabel,
              icon: Icons.workspace_premium_outlined,
              selected: _filterCoaches,
              accentColor: instrument.successColor,
              onTap: () {
                setState(() {
                  _filterCoaches = true;
                  _filters = const UserFilters();
                });
              },
            ),
            if (_filterCoaches)
              CanvasPillItem(
                key: const ValueKey('coach_filters'),
                label: hasExtraFilters
                    ? AppLocalizations.of(context).filtersActiveLabel
                    : AppLocalizations.of(context).filterCoachesLabel,
                icon: Icons.tune,
                selected: hasExtraFilters,
                accentColor: instrument.moderateEffortColor,
                onTap: _showFilterBottomSheet,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
          child: Container(
            decoration: InstrumentTheme.instrumentCardDecoration(
              context,
              radius: 20,
            ),
            padding: EdgeInsets.all(dims.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).coachDirectoryEyebrow,
                  style: InstrumentTheme.microLabel(context),
                ),
                const SizedBox(height: 10),
                InstrumentMetricMatrix(
                  cells: [
                    InstrumentMetricCellData(
                      slot: MetricSlot.setsCount,
                      label: AppLocalizations.of(context).showingUpperLabel,
                      value: '${users.length}',
                      valueColor: instrument.workingAura,
                    ),
                    InstrumentMetricCellData(
                      slot: MetricSlot.kpsh,
                      label: AppLocalizations.of(context).publicUpperLabel,
                      value: '$publicCount',
                      valueColor: instrument.successColor,
                    ),
                    InstrumentMetricCellData(
                      slot: MetricSlot.frequencyPerWeek,
                      label: AppLocalizations.of(context).coachesUpperLabel,
                      value: '$coachCount',
                    ),
                    InstrumentMetricCellData(
                      slot: MetricSlot.density,
                      label: AppLocalizations.of(context).sortUpperLabel,
                      value: (_filters.sortBy ?? 'created_at').toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          Padding(
            padding: EdgeInsets.all(dims.pagePadding * 2),
            child: Center(
              child: Text(
                'No users yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          for (final user in users) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: dims.pagePadding),
              child: _buildUserCard(user, hairline),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _buildUserCard(UserSummary user, Color hairline) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!.substring(0, 1).toUpperCase()
        : (user.userId.isNotEmpty
              ? user.userId.substring(0, 1).toUpperCase()
              : '?');

    final parts = <String>[
      'Created ${DateFormat('dd.MM.yyyy HH:mm').format(user.createdAt.toLocal())}',
    ];
    if (user.coachingEnabled == true) {
      if (user.rateAmountMinor != null) {
        final rate = user.rateAmountMinor! / 100;
        parts.add('${rate.toStringAsFixed(0)} USD/mo');
      }
      if (user.specializations.isNotEmpty) {
        parts.add(user.specializations.take(2).join(', '));
      }
    }
    final hasRating =
        user.coachingEnabled == true &&
        user.averageRating != null &&
        (user.reviewCount ?? 0) > 0;

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: user.coachingEnabled == true
            ? instrument.workingAura
            : null,
        radius: 20,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.uid == user.userId) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PublicUserProfileScreen(
                  userId: user.userId,
                  initialName: user.displayName,
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(dims.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: instrument.workingAura.withValues(alpha: 0.16),
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(
                        initial,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: instrument.workingAura,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            user.displayName ?? 'User ${user.userId}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          user.isPublic ? Icons.lock_open : Icons.lock_outline,
                          size: 16,
                          color: user.isPublic
                              ? instrument.successColor
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      parts.join(' · '),
                      style: InstrumentTheme.tabular(
                        (theme.textTheme.bodySmall ?? const TextStyle())
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    if (hasRating) ...[
                      const SizedBox(height: 8),
                      CoachRatingDisplay(
                        averageRating: user.averageRating,
                        reviewCount: user.reviewCount,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final UserFilters filters;
  final ValueChanged<UserFilters> onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.filters,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late UserFilters _filters;
  final _minRateController = TextEditingController();
  final _maxRateController = TextEditingController();
  String _sortBy = 'created_at';

  static const Map<String, String> _languageOptions = {
    'en': 'English',
    'ua': 'Ukrainian',
    'ru': 'Russian',
    'pl': 'Polish',
    'de': 'German',
  };

  static const Map<String, String> _specializationOptions = {
    'strength': 'Strength Training',
    'hypertrophy': 'Hypertrophy',
    'weight_loss': 'Weight Loss',
    'endurance': 'Endurance',
    'powerlifting': 'Powerlifting',
    'bodybuilding': 'Bodybuilding',
    'functional': 'Functional Training',
    'rehabilitation': 'Rehabilitation',
    'nutrition': 'Nutrition Coaching',
    'online': 'Online Coaching',
    'in_person': 'In-Person Training',
    'youth': 'Youth Training',
    'senior': 'Senior Fitness',
    'mobility': 'Mobility/Flexibility',
  };

  late Set<String> _selectedLanguages;
  late Set<String> _selectedSpecializations;

  @override
  void initState() {
    super.initState();
    _filters = widget.filters;
    _minRateController.text = _filters.minRate != null
        ? (_filters.minRate! ~/ 100).toString()
        : '';
    _maxRateController.text = _filters.maxRate != null
        ? (_filters.maxRate! ~/ 100).toString()
        : '';
    _sortBy = _filters.sortBy ?? 'created_at';

    _selectedLanguages = <String>{
      for (final code in (_filters.languages ?? const <String>[]))
        if (_languageOptions.containsKey(code)) code,
    };

    _selectedSpecializations = <String>{
      for (final code in (_filters.specializations ?? const <String>[]))
        if (_specializationOptions.containsKey(code)) code,
    };
  }

  @override
  void dispose() {
    _minRateController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final specializations = _selectedSpecializations.isEmpty
        ? null
        : _selectedSpecializations.toList();
    final languages = _selectedLanguages.toList();

    final minRate = int.tryParse(_minRateController.text);
    final maxRate = int.tryParse(_maxRateController.text);

    final minRateCents = minRate != null ? minRate * 100 : null;
    final maxRateCents = maxRate != null ? maxRate * 100 : null;

    widget.onApply(
      UserFilters(
        coach: _filters.coach,
        specializations: specializations,
        languages: languages.isEmpty ? null : languages,
        minRate: minRateCents,
        maxRate: maxRateCents,
        sortBy: _sortBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxBodyHeight = MediaQuery.sizeOf(context).height * 0.68;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxBodyHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context).settingsSpecializationsHeader,
              style: InstrumentTheme.microLabel(context),
            ),
            const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in _specializationOptions.entries)
              InstrumentSelectablePill(
                label: entry.value,
                selected: _selectedSpecializations.contains(entry.key),
                bordered: false,
                onTap: () {
                  setState(() {
                    if (_selectedSpecializations.contains(entry.key)) {
                      _selectedSpecializations.remove(entry.key);
                    } else {
                      _selectedSpecializations.add(entry.key);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context).settingsLanguagesHeader,
          style: InstrumentTheme.microLabel(context),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in _languageOptions.entries)
              InstrumentSelectablePill(
                label: entry.value,
                selected: _selectedLanguages.contains(entry.key),
                bordered: false,
                onTap: () {
                  setState(() {
                    if (_selectedLanguages.contains(entry.key)) {
                      _selectedLanguages.remove(entry.key);
                    } else {
                      _selectedLanguages.add(entry.key);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final minField = TextField(
              controller: _minRateController,
              keyboardType: TextInputType.number,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodyMedium ?? const TextStyle(),
              ),
              decoration: InstrumentTheme.inputDecoration(
                context,
                labelText: AppLocalizations.of(context).minRateUsdLabel,
              ),
            );
            final maxField = TextField(
              controller: _maxRateController,
              keyboardType: TextInputType.number,
              style: InstrumentTheme.tabular(
                theme.textTheme.bodyMedium ?? const TextStyle(),
              ),
              decoration: InstrumentTheme.inputDecoration(
                context,
                labelText: AppLocalizations.of(context).maxRateUsdLabel,
              ),
            );
            if (constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  minField,
                  const SizedBox(height: 10),
                  maxField,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: minField),
                const SizedBox(width: 12),
                Expanded(child: maxField),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _sortBy,
          isExpanded: true,
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: AppLocalizations.of(context).sortByLabel,
          ),
          items: [
            DropdownMenuItem(
              value: 'created_at',
              child: Text(AppLocalizations.of(context).sortCreatedAt),
            ),
            DropdownMenuItem(
              value: 'rating',
              child: Text(AppLocalizations.of(context).sortRating),
            ),
            DropdownMenuItem(
              value: 'last_active',
              child: Text(AppLocalizations.of(context).sortLastActive),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _sortBy = value ?? 'created_at';
            });
          },
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            InstrumentActionButton(
              label: AppLocalizations.of(context).clearTooltip,
              variant: InstrumentActionVariant.secondary,
              onPressed: widget.onClear,
            ),
            InstrumentActionButton(
              label: AppLocalizations.of(context).applyFiltersLabel,
              variant: InstrumentActionVariant.primary,
              onPressed: _applyFilters,
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
