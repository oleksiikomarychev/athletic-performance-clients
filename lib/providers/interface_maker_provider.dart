import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/l10n/app_localizations.dart';

const _kInterfaceMakerPrefsKey = 'carrot_interface_maker_config_v1';

enum InterfacePreset {
  powerlifter,
  volume,
  minimalist,
  custom;

  String get label {
    switch (this) {
      case InterfacePreset.powerlifter:
        return 'Strength 5/3/1';
      case InterfacePreset.volume:
        return 'Volume';
      case InterfacePreset.minimalist:
        return 'Minimalist';
      case InterfacePreset.custom:
        return 'Custom';
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case InterfacePreset.powerlifter:
        return l10n.presetPowerlifter;
      case InterfacePreset.volume:
        return l10n.presetVolume;
      case InterfacePreset.minimalist:
        return l10n.presetMinimalist;
      case InterfacePreset.custom:
        return l10n.presetCustom;
    }
  }

  static InterfacePreset fromStorage(String? raw) {
    for (final value in InterfacePreset.values) {
      if (value.name == raw) return value;
    }
    return InterfacePreset.powerlifter;
  }
}

enum MetricSlot {
  peakIntensity,
  e1rm,
  peakRpe,
  avgRpe,
  tonnage,
  kpsh,
  setsCount,
  density,
  durationWeeks,
  frequencyPerWeek;

  String get shortLabel {
    switch (this) {
      case MetricSlot.peakIntensity:
        return 'PEAK %';
      case MetricSlot.e1rm:
        return 'E1RM';
      case MetricSlot.peakRpe:
        return 'PEAK RPE';
      case MetricSlot.avgRpe:
        return 'AVG RPE';
      case MetricSlot.tonnage:
        return 'TONNAGE';
      case MetricSlot.kpsh:
        return 'REPS';
      case MetricSlot.setsCount:
        return 'SETS';
      case MetricSlot.density:
        return 'DENSITY';
      case MetricSlot.durationWeeks:
        return 'WEEKS';
      case MetricSlot.frequencyPerWeek:
        return 'FREQ';
    }
  }

  String localizedShortLabel(AppLocalizations l10n) {
    switch (this) {
      case MetricSlot.peakIntensity:
        return l10n.slotShortPeakIntensity;
      case MetricSlot.e1rm:
        return l10n.slotShortE1rm;
      case MetricSlot.peakRpe:
        return l10n.slotShortPeakRpe;
      case MetricSlot.avgRpe:
        return l10n.slotShortAvgRpe;
      case MetricSlot.tonnage:
        return l10n.slotShortTonnage;
      case MetricSlot.kpsh:
        return l10n.slotShortKpsh;
      case MetricSlot.setsCount:
        return l10n.slotShortSetsCount;
      case MetricSlot.density:
        return l10n.slotShortDensity;
      case MetricSlot.durationWeeks:
        return l10n.slotShortDurationWeeks;
      case MetricSlot.frequencyPerWeek:
        return l10n.slotShortFrequencyPerWeek;
    }
  }

  String get displayName {
    switch (this) {
      case MetricSlot.peakIntensity:
        return 'Peak % 1RM';
      case MetricSlot.e1rm:
        return 'Estimated 1RM';
      case MetricSlot.peakRpe:
        return 'Peak RPE';
      case MetricSlot.avgRpe:
        return 'Average RPE';
      case MetricSlot.tonnage:
        return 'Tonnage';
      case MetricSlot.kpsh:
        return 'Total Reps';
      case MetricSlot.setsCount:
        return 'Working Sets';
      case MetricSlot.density:
        return 'Density';
      case MetricSlot.durationWeeks:
        return 'Duration';
      case MetricSlot.frequencyPerWeek:
        return 'Workouts/week';
    }
  }

