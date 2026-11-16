import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/empty_state.dart';
import 'package:workout_app/widgets/error_message.dart';
import 'package:workout_app/widgets/loading_indicator.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import '../config/api_config.dart';
import '../models/exercise_definition.dart';
import 'exercises_screen.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;

  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercisesNotifierProvider);

    return AssistantChatHost(
      contextBuilder: () async => {
        'screen': 'exercise_detail',
        'entities': {'exercise_id': exerciseId},
      },
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar(
            title: l10n.exerciseTitle,
            onTitleTap: openChat,
            showBack: true,
          ),
          body: state.when(
            loading: () => Padding(
              padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
              child: const LoadingIndicator(),
            ),
            error: (e, _) => Padding(
              padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
              child: ErrorMessage(
                message: l10n.failedToLoadExercise('$e'),
                onRetry: () => ref.invalidate(exercisesNotifierProvider),
              ),
            ),
            data: (exercises) {
              final ExerciseDefinition? current = exercises
                  .cast<ExerciseDefinition?>()
                  .firstWhere((x) => x?.id == exerciseId, orElse: () => null);

              if (current == null) {
                return Padding(
                  padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
                  child: EmptyState(
                    icon: Icons.fitness_center_rounded,
                    title: l10n.exerciseNotFoundTitle,
                    description: l10n.exerciseDetailNotFoundDescription,
                  ),
                );
              }

              final int? parentId = current.rootExerciseId;
              final ExerciseDefinition? parent = parentId == null
                  ? null
                  : exercises.cast<ExerciseDefinition?>().firstWhere(
                      (x) => x?.id == parentId,
                      orElse: () => null,
                    );

              final variants =
                  exercises
                      .where(
                        (e) =>
                            e.rootExerciseId != null &&
                            e.rootExerciseId == current.id,
                      )
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));

              final siblings = parent == null
                  ? <ExerciseDefinition>[]
                  : (exercises
                        .where(
                          (e) =>
                              e.rootExerciseId != null &&
                              e.rootExerciseId == parent.id &&
                              e.id != current.id,
                        )
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name)));

              final theme = Theme.of(context);
              final instrument = InstrumentTheme.of(context);

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  topInset + 8,
                  16,
                  bottomInset + 24,
                ),
                children: [
                  Container(
                    decoration: InstrumentTheme.instrumentCardDecoration(
                      context,
                      accentColor: instrument.workingAura,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXERCISE SPEC',
                                style: InstrumentTheme.microLabel(
                                  context,
                                  color: instrument.workingAura,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                current.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (current.imageUrl != null &&
                            current.imageUrl!.trim().isNotEmpty) ...[
                          Container(height: 1, color: instrument.hairlineBorder),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IMAGE',
                                  style: InstrumentTheme.microLabel(context),
                                ),
                                const SizedBox(height: 8),
                                _ExerciseImage(imagePathOrUrl: current.imageUrl!),
                              ],
                            ),
                          ),
                        ],
                        if (current.gifUrl != null &&
                            current.gifUrl!.trim().isNotEmpty) ...[
                          Container(height: 1, color: instrument.hairlineBorder),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ANIMATION',
                                  style: InstrumentTheme.microLabel(context),
                                ),
                                const SizedBox(height: 8),
                                _ExerciseImage(imagePathOrUrl: current.gifUrl!),
                              ],
                            ),
                          ),
                        ],
                        Container(height: 1, color: instrument.hairlineBorder),
                        _SpecLineRow(
                          label: l10n.muscleGroupHeader,
                          value: current.muscleGroup ?? '—',
                        ),
                        Container(height: 1, color: instrument.hairlineBorder),
                        _SpecLineRow(
                          label: l10n.equipmentHeader,
                          value: current.equipment ?? '—',
                        ),
                        Container(height: 1, color: instrument.hairlineBorder),
                        _SpecLineRow(
                          label: l10n.movementTypeHeader,
                          value: current.movementType ?? '—',
                        ),
                        Container(height: 1, color: instrument.hairlineBorder),
                        _SpecLineRow(
                          label: l10n.regionHeader,
                          value: current.region ?? '—',
                        ),
                        Container(height: 1, color: instrument.hairlineBorder),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MetaTagsStrip(
                                label: l10n.targetMusclesHeader,
                                values:
                                    current.targetMuscles ?? const <String>[],
                                accentColor: instrument.workingAura,
                              ),
                              const SizedBox(height: 12),
                              _MetaTagsStrip(
                                label: l10n.synergistMusclesHeader,
                                values:
                                    current.synergistMuscles ??
                                    const <String>[],
                                accentColor: instrument.deloadAura,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (parent != null) ...[
                    const SizedBox(height: 14),
                    _RelatedExercisesModule(
                      eyebrow: l10n.parentExerciseEyebrow,
                      title: l10n.baseMovementTitle,
                      items: [parent],
                    ),
                  ],
                  if (variants.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _RelatedExercisesModule(
                      eyebrow: l10n.variantsCountEyebrow(variants.length),
                      title: l10n.directVariantsTitle,
                      items: variants,
                    ),
                  ],
                  if (siblings.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _RelatedExercisesModule(
                      eyebrow: l10n.otherVariantsCountEyebrow(siblings.length),
                      title: l10n.relatedSiblingsTitle,
                      items: siblings,
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _RelatedExercisesModule extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<ExerciseDefinition> items;

  const _RelatedExercisesModule({
    required this.eyebrow,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context),
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
                  style: InstrumentTheme.microLabel(context).copyWith(
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
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Container(height: 1, color: instrument.hairlineBorder),
            InkWell(
              onTap: items[i].id == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ExerciseDetailScreen(exerciseId: items[i].id!),
                        ),
                      );
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 18,
                        color: instrument.workingAura,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${items[i].muscleGroup ?? AppLocalizations.of(context).noMuscleGroup} · ${items[i].equipment ?? AppLocalizations.of(context).noEquipment}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imagePathOrUrl;

  const _ExerciseImage({required this.imagePathOrUrl});

  String _toAbsoluteUrl(String pathOrUrl) {
    final trimmed = pathOrUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('api/')) {
      return ApiConfig.buildFullUrl(trimmed);
    }

    if (trimmed.startsWith('/')) {
      final endpoint = ApiConfig.buildEndpoint(trimmed);
      return ApiConfig.buildFullUrl(endpoint);
    }

    return ApiConfig.buildFullUrl(trimmed);
  }

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _toAbsoluteUrl(imagePathOrUrl);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: InstrumentPalette.obsidianSlotHigh,
        child: FutureBuilder<String?>(
          future: _getIdToken(),
          builder: (context, snapshot) {
            final token = snapshot.data;
            final headers = (token == null || token.isEmpty)
                ? null
                : <String, String>{'Authorization': 'Bearer $token'};

            return Image.network(
              url,
              headers: headers,
              fit: BoxFit.cover,
              height: 220,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: Text(
                      'Failed to load image',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SpecLineRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecLineRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(label, style: InstrumentTheme.microLabel(context)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTagsStrip extends StatelessWidget {
  final String label;
  final List<String> values;
  final Color accentColor;

  const _MetaTagsStrip({
    required this.label,
    required this.values,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (values.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: InstrumentTheme.microLabel(context)),
          const SizedBox(height: 4),
          Text(
            '—',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final sorted = values.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final item in sorted)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
