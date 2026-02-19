import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/match_provider.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchProvider);
    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ),
      );
    }

    final entries = List<({String name, int score})>.generate(
      match.players.length,
      (index) => (
        name: match.players[index].name,
        score: ref.read(matchProvider.notifier).getTotalScore(index),
      ),
    )..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      appBar: AppBar(title: const Text('Ranking final')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BounceIn(
          duration: const Duration(milliseconds: 450),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Resultados',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    final prevScore = index == 0 ? null : entries[index - 1].score;
                    final rank = prevScore == item.score ? null : index + 1;

                    return Card(
                      child: ListTile(
                        leading: Text(
                          rank == null ? '=' : '#$rank',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        title: Text(item.name),
                        trailing: Text(
                          '${item.score} pts',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(matchProvider.notifier).clearMatch();
                  context.go('/');
                },
                child: const Text('Volver al home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
