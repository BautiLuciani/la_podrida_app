import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/application/providers/settings_provider.dart';
import 'package:la_podrida_app/core/router/app_router.dart';
import 'package:la_podrida_app/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: LaPodridaApp()));
}

class LaPodridaApp extends ConsumerStatefulWidget {
  const LaPodridaApp({super.key});

  @override
  ConsumerState<LaPodridaApp> createState() => _LaPodridaAppState();
}

class _LaPodridaAppState extends ConsumerState<LaPodridaApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(settingsProvider.notifier).loadFromStorage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'La Podrida',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
