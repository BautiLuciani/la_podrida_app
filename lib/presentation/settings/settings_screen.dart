import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          label: const Text(
            'Volver',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
        ),
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: FadeInUp(
        duration: const Duration(milliseconds: 320),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: SwitchListTile(
                value: settings.blockFourZeros,
                title: const Text('Regla 000', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('Bloquear 4 rondas seguidas pidiendo 0'),
                onChanged: (_) => settingsNotifier.toggleBlockFourZeros(),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puntos por baza',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text('${settings.pointsPerBaza} punto(s)'),
                    Slider(
                      min: 1,
                      max: 5,
                      divisions: 4,
                      value: settings.pointsPerBaza.toDouble(),
                      label: settings.pointsPerBaza.toString(),
                      onChanged: (value) {
                        settingsNotifier.setPointsPerBaza(value.toInt());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                value: settings.extraRound,
                title: const Text('Ronda Extra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('Ronda extra al final de la partida. Los jugadores deben pedir bazas sin ver sus cartas.'),
                onChanged: (_) => settingsNotifier.toggleExtraRound(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
