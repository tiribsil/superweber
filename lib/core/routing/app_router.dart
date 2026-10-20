import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/game/presentation/game_screen.dart';
import '../../features/navigation/presentation/main_scaffold.dart';
import '../../features/records/presentation/records_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../theme/theme_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedRoute = prefs?.getString('last_route') ?? '/login';

  return GoRouter(
    initialLocation: savedRoute,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Persist current route to SharedPreferences
          final loc = state.matchedLocation;
          if (loc != '/login') {
            prefs?.setString('last_route', loc);
          }
          return MainScaffold(
            location: loc,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/game',
            builder: (context, state) => const GameScreen(),
          ),
          GoRoute(
            path: '/records',
            builder: (context, state) => const RecordsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