  String localizedDisplayName(AppLocalizations l10n) {
    switch (this) {
      case MetricSlot.peakIntensity:
        return l10n.slotNamePeakIntensity;
      case MetricSlot.e1rm:
        return l10n.slotNameE1rm;
      case MetricSlot.peakRpe:
        return l10n.slotNamePeakRpe;
      case MetricSlot.avgRpe:
        return l10n.slotNameAvgRpe;
      case MetricSlot.tonnage:
        return l10n.slotNameTonnage;
      case MetricSlot.kpsh:
        return l10n.slotNameKpsh;
      case MetricSlot.setsCount:
        return l10n.slotNameSetsCount;
      case MetricSlot.density:
        return l10n.slotNameDensity;
      case MetricSlot.durationWeeks:
        return l10n.slotNameDurationWeeks;
      case MetricSlot.frequencyPerWeek:
        return l10n.slotNameFrequencyPerWeek;
    }
  }

  /// Maps a telemetry slot to the corresponding analytics chart metric key.
  String get analyticsMetricKey {
    switch (this) {
      case MetricSlot.peakIntensity:
      case MetricSlot.e1rm:
        return 'one_rm';
      case MetricSlot.peakRpe:
      case MetricSlot.avgRpe:
        return 'effort';
      case MetricSlot.tonnage:
      case MetricSlot.density:
        return 'volume';
      case MetricSlot.kpsh:
        return 'kpsh';
      case MetricSlot.setsCount:
      case MetricSlot.durationWeeks:
      case MetricSlot.frequencyPerWeek:
        return 'reps';
    }
  }

