import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as pv;
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/workouts_screen.dart';
import 'package:workout_app/screens/calendar_plans_screen.dart';
import 'package:workout_app/screens/coach/coach_dashboard_screen.dart';
import 'package:workout_app/screens/coach/coach_athletes_screen.dart';
import 'package:workout_app/screens/debug_screen.dart';
import 'package:workout_app/screens/social/social_feed_screen.dart';
import 'package:workout_app/screens/user_profile_screen.dart';
import 'package:workout_app/screens/settings/settings_home_screen.dart';
import 'package:workout_app/widgets/custom_bottom_nav_bar.dart';
import 'package:workout_app/widgets/assistant_chat_host.dart';
import 'package:workout_app/config/constants/theme_constants.dart';
import 'package:workout_app/config/theme/responsive.dart';
import 'package:workout_app/config/api_config.dart';
import 'package:workout_app/services/chat_service.dart';

class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

enum HomeTab { workouts, plans, social, crm, debug }

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  HomeTab _activeTab = HomeTab.workouts;

  void _onItemTapped(HomeTab tab) {
    if (_activeTab == tab) return;
    setState(() {
      _activeTab = tab;
      switch (tab) {
        case HomeTab.workouts:
          debugPrint('Accessing endpoint: ${ApiConfig.workoutsEndpoint}');
          break;
        case HomeTab.plans:
          debugPrint('Accessing endpoint: ${ApiConfig.calendarPlansEndpoint}');
          break;
        case HomeTab.social:
          debugPrint('Opening social feed');
          break;
        case HomeTab.crm:
          debugPrint('Navigating to CoachDashboardScreen');
          break;
        case HomeTab.debug:
          debugPrint('Navigating to DebugScreen');
          break;
      }
    });
  }

  Widget _tabBody(HomeTab tab) {
    switch (tab) {
      case HomeTab.workouts:
        return WorkoutsScreen();
      case HomeTab.plans:
        return CalendarPlansScreen();
      case HomeTab.social:
        return SocialFeedScreen();
      case HomeTab.crm:
        return const CoachDashboardScreen();
      case HomeTab.debug:
        return const DebugScreen();
    }
  }

  String _tabTitle(HomeTab tab) {
    switch (tab) {
      case HomeTab.workouts:
        return 'Тренировки';
      case HomeTab.plans:
        return 'Планы тренировок';
      case HomeTab.social:
        return 'Лента';
      case HomeTab.crm:
        return 'CRM';
      case HomeTab.debug:
        return 'Отладка';
    }
  }

  BottomNavBarItem _navItemFor(HomeTab tab) {
    switch (tab) {
      case HomeTab.workouts:
        return const BottomNavBarItem(
          icon: Icons.fitness_center,
          label: 'Тренировки',
          activeLabel: 'Тренировки',
        );
      case HomeTab.plans:
        return const BottomNavBarItem(
          icon: Icons.schedule,
          label: 'Планы',
          activeLabel: 'Планы',
        );
      case HomeTab.social:
        return const BottomNavBarItem(
          icon: Icons.dynamic_feed_outlined,
          label: 'Лента',
          activeLabel: 'Лента',
        );
      case HomeTab.crm:
        return const BottomNavBarItem(
          icon: Icons.analytics_outlined,
          label: 'CRM',
          activeLabel: 'CRM',
        );
      case HomeTab.debug:
        return const BottomNavBarItem(
          icon: Icons.bug_report_outlined,
          label: 'Дебаг',
          activeLabel: 'Дебаг',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final isCoach = profileAsync.maybeWhen(
      data: (profile) => profile.coaching?.enabled ?? false,
      orElse: () => false,
    );

    final tabs = <HomeTab>[
      HomeTab.workouts,
      HomeTab.plans,
      HomeTab.social,
      if (isCoach) HomeTab.crm,
      HomeTab.debug,
    ];

    if (!tabs.contains(_activeTab)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _activeTab = HomeTab.workouts;
          });
        }
      });
    }

    final selectedIndex = tabs.indexOf(_activeTab).clamp(0, tabs.length - 1);
    final isWide = Responsive.isWide(context);
    final isExpanded = Responsive.isExpanded(context);

    return AssistantChatHost(
      builder: (context, openChat) {
        final bodyContent = IndexedStack(
          index: selectedIndex,
          children: tabs.map(_tabBody).toList(growable: false),
        );

        if (isWide) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: isExpanded,
                  minExtendedWidth: 210,
                  selectedIndex: selectedIndex,
                  backgroundColor: isDark
                      ? AppColors.darkChrome
                      : theme.colorScheme.surfaceContainerLowest,
                  onDestinationSelected: (index) {
                    if (index < 0 || index >= tabs.length) return;
                    _onItemTapped(tabs[index]);
                  },
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: isDark ? null : AppGradients.blue,
                                color: isDark ? AppColors.primary : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (isExpanded) ...[
                              const SizedBox(width: 10),
                              Text(
                                'Workout App',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (isExpanded)
                          SizedBox(
                            width: 180,
                            child: FilledButton.tonalIcon(
                              onPressed: openChat,
                              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                              label: const Text('AI Ассистент'),
                            ),
                          )
                        else
                          IconButton.filledTonal(
                            tooltip: 'AI Ассистент',
                            onPressed: openChat,
                            icon: const Icon(Icons.auto_awesome_outlined),
                          ),
                      ],
                    ),
                  ),
                  destinations: tabs
                      .map((tab) {
                        final item = _navItemFor(tab);
                        return NavigationRailDestination(
                          icon: Icon(item.icon),
                          label: Text(item.label),
                        );
                      })
                      .toList(growable: false),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isExpanded) ...[
                              SizedBox(
                                width: 180,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const UserProfileScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.account_circle_outlined),
                                  label: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Профиль'),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsHomeScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.settings_outlined),
                                  label: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Настройки'),
                                  ),
                                ),
                              ),
                            ] else ...[
                              IconButton(
                                tooltip: 'Профиль',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const UserProfileScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.account_circle_outlined),
                              ),
                              IconButton(
                                tooltip: 'Настройки',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsHomeScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.settings_outlined),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: bodyContent),
              ],
            ),
          );
        }

        return Scaffold(
          body: kIsWeb ? bodyContent : _tabBody(_activeTab),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              if (index < 0 || index >= tabs.length) return;
              _onItemTapped(tabs[index]);
            },
            items: tabs.map(_navItemFor).toList(),
          ),
        );
      },
    );
  }
}
