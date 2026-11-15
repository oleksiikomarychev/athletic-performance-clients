import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/features/auth/auth_service.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_profile.dart';
import 'package:workout_app/providers/app_locale_provider.dart';
import 'package:workout_app/providers/app_theme_mode_provider.dart';
import 'package:workout_app/providers/app_ui_density_provider.dart';
import 'package:workout_app/providers/profile_screen_sections_provider.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/services/user_analytics_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

class SettingsGeneralScreen extends ConsumerStatefulWidget {
  const SettingsGeneralScreen({super.key});

  @override
  ConsumerState<SettingsGeneralScreen> createState() =>
      _SettingsGeneralScreenState();
}

class _SettingsGeneralScreenState extends ConsumerState<SettingsGeneralScreen> {
  bool _trackedOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_trackedOpen || !mounted) return;
      _trackedOpen = true;
      final profileAsync = ref.read(userProfileProvider);
      final profile = profileAsync.value;
      await UserAnalyticsService.instance.trackScreenOpen(
        'settings_general',
        properties: {
          'coaching_enabled': profile?.coaching?.enabled ?? false,
          'coaching_eligible': profile?.coachingEligibility?.eligible ?? false,
          'has_stripe_account':
              profile?.coaching?.stripeConnectAccountId != null,
        },
      );
    });
  }

  double _calculateProfileCompletionScore(
    String tagline,
    String description,
    List<String> specializations,
    List<String> languages,
    String? rateType,
  ) {
    int score = 0;
    const int maxScore = 5;
    if (tagline.isNotEmpty) score++;
    if (description.isNotEmpty) score++;
    if (specializations.isNotEmpty) score++;
    if (languages.isNotEmpty) score++;
    if (rateType != null) score++;
    return score / maxScore;
  }

  void _showStatusSnack(String message, {Color? accentColor}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final instrument = InstrumentTheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: accentColor ??
            (theme.brightness == Brightness.dark
                ? InstrumentPalette.obsidianCardMid
                : theme.colorScheme.inverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: instrument.hairlineBorder, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final density = ref.watch(appUiDensityProvider);
    final sectionPrefs = ref.watch(profileScreenSectionsProvider);
    final languageCode = ref.watch(appLocaleProvider)?.languageCode;

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

    return AmbientScaffoldShell(
      appBar: PrimaryAppBar.detail(title: 'General settings'),
      body: ResponsiveContainer(
        maxWidth: Breakpoints.maxContentWidthNarrow,
        child: profileAsync.when(
          loading: () => Padding(
            padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
            child: Center(
              child: CircularProgressIndicator(
                color: instrument.workingAura,
                strokeWidth: 2.5,
              ),
            ),
          ),
          error: (e, _) => Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, bottomInset + 24),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: InstrumentTheme.instrumentCardDecoration(
                  context,
                  accentColor: instrument.peakEffortColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROFILE LOAD ERROR',
                      style: InstrumentTheme.microLabel(
                        context,
                        color: instrument.peakEffortColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load profile: $e',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InstrumentActionButton(
                      label: 'Retry',
                      icon: Icons.refresh_rounded,
                      variant: InstrumentActionVariant.secondary,
                      onPressed: () => ref.invalidate(userProfileProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (profile) {
            final timezone = profile.settings.timezone ?? '';
            final coaching = profile.coaching;
            final coachingEnabled = coaching?.enabled ?? false;
            final eligibleForCoaching =
                profile.coachingEligibility?.eligible ?? false;

            Future<void> setLanguage(String? code) async {
              final ctrl = ref.read(appLocaleProvider.notifier);
              final svc = ref.read(sl.profileServiceProvider);
              if (code == null) {
                await ctrl.setSystemLocale();
                await svc.updateSettings(locale: null);
              } else {
                await ctrl.setLocaleCode(code);
                await svc.updateSettings(locale: code);
              }
              ref.invalidate(userProfileProvider);
            }

            Future<void> setCoachingEnabled(bool value) async {
              await UserAnalyticsService.instance.trackUserAction(
                'coaching_status_change',
                properties: {
                  'action': value ? 'enable' : 'disable',
                  'previous_status': coachingEnabled ? 'enabled' : 'disabled',
                  'new_status': value ? 'enabled' : 'disabled',
                  'screen': 'settings_general',
                },
              );

              try {
                final svc = ref.read(sl.profileServiceProvider);
                await svc.updateCoachingProfile(enabled: value);
                ref.invalidate(userProfileProvider);
                _showStatusSnack(
                  value ? 'Coaching enabled' : 'Coaching disabled',
                );
              } catch (e) {
                _showStatusSnack(
                  'Failed to update coaching: $e',
                  accentColor: instrument.peakEffortColor,
                );
              }
            }

            Future<void> showCoachingSettingsDialog() async {
              await UserAnalyticsService.instance.trackUserAction(
                'coaching_settings_open',
                properties: {
                  'screen': 'settings_general',
                  'action': 'open_settings_dialog',
                  'coaching_enabled': coachingEnabled,
                },
              );

              if (!context.mounted) return;
              final formKey = GlobalKey<_CoachingSettingsDialogFormState>();
              final draft = await showInstrumentDialog<_CoachingDraft>(
                context: context,
                eyebrow: 'COACH PROFILE',
                title: 'Coaching settings',
                content: _CoachingSettingsDialogForm(
                  key: formKey,
                  initialEnabled: coaching?.enabled ?? false,
                  initialTagline: coaching?.tagline ?? '',
                  initialDescription: coaching?.description ?? '',
                  initialSpecializations: coaching?.specializations ?? const [],
                  initialLanguages: coaching?.languages ?? const [],
                  initialRateText: coaching?.ratePlan?.amountMinor != null
                      ? (coaching!.ratePlan!.amountMinor! / 100)
                          .toStringAsFixed(0)
                      : '',
                ),
                actionsBuilder: (ctx) => [
                  InstrumentActionButton(
                    label: l10n.cancel,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(null),
                  ),
                  InstrumentActionButton(
                    label: l10n.save,
                    variant: InstrumentActionVariant.primary,
                    onPressed: () => Navigator.of(ctx).pop(
                      formKey.currentState?.buildDraft(),
                    ),
                  ),
                ],
              );

              if (draft == null) return;

              int? parseAmount(String text) {
                if (text.trim().isEmpty) return null;
                final value = double.tryParse(text.trim());
                if (value == null) return null;
                return (value * 100).round();
              }

              final svc = ref.read(sl.profileServiceProvider);

              try {
                await UserAnalyticsService.instance.trackUserAction(
                  'coaching_profile_update',
                  properties: {
                    'screen': 'settings_general',
                    'action': 'save_coaching_settings',
                    'enabled': draft.enabled,
                    'has_tagline': draft.tagline.isNotEmpty,
                    'has_description': draft.description.isNotEmpty,
                    'has_specializations': draft.specializations.isNotEmpty,
                    'has_languages': draft.languages.isNotEmpty,
                    'has_rate_plan': draft.rateAmountText.isNotEmpty,
                  },
                );

                await svc.updateCoachingProfile(
                  enabled: draft.enabled,
                  tagline: draft.tagline,
                  description: draft.description,
                  specializations: draft.specializations,
                  languages: draft.languages,
                  ratePlan: draft.rateAmountText.isNotEmpty
                      ? CoachingRatePlan(
                          amountMinor: parseAmount(draft.rateAmountText),
                        )
                      : null,
                );
                ref.invalidate(userProfileProvider);

                final currentCoaching = profile.coaching;
                final wasPreviouslyEnabled = currentCoaching?.enabled ?? false;
                final hasCompleteProfile = draft.tagline.isNotEmpty &&
                    draft.description.isNotEmpty &&
                    draft.specializations.isNotEmpty;

                if (!wasPreviouslyEnabled &&
                    draft.enabled &&
                    hasCompleteProfile) {
                  await UserAnalyticsService.instance
                      .trackTrainerProfilePublished(
                    properties: {
                      'has_tagline': draft.tagline.isNotEmpty,
                      'has_description': draft.description.isNotEmpty,
                      'has_specializations': draft.specializations.isNotEmpty,
                      'has_languages': draft.languages.isNotEmpty,
                      'has_rate_plan': draft.rateAmountText.isNotEmpty,
                      'profile_completion_score':
                          _calculateProfileCompletionScore(
                        draft.tagline,
                        draft.description,
                        draft.specializations,
                        draft.languages,
                        draft.rateAmountText.isNotEmpty ? 'per_month' : null,
                      ),
                    },
                  );
                }

                _showStatusSnack('Coaching profile updated');
              } catch (e) {
                final message = e is ApiException
                    ? e.message
                    : 'Failed to update coaching profile: $e';
                _showStatusSnack(
                  message,
                  accentColor: instrument.peakEffortColor,
                );
              }
            }

            Future<void> setTimezone(String? value) async {
              final svc = ref.read(sl.profileServiceProvider);
              final trimmed = (value ?? '').trim();
              await svc.updateSettings(
                timezone: trimmed.isEmpty ? null : trimmed,
              );
              ref.invalidate(userProfileProvider);
            }

            Future<void> setPublicProfile(bool value) async {
              final svc = ref.read(sl.profileServiceProvider);
              await svc.updateProfile(isPublic: value);
              ref.invalidate(userProfileProvider);
            }

            String languageSubtitle() {
              if (languageCode == null) return l10n.languageSystem;
              switch (languageCode) {
                case 'en':
                  return l10n.languageEnglish;
                case 'uk':
                  return l10n.languageUkrainian;
                default:
                  return languageCode;
              }
            }

            String themeSubtitle() {
              switch (themeMode) {
                case ThemeMode.system:
                  return 'System';
                case ThemeMode.light:
                  return 'Light';
                case ThemeMode.dark:
                  return 'Dark';
              }
            }

            Future<void> pickThemeMode() async {
              final selected = await showInstrumentBottomSheet<ThemeMode>(
                context: context,
                eyebrow: 'APPEARANCE',
                title: 'Theme mode',
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetOptionRow(
                      label: 'System',
                      selected: themeMode == ThemeMode.system,
                      onTap: () => Navigator.of(ctx).pop(ThemeMode.system),
                    ),
                    _SheetHairline(),
                    _SheetOptionRow(
                      label: 'Light',
                      selected: themeMode == ThemeMode.light,
                      onTap: () => Navigator.of(ctx).pop(ThemeMode.light),
                    ),
                    _SheetHairline(),
                    _SheetOptionRow(
                      label: 'Dark',
                      selected: themeMode == ThemeMode.dark,
                      onTap: () => Navigator.of(ctx).pop(ThemeMode.dark),
                    ),
                  ],
                ),
              );
              if (selected == null) return;
              await ref.read(appThemeModeProvider.notifier).setThemeMode(
                    selected,
                  );
            }

            Future<void> pickDensity() async {
              final selected = await showInstrumentBottomSheet<UiDensity>(
                context: context,
                eyebrow: 'LAYOUT SCALE',
                title: 'Interface size',
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetOptionRow(
                      label: 'Compact',
                      subtitle: 'Less space between elements',
                      selected: density == UiDensity.compact,
                      onTap: () => Navigator.of(ctx).pop(UiDensity.compact),
                    ),
                    _SheetHairline(),
                    _SheetOptionRow(
                      label: 'Comfortable',
                      subtitle: 'More space between elements',
                      selected: density == UiDensity.comfortable,
                      onTap: () => Navigator.of(ctx).pop(UiDensity.comfortable),
                    ),
                  ],
                ),
              );
              if (selected != null) {
                await ref.read(appUiDensityProvider.notifier).setDensity(
                      selected,
                    );
              }
            }

            Future<void> pickLanguage() async {
              final selected =
                  await showInstrumentBottomSheet<({String? code})>(
                context: context,
                eyebrow: 'LOCALIZATION',
                title: l10n.language,
                builder: (ctx) {
                  final current = languageCode;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SheetOptionRow(
                        label: l10n.languageSystem,
                        selected: current == null,
                        onTap: () => Navigator.of(ctx).pop((code: null)),
                      ),
                      _SheetHairline(),
                      _SheetOptionRow(
                        label: l10n.languageEnglish,
                        selected: current == 'en',
                        onTap: () => Navigator.of(ctx).pop((code: 'en')),
                      ),
                      _SheetHairline(),
                      _SheetOptionRow(
                        label: l10n.languageUkrainian,
                        selected: current == 'uk',
                        onTap: () => Navigator.of(ctx).pop((code: 'uk')),
                      ),
                    ],
                  );
                },
              );
              if (selected == null || selected.code == languageCode) return;
              await setLanguage(selected.code);
            }

            Future<void> editTimezone() async {
              final formKey = GlobalKey<_TimezoneDialogFormState>();
              final result = await showInstrumentDialog<String?>(
                context: context,
                eyebrow: 'REGION & CLOCK',
                title: l10n.timezone,
                content: _TimezoneDialogForm(
                  key: formKey,
                  initialTimezone: timezone,
                ),
                actionsBuilder: (ctx) => [
                  InstrumentActionButton(
                    label: l10n.cancel,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(null),
                  ),
                  InstrumentActionButton(
                    label: l10n.save,
                    variant: InstrumentActionVariant.primary,
                    onPressed: () => Navigator.of(ctx).pop(
                      formKey.currentState?.value,
                    ),
                  ),
                ],
              );
              if (result == null) return;
              await setTimezone(result);
            }

            Future<void> signOut() async {
              final ok = await showInstrumentDialog<bool>(
                context: context,
                eyebrow: 'SESSION ACCESS',
                title: 'Sign out',
                message: 'Are you sure you want to sign out?',
                actionsBuilder: (ctx) => [
                  InstrumentActionButton(
                    label: l10n.cancel,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  InstrumentActionButton(
                    label: 'Sign out',
                    variant: InstrumentActionVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              );
              if (ok != true) return;
              await AuthService().signOut();
            }

            Future<void> deleteAccount() async {
              final ok = await showInstrumentDialog<bool>(
                context: context,
                eyebrow: 'IRREVERSIBLE ACTION',
                title: 'Delete account',
                message:
                    'This will schedule deletion of your account data. Continue?',
                accentColor: instrument.peakEffortColor,
                actionsBuilder: (ctx) => [
                  InstrumentActionButton(
                    label: l10n.cancel,
                    variant: InstrumentActionVariant.secondary,
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  InstrumentActionButton(
                    label: 'Delete',
                    variant: InstrumentActionVariant.destructive,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              );
              if (ok != true) return;

              try {
                final svc = ref.read(sl.accountServiceProvider);
                await svc.purgeAccount();
                await AuthService().signOut();
                _showStatusSnack('Account deletion scheduled');
              } catch (e) {
                _showStatusSnack(
                  'Failed to delete account: $e',
                  accentColor: instrument.peakEffortColor,
                );
              }
            }

            Future<void> connectStripe() async {
              await UserAnalyticsService.instance.trackUserAction(
                'stripe_connect_attempt',
                properties: {
                  'screen': 'settings_general',
                  'action': 'connect_stripe',
                  'has_existing_account':
                      coaching?.stripeConnectAccountId != null,
                },
              );

              try {
                final svc = ref.read(sl.profileServiceProvider);
                final response = await svc.createStripeConnectOnboardingLink();
                final url = response['onboarding_url'] as String?;

                if (url != null && await canLaunchUrl(Uri.parse(url))) {
                  await UserAnalyticsService.instance.trackUserAction(
                    'stripe_connect_redirect',
                    properties: {
                      'screen': 'settings_general',
                      'action': 'redirect_to_stripe',
                      'onboarding_url': url,
                    },
                  );
                  _showStatusSnack('Opening Stripe setup...');
                } else {
                  await UserAnalyticsService.instance.trackUserAction(
                    'stripe_connect_failed',
                    properties: {
                      'screen': 'settings_general',
                      'action': 'stripe_redirect_failed',
                      'has_url': url != null,
                    },
                  );
                  _showStatusSnack(
                    'Failed to open Stripe setup',
                    accentColor: instrument.peakEffortColor,
                  );
                }
              } catch (e) {
                await UserAnalyticsService.instance.trackUserAction(
                  'stripe_connect_error',
                  properties: {
                    'screen': 'settings_general',
                    'action': 'stripe_connect_error',
                    'error_message': e.toString(),
                  },
                );
                _showStatusSnack(
                  'Failed to connect Stripe: $e',
                  accentColor: instrument.peakEffortColor,
                );
              }
            }

            return ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                topInset + 8,
                16,
                bottomInset + 24,
              ),
              children: [
                CanvasPillStrip(
                  padding: EdgeInsets.zero,
                  items: [
                    CanvasPillItem(
                      label: 'System',
                      icon: Icons.brightness_auto_outlined,
                      selected: themeMode == ThemeMode.system,
                      onTap: () => ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.system),
                    ),
                    CanvasPillItem(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      selected: themeMode == ThemeMode.light,
                      onTap: () => ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light),
                    ),
                    CanvasPillItem(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      selected: themeMode == ThemeMode.dark,
                      onTap: () => ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _GeneralModuleCard(
                  eyebrow: 'APPEARANCE & LOCALE',
                  title: 'Interface configuration',
                  children: [
                    _GeneralNavRow(
                      title: 'Theme',
                      subtitle: themeSubtitle(),
                      onTap: pickThemeMode,
                    ),
                    _SheetHairline(),
                    _GeneralNavRow(
                      title: 'Interface size',
                      subtitle: density == UiDensity.compact
                          ? 'Compact'
                          : 'Comfortable',
                      onTap: pickDensity,
                    ),
                    _SheetHairline(),
                    _GeneralNavRow(
                      title: l10n.language,
                      subtitle: languageSubtitle(),
                      onTap: pickLanguage,
                    ),
                    _SheetHairline(),
                    _GeneralNavRow(
                      title: l10n.timezone,
                      subtitle: timezone.isEmpty ? 'Not set' : timezone,
                      onTap: editTimezone,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _GeneralModuleCard(
                  eyebrow: 'PROFILE TELEMETRY',
                  title: 'Visibility & charts',
                  children: [
                    _GeneralToggleRow(
                      title: l10n.publicProfile,
                      value: profile.isPublic,
                      onChanged: (v) => setPublicProfile(v),
                    ),
                    _SheetHairline(),
                    _GeneralToggleRow(
                      title: 'Show activity chart',
                      value: sectionPrefs.showActivityChart,
                      onChanged: (v) => ref
                          .read(profileScreenSectionsProvider.notifier)
                          .setShowActivityChart(v),
                    ),
                    _SheetHairline(),
                    _GeneralToggleRow(
                      title: 'Show workout history',
                      value: sectionPrefs.showWorkoutHistory,
                      onChanged: (v) => ref
                          .read(profileScreenSectionsProvider.notifier)
                          .setShowWorkoutHistory(v),
                    ),
                    _SheetHairline(),
                    _GeneralToggleRow(
                      title: 'Show workout analytics',
                      value: sectionPrefs.showWorkoutAnalytics,
                      onChanged: (v) => ref
                          .read(profileScreenSectionsProvider.notifier)
                          .setShowWorkoutAnalytics(v),
                    ),
                    _SheetHairline(),
                    _GeneralToggleRow(
                      title: 'Show all time',
                      value: sectionPrefs.workoutAnalyticsShowAllTime,
                      onChanged: sectionPrefs.showWorkoutAnalytics
                          ? (v) => ref
                              .read(profileScreenSectionsProvider.notifier)
                              .setWorkoutAnalyticsShowAllTime(v)
                          : null,
                    ),
                    _SheetHairline(),
                    _GeneralToggleRow(
                      title: 'Use horizontal scroll',
                      value: sectionPrefs.workoutAnalyticsUseHorizontalScroll,
                      onChanged: sectionPrefs.showWorkoutAnalytics
                          ? (v) => ref
                              .read(profileScreenSectionsProvider.notifier)
                              .setWorkoutAnalyticsUseHorizontalScroll(v)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _GeneralModuleCard(
                  eyebrow: 'COACHING & PAYOUTS',
                  title: 'Trainer controls',
                  children: [
                    _GeneralToggleRow(
                      title: 'Enable coaching',
                      value: coachingEnabled,
                      onChanged: eligibleForCoaching
                          ? (v) => setCoachingEnabled(v)
                          : null,
                    ),
                    _SheetHairline(),
                    _GeneralNavRow(
                      title: 'Coaching settings',
                      subtitle: eligibleForCoaching
                          ? null
                          : 'Not available for this account',
                      onTap: (coachingEnabled || eligibleForCoaching)
                          ? showCoachingSettingsDialog
                          : null,
                    ),
                    if (coachingEnabled &&
                        coaching?.stripeConnectAccountId == null) ...[
                      _SheetHairline(),
                      _GeneralNavRow(
                        title: 'Connect Stripe payouts',
                        subtitle: 'Set up payment processing for coaching',
                        onTap: connectStripe,
                      ),
                    ],
                    if (coachingEnabled &&
                        coaching?.stripeConnectAccountId != null) ...[
                      _SheetHairline(),
                      _GeneralNavRow(
                        title: 'Stripe connected',
                        subtitle: 'Payment processing is set up',
                        trailing: Icon(
                          Icons.check_circle_rounded,
                          color: instrument.successColor,
                          size: 20,
                        ),
                        onTap: connectStripe,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                _GeneralModuleCard(
                  eyebrow: 'ACCOUNT ZONE',
                  title: 'Session & data',
                  children: [
                    _GeneralNavRow(
                      title: 'Sign out',
                      onTap: signOut,
                    ),
                    _SheetHairline(),
                    _GeneralNavRow(
                      title: 'Delete account',
                      titleColor: instrument.peakEffortColor,
                      trailing: Icon(
                        Icons.delete_outline_rounded,
                        color: instrument.peakEffortColor,
                        size: 20,
                      ),
                      onTap: deleteAccount,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GeneralModuleCard extends StatelessWidget {
  final String eyebrow;
  final String title;
  final List<Widget> children;

  const _GeneralModuleCard({
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eyebrow, style: InstrumentTheme.microLabel(context)),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SheetHairline(),
          ...children,
        ],
      ),
    );
  }
}

class _GeneralNavRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _GeneralNavRow({
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    final primaryColor = titleColor ?? scheme.onSurface;
    final mutedColor = scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? primaryColor
                            : primaryColor.withValues(alpha: 0.45),
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: enabled
                              ? mutedColor
                              : mutedColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: enabled
                        ? mutedColor
                        : mutedColor.withValues(alpha: 0.4),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralToggleRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _GeneralToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final enabled = onChanged != null;

    return InkWell(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? scheme.onSurface
                        : scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: instrument.workingAura.withValues(alpha: 0.55),
                activeThumbColor: instrument.workingAura,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOptionRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SheetOptionRow({
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected
                            ? instrument.workingAura
                            : scheme.onSurface,
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
              if (selected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: instrument.workingAura,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHairline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: InstrumentTheme.of(context).hairlineBorder,
    );
  }
}

class _CoachingDraft {
  final bool enabled;
  final String tagline;
  final String description;
  final List<String> specializations;
  final List<String> languages;
  final String rateAmountText;

  const _CoachingDraft({
    required this.enabled,
    required this.tagline,
    required this.description,
    required this.specializations,
    required this.languages,
    required this.rateAmountText,
  });
}

class _CoachingSettingsDialogForm extends StatefulWidget {
  final bool initialEnabled;
  final String initialTagline;
  final String initialDescription;
  final List<String> initialSpecializations;
  final List<String> initialLanguages;
  final String initialRateText;

  const _CoachingSettingsDialogForm({
    super.key,
    required this.initialEnabled,
    required this.initialTagline,
    required this.initialDescription,
    required this.initialSpecializations,
    required this.initialLanguages,
    required this.initialRateText,
  });

  @override
  State<_CoachingSettingsDialogForm> createState() =>
      _CoachingSettingsDialogFormState();
}

class _CoachingSettingsDialogFormState
    extends State<_CoachingSettingsDialogForm> {
  static const _languageOptions = <String, String>{
    'en': 'English',
    'ua': 'Ukrainian',
    'ru': 'Russian',
    'pl': 'Polish',
    'de': 'German',
  };

  static const _specializationOptions = <String, String>{
    'strength': 'Strength Training',
    'hypertrophy': 'Hypertrophy',
    'weight_loss': 'Weight Loss',
    'endurance': 'Endurance',
    'powerlifting': 'Powerlifting',
    'bodybuilding': 'Bodybuilding',
    'functional': 'Functional Training',
    'rehabilitation': 'Rehabilitation',
    'nutrition': 'Nutrition Coaching',
    'online': 'Online Coaching',
    'in_person': 'In-Person Training',
    'youth': 'Youth Training',
    'senior': 'Senior Fitness',
    'mobility': 'Mobility/Flexibility',
  };

  late bool _enabled = widget.initialEnabled;
  late final TextEditingController _taglineController = TextEditingController(
    text: widget.initialTagline,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.initialDescription);
  late final TextEditingController _rateAmountController =
      TextEditingController(text: widget.initialRateText);
  late final Set<String> _selectedSpecializations = {
    ...widget.initialSpecializations,
  };
  late final Set<String> _selectedLanguages = {...widget.initialLanguages};

  @override
  void dispose() {
    _taglineController.dispose();
    _descriptionController.dispose();
    _rateAmountController.dispose();
    super.dispose();
  }

  void _toggleItem(Set<String> set, String key) {
    setState(() {
      if (!set.add(key)) {
        set.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GeneralToggleRow(
          title: 'Enable coaching features',
          value: _enabled,
          onChanged: (v) => setState(() => _enabled = v),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _taglineController,
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: 'Tagline',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: 'Description',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        Text('SPECIALIZATIONS', style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in _specializationOptions.entries)
              InstrumentSelectablePill(
                label: entry.value,
                selected: _selectedSpecializations.contains(entry.key),
                bordered: false,
                onTap: () => _toggleItem(_selectedSpecializations, entry.key),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text('LANGUAGES', style: InstrumentTheme.microLabel(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in _languageOptions.entries)
              InstrumentSelectablePill(
                label: entry.value,
                selected: _selectedLanguages.contains(entry.key),
                bordered: false,
                onTap: () => _toggleItem(_selectedLanguages, entry.key),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _rateAmountController,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InstrumentTheme.inputDecoration(
            context,
            labelText: 'Rate per month (USD)',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 6),
        Text(
          'Amount is entered in dollars (e.g. 120 = \$120.00).',
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  _CoachingDraft buildDraft() => _CoachingDraft(
    enabled: _enabled,
    tagline: _taglineController.text.trim(),
    description: _descriptionController.text.trim(),
    specializations: _selectedSpecializations.toList(),
    languages: _selectedLanguages.toList(),
    rateAmountText: _rateAmountController.text.trim(),
  );
}

class _TimezoneDialogForm extends StatefulWidget {
  final String initialTimezone;

  const _TimezoneDialogForm({
    super.key,
    required this.initialTimezone,
  });

  @override
  State<_TimezoneDialogForm> createState() => _TimezoneDialogFormState();
}

class _TimezoneDialogFormState extends State<_TimezoneDialogForm> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialTimezone,
  );

  String get value => _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InstrumentTheme.inputDecoration(
        context,
        hintText: 'e.g. Europe/Kyiv',
      ),
    );
  }
}
