import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fb_auth;
import 'dart:math' as math;
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/theme_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  static const String weberShadowAsset = 'assets/weber_sombra.png';
  static const String borboletasAsset = 'assets/borboletas.png';
  static const String googleClientId =
      '744416865405-ivq2j65iqksmhhofe225r1smdnvg8c5h.apps.googleusercontent.com';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.sizeOf(context);
    
    // Robust mobile detection (covers all portrait mobile devices & viewports < 900px)
    final isMobile = screenSize.width < 900 || screenSize.width < screenSize.height;
    final scale = isMobile
    ? 1.0
    : math.min(screenSize.height / 1080.0, screenSize.width / 1920.0).clamp(0.5, 1.2);

    final emailProvider = fb_auth.EmailAuthProvider();
    final googleProvider = GoogleProvider(clientId: googleClientId);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : const Color.fromARGB(255, 156, 170, 250),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Butterfly: 
          Positioned(
            top: 0,
            bottom: 0,
            left: isMobile ? 0 : screenSize.width * 0.42,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Transform.scale(
                  scale: 1.5,
                  child: Opacity(
                    opacity: 0.85,
                    child: Image.asset(
                      borboletasAsset,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Weber Shadow: Bottom-center on mobile, bottom-left on web
          Positioned(
            left: 0,
            right: isMobile ? 0 : null,
            bottom: 0,
            width: isMobile ? null : screenSize.width * 0.42,
            height: screenSize.height * (isMobile ? 0.55 : 0.75),
            child: IgnorePointer(
              child: Image.asset(
                weberShadowAsset,
                fit: BoxFit.contain,
                alignment: isMobile ? Alignment.bottomCenter : Alignment.bottomLeft,
              ),
            ),
          ),

          // 3. Top Header: Title
          Positioned(
            top: isMobile ? 24 : 70 * scale,
            left: 20,
            right: 20,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.gaegu(
                      fontSize: isMobile ? 64 : 120 * scale,
                      letterSpacing: 2.5 * scale,
                      color: const Color.fromARGB(255, 255, 226, 255),
                      fontWeight: FontWeight.w900,
                      shadows: [
                        Shadow(
                          offset: const Offset(3, 4),
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 4. Buttons Section: Centered on mobile, center-right on web
          SafeArea(
            child: Align(
              alignment: isMobile
                  ? const Alignment(0, 0.45)
                  : const Alignment(0.65, 0.15),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isMobile ? 500 : 500 * scale),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Play Button (Abre o diálogo de autenticação)
                      _CuteMenuButton(
                        scale: scale,
                        icon: Icons.play_arrow_rounded,
                        title: l10n.play,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 146, 209),
                        foregroundColor: Colors.white,
                        onPressed: () => _showLoginDialog(
                          context,
                          emailProvider,
                          googleProvider,
                          l10n,
                        ),
                      ),
                      SizedBox(height: isMobile ? 18 : 40 * scale),

                      // Language Button
                      _CuteMenuButton(
                        scale: scale,
                        icon: Icons.language_rounded,
                        title: l10n.selectLanguage,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 146, 209),
                        foregroundColor: Colors.white,
                        valueBadge: themeState.locale.languageCode == 'en'
                            ? '🇺🇸 English'
                            : '🇧🇷 Português',
                        onPressed: () => _showLanguageDialog(
                          context,
                          ref,
                          themeState.locale.languageCode,
                          l10n,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Developer Names: Container completely removed for both mobile and web
          Positioned(
            bottom: isMobile ? 14 : 14 * scale,
            right: isMobile ? 0 : 18 * scale,
            left: isMobile ? 0 : null,
            child: SafeArea(
              top: false,
              left: false,
              child: Text(
                l10n.authors,
                textAlign: isMobile ? TextAlign.center : TextAlign.right,
                style: GoogleFonts.gaegu(
                  fontSize: isMobile ? 18 : 18 * scale,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showLoginDialog(
    BuildContext context,
    fb_auth.EmailAuthProvider emailProvider,
    GoogleProvider googleProvider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Login',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  fb_auth.FirebaseUIActions(
                    actions: [
                      fb_auth.AuthStateChangeAction<fb_auth.SignedIn>((
                        ctx,
                        state,
                      ) {
                        Navigator.of(dialogCtx).pop();
                        context.go('/history');
                      }),
                      fb_auth.AuthStateChangeAction<fb_auth.UserCreated>((
                        ctx,
                        state,
                      ) {
                        Navigator.of(dialogCtx).pop();
                        context.go('/history');
                      }),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        fb_auth.LoginView(
                          action: fb_auth.AuthAction.signIn,
                          providers: [emailProvider],
                          showTitle: false,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.semConta,
                              style: theme.textTheme.bodyMedium,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(dialogCtx).pop();
                                _showRegisterDialog(
                                  context,
                                  emailProvider,
                                  googleProvider,
                                  l10n,
                                );
                              },
                              child: Text(
                                l10n.criaConta,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                l10n.or,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        fb_auth.OAuthProviderButton(
                          provider: googleProvider,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.person_outline_rounded),
                          label: Text(l10n.playAsGuest),
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            context.go('/history');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog(
    BuildContext context,
    fb_auth.EmailAuthProvider emailProvider,
    GoogleProvider googleProvider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.criaConta,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  fb_auth.FirebaseUIActions(
                    actions: [
                      fb_auth.AuthStateChangeAction<fb_auth.SignedIn>((
                        ctx,
                        state,
                      ) {
                        Navigator.of(dialogCtx).pop();
                        context.go('/history');
                      }),
                      fb_auth.AuthStateChangeAction<fb_auth.UserCreated>((
                        ctx,
                        state,
                      ) {
                        Navigator.of(dialogCtx).pop();
                        context.go('/history');
                      }),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        fb_auth.LoginView(
                          action: fb_auth.AuthAction.signUp,
                          providers: [emailProvider],
                          showTitle: false,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.jaTemConta,
                              style: theme.textTheme.bodyMedium,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(dialogCtx).pop();
                                _showLoginDialog(
                                  context,
                                  emailProvider,
                                  googleProvider,
                                  l10n,
                                );
                              },
                              child: Text(
                                l10n.login,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                l10n.or,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        fb_auth.OAuthProviderButton(
                          provider: googleProvider,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final themeNotifier = ref.read(themeProvider.notifier);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.language_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text(l10n.selectLanguage,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CuteOptionTile(
              label: l10n.portuguese,
              emoji: '🇧🇷',
              isSelected: currentLang == 'pt',
              onTap: () {
                themeNotifier.setLocale(const Locale('pt', 'BR'));
                Navigator.of(dialogCtx).pop();
              },
            ),
            const SizedBox(height: 10),
            _CuteOptionTile(
              label: l10n.english,
              emoji: '🇺🇸',
              isSelected: currentLang == 'en',
              onTap: () {
                themeNotifier.setLocale(const Locale('en', 'US'));
                Navigator.of(dialogCtx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Cute Reusable UI Widgets ---

class _CuteMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? valueBadge;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double scale;

  const _CuteMenuButton({
    this.scale = 1.0,
    required this.icon,
    required this.title,
    this.valueBadge,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 900 ||
        MediaQuery.sizeOf(context).width < MediaQuery.sizeOf(context).height;
    final borderRadius = BorderRadius.circular(45);

    final bgColor = backgroundColor ??
        theme.colorScheme.surface.withValues(alpha: 0.94);

    final fgColor = foregroundColor ?? theme.colorScheme.onSurface;

    return Container(
      height: isMobile ? 68 : 100 * scale,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: fgColor, size: isMobile ? 24 : 28 * scale),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.gaegu(
                      color: fgColor,
                      fontSize: isMobile ? 26 : 35 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (valueBadge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      valueBadge!,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: fgColor.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CuteOptionTile extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _CuteOptionTile({
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}