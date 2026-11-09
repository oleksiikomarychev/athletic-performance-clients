import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';

class SettingsLegalScreen extends StatelessWidget {
  const SettingsLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
      ),
      body: ListView(
        padding: EdgeInsets.all(UiDimensions.of(context).pagePadding),
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'This is a placeholder. Add your privacy policy text or open a web page.',
          ),
          SizedBox(height: UiDimensions.of(context).sectionGap),
          Text(
            'Terms of Service',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'This is a placeholder. Add your terms of service text or open a web page.',
          ),
        ],
      ),
    );
  }
}
