import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

OverlayEntry? _activeSnackOverlay;
Timer? _activeSnackTimer;

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final instrument = InstrumentTheme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final accent = isError ? instrument.peakEffortColor : instrument.workingAura;

  _activeSnackTimer?.cancel();
  _activeSnackOverlay?.remove();
  _activeSnackOverlay = null;

  final entry = OverlayEntry(
    builder: (overlayContext) {
      final media = MediaQuery.of(overlayContext);
      final bottomInset = media.viewInsets.bottom + media.padding.bottom + 16;
      return Positioned(
        bottom: bottomInset,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: InstrumentTheme.instrumentCardDecoration(
              overlayContext,
              accentColor: accent,
              radius: 16,
              fillColor: isDark
                  ? InstrumentPalette.obsidianCardLow.withValues(alpha: 0.96)
                  : scheme.surface.withValues(alpha: 0.98),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: accent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: InstrumentTheme.tabular(
                        (theme.textTheme.bodyMedium ?? const TextStyle())
                            .copyWith(color: scheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  _activeSnackOverlay = entry;

  _activeSnackTimer = Timer(const Duration(seconds: 3), () {
    _activeSnackOverlay?.remove();
    _activeSnackOverlay = null;
    _activeSnackTimer = null;
  });
}
