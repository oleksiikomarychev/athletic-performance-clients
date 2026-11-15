import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_app/config/constants/legal_constants.dart';
import 'package:workout_app/config/theme/app_theme.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/models/user_profile.dart';
import 'package:workout_app/providers/providers.dart';
import 'package:workout_app/screens/debug/amplitude_test_screen.dart';
import 'package:workout_app/screens/settings/settings_general_screen.dart';
import 'package:workout_app/screens/settings/settings_home_screen.dart';
import 'package:workout_app/screens/settings/settings_import_screen.dart';
import 'package:workout_app/screens/settings/settings_legal_screen.dart';
import 'package:workout_app/widgets/instrument_modal.dart';
import 'package:workout_app/widgets/interface_maker_sheet.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildApp(Widget home, {double textScale = 1.0}) {
    return ProviderScope(
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

  UserProfile buildSampleProfile() {
    final now = DateTime.utc(2026, 1, 1);
    return UserProfile(
      userId: 'user-1',
      displayName: 'Test Athlete',
      bio: null,
      photoUrl: null,
      isPublic: true,
      createdAt: now,
      updatedAt: now,
      settings: const UserSettings(
        unitSystem: 'metric',
        locale: 'en',
        timezone: 'Europe/Kyiv',
        notificationsEnabled: true,
      ),
      coaching: CoachingProfile(
        enabled: true,
        tagline: 'Strength coach',
        description: 'Linear & conjugate programming',
        specializations: const ['strength', 'powerlifting'],
        languages: const ['en', 'ua'],
        ratePlan: const CoachingRatePlan(amountMinor: 12000),
        createdAt: now,
        updatedAt: now,
        stripeConnectAccountId: 'acct_test_123',
      ),
      coachingEligibility: const CoachingEligibility(
        eligible: true,
        threshold: 100,
        maxUniqueAdopters: 120,
        bestRootPlanId: 1,
      ),
    );
  }

  group('LegalDocumentsRepository & SettingsLegalScreen', () {
    test('provides Privacy, Terms, and Health Disclaimer in EN, RU, and UK', () {
      for (final lang in ['en', 'ru', 'uk']) {
        final docs = LegalDocumentsRepository.getAllDocuments(lang);
        expect(docs.length, 3);
        expect(docs[0].type, LegalDocumentType.privacy);
        expect(docs[1].type, LegalDocumentType.terms);
        expect(docs[2].type, LegalDocumentType.healthDisclaimer);

        for (final doc in docs) {
          expect(doc.title, isNotEmpty);
          expect(doc.tldrPoints, isNotEmpty);
          expect(doc.sections, isNotEmpty);
        }
      }
      expect(LegalConfig.hasPlaceholders, isTrue);
    });

    testWidgets(
      'renders tabs and switches between documents and languages',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildApp(const SettingsLegalScreen(initialLanguageCode: 'ru')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Политика конфиденциальности'), findsWidgets);
        expect(find.text('Коротко о главном (TL;DR)'), findsOneWidget);

        await tester.tap(find.text('Условия (ToS)'));
        await tester.pumpAndSettle();
        expect(
          find.text('Условия использования (Terms of Service)'),
          findsOneWidget,
        );

        await tester.tap(find.text('Мед. дисклеймер'));
        await tester.pumpAndSettle();
        expect(find.text('Медицинский и фитнес-дисклеймер'), findsOneWidget);

        await tester.tap(find.text('RU'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('English (EN)'));
        await tester.pumpAndSettle();

        expect(find.text('Health & Fitness Disclaimer'), findsOneWidget);
        expect(find.byType(Card), findsNothing);
      },
    );

    testWidgets(
      'opens directly on initialDocument when provided and scrolls to sections',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildApp(
            const SettingsLegalScreen(
              initialDocument: LegalDocumentType.healthDisclaimer,
              initialLanguageCode: 'en',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Health & Fitness Disclaimer'), findsOneWidget);

        await tester.drag(find.byType(ListView), const Offset(0, -350));
        await tester.pumpAndSettle();
        expect(find.text('Not Medical Advice'), findsOneWidget);
      },
    );

    testWidgets(
      'SettingsHomeScreen, SettingsLegalScreen, SettingsImportScreen, and AmplitudeTestScreen fit 320px @ 2.0x textScale without overflow',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        for (final screen in <Widget>[
          const SettingsHomeScreen(),
          const SettingsLegalScreen(initialLanguageCode: 'ru'),
          const SettingsImportScreen(),
          const AmplitudeTestScreen(),
        ]) {
          await tester.pumpWidget(buildApp(screen, textScale: 2.0));
          await tester.pumpAndSettle();
          expect(
            find.byType(Card),
            findsNothing,
            reason: 'Card found in ${screen.runtimeType}',
          );
          expect(
            tester.takeException(),
            isNull,
            reason: 'Layout overflow in ${screen.runtimeType}',
          );
        }
      },
    );
  });

  group('SettingsGeneralScreen', () {
    testWidgets(
      'renders instrument modules, Coaching settings dialog, and Sign out dialog at 320px @ 2.0x textScale without overflow',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 720));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final profile = buildSampleProfile();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userProfileProvider.overrideWith((ref) async => profile),
            ],
            child: MaterialApp(
              theme: AppTheme.darkTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: true,
                  textScaler: const TextScaler.linear(2.0),
                ),
                child: child!,
              ),
              home: const SettingsGeneralScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(CanvasPillStrip), findsOneWidget);
        expect(find.byType(Card), findsNothing);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(FilterChip), findsNothing);
        expect(tester.takeException(), isNull);

        // Open Theme bottom sheet and dismiss cleanly
        await tester.tap(find.text('Theme'));
        await tester.pumpAndSettle();
        expect(find.byType(InstrumentBottomSheetShell), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Dark').last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Scroll to Coaching settings & open InstrumentDialog with InstrumentSelectablePills
        await tester.scrollUntilVisible(
          find.text('Coaching settings'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Stripe connected'), findsOneWidget);

        await tester.tap(find.text('Coaching settings'));
        await tester.pumpAndSettle();
        expect(find.byType(InstrumentDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(FilterChip), findsNothing);
        expect(find.byType(InstrumentSelectablePill), findsWidgets);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Scroll to Sign out & open InstrumentDialog confirmation
        await tester.scrollUntilVisible(
          find.text('Sign out'),
          250,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign out'));
        await tester.pumpAndSettle();
        expect(find.byType(InstrumentDialog), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
