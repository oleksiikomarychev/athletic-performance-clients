import 'package:flutter/material.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_profile.dart';
import 'package:workout_app/widgets/instrument_modal.dart';

class UserProfileView extends StatelessWidget {
  final UserProfile profile;
  final bool isOwner;
  final String? subtitle;
  final String? avatarUrlOverride;
  final VoidCallback? onEditProfile;
  final VoidCallback? onManageCoaching;
  final VoidCallback? onAvatarTool;
  final VoidCallback? onRequestCoaching;
  final List<Widget> additionalSections;
  final bool showCoachingCard;

  const UserProfileView({
    super.key,
    required this.profile,
    required this.isOwner,
    this.subtitle,
    this.avatarUrlOverride,
    this.onEditProfile,
    this.onManageCoaching,
    this.onAvatarTool,
    this.onRequestCoaching,
    this.additionalSections = const [],
    this.showCoachingCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(context),
        if ((profile.bio ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            profile.bio!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
        if (showCoachingCard) ...[
          SizedBox(height: dims.sectionGap),
          _buildCoachingCard(context),
        ],
        ...additionalSections,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final avatarUrl = avatarUrlOverride ?? profile.photoUrl;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final initial = (profile.displayName?.isNotEmpty ?? false)
        ? profile.displayName!.substring(0, 1).toUpperCase()
        : (profile.userId.isNotEmpty
              ? profile.userId.substring(0, 1).toUpperCase()
              : '?');

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: dims.avatarRadius,
              backgroundColor: instrument.workingAura.withValues(alpha: 0.16),
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initial,
                      style: TextStyle(
                        fontSize: dims.avatarRadius * 0.7,
                        fontWeight: FontWeight.w800,
                        color: instrument.workingAura,
                      ),
                    )
                  : null,
            ),
            if (isOwner && onAvatarTool != null)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.brightness == Brightness.dark
                      ? InstrumentPalette.obsidianCardLow
                      : scheme.surface,
                  border: Border.all(
                    color: instrument.hairlineBorder.withValues(alpha: 0.8),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: instrument.workingAura,
                  ),
                  onPressed: onAvatarTool,
                  tooltip: 'Avatar',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: dims.rowGap),
        Text(
          profile.displayName ?? 'User ${profile.userId}',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: dims.profileNameFontSize,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle ?? profile.userId,
          textAlign: TextAlign.center,
          style: InstrumentTheme.tabular(
            (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (isOwner && (onEditProfile != null || onManageCoaching != null)) ...[
          SizedBox(height: dims.rowGap),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (onEditProfile != null)
                InstrumentActionButton(
                  label: l10n.editProfileButton,
                  icon: Icons.edit_outlined,
                  variant: InstrumentActionVariant.secondary,
                  onPressed: onEditProfile,
                ),
              if (onManageCoaching != null)
                InstrumentActionButton(
                  label: l10n.coachingSettingsButton,
                  icon: Icons.workspace_premium_outlined,
                  variant: InstrumentActionVariant.secondary,
                  onPressed: onManageCoaching,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCoachingCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final coaching = profile.coaching;
    final enabled = coaching?.enabled ?? false;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);
    final hairline =
        (theme.brightness == Brightness.dark
                ? instrument.hairlineBorder
                : scheme.outlineVariant)
            .withValues(alpha: 0.65);

    return Container(
      width: double.infinity,
      decoration: InstrumentTheme.instrumentCardDecoration(
        context,
        accentColor: enabled ? instrument.successColor : null,
        radius: 22,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              dims.cardPadding,
              dims.cardPadding,
              dims.cardPadding,
              12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: enabled
                      ? instrument.successColor
                      : scheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COACHING STATUS',
                        style: InstrumentTheme.microLabel(
                          context,
                          color: enabled
                              ? instrument.successColor
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.coachingTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    enabled
                        ? l10n.coachingAcceptingNewClients.toUpperCase()
                        : l10n.coachingDisabled.toUpperCase(),
                    textAlign: TextAlign.end,
                    style: InstrumentTheme.microLabel(
                      context,
                      color: enabled
                          ? instrument.successColor
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: hairline),
          Padding(
            padding: EdgeInsets.all(dims.cardPadding),
            child: !enabled
                ? Text(
                    l10n.coachingDisabledDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if ((coaching?.tagline?.isNotEmpty ?? false)) ...[
                        Text(
                          coaching!.tagline!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if ((coaching?.description?.isNotEmpty ?? false)) ...[
                        Text(
                          coaching!.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if ((coaching?.specializations ?? []).isNotEmpty)
                        _bareDetailRow(
                          context,
                          hairline: hairline,
                          label: l10n.coachingSpecializations,
                          value: coaching!.specializations.join(', '),
                        ),
                      if ((coaching?.languages ?? []).isNotEmpty)
                        _bareDetailRow(
                          context,
                          hairline: hairline,
                          label: l10n.coachingLanguages,
                          value: coaching!.languages.join(', '),
                        ),
                      if (coaching?.ratePlan != null)
                        _bareDetailRow(
                          context,
                          hairline: hairline,
                          label: l10n.coachingRate,
                          value: coaching!.ratePlan!.amountMinor != null
                              ? '${(coaching.ratePlan!.amountMinor! / 100).toStringAsFixed(0)} USD / month'
                              : l10n.coachingCustomRate,
                          accentColor: instrument.workingAura,
                        ),
                      if (!isOwner && onRequestCoaching != null) ...[
                        const SizedBox(height: 14),
                        InstrumentActionButton(
                          label: l10n.requestCoaching,
                          icon: Icons.handshake_outlined,
                          variant: InstrumentActionVariant.primary,
                          expanded: true,
                          onPressed: enabled ? onRequestCoaching : null,
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bareDetailRow(
    BuildContext context, {
    required Color hairline,
    required String label,
    required String value,
    Color? accentColor,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: InstrumentTheme.microLabel(context),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: InstrumentTheme.tabular(
              (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w600,
                color: accentColor ?? scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