  static MetricSlot? fromStorage(String? raw) {
    for (final value in MetricSlot.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum LayoutModule {
  variantOrHorizonStrip,
  commandBriefing,
  primaryTelemetry,
  scheduleOrLibrary;

  String get displayName {
    switch (this) {
      case LayoutModule.variantOrHorizonStrip:
        return 'Presets / Variants strip';
      case LayoutModule.commandBriefing:
        return 'Load Briefing';
      case LayoutModule.primaryTelemetry:
        return 'Telemetry & Chart';
      case LayoutModule.scheduleOrLibrary:
        return 'Library / Microcycles';
    }
  }

  String localizedDisplayName(AppLocalizations l10n) {
    switch (this) {
      case LayoutModule.variantOrHorizonStrip:
        return l10n.moduleVariantOrHorizonStrip;
      case LayoutModule.commandBriefing:
        return l10n.moduleCommandBriefing;
      case LayoutModule.primaryTelemetry:
        return l10n.modulePrimaryTelemetry;
      case LayoutModule.scheduleOrLibrary:
        return l10n.moduleScheduleOrLibrary;
    }
  }

  static LayoutModule? fromStorage(String? raw) {
    for (final value in LayoutModule.values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

@immutable
class InterfaceConfig {
  static const List<LayoutModule> defaultModuleOrder = [
    LayoutModule.variantOrHorizonStrip,
    LayoutModule.commandBriefing,
    LayoutModule.primaryTelemetry,
    LayoutModule.scheduleOrLibrary,
  ];

  final InterfacePreset preset;
  final List<MetricSlot> slots;
  final List<LayoutModule> moduleOrder;
  final Set<LayoutModule> hiddenModules;
  final bool showChart;
  final bool snarkyVoice;

  const InterfaceConfig({
    required this.preset,
    required this.slots,
    this.moduleOrder = defaultModuleOrder,
    this.hiddenModules = const {},
    this.showChart = true,
    this.snarkyVoice = false,
  });

  factory InterfaceConfig.powerlifter({bool snarkyVoice = false}) =>
      InterfaceConfig(
        preset: InterfacePreset.powerlifter,
        slots: const [
          MetricSlot.peakIntensity,
          MetricSlot.e1rm,
          MetricSlot.peakRpe,
          MetricSlot.kpsh,
        ],
        moduleOrder: defaultModuleOrder,
        hiddenModules: const {},
        showChart: true,
        snarkyVoice: snarkyVoice,
      );

  factory InterfaceConfig.volume({bool snarkyVoice = false}) => InterfaceConfig(
    preset: InterfacePreset.volume,
    slots: const [
      MetricSlot.tonnage,
      MetricSlot.setsCount,
      MetricSlot.density,
      MetricSlot.avgRpe,
    ],
    moduleOrder: defaultModuleOrder,
    hiddenModules: const {},
    showChart: true,
    snarkyVoice: snarkyVoice,
  );

  factory InterfaceConfig.minimalist({bool snarkyVoice = false}) =>
      InterfaceConfig(
        preset: InterfacePreset.minimalist,
        slots: const [
          MetricSlot.tonnage,
          MetricSlot.setsCount,
          MetricSlot.peakRpe,
          MetricSlot.e1rm,
        ],
        moduleOrder: defaultModuleOrder,
        hiddenModules: const {LayoutModule.commandBriefing},
        showChart: false,
        snarkyVoice: snarkyVoice,
      );

  factory InterfaceConfig.forPreset(
    InterfacePreset preset, {
    bool snarkyVoice = false,
  }) {
    switch (preset) {
      case InterfacePreset.powerlifter:
        return InterfaceConfig.powerlifter(snarkyVoice: snarkyVoice);
      case InterfacePreset.volume:
        return InterfaceConfig.volume(snarkyVoice: snarkyVoice);
      case InterfacePreset.minimalist:
        return InterfaceConfig.minimalist(snarkyVoice: snarkyVoice);
      case InterfacePreset.custom:
        return InterfaceConfig.powerlifter(
          snarkyVoice: snarkyVoice,
        ).copyWith(preset: InterfacePreset.custom);
    }
  }

  List<LayoutModule> get visibleModules => moduleOrder
      .where((m) => !hiddenModules.contains(m))
      .toList(growable: false);

  bool isModuleVisible(LayoutModule module) => !hiddenModules.contains(module);

  InterfaceConfig copyWith({
    InterfacePreset? preset,
    List<MetricSlot>? slots,
    List<LayoutModule>? moduleOrder,
    Set<LayoutModule>? hiddenModules,
    bool? showChart,
    bool? snarkyVoice,
  }) {
    return InterfaceConfig(
      preset: preset ?? this.preset,
      slots: slots ?? this.slots,
      moduleOrder: moduleOrder ?? this.moduleOrder,
      hiddenModules: hiddenModules ?? this.hiddenModules,
      showChart: showChart ?? this.showChart,
      snarkyVoice: snarkyVoice ?? this.snarkyVoice,
    );
  }

  Map<String, dynamic> toJson() => {
    'preset': preset.name,
    'slots': slots.map((s) => s.name).toList(growable: false),
    'module_order': moduleOrder.map((m) => m.name).toList(growable: false),
    'hidden_modules': hiddenModules.map((m) => m.name).toList(growable: false),
    'show_chart': showChart,
    'snarky_voice': snarkyVoice,
  };

  factory InterfaceConfig.fromJson(Map<String, dynamic> json) {
    final preset = InterfacePreset.fromStorage(json['preset'] as String?);
    final rawSlots = (json['slots'] as List<dynamic>? ?? [])
        .map((e) => MetricSlot.fromStorage(e?.toString()))
        .whereType<MetricSlot>()
        .toList(growable: false);
    final fallback = InterfaceConfig.forPreset(preset);
    final resolvedSlots = rawSlots.length == 4 ? rawSlots : fallback.slots;

    final rawOrder = (json['module_order'] as List<dynamic>? ?? [])
        .map((e) => LayoutModule.fromStorage(e?.toString()))
        .whereType<LayoutModule>()
        .toList();
    for (final m in defaultModuleOrder) {
      if (!rawOrder.contains(m)) rawOrder.add(m);
    }

    final rawHidden = (json['hidden_modules'] as List<dynamic>? ?? [])
        .map((e) => LayoutModule.fromStorage(e?.toString()))
        .whereType<LayoutModule>()
        .toSet();

    return InterfaceConfig(
      preset: preset,
      slots: resolvedSlots,
      moduleOrder: rawOrder,
      hiddenModules: rawHidden,
      showChart: (json['show_chart'] as bool?) ?? fallback.showChart,
      snarkyVoice: (json['snarky_voice'] as bool?) ?? false,
    );
  }
}

final interfaceMakerProvider =
    StateNotifierProvider<InterfaceMakerController, InterfaceConfig>((ref) {
      return InterfaceMakerController();
    });

class InterfaceMakerController extends StateNotifier<InterfaceConfig> {
  bool _mutatedLocally = false;

  InterfaceMakerController() : super(InterfaceConfig.powerlifter()) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kInterfaceMakerPrefsKey);
      if (raw == null || raw.isEmpty || _mutatedLocally) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && !_mutatedLocally) {
        state = InterfaceConfig.fromJson(decoded);
      }
    } catch (_) {
      // Ignore corrupt local preferences and retain defaults.
    }
  }

  Future<void> _save(InterfaceConfig next) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kInterfaceMakerPrefsKey, jsonEncode(next.toJson()));
    } catch (_) {
      // Ignore persistence failures in headless tests.
    }
  }

  Future<void> applyPreset(InterfacePreset preset) async {
    _mutatedLocally = true;
    final next = InterfaceConfig.forPreset(
      preset,
      snarkyVoice: state.snarkyVoice,
    );
    state = next;
    await _save(next);
  }

  Future<void> setSlot(int index, MetricSlot slot) async {
    if (index < 0 || index >= state.slots.length) return;
    _mutatedLocally = true;
    final updatedSlots = List<MetricSlot>.from(state.slots);
    updatedSlots[index] = slot;
    final next = state.copyWith(
      preset: InterfacePreset.custom,
      slots: updatedSlots,
    );
    state = next;
    await _save(next);
  }

  Future<void> setShowChart(bool showChart) async {
    _mutatedLocally = true;
    final next = state.copyWith(
      preset: InterfacePreset.custom,
      showChart: showChart,
    );
    state = next;
    await _save(next);
  }

  Future<void> setSnarkyVoice(bool snarkyVoice) async {
    _mutatedLocally = true;
    final next = state.copyWith(snarkyVoice: snarkyVoice);
    state = next;
    await _save(next);
  }

  Future<void> toggleModuleVisibility(LayoutModule module) async {
    _mutatedLocally = true;
    final updatedHidden = Set<LayoutModule>.from(state.hiddenModules);
    if (updatedHidden.contains(module)) {
      updatedHidden.remove(module);
    } else {
      // Keep primary telemetry visible if everything else would disappear.
      if (module == LayoutModule.primaryTelemetry &&
          updatedHidden.length >= state.moduleOrder.length - 1) {
        return;
      }
      updatedHidden.add(module);
    }
    final next = state.copyWith(
      preset: InterfacePreset.custom,
      hiddenModules: updatedHidden,
    );
    state = next;
    await _save(next);
  }

  Future<void> moveModule(int oldIndex, int newIndex) async {
    if (oldIndex < 0 ||
        oldIndex >= state.moduleOrder.length ||
        newIndex < 0 ||
        newIndex >= state.moduleOrder.length ||
        oldIndex == newIndex) {
      return;
    }
    _mutatedLocally = true;
    final updatedOrder = List<LayoutModule>.from(state.moduleOrder);
    final item = updatedOrder.removeAt(oldIndex);
    updatedOrder.insert(newIndex, item);
    final next = state.copyWith(
      preset: InterfacePreset.custom,
      moduleOrder: updatedOrder,
    );
    state = next;
    await _save(next);
  }

  Future<void> resetToDefault() => applyPreset(InterfacePreset.powerlifter);
}
