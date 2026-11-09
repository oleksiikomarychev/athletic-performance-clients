import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';

const _densityKey = 'app_ui_density';

final appUiDensityProvider =
    StateNotifierProvider<AppUiDensityController, UiDensity>((ref) {
      return AppUiDensityController();
    });

class AppUiDensityController extends StateNotifier<UiDensity> {
  bool _loaded = false;
  UiDensity? _pending;

  AppUiDensityController({UiDensity? initialDensity})
    : super(initialDensity ?? UiDensity.compact) {
    if (initialDensity != null) {
      _loaded = true;
    } else {
      unawaited(_load());
    }
  }

  static Future<UiDensity> loadInitialDensity() async {
    final prefs = await SharedPreferences.getInstance();
    return _parse(prefs.getString(_densityKey));
  }

  static UiDensity _parse(String? value) =>
      value == 'comfortable' ? UiDensity.comfortable : UiDensity.compact;

  Future<void> _load() async {
    final saved = await loadInitialDensity();
    if (_pending == null) state = saved;
    _loaded = true;
    final pending = _pending;
    if (pending != null) {
      _pending = null;
      await setDensity(pending);
    }
  }

  Future<void> setDensity(UiDensity density) async {
    if (!_loaded) {
      _pending = density;
      state = density;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_densityKey, density.name);
    state = density;
  }
}
