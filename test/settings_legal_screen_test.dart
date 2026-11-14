import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/config/constants/legal_constants.dart';
import 'package:workout_app/screens/settings/settings_legal_screen.dart';

void main() {
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

    testWidgets('renders tabs and switches between documents and languages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsLegalScreen(
            initialLanguageCode: 'ru',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default tab is Privacy Policy (in Russian)
      expect(find.text('Политика конфиденциальности'), findsWidgets);
      expect(find.text('Коротко о главном (TL;DR)'), findsOneWidget);

      // Switch to Terms of Service tab
      await tester.tap(find.text('Условия (ToS)'));
      await tester.pumpAndSettle();
      expect(
        find.text('Условия использования (Terms of Service)'),
        findsOneWidget,
      );

      // Switch to Health Disclaimer tab
      await tester.tap(find.text('Мед. дисклеймер'));
      await tester.pumpAndSettle();
      expect(find.text('Медицинский и фитнес-дисклеймер'), findsOneWidget);

      // Switch language to English via AppBar menu
      await tester.tap(find.text('RU'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English (EN)'));
      await tester.pumpAndSettle();

      expect(find.text('Health & Fitness Disclaimer'), findsOneWidget);
    });

    testWidgets('opens directly on initialDocument when provided and scrolls to sections',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsLegalScreen(
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
    });
  });
}
