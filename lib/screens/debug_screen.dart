import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart' as pv;
import 'package:workout_app/config/theme/instrument_theme.dart';
import 'package:workout_app/screens/coach/athlete_detail_screen.dart';
import 'package:workout_app/screens/coach/coach_athletes_screen.dart';
import 'package:workout_app/screens/coach/coach_chat_screen.dart';
import 'package:workout_app/screens/coach/coach_relationships_screen.dart';
import 'package:workout_app/screens/coach/coach_dashboard_screen.dart';
import 'package:workout_app/services/chat_service.dart';
import 'package:workout_app/widgets/ambient_scaffold_shell.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/primary_app_bar.dart';

import '../models/calendar_plan.dart';
import '../models/exercise_definition.dart';
import '../models/macro.dart';
import '../models/microcycle.dart';
import '../models/plan_schedule.dart';
import '../models/workout_session.dart';
import 'active_plan_screen.dart';
import 'all_users_screen.dart';
import 'analytics_screen.dart';
import 'calendar_plan_create.dart';
import 'calendar_plan_detail.dart';
import 'calendar_plans_screen.dart';
import 'chat_screen.dart';
import 'coach_athlete_plan_screen.dart';
import 'coaching/my_coaches_screen.dart';
import 'exercise_form_screen.dart';
import 'exercise_list_screen.dart';
import 'exercise_selection_screen.dart';
import 'exercises_screen.dart';
import 'home_screen_new.dart';
import 'macros/macro_editor_screen.dart';
import 'macros/macros_list_screen.dart';
import 'macros/macros_preview_screen.dart';
import 'nutrition_plan_active.dart';
import 'nutrition_plan_create.dart';
import 'nutrition_plan_detail.dart';
import 'nutrition_plans_list.dart';
import 'plan_editor_screen.dart';
import 'plan_microcycle_editor.dart';
import 'progression_detail_screen.dart';
import 'public_user_profile_screen.dart';
import 'session_history_screen.dart';
import 'session_log_screen.dart';
import 'social/social_feed_screen.dart';
import 'splash_screen_new.dart';
import 'user_max_screen.dart';
import 'user_profile_screen.dart';
import 'workout_detail_screen.dart';
import 'workout_list_screen.dart';
import 'workout_session_history_screen.dart';
import 'workouts_screen.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> screens = {
      'Active Plan': (context) => const ActivePlanScreen(),
      'Analytics': (context) => const AnalyticsScreen(),
      'Calendar Plan Create': (context) => const CalendarPlanCreate(),
      'Calendar Plan Detail (stub)': (context) =>
          CalendarPlanDetail(plan: _stubCalendarPlan()),
      'Calendar Plans': (context) => const CalendarPlansScreen(),
      'Chat Screen (embedded)': (context) => const _EmbeddedChatDebugPage(),
      'Exercise Selection': (context) => ExerciseSelectionScreen(),
      'Exercise Form (stub)': (context) =>
          ExerciseFormScreen(exercise: _stubExerciseDefinition(), workoutId: 0),
      'Workout Detail': (context) => WorkoutDetailScreen(workoutId: 2000),
      'Workouts': (context) => WorkoutsScreen(),
      'Workout List': (context) => WorkoutListScreen(progressionId: 1),
      'Exercise List': (context) => ExerciseListScreen(),
      'Exercises Screen': (context) => const ExercisesScreen(),
      'Home Screen': (context) => const HomeScreenNew(),
      'Macro Editor': (context) =>
          MacroEditorScreen(initial: _stubPlanMacro(), calendarPlanId: 1),
      'Macros List': (context) => const MacrosListScreen(calendarPlanId: 1),
      'Macros Preview': (context) =>
          const MacrosPreviewScreen(appliedPlanId: 1),
      'Plan Editor (stub)': (context) =>
          PlanEditorScreen(plan: _stubCalendarPlan()),
      'Plan Microcycle Editor (stub)': (context) =>
          PlanMicrocycleEditor(microcycle: _stubMicrocycle()),
      'Progression Detail (stub)': (context) =>
          const ProgressionDetailScreen(templateId: 1),
      'User Maxes': (context) => const UserMaxScreen(),
      'Session History': (context) => const SessionHistoryScreen(),
      'Session Log': (context) =>
          SessionLogScreen(session: _stubWorkoutSession()),
      'Splash Screen': (context) => const SplashScreenNew(),
      'User Profile': (context) => const UserProfileScreen(),
      'All Users (list)': (context) => const AllUsersScreen(),
      'Workout Session History': (context) =>
          const WorkoutSessionHistoryScreen(workoutId: 1),
      'Coach Dashboard (CRM)': (context) => const CoachDashboardScreen(),
      'Coach Athletes (CRM)': (context) => const CoachAthletesScreen(),
      'Nutrition Plan Active': (context) => const NutritionPlanActive(),
      'Nutrition Plans List': (context) => const NutritionPlansList(),
      'Nutrition Plan Detail': (context) =>
          const NutritionPlanDetail(sessionData: {}),
      'Nutrition Plan Create': (context) => const NutritionPlanCreate(),
      ..._coachAndSocialScreens(),
    };

    final entries = screens.entries.toList();

    return AssistantChatHost(
      builder: (context, openChat) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final instrument = InstrumentTheme.of(context);
        final topInset = AmbientScaffoldShell.topContentInset(context);
        final bottomInset = AmbientScaffoldShell.bottomContentInset(context);

        return AmbientScaffoldShell(
          appBar: PrimaryAppBar.main(
            title: 'Debug Screen',
            onTitleTap: openChat,
            actions: [_buildOverflowMenu(context)],
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              topInset + 8,
              16,
              bottomInset + 24,
            ),
            children: [
              Container(
                decoration: InstrumentTheme.instrumentCardDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ROUTE SANDBOX',
                                  style: InstrumentTheme.microLabel(context),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'All screens',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entries.length} ROUTES',
                            style: InstrumentTheme.microLabel(
                              context,
                              color: instrument.workingAura,
                            ).copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (int i = 0; i < entries.length; i++) ...[
                      Container(height: 1, color: instrument.hairlineBorder),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: entries[i].value),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 54),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entries[i].key,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'logout') {
          _handleLogout(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final instrument = InstrumentTheme.of(context);
    final shouldLogout = await showInstrumentDialog<bool>(
      context: context,
      eyebrow: 'DEBUG SESSION',
      title: 'Выйти из аккаунта?',
      message: 'Вы уверены, что хотите выйти?',
      accentColor: instrument.peakEffortColor,
      actionsBuilder: (ctx) => [
        InstrumentActionButton(
          label: 'Отмена',
          variant: InstrumentActionVariant.secondary,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        InstrumentActionButton(
          label: 'Выйти',
          variant: InstrumentActionVariant.destructive,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      try {
        final chat = pv.Provider.of<ChatService>(context, listen: false);
        await chat.disconnect();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn(
          clientId:
              '282810209663-u4upa0psrlsd24ls422na68n1gcmlllb.apps.googleusercontent.com',
        ).signOut();
      } catch (_) {}
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при выходе: $e'),
          backgroundColor: InstrumentTheme.of(context).peakEffortColor,
        ),
      );
    }
  }

  Map<String, WidgetBuilder> _coachAndSocialScreens() {
    return {
      'Coach Chat (stub)': (context) => CoachChatScreen(
        args: CoachChatScreenArgs(
          channelId: 'debug-channel',
          title: 'Debug Coach Chat',
        ),
      ),
      'Coach Relationships': (context) => const CoachRelationshipsScreen(),
      'Coach Athlete Detail (stub)': (context) =>
          const AthleteDetailScreen(athleteId: 'debug-athlete'),
      'Coach Athlete Plan (stub)': (context) => const CoachAthletePlanScreen(
        athleteId: 'debug-athlete',
        athleteName: 'Debug Athlete',
      ),
      'My Coaches': (context) => const MyCoachesScreen(),
      'Social Feed': (context) => const SocialFeedScreen(),
      'Public User Profile (stub)': (context) => const PublicUserProfileScreen(
        userId: 'debug-user',
        initialName: 'Debug User',
      ),
    };
  }

  CalendarPlan _stubCalendarPlan() {
    return CalendarPlan(
      id: 0,
      name: 'Sample Plan',
      schedule: const {},
      durationWeeks: 0,
      mesocycles: const [],
    );
  }

  ExerciseDefinition _stubExerciseDefinition() {
    return const ExerciseDefinition(
      id: 0,
      name: 'Sample Exercise',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
    );
  }

  PlanMacro _stubPlanMacro() {
    return PlanMacro(
      calendarPlanId: 1,
      name: 'Sample Macro',
      isActive: true,
      priority: 100,
      rule: MacroRule.empty(),
    );
  }

  Microcycle _stubMicrocycle() {
    return const Microcycle(
      id: 0,
      mesocycleId: 0,
      name: 'Sample Microcycle',
      orderIndex: 0,
      schedule: <String, List<ExerciseScheduleItemDto>>{},
      daysCount: 7,
    );
  }

  WorkoutSession _stubWorkoutSession() {
    final now = DateTime.now();
    return WorkoutSession(
      id: 0,
      workoutId: 0,
      startedAt: now,
      finishedAt: now,
      status: 'completed',
      durationSeconds: 0,
      progress: const {},
    );
  }
}

class _EmbeddedChatDebugPage extends StatelessWidget {
  const _EmbeddedChatDebugPage();

  @override
  Widget build(BuildContext context) {
    final topInset = AmbientScaffoldShell.topContentInset(context);
    final bottomInset = AmbientScaffoldShell.bottomContentInset(context);
    return AmbientScaffoldShell(
      appBar: PrimaryAppBar.detail(title: 'Chat Screen (embedded)'),
      body: Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: const ChatScreen(embedded: true),
      ),
    );
  }
}
