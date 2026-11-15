import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kInterfaceMakerPrefsKey = 'carrot_interface_maker_config_v1';

enum InterfacePreset {
  powerlifter,
  volume,
  minimalist,
  custom;

  String get label {
    switch (this) {
      case InterfacePreset.powerlifter:
        return 'Сила 5/3/1';
      case InterfacePreset.volume:
        return 'Объём';
      case InterfacePreset.minimalist:
        return 'Минимализм';
      case InterfacePreset.custom:
        return 'Свой';
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
        return 'ТОННАЖ';
      case MetricSlot.kpsh:
        return 'КПШ';
      case MetricSlot.setsCount:
        return 'ПОДХОДЫ';
      case MetricSlot.density:
        return 'ПЛОТН.';
      case MetricSlot.durationWeeks:
        return 'НЕДЕЛИ';
      case MetricSlot.frequencyPerWeek:
        return 'ЧАСТОТА';
    }
  }

  String get displayName {
    switch (this) {
      case MetricSlot.peakIntensity:
        return 'Пик % 1RM';
      case MetricSlot.e1rm:
        return 'Расчётный 1RM';
      case MetricSlot.peakRpe:
        return 'Пик RPE';
      case MetricSlot.avgRpe:
        return 'Средний RPE';
      case MetricSlot.tonnage:
        return 'Тоннаж';
      case MetricSlot.kpsh:
        return 'КПШ (Повторы)';
      case MetricSlot.setsCount:
        return 'Рабочие подходы';
      case MetricSlot.density:
        return 'Плотность';
      case MetricSlot.durationWeeks:
        return 'Длительность';
      case MetricSlot.frequencyPerWeek:
        return 'Тренировок/нед';
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
        return 'Лента пресетов / вариантов';
      case LayoutModule.commandBriefing:
        return 'Сводка нагрузки (Briefing)';
      case LayoutModule.primaryTelemetry:
        return 'Телеметрия и график';
      case LayoutModule.scheduleOrLibrary:
        return 'Библиотека / Микроциклы';
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
