import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/models/user_profile.dart';
import 'package:workout_app/models/user_stats.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/services/base_api_service.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/coach_rating_display.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/profile_sections.dart';
import 'package:workout_app/widgets/review_card.dart';
import 'package:workout_app/widgets/review_form_dialog.dart';
import 'package:workout_app/widgets/user_profile_view.dart';

class PublicUserProfileScreen extends ConsumerWidget {
  final String userId;
  final String? initialName;

  const PublicUserProfileScreen({
    super.key,
    required this.userId,
    this.initialName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicUserProfileProvider(userId));
    final aggregatesAsync = ref.watch(publicProfileAggregatesProvider(userId));
    final env = ref.watch(activeTrainingEnvironmentProvider(null));

    return AssistantChatHost(
      builder: (context, openChat) {
        return AmbientScaffoldShell(
          environment: env,
          appBar: PrimaryAppBar(
            title: initialName ?? 'Profile',
            onTitleTap: openChat,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(publicUserProfileProvider(userId));
              ref.invalidate(publicProfileAggregatesProvider(userId));
              ref.invalidate(coachReviewsProvider(userId));
              await Future.wait([
                ref.read(publicUserProfileProvider(userId).future),
                ref.read(publicProfileAggregatesProvider(userId).future),
                ref.read(coachReviewsProvider(userId).future),
              ]);
            },
            child: profileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(context, ref, error),
              data: (profile) {
                return aggregatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _buildErrorState(context, ref, error),
                  data: (stats) => _buildContent(context, ref, profile, stats),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(dims.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: instrument.peakEffortColor,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load profile: $error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            InstrumentActionButton(
              label: 'Retry',
              icon: Icons.refresh,
              variant: InstrumentActionVariant.primary,
              onPressed: () {
                ref.invalidate(publicUserProfileProvider(userId));
                ref.invalidate(publicProfileAggregatesProvider(userId));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    UserStats stats,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isSelf = currentUser != null && currentUser.uid == profile.userId;
    final coaching = profile.coaching;
    final canRequestCoaching = !isSelf && coaching != null && coaching.enabled;
    final dims = UiDimensions.of(context);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        dims.pagePadding,
        AmbientScaffoldShell.topContentInset(context),
        dims.pagePadding,
        AmbientScaffoldShell.bottomContentInset(context),
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: UserProfileView(
              profile: profile,
              isOwner: false,
              subtitle: profile.userId,
              onRequestCoaching: canRequestCoaching
                  ? () => _showRequestDialog(context, ref, profile)
                  : null,
              showCoachingCard: true,
              additionalSections: [
                SizedBox(height: dims.sectionGap),
                ProfileStatsRow(stats: stats, padding: EdgeInsets.zero),
              ],
            ),
          ),
        ),
        SizedBox(height: dims.sectionGap),
        ProfileActivitySection(stats: stats, padding: EdgeInsets.zero),
        SizedBox(height: dims.sectionGap),
        ProfileCompletedWorkoutsSection(
          sessions: stats.completedSessions,
          padding: EdgeInsets.zero,
          onSessionTap: (session) {
            Navigator.of(context).pushNamed('/session-log', arguments: session);
          },
        ),
        if (coaching != null && coaching.enabled) ...[
          SizedBox(height: dims.sectionGap),
          _buildReviewsSection(context, ref, profile),
        ],
      ],
    );
  }

  Future<void> _showRequestDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final noteController = TextEditingController();
    final result = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: 'COACHING REQUEST',
      title: 'Request coaching from ${profile.displayName ?? profile.userId}',
      content: TextField(
        controller: noteController,
        decoration: InstrumentTheme.inputDecoration(
          context,
          labelText: 'Message (optional)',
        ),
        maxLines: 3,
      ),
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: 'Cancel',
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        InstrumentActionButton(
          label: 'Send',
          variant: InstrumentActionVariant.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );

    if (result != true) return;

    try {
      final svc = ref.read(sl.crmRelationshipsServiceProvider);
      await svc.requestCoaching(
        coachId: profile.userId,
        note: noteController.text.trim(),
      );
      if (context.mounted) {
        showAppSnackBar(context, 'Request sent');
      }
    } catch (e) {
      if (context.mounted) {
        final message = e is ApiException
            ? e.message
            : 'Failed to send request: $e';
        showAppSnackBar(context, message, isError: true);
      }
    }
  }

  Widget _buildReviewsSection(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) {
    final reviewsAsync = ref.watch(coachReviewsProvider(profile.userId));
    final coaching = profile.coaching;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isSelf = currentUser != null && currentUser.uid == profile.userId;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Reviews',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (coaching != null && coaching.averageRating != null)
              CoachRatingDisplay(
                averageRating: coaching.averageRating,
                reviewCount: coaching.reviewCount,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isSelf && coaching != null && coaching.enabled) ...[
          InstrumentActionButton(
            label: 'Write a Review',
            icon: Icons.star_rounded,
            variant: InstrumentActionVariant.primary,
            onPressed: () => _showReviewDialog(context, ref, profile),
          ),
          const SizedBox(height: 12),
        ],
        reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Failed to load reviews',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          data: (response) {
            if (response.reviews.isEmpty) {
              return Container(
                decoration: InstrumentTheme.instrumentCardDecoration(
                  context,
                  radius: 18,
                ),
                padding: EdgeInsets.all(dims.cardPadding),
                child: Center(
                  child: Text(
                    'No reviews yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: response.reviews
                  .map((review) => ReviewCard(review: review))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final svc = ref.read(sl.crmRelationshipsServiceProvider);
      final links = await svc.getMyCoaches(status: 'active');
      final link = links.firstWhere(
        (l) => l.coachId == profile.userId,
        orElse: () => throw Exception('No active coaching relationship found'),
      );

      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder: (ctx) => ReviewFormDialog(
          linkId: link.id,
          coachName: profile.displayName ?? profile.userId,
          onSubmit: (linkId, rating, comment) async {
            final reviewSvc = ref.read(sl.crmReviewsServiceProvider);
            await reviewSvc.createReview(
              linkId: linkId,
              rating: rating,
              comment: comment,
            );
            ref.invalidate(coachReviewsProvider(profile.userId));
            ref.invalidate(publicUserProfileProvider(profile.userId));
          },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, 'Cannot review: $e', isError: true);
      }
    }
  }
}
