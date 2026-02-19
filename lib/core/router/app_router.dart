import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/presentation/home/home_screen.dart';
import 'package:la_podrida_app/presentation/match/match_screen.dart';
import 'package:la_podrida_app/presentation/results/results_screen.dart';
import 'package:la_podrida_app/presentation/settings/settings_screen.dart';
import 'package:la_podrida_app/presentation/setup/setup_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/match',
        builder: (context, state) => const MatchScreen(),
      ),
      GoRoute(
        path: '/results',
        builder: (context, state) => const ResultsScreen(),
      ),
    ],
  ),
);
