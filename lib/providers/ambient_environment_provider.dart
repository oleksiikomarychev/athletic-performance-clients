import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/calendar_plan.dart';
import 'package:workout_app/models/exercise_set_dto.dart';
import 'package:workout_app/models/workout.dart';

/// Physiological atmosphere states driven by real training load and session activity.
enum TrainingEnvironmentState {
  deload,
  workingVolume,
  cnsStorm,
  liveExecution,
}

/// Immutable telemetry summary and reactive briefing payload for [AmbientScaffoldShell].
@immutable
class TrainingEnvironmentData {
  final TrainingEnvironmentState state;
  final double? peakRpe;
  final double? avgRpe;
  final double? peakIntensity;
  final double? peakWeight;
  final int? peakReps;
  final int totalSets;
  final double totalTonnage;
  final String? contextLabel;
  final bool isIdle;
  final String badgeLabel;
  final String tacticalBriefing;
  final String carrotSnarkBriefing;

  const TrainingEnvironmentData({
    required this.state,
    this.peakRpe,
    this.avgRpe,
    this.peakIntensity,
    this.peakWeight,
    this.peakReps,
    this.totalSets = 0,
    this.totalTonnage = 0.0,
    this.contextLabel,
    this.isIdle = false,
    required this.badgeLabel,
    required this.tacticalBriefing,
    required this.carrotSnarkBriefing,
  });

  const TrainingEnvironmentData.idle()
    : state = TrainingEnvironmentState.workingVolume,
      peakRpe = null,
      avgRpe = null,
      peakIntensity = null,
      peakWeight = null,
      peakReps = null,
      totalSets = 0,
      totalTonnage = 0.0,
      contextLabel = null,
      isIdle = true,
      badgeLabel = 'WORK ZONE',
      tacticalBriefing = 'System ready. Select a session or configure the grid.',
      carrotSnarkBriefing = 'The barbell will not lift itself. Pick a target.';

  Color accentColor(InstrumentTheme theme) {
    switch (state) {
      case TrainingEnvironmentState.deload:
        return theme.deloadAura;
      case TrainingEnvironmentState.workingVolume:
        return theme.workingAura;
      case TrainingEnvironmentState.cnsStorm:
        return theme.stormAura;
      case TrainingEnvironmentState.liveExecution:
        return theme.executionAccent;
    }
  }

  String briefing({bool snarky = false}) =>
      snarky ? carrotSnarkBriefing : tacticalBriefing;

  String localizedBadgeLabel(AppLocalizations l10n) {
    switch (state) {
      case TrainingEnvironmentState.liveExecution:
        return l10n.envBadgeLive;
      case TrainingEnvironmentState.cnsStorm:
        return l10n.envBadgeCnsStorm;
      case TrainingEnvironmentState.deload:
        return l10n.envBadgeDeload;
      case TrainingEnvironmentState.workingVolume:
        return l10n.envBadgeWorkZone;
    }
  }

