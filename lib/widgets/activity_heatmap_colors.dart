import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

class ActivityHeatmapColors {
  static List<Color> palette(BuildContext context) {
    final instrument = InstrumentTheme.of(context);
    if (Theme.of(context).brightness == Brightness.dark) {
      return [
        InstrumentPalette.obsidianSlotHigh,
        Color.lerp(
          InstrumentPalette.obsidianSlotHigh,
          instrument.deloadAura,
          0.30,
        )!,
        Color.lerp(
          InstrumentPalette.obsidianSlotHigh,
          instrument.deloadAura,
          0.55,
        )!,
        instrument.deloadAura,
        instrument.executionAccent,
      ];
    }

    return const [
      Color(0xFFEBEDF0),
      Color(0xFFC6E48B),
      Color(0xFF7BC96F),
      Color(0xFF239A3B),
      Color(0xFF196127),
    ];
  }

  static Color forVolume(BuildContext context, double volume, double maxVolume) {
    final colors = palette(context);
    if (volume <= 0 || maxVolume <= 0) return colors[0];
    final intensity = volume / maxVolume;
    if (intensity <= 0.25) return colors[1];
    if (intensity <= 0.50) return colors[2];
    if (intensity <= 0.75) return colors[3];
    return colors[4];
  }
}
