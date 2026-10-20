import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fb_auth;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final providers = <fb_auth.AuthProvider>[
      fb_auth.EmailAuthProvider(),
      GoogleProvider(clientId: 'mock-google-client-id-for-superweber'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Language selector with flags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.translate('select_language'),
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: themeState.locale.languageCode,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'pt',
                                child: Row(
                                  children: [
                                    Text('🇧🇷', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('Português'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Row(
                                  children: [
                                    Text('🇺🇸', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('English'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (langCode) {
                              if (langCode == 'en') {
                                themeNotifier.setLocale(const Locale('en', 'US'));
                              } else {
                                themeNotifier.setLocale(const Locale('pt', 'BR'));
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // App Logo / Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology, size: 36, color: theme.colorScheme.primary),
                          const SizedBox(width: 10),
                          Text(
                            l10n.translate('app_title'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Mandatory Team Members Notice
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          l10n.translate('team_members'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Firebase UI Auth Form
                      fb_auth.FirebaseUIActions(
                        actions: [
                          fb_auth.AuthStateChangeAction<fb_auth.SignedIn>((context, state) {
                            context.go('/game');
                          }),
                          fb_auth.AuthStateChangeAction<fb_auth.UserCreated>((context, state) {
                            context.go('/game');
                          }),
                        ],
                        child: fb_auth.LoginView(
                          action: fb_auth.AuthAction.signIn,
                          providers: providers,
                          showTitle: false,
                        ),
                      ),

                      const SizedBox(height: 16),
                      // Guest / Test access button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(l10n.translate('play')),
                        onPressed: () {
                          context.go('/game');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
