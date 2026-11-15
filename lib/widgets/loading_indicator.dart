import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final instrument = InstrumentTheme.of(context);
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(instrument.workingAura),
      ),
    );
  }
}
