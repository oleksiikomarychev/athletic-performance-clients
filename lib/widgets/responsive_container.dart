import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/responsive.dart';

/// Centers [child] and constrains its maximum width on wide web viewports
/// while leaving Android and iOS layouts completely unchanged.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidthWide,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return padding != null ? Padding(padding: padding!, child: child) : child;
    }

    Widget content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Align(
      alignment: alignment,
      child: content,
    );
  }
}
