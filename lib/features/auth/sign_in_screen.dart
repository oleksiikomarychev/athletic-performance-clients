import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workout_app/config/constants/legal_constants.dart';
import 'package:workout_app/l10n/app_localizations.dart';
import 'package:workout_app/screens/settings/settings_legal_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const androidClientIdFallback =
        '282810209663-2c8gaol6ijkhp96tc1c70fuj4bdvpgse.apps.googleusercontent.com';
    const iosClientIdFallback =
        '282810209663-u4upa0psrlsd24ls422na68n1gcmlllb.apps.googleusercontent.com';
    const webClientIdFallback =
        '282810209663-hqb6rd3lfme15d3l3s0ot6776stubutv.apps.googleusercontent.com';

    const webClientIdOverride = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue: '',
    );

    final webClientIdFromEnv = dotenv.isInitialized
        ? (dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID') ?? '')
        : '';
    final webClientId = webClientIdOverride.isNotEmpty
        ? webClientIdOverride
        : (webClientIdFromEnv.isNotEmpty
              ? webClientIdFromEnv
              : webClientIdFallback);

    final androidClientIdFromEnv = dotenv.isInitialized
        ? (dotenv.maybeGet('GOOGLE_ANDROID_CLIENT_ID') ?? '')
        : '';
    final androidClientId = androidClientIdFromEnv.isNotEmpty
        ? androidClientIdFromEnv
        : androidClientIdFallback;

    final iosClientIdFromEnv = dotenv.isInitialized
        ? (dotenv.maybeGet('GOOGLE_IOS_CLIENT_ID') ?? '')
        : '';
    final iosClientId = iosClientIdFromEnv.isNotEmpty
        ? iosClientIdFromEnv
        : iosClientIdFallback;

    final providerClientId = kIsWeb
        ? webClientId
        : (defaultTargetPlatform == TargetPlatform.android
              ? androidClientId
              : defaultTargetPlatform == TargetPlatform.iOS
              ? iosClientId
              : webClientId);
    final providers = <fui.AuthProvider>[fui.EmailAuthProvider()];

    if (providerClientId.isNotEmpty) {
      providers.add(GoogleProvider(clientId: providerClientId));
    }

    return fui.SignInScreen(
      providers: providers,
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const FlutterLogo(size: 80),
              const SizedBox(height: 16),
              Text(
                'Workout App',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).signInTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
      subtitleBuilder: (context, action) {
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: action == fui.AuthAction.signIn
              ? Text(l10n.signInWelcomeBack)
              : Text(l10n.signInCreateAccount),
        );
      },
      footerBuilder: (context, action) {
        final l10n = AppLocalizations.of(context);
        void openLegal(LegalDocumentType docType) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsLegalScreen(initialDocument: docType),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.signInLegalConsent,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => openLegal(LegalDocumentType.terms),
                    child: Text(
                      l10n.legalTermsOfService,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => openLegal(LegalDocumentType.privacy),
                    child: Text(
                      l10n.legalPrivacyPolicy,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () =>
                        openLegal(LegalDocumentType.healthDisclaimer),
                    child: Text(
                      l10n.legalMedicalDisclaimer,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
