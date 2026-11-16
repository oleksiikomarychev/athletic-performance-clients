import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/theme/ui_dimensions.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/providers/ambient_environment_provider.dart';
import 'package:workout_app/providers/interface_maker_provider.dart';
import 'package:workout_app/services/service_locator.dart' as sl;
import 'package:workout_app/src/widgets/snack_utils.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/responsive_container.dart';

enum _SocialFeedFilter { all, withStats, liked }

final _socialFeedFilterProvider = StateProvider<_SocialFeedFilter>(
  (_) => _SocialFeedFilter.all,
);

final socialFeedProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final svc = ref.watch(sl.socialServiceProvider);
  final posts = await svc.getWorkoutFeed(limit: 20, expand: 'reactions');

  final authorIds = posts
      .map((p) => p['firebase_uid']?.toString())
      .whereType<String>()
      .toSet()
      .toList();

  final authors = await svc.getUsersByIds(authorIds);
  final authorsMap = {for (var a in authors) a['user_id'].toString(): a};

  return {'posts': posts, 'authors': authorsMap};
});

class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFeed = ref.watch(socialFeedProvider);
    final activeFilter = ref.watch(_socialFeedFilterProvider);
    final env = ref.watch(activeTrainingEnvironmentProvider(null));
    final instrument = InstrumentTheme.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dims = UiDimensions.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hairline =
        (isDark ? instrument.hairlineBorder : scheme.outlineVariant).withValues(
          alpha: 0.65,
        );

    return AssistantChatHost(
      builder: (context, openChat) {
        final l10n = AppLocalizations.of(context);
        return AmbientScaffoldShell(
          environment: env,
          extendBody: false,
          appBar: PrimaryAppBar(
            title: l10n.workoutFeedTitle,
            onTitleTap: openChat,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: () => ref.refresh(socialFeedProvider),
              ),
            ],
          ),
          body: asyncFeed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(dims.pagePadding),
                child: Text(
                  l10n.genericError('$error'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            data: (data) {
              final rawPosts = data['posts'] as List<Map<String, dynamic>>;
              final authors = data['authors'] as Map<String, dynamic>;

              final filteredPosts = rawPosts.where((post) {
                if (activeFilter == _SocialFeedFilter.withStats) {
                  final attachments = post['attachments'];
                  return attachments is List &&
                      attachments.whereType<Map>().any(
                        (att) => att['type'] == 'workout_stats',
                      );
                }
                if (activeFilter == _SocialFeedFilter.liked) {
                  final reactions = post['reactions'] as List<dynamic>? ?? [];
                  return reactions.any(
                    (r) =>
                        r is Map &&
                        r['type'] == 'like' &&
                        (r['user_reacted'] == true),
                  );
                }
                return true;
              }).toList();

              return RefreshIndicator(
                onRefresh: () => ref.refresh(socialFeedProvider.future),
                child: ResponsiveContainer(
                  maxWidth: Breakpoints.maxContentWidthNarrow,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      AmbientScaffoldShell.topContentInset(context),
                      0,
                      24,
                    ),
                    children: [
                      CanvasPillStrip(
                        padding: EdgeInsets.symmetric(
                          horizontal: dims.pagePadding,
                        ),
                        items: [
                          CanvasPillItem(
                            key: const ValueKey('feed_all'),
                            label: l10n.allPostsLabel,
                            selected: activeFilter == _SocialFeedFilter.all,
                            onTap: () =>
                                ref
                                        .read(_socialFeedFilterProvider.notifier)
                                        .state =
                                    _SocialFeedFilter.all,
                          ),
                          CanvasPillItem(
                            key: const ValueKey('feed_stats'),
                            label: l10n.withStatsLabel,
                            icon: Icons.bar_chart_rounded,
                            selected:
                                activeFilter == _SocialFeedFilter.withStats,
                            accentColor: instrument.workingAura,
                            onTap: () =>
                                ref
                                        .read(_socialFeedFilterProvider.notifier)
                                        .state =
                                    _SocialFeedFilter.withStats,
                          ),
                          CanvasPillItem(
                            key: const ValueKey('feed_liked'),
                            label: l10n.likedLabel,
                            icon: Icons.favorite_outline,
                            selected: activeFilter == _SocialFeedFilter.liked,
                            accentColor: instrument.peakEffortColor,
                            onTap: () =>
                                ref
                                        .read(_socialFeedFilterProvider.notifier)
                                        .state =
                                    _SocialFeedFilter.liked,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (filteredPosts.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(dims.pagePadding * 2),
                          child: Center(
                            child: Text(
                              'No posts yet.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        for (final post in filteredPosts) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: dims.pagePadding,
                            ),
                            child: _SocialPostModule(
                              post: post,
                              authors: authors,
                              hairline: hairline,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? InstrumentPalette.obsidianDock.withValues(alpha: 0.94)
                  : scheme.surface.withValues(alpha: 0.96),
              border: Border(top: BorderSide(color: hairline, width: 1.0)),
            ),
            child: SafeArea(
              top: false,
              child: ResponsiveContainer(
                maxWidth: Breakpoints.maxContentWidthNarrow,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    dims.pagePadding,
                    10,
                    dims.pagePadding,
                    10,
                  ),
                  child: InstrumentActionButton(
                    label: l10n.createPostLabel,
                    icon: Icons.add,
                    variant: InstrumentActionVariant.primary,
                    expanded: true,
                    onPressed: () => _showCreatePostDialog(context, ref),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePostDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contentController = TextEditingController();
    String selectedScope = 'public';

    showInstrumentDialog<void>(
      context: context,
      eyebrow: l10n.socialFeedEyebrow,
      title: l10n.createPostLabel,
      content: StatefulBuilder(
        builder: (dialogCtx, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InstrumentTheme.inputDecoration(
                  dialogCtx,
                  hintText: "What's on your mind?",
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.visibilityUpperLabel,
                style: InstrumentTheme.microLabel(dialogCtx),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InstrumentSelectablePill(
                    label: l10n.visibilityPublic,
                    selected: selectedScope == 'public',
                    bordered: false,
                    onTap: () => setState(() => selectedScope = 'public'),
                  ),
                  InstrumentSelectablePill(
                    label: l10n.visibilityFollowers,
                    selected: selectedScope == 'followers',
                    bordered: false,
                    onTap: () => setState(() => selectedScope = 'followers'),
                  ),
                  InstrumentSelectablePill(
                    label: l10n.visibilityPrivate,
                    selected: selectedScope == 'private',
                    bordered: false,
                    onTap: () => setState(() => selectedScope = 'private'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actionsBuilder: (dialogCtx) => [
        InstrumentActionButton(
          label: l10n.cancel,
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(dialogCtx).pop(),
        ),
        InstrumentActionButton(
          label: l10n.postLabel,
          variant: InstrumentActionVariant.primary,
          onPressed: () async {
            final content = contentController.text.trim();
            if (content.isEmpty) return;

            final socialSvc = ref.read(sl.socialServiceProvider);
            try {
              await socialSvc.createWorkoutPost(
                content: content,
                scope: selectedScope,
              );
              if (dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop();
              }
              ref.invalidate(socialFeedProvider);
            } catch (e) {
              if (context.mounted) {
                showAppSnackBar(
                  context,
                  'Error creating post: $e',
                  isError: true,
                );
              }
            }
          },
        ),
      ],
    );
  }
}

class _SocialPostModule extends ConsumerWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> authors;
  final Color hairline;

  const _SocialPostModule({
    required this.post,
    required this.authors,
    required this.hairline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final instrument = InstrumentTheme.of(context);
    final dims = UiDimensions.of(context);

    final authorId = post['firebase_uid']?.toString();
    final author = authors[authorId] as Map<String, dynamic>?;
    final authorName = author?['display_name']?.toString() ?? 'Unknown';
    final authorPhoto = author?['photo_url']?.toString();
    final content = post['content']?.toString() ?? '';
    final createdAt = post['created_at']?.toString();
    final createdDate = createdAt == null ? null : DateTime.tryParse(createdAt);
    final displayDate = createdDate == null
        ? (createdAt ?? '')
        : DateFormat('dd.MM.yyyy HH:mm').format(createdDate.toLocal());

    final reactions = post['reactions'] as List<dynamic>? ?? [];
    final likeReaction = reactions.firstWhere(
      (r) => r['type'] == 'like',
      orElse: () => {'count': 0, 'user_reacted': false},
    );
    final likeCount = likeReaction['count'] as int? ?? 0;
    final userReacted = likeReaction['user_reacted'] as bool? ?? false;

    final stats = (post['attachments'] is List)
        ? (post['attachments'] as List).whereType<Map>().firstWhere(
            (att) => att['type'] == 'workout_stats',
            orElse: () => const {},
          )
        : const {};

    final statEntries = stats.entries
        .where((e) => e.key.toString() != 'type')
        .toList();

    return Container(
      decoration: InstrumentTheme.instrumentCardDecoration(context, radius: 22),
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
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: instrument.workingAura.withValues(
                    alpha: 0.16,
                  ),
                  backgroundImage: authorPhoto != null
                      ? NetworkImage(authorPhoto)
                      : null,
                  child: authorPhoto == null
                      ? Icon(
                          Icons.person,
                          color: instrument.workingAura,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: InstrumentTheme.tabular(
                          (theme.textTheme.bodySmall ?? const TextStyle())
                              .copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: hairline),
          Padding(
            padding: EdgeInsets.all(dims.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
                if (statEntries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InstrumentMetricMatrix(
                    cells: statEntries
                        .take(4)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (entry) => InstrumentMetricCellData(
                            slot: MetricSlot.values[
                              entry.key % MetricSlot.values.length
                            ],
                            label: entry.value.key.toString().toUpperCase(),
                            value: '${entry.value.value}',
                            valueColor: instrument.workingAura,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Container(height: 1, color: hairline),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: dims.cardPadding,
              vertical: 6,
            ),
            child: Row(
              children: [
                Text(
                  'WORKOUT LOG',
                  style: InstrumentTheme.microLabel(context),
                ),
                const Spacer(),
                Text(
                  '$likeCount',
                  style: InstrumentTheme.tabular(
                    (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w700,
                      color: userReacted
                          ? instrument.peakEffortColor
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    userReacted ? Icons.favorite : Icons.favorite_border,
                    color: userReacted
                        ? instrument.peakEffortColor
                        : scheme.onSurfaceVariant,
                  ),
                  tooltip: AppLocalizations.of(context).likeLabel,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () {
                    final socialSvc = ref.read(sl.socialServiceProvider);
                    socialSvc.toggleReaction(
                      postId: post['id'].toString(),
                      reactionType: 'like',
                    );
                    ref.invalidate(socialFeedProvider);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