  String localizedBriefing(AppLocalizations l10n, {bool snarky = false}) {
    if (isIdle) {
      return snarky ? l10n.envIdleSnarky : l10n.envIdleTactical;
    }
    final peakSetSnippet = _formatPeakSet(
      peakWeight: peakWeight,
      peakReps: peakReps,
      peakRpe: peakRpe,
      peakIntensity: peakIntensity,
      l10n: l10n,
    );
    final tonnageSnippet = totalTonnage > 0
        ? l10n.unitKgValue(totalTonnage.round().toString())
        : (totalSets > 0 ? l10n.unitSetsShort(totalSets.toString()) : null);

    switch (state) {
      case TrainingEnvironmentState.liveExecution:
        if (snarky) {
          return peakSetSnippet != null
              ? l10n.envLiveSnarkyPeak(peakSetSnippet)
              : l10n.envLiveSnarky;
        }
        return peakSetSnippet != null
            ? l10n.envLiveTacticalPeak(peakSetSnippet)
            : l10n.envLiveTactical;
      case TrainingEnvironmentState.cnsStorm:
        final intensity = peakIntensity;
        final detail = peakSetSnippet ??
            (intensity != null
                ? '${intensity.round()}% 1RM'
                : 'RPE ${(peakRpe ?? 9.0).toStringAsFixed(1)}');
        if (snarky) {
          return l10n.envStormSnarky(detail);
        }
        return tonnageSnippet != null
            ? l10n.envStormTacticalWithTonnage(detail, tonnageSnippet)
            : l10n.envStormTactical(detail);
      case TrainingEnvironmentState.deload:
        final rpe = peakRpe;
        final rpeLabel = rpe != null
            ? 'RPE ${rpe.toStringAsFixed(1)}'
            : l10n.envDeloadLightZone;
        if (snarky) {
          return l10n.envDeloadSnarky(rpeLabel);
        }
        return tonnageSnippet != null
            ? l10n.envDeloadTacticalWithTonnage(rpeLabel, tonnageSnippet)
            : l10n.envDeloadTactical(rpeLabel);
      case TrainingEnvironmentState.workingVolume:
        if (peakSetSnippet != null && tonnageSnippet != null) {
          return snarky
              ? l10n.envWorkSnarkyPeak(peakSetSnippet)
              : l10n.envWorkTacticalPeakTonnage(peakSetSnippet, tonnageSnippet);
        } else if (totalSets > 0) {
          if (snarky) {
            return l10n.envWorkSnarkySets(totalSets.toString());
          }
          return tonnageSnippet != null
              ? l10n.envWorkTacticalSetsWithTonnage(
                  totalSets.toString(),
                  tonnageSnippet,
                )
              : l10n.envWorkTacticalSets(totalSets.toString());
        } else {
          final prefix =
              (contextLabel != null && contextLabel!.trim().isNotEmpty)
                  ? '${contextLabel!.trim()} · '
                  : '';
          return snarky
              ? l10n.envWorkSnarkyReady(prefix)
              : l10n.envWorkTacticalReady(prefix);
        }
    }
  }

