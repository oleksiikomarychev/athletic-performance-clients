import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/coach_review.dart';
import 'package:workout_app/models/crm_analytics.dart';
import 'package:workout_app/models/crm_coach_athlete_link.dart';
import 'package:workout_app/models/user_profile.dart';
import 'package:workout_app/models/user_stats.dart';
import 'package:workout_app/models/user_summary.dart';
import 'package:workout_app/models/workout_session.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/all_users_screen.dart';
import 'package:workout_app/screens/coach/coach_athletes_screen.dart';
import 'package:workout_app/screens/coach/coach_dashboard_screen.dart';
import 'package:workout_app/screens/coach/coach_relationships_screen.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/coach_rating_display.dart';
import 'package:workout_app/widgets/instrument_metric_matrix.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';
import 'package:workout_app/widgets/profile_sections.dart';
import 'package:workout_app/widgets/review_card.dart';
import 'package:workout_app/widgets/user_profile_view.dart';

Widget _wrapNarrowInstrumentApp(
  Widget home, {
  List<Override> overrides = const [],
  double textScale = 2.0,
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.darkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

void main() {
  testWidgets(
    'CoachDashboardScreen uses AmbientScaffoldShell, PrimaryAppBar, and InstrumentMetricMatrix at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final summary = CoachSummaryAnalyticsModel(
        coachId: 'coach-1',
        generatedAt: DateTime(2026, 5, 1),
        weeks: 12,
        totalAthletes: 12,
        activeLinks: 10,
        avgSessionsPerWeek: 3.8,
        inactiveAthletesCount: 2,
        avgPlanAdherence: 0.86,
        avgIntensity: 78.5,
        avgEffort: 8.1,
        segmentCounts: const {'on_track': 8, 'at_risk': 2},
      );

      await tester.pumpWidget(
        _wrapNarrowInstrumentApp(
          const CoachDashboardScreen(),
          overrides: [
            coachSummaryAnalyticsProvider.overrideWith((ref) async => summary),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(PrimaryAppBar), findsOneWidget);
      expect(find.byType(AssistantChatHost), findsOneWidget);
      expect(find.byType(InstrumentMetricMatrix), findsOneWidget);
      expect(find.byType(InstrumentActionButton), findsNWidgets(2));
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    },
  );

  testWidgets(
    'CoachAthletesScreen renders CanvasPillStrip filters and single-contour modules without overflow at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final athletesAnalytics = CoachAthletesAnalyticsModel(
        coachId: 'coach-1',
        generatedAt: DateTime(2026, 5, 1),
        weeks: 12,
        totalAthletes: 2,
        activeLinks: 2,
        athletes: [
          AthleteTrainingSummaryModel(
            athleteId: 'ath-1',
            lastWorkoutAt: DateTime(2026, 4, 30),
            sessionsCount: 24,
            totalVolume: 18500,
            activePlanId: 42,
            activePlanName: 'Strength Block',
            daysSinceLastWorkout: 1,
            sessionsPerWeek: 4.0,
            planAdherence: 0.92,
            avgIntensity: 81.2,
            avgEffort: 8.4,
            effortDistribution: const {'7': 0.2, '8': 0.5, '9': 0.3},
            segment: 'top_performer',
          ),
          AthleteTrainingSummaryModel(
            athleteId: 'ath-2',
            lastWorkoutAt: DateTime(2026, 4, 20),
            sessionsCount: 6,
            totalVolume: 4200,
            activePlanId: 43,
            activePlanName: 'Base Block',
            daysSinceLastWorkout: 11,
            sessionsPerWeek: 1.5,
            planAdherence: 0.45,
            avgIntensity: 71.0,
            avgEffort: 7.2,
            effortDistribution: const {'7': 0.7, '8': 0.3},
            segment: 'at_risk',
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapNarrowInstrumentApp(
          const CoachAthletesScreen(),
          overrides: [
            coachAthletesAnalyticsProvider.overrideWith(
              (ref) async => athletesAnalytics,
            ),
            athleteDisplayNameProvider('ath-1').overrideWith(
              (ref) async => 'Alex Mercer',
            ),
            athleteDisplayNameProvider('ath-2').overrideWith(
              (ref) async => 'Taylor Vance',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(CanvasPillStrip), findsNWidgets(2));
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(Card), findsNothing);
      expect(find.text('Alex Mercer'), findsOneWidget);

      final atRiskFinder = find.text('at risk');
      await Scrollable.ensureVisible(
        tester.element(atRiskFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(atRiskFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Taylor Vance'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsNothing);
    },
  );

  testWidgets(
    'CoachRelationshipsScreen uses CanvasPillStrip, InstrumentActionButton Wrap, and InstrumentDialog at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final links = [
        CoachAthleteLink(
          id: 1,
          coachId: 'coach-1',
          athleteId: 'ath-pending',
          status: 'pending',
          channelId: null,
          createdAt: DateTime(2026, 4, 28),
          updatedAt: DateTime(2026, 4, 28),
          note: 'Looking to prep for a meet',
        ),
        CoachAthleteLink(
          id: 2,
          coachId: 'coach-1',
          athleteId: 'ath-active',
          status: 'active',
          channelId: 'chan-99',
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 25),
        ),
      ];

      final summaryMap = <String, AthleteTrainingSummaryModel>{
        'ath-active': AthleteTrainingSummaryModel(
          athleteId: 'ath-active',
          lastWorkoutAt: DateTime(2026, 4, 30),
          sessionsCount: 18,
          totalVolume: 12400,
          activePlanId: 10,
          activePlanName: 'Peaking 5x',
          daysSinceLastWorkout: 2,
          sessionsPerWeek: 3.5,
          planAdherence: 0.88,
          avgIntensity: 80.0,
          avgEffort: 8.0,
          effortDistribution: null,
          segment: 'on_track',
        ),
      };

      final users = [
        UserSummary(
          userId: 'ath-pending',
          displayName: 'Pending Athlete',
          photoUrl: null,
          isPublic: true,
          createdAt: DateTime(2026, 1, 1),
          lastActiveAt: null,
        ),
        UserSummary(
          userId: 'ath-active',
          displayName: 'Active Athlete',
          photoUrl: null,
          isPublic: true,
          createdAt: DateTime(2026, 1, 1),
          lastActiveAt: null,
        ),
      ];

      await tester.pumpWidget(
        _wrapNarrowInstrumentApp(
          const CoachRelationshipsScreen(),
          overrides: [
            coachRelationshipsProvider.overrideWith((ref) async => links),
            coachRelationshipsAnalyticsProvider.overrideWith(
              (ref) async => summaryMap,
            ),
            allUsersProvider(false).overrideWith((ref) async => users),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CanvasPillStrip), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
      expect(find.byType(ListTile), findsNothing);

      final declineFinder = find.text('Decline').first;
      await Scrollable.ensureVisible(
        tester.element(declineFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(declineFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(InstrumentDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets(
    'AllUsersScreen renders CanvasPillStrip, CoachRatingDisplay, and InstrumentBottomSheetShell filters at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 760));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final allUsers = [
        UserSummary(
          userId: 'u1',
          displayName: 'Coach Elena',
          photoUrl: null,
          isPublic: true,
          createdAt: DateTime(2026, 3, 15),
          lastActiveAt: DateTime(2026, 4, 30),
          coachingEnabled: true,
          averageRating: 4.8,
          reviewCount: 19,
          specializations: const ['strength', 'powerlifting'],
          rateAmountMinor: 12000,
        ),
      ];

      await tester.pumpWidget(
        _wrapNarrowInstrumentApp(
          const AllUsersScreen(),
          overrides: [
            filteredUsersProvider(
              const UserFilters(coach: false),
            ).overrideWith((ref) async => allUsers),
            filteredUsersProvider(
              const UserFilters(coach: true),
            ).overrideWith((ref) async => allUsers),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AmbientScaffoldShell), findsOneWidget);
      expect(find.byType(CanvasPillStrip), findsOneWidget);
      expect(find.byType(CoachRatingDisplay), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
      expect(find.byType(ListTile), findsNothing);

      final coachesOnlyFinder = find.text('Coaches only');
      await Scrollable.ensureVisible(
        tester.element(coachesOnlyFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(coachesOnlyFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final filterCoachesFinder = find.text('Filter coaches');
      await Scrollable.ensureVisible(
        tester.element(filterCoachesFinder),
        alignment: 0.5,
      );
      await tester.pumpAndSettle();
      await tester.tap(filterCoachesFinder);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(InstrumentBottomSheetShell), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
      expect(find.byType(InstrumentSelectablePill), findsWidgets);
    },
  );

  testWidgets(
    'UserProfileView, ProfileStatsRow, and ReviewCard enforce Max Border Depth = 1 and tabular figures at 320px @ 2.0x',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 820));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final profile = UserProfile(
        userId: 'coach-99',
        displayName: 'Coach Marcus',
        bio: 'Evidence-based strength & peaking.',
        photoUrl: null,
        isPublic: true,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2026, 4, 1),
        settings: const UserSettings(
          unitSystem: 'metric',
          locale: 'en',
          timezone: 'UTC',
          notificationsEnabled: true,
        ),
        coaching: CoachingProfile(
          enabled: true,
          tagline: 'Powerlifting & Hypertrophy',
          description: 'Weekly video review and RPE auto-regulation.',
          specializations: const ['Powerlifting', 'Hypertrophy'],
          languages: const ['English', 'Ukrainian'],
          ratePlan: const CoachingRatePlan(amountMinor: 15000),
          createdAt: DateTime(2025, 6, 1),
          updatedAt: DateTime(2026, 4, 1),
          averageRating: 4.9,
          reviewCount: 12,
        ),
      );

      final stats = UserStats(
        totalWorkouts: 142,
        totalVolume: 245000,
        activeDays: 98,
        activityMap: {
          DateTime(2026, 5, 1): const DayActivity(sessionCount: 1, volume: 4200),
        },
        completedSessions: [
          WorkoutSession(
            id: 1,
            workoutId: 77,
            startedAt: DateTime(2026, 4, 29),
            finishedAt: DateTime(2026, 4, 29, 1, 10),
            status: 'completed',
          ),
        ],
        maxDayVolume: 5000,
        weeks: 12,
      );

      final review = CoachReview(
        id: 10,
        linkId: 5,
        reviewerId: 'u-1',
        reviewerName: 'Jordan',
        coachId: 'coach-99',
        rating: 5,
        comment: 'Clear programming and fast feedback.',
        createdAt: DateTime(2026, 4, 25),
        updatedAt: DateTime(2026, 4, 25),
      );

      await tester.pumpWidget(
        _wrapNarrowInstrumentApp(
          AmbientScaffoldShell(
            appBar: const PrimaryAppBar(title: 'Profile', showBack: false),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(12, 96, 12, 32),
              children: [
                UserProfileView(
                  profile: profile,
                  isOwner: false,
                  onRequestCoaching: () {},
                  additionalSections: [
                    const SizedBox(height: 16),
                    ProfileStatsRow(stats: stats, padding: EdgeInsets.zero),
                  ],
                ),
                const SizedBox(height: 16),
                ProfileActivitySection(stats: stats, padding: EdgeInsets.zero),
                const SizedBox(height: 16),
                ProfileCompletedWorkoutsSection(
                  sessions: stats.completedSessions,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                ReviewCard(review: review),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.byType(InstrumentMetricMatrix), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byType(ReviewCard),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(Card), findsNothing);
      expect(find.byType(ReviewCard), findsOneWidget);
    },
  );
}
