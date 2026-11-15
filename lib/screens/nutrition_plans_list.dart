import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/src/api/nutrition_api.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import 'nutrition_plan_create.dart';
import 'nutrition_plan_detail.dart';

class NutritionPlansList extends StatefulWidget {
  const NutritionPlansList({super.key});

  @override
  State<NutritionPlansList> createState() => _NutritionPlansListState();
}

class _NutritionPlansListState extends State<NutritionPlansList> {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessions = await NutritionApi.getAllSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _refreshSessions() async {
    await _loadSessions();
  }

  Future<void> _createSession() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NutritionPlanCreate()),
    );
    if (result != null) {
      await _refreshSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'nutrition_plans_list',
        'entities': {'sessions_count': _sessions.length},
      },
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.nutritionSessionsTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                onPressed: _createSession,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Create session',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshSessions,
            child: _buildBody(context, l10n),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: const LoadingIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: ErrorMessage(
          message: 'Failed to load nutrition sessions: $_errorMessage',
          onRetry: _loadSessions,
        ),
      );
    }

    if (_sessions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, topInset + 24, 16, bottomInset + 24),
        children: [
          EmptyState(
            icon: Icons.restaurant_rounded,
            title: l10n.nutritionSessionsEmpty,
            description: l10n.nutritionSessionsEmptyDesc,
            action: InstrumentActionButton(
              label: 'Create Session',
              icon: Icons.add_rounded,
              onPressed: _createSession,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, bottomInset + 24),
      itemCount: _sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _NutritionSessionCard(
          session: session,
          l10n: l10n,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NutritionPlanDetail(sessionData: session),
              ),
            ).then((_) => _refreshSessions());
          },
        );
      },
    );
  }
}

class _NutritionSessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _NutritionSessionCard({
    required this.session,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final entries = session['entries'] as List<dynamic>? ?? const [];
    final dateRaw = session['date']?.toString();
    final dateLabel = (dateRaw != null && dateRaw.isNotEmpty)
        ? dateRaw.split('T').first
        : 'UNSCHEDULED';

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'NUTRITION · $dateLabel',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: instrument.deloadAura,
                        ).copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.nutritionSessionTitle(session['session_id'].toString()),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: instrument.hairlineBorder),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.userIdLabel(session['user_id'].toString()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      l10n.entriesCount(entries.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
