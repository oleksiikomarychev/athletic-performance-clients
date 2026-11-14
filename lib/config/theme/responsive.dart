import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class Breakpoints {
  static const double compact = 640;
  static const double medium = 840;
  static const double expanded = 1120;

  static const double maxContentWidthNarrow = 720;
  static const double maxContentWidthMedium = 920;
  static const double maxContentWidthWide = 1160;
}

class Responsive {
  static double widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      !kIsWeb || widthOf(context) < Breakpoints.compact;

  static bool isWide(BuildContext context) =>
      kIsWeb && widthOf(context) >= Breakpoints.medium;

  static bool isExpanded(BuildContext context) =>
      kIsWeb && widthOf(context) >= Breakpoints.expanded;

  static int gridColumns(
    BuildContext context, {
    int compact = 1,
    int medium = 2,
    int expanded = 3,
  }) {
    if (!kIsWeb) return compact;
    final width = widthOf(context);
    if (width >= Breakpoints.expanded) return expanded;
    if (width >= Breakpoints.compact) return medium;
    return compact;
  }
}
