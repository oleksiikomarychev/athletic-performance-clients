import 'package:flutter/material.dart';
import 'package:workout_app/config/constants/route_names.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant)
            .withValues(alpha: isDark ? 0.85 : 0.55);

    return AmbientScaffoldShell(
      appBar: const PrimaryAppBar.detail(title: 'Settings'),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            AmbientScaffoldShell.topContentInset(context),
            16,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: [
            Container(
              decoration: InstrumentTheme.instrumentCardDecoration(
                context,
                accentColor: instrument.workingAura,
                radius: 22,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'INSTRUMENT CONTROL',
                          style: InstrumentTheme.microLabel(
                            context,
                            color: instrument.workingAura,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Workspace & Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: hairline),
                  _SettingsNavRow(
                    icon: Icons.tune_rounded,
                    iconColor: instrument.workingAura,
                    title: 'General',
                    subtitle: 'Theme, density, language, coaching & account',
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteNames.settingsGeneral);
                    },
                  ),
                  Container(height: 1, color: hairline),
                  _SettingsNavRow(
                    icon: Icons.file_upload_outlined,
                    iconColor: instrument.deloadAura,
                    title: 'Import workouts',
                    subtitle: 'Import Hevy CSV training history',
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteNames.settingsImport);
                    },
                  ),
                  Container(height: 1, color: hairline),
                  _SettingsNavRow(
                    icon: Icons.analytics_outlined,
                    iconColor: instrument.moderateEffortColor,
                    title: 'Amplitude Test',
                    subtitle: 'Diagnostics and funnel event telemetry',
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteNames.amplitudeTest);
                    },
                  ),
                  Container(height: 1, color: hairline),
                  _SettingsNavRow(
                    icon: Icons.gavel_outlined,
                    iconColor: scheme.onSurfaceVariant,
                    title: 'Privacy policy & Terms',
                    subtitle:
                        'Privacy Policy, Terms of Service & Health Disclaimer',
                    onTap: () {
                      Navigator.of(context).pushNamed(RouteNames.settingsLegal);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsNavRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