  static TrainingEnvironmentData evaluate({
    bool isLiveExecution = false,
    double? peakRpe,
    double? avgRpe,
    double? peakIntensity,
    double? peakWeight,
    int? peakReps,
    int totalSets = 0,
    double totalTonnage = 0.0,
    String? contextLabel,
  }) {
    final TrainingEnvironmentState resolvedState;
    if (isLiveExecution) {
      resolvedState = TrainingEnvironmentState.liveExecution;
    } else if ((peakRpe != null && peakRpe >= 9.0) ||
        (peakIntensity != null && peakIntensity >= 85.0)) {
      resolvedState = TrainingEnvironmentState.cnsStorm;
    } else if ((peakRpe != null && peakRpe > 0 && peakRpe <= 6.5) &&
        (peakIntensity == null || peakIntensity < 70.0)) {
      resolvedState = TrainingEnvironmentState.deload;
    } else {
      resolvedState = TrainingEnvironmentState.workingVolume;
    }

    final peakSetSnippet = _formatPeakSet(
      peakWeight: peakWeight,
      peakReps: peakReps,
      peakRpe: peakRpe,
      peakIntensity: peakIntensity,
    );
    final tonnageSnippet = totalTonnage > 0
        ? '${totalTonnage.round()} kg'
        : (totalSets > 0 ? '$totalSets sets' : null);

    late final String badgeLabel;
    late final String tactical;
    late final String snarky;

    switch (resolvedState) {
      case TrainingEnvironmentState.liveExecution:
        badgeLabel = 'LIVE';
        tactical = peakSetSnippet != null
            ? 'Session in progress · Peak $peakSetSnippet'
            : 'Active session in progress · Focus mode';
        snarky = peakSetSnippet != null
            ? 'Clock is ticking. Conquer $peakSetSnippet and quit whining.'
            : 'Stopwatch is running. Less talk, more reps.';
        break;
      case TrainingEnvironmentState.cnsStorm:
        badgeLabel = 'CNS STORM';
        final detail = peakSetSnippet ??
            (peakIntensity != null
                ? '${peakIntensity.round()}% 1RM'
                : 'RPE ${(peakRpe ?? 9.0).toStringAsFixed(1)}');
        tactical = tonnageSnippet != null
            ? 'Peak $detail · Volume $tonnageSnippet · High CNS load'
            : 'Peak $detail · Peak CNS load';
        snarky = 'Peak $detail. CNS is begging for mercy — turn it up.';
        break;
      case TrainingEnvironmentState.deload:
        badgeLabel = 'DELOAD';
        final rpeLabel = peakRpe != null
            ? 'RPE ${peakRpe.toStringAsFixed(1)}'
            : 'light zone';
        tactical = tonnageSnippet != null
            ? 'Recovery · $rpeLabel · Volume $tonnageSnippet'
            : 'Deload phase · $rpeLabel · Adaptation';
        snarky = 'Resort mode ($rpeLabel). Do not even think about adding plates.';
        break;
      case TrainingEnvironmentState.workingVolume:
        badgeLabel = 'WORK ZONE';
        if (peakSetSnippet != null && tonnageSnippet != null) {
          tactical = 'Peak $peakSetSnippet · Working volume $tonnageSnippet';
          snarky = 'Working corridor: $peakSetSnippet. Discipline beats ego.';
        } else if (totalSets > 0) {
          tactical =
              'Work zone · $totalSets sets${tonnageSnippet != null ? ' · $tonnageSnippet' : ''}';
          snarky = '$totalSets working sets. Boring? That is called progress.';
        } else {
          final prefix = (contextLabel != null && contextLabel.trim().isNotEmpty)
              ? '${contextLabel.trim()} · '
              : '';
          tactical = '${prefix}Work zone · Ready to launch';
          snarky = '${prefix}Clean slate. Load it properly.';
        }
        break;
    }

    return TrainingEnvironmentData(
      state: resolvedState,
      peakRpe: peakRpe,
      avgRpe: avgRpe,
      peakIntensity: peakIntensity,
      peakWeight: peakWeight,
      peakReps: peakReps,
      totalSets: totalSets,
      totalTonnage: totalTonnage,
      contextLabel: contextLabel,
      badgeLabel: badgeLabel,
      tacticalBriefing: tactical,
      carrotSnarkBriefing: snarky,
    );
  }

  static String? _formatPeakSet({
    double? peakWeight,
    int? peakReps,
    double? peakRpe,
    double? peakIntensity,
    AppLocalizations? l10n,
  }) {
    final parts = <String>[];
    if (peakWeight != null && peakWeight > 0) {
      final wStr = peakWeight == peakWeight.roundToDouble()
          ? peakWeight.round().toString()
          : peakWeight.toStringAsFixed(1);
      final wLabel = l10n != null ? l10n.unitKgValue(wStr) : '$wStr kg';
      if (peakReps != null && peakReps > 0) {
        parts.add('$wLabel × $peakReps');
      } else {
        parts.add(wLabel);
      }
    } else if (peakIntensity != null && peakIntensity > 0) {
      parts.add('${peakIntensity.round()}%');
    }

    if (peakRpe != null && peakRpe > 0) {
      final rpeStr = peakRpe == peakRpe.roundToDouble()
          ? peakRpe.toStringAsFixed(0)
          : peakRpe.toStringAsFixed(1);
      parts.add('@ RPE $rpeStr');
    }

    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  static TrainingEnvironmentData fromSets(
    Iterable<ExerciseSetDto> sets, {
    bool isLiveExecution = false,
    double? fallbackSessionRpe,
    String? contextLabel,
  }) {
    final flattened = <ExerciseSetDto>[];
    void collect(ExerciseSetDto s) {
      if (s.subsets.isNotEmpty) {
        for (final sub in s.subsets) {
          collect(sub);
        }
      } else {
        flattened.add(s);
      }
    }

    for (final s in sets) {
      collect(s);
    }

    double? peakRpe;
    double rpeSum = 0;
    int rpeCount = 0;
    double? peakIntensity;
    double? peakWeight;
    int? peakReps;
    double totalTonnage = 0;

    double bestScore = -1;

    for (final s in flattened) {
      final rpe = (s.rpe != null && s.rpe! > 0)
          ? s.rpe
          : (s.effort > 0 ? s.effort : null);
      if (rpe != null) {
        rpeSum += rpe;
        rpeCount++;
        if (peakRpe == null || rpe > peakRpe) {
          peakRpe = rpe;
        }
      }
      if (s.intensity > 0) {
        final intensityVal = s.intensity.toDouble();
        if (peakIntensity == null || intensityVal > peakIntensity) {
          peakIntensity = intensityVal;
        }
      }
      if (s.weight > 0 && s.reps > 0) {
        totalTonnage += s.weight * s.reps;
      }

      // Identify the "boss" / peak set by weight first, then RPE/intensity.
      final score = (s.weight > 0 ? s.weight * 100 : 0.0) +
          ((rpe ?? 0.0) * 10) +
          s.intensity.toDouble();
      if (score > bestScore && (s.weight > 0 || rpe != null || s.intensity > 0)) {
        bestScore = score;
        peakWeight = s.weight > 0 ? s.weight : null;
        peakReps = s.reps > 0 ? s.reps : null;
      }
    }

    if (peakRpe == null && fallbackSessionRpe != null && fallbackSessionRpe > 0) {
      peakRpe = fallbackSessionRpe;
    }

    return evaluate(
      isLiveExecution: isLiveExecution,
      peakRpe: peakRpe,
      avgRpe: rpeCount > 0 ? rpeSum / rpeCount : peakRpe,
      peakIntensity: peakIntensity,
      peakWeight: peakWeight,
      peakReps: peakReps,
      totalSets: flattened.length,
      totalTonnage: totalTonnage,
      contextLabel: contextLabel,
    );
  }

  static TrainingEnvironmentData fromWorkout(
    Workout? workout, {
    bool isLiveExecution = false,
  }) {
    if (workout == null) {
      return const TrainingEnvironmentData.idle();
    }
    final allSets = workout.exerciseInstances.expand((e) => e.sets);
    return fromSets(
      allSets,
      isLiveExecution: isLiveExecution,
      fallbackSessionRpe: workout.effortSession,
      contextLabel: workout.name,
    );
  }

  static TrainingEnvironmentData fromPlan(
    CalendarPlan plan, {
    bool isLiveExecution = false,
  }) {
    double? peakRpe;
    double rpeSum = 0;
    int rpeCount = 0;
    double? peakIntensity;
    int totalSets = 0;

    for (final meso in plan.mesocycles) {
      for (final micro in meso.microcycles) {
        for (final dayItems in micro.schedule.values) {
          for (final item in dayItems) {
            for (final set in item.sets) {
              totalSets++;
              final eff = set.effort;
              if (eff != null && eff > 0) {
                rpeSum += eff;
                rpeCount++;
                if (peakRpe == null || eff > peakRpe) {
                  peakRpe = eff;
                }
              }
              final inten = set.intensity;
              if (inten != null && inten > 0) {
                if (peakIntensity == null || inten > peakIntensity) {
                  peakIntensity = inten;
                }
              }
            }
          }
        }
      }
    }

    return evaluate(
      isLiveExecution: isLiveExecution,
      peakRpe: peakRpe,
      avgRpe: rpeCount > 0 ? rpeSum / rpeCount : null,
      peakIntensity: peakIntensity,
      totalSets: totalSets,
      contextLabel: plan.name,
    );
  }
}

/// Optional screen-level override for [activeTrainingEnvironmentProvider].
final ambientEnvironmentOverrideProvider =
    StateProvider<TrainingEnvironmentData?>((ref) => null);

/// Resolves the active [TrainingEnvironmentData] for the current viewport.
final activeTrainingEnvironmentProvider =
    Provider.family<TrainingEnvironmentData, TrainingEnvironmentData?>((
      ref,
      explicit,
    ) {
      return explicit ??
          ref.watch(ambientEnvironmentOverrideProvider) ??
          const TrainingEnvironmentData.idle();
    });
