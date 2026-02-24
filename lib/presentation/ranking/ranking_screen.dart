import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/ranking_provider.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(rankingProvider.notifier).loadFromStorage());
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar historial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Se eliminaran todos los puntos del ranking.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7CBD3),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Borrar'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldClear == true) {
      await ref.read(rankingProvider.notifier).clearHistory();
    }
  }
  @override
  Widget build(BuildContext context) {
    final rankingState = ref.watch(rankingProvider);
    final entries = rankingState.pointsByPlayer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Color backgroundFor(int index) {
      if (index == 0) return const Color(0xFFFFF4CC);
      if (index == 1) return const Color(0xFFF0F2F5);
      if (index == 2) return const Color(0xFFFFE8D6);
      return Colors.white;
    }

    Color borderFor(int index) {
      if (index == 0) return const Color(0xFFE3AA00);
      if (index == 1) return const Color(0xFFA7B0BB);
      if (index == 2) return const Color(0xFFD4702A);
      return const Color(0xFFD3D7DE);
    }

    Widget leadingFor(int index) {
      if (index == 0) {
        return const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE3AA00));
      }
      if (index == 1) {
        return const Icon(Icons.military_tech_outlined, color: Color(0xFFA7B0BB));
      }
      if (index == 2) {
        return const Icon(Icons.military_tech_outlined, color: Color(0xFFD4702A));
      }
      return Text(
        '${index + 1}',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 30,
          color: Color(0xFF3A506B),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        'Volver',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Icon(Icons.workspace_premium_rounded, size: 46, color: Color(0xFFE3AA00)),
                const SizedBox(height: 8),
                const Text(
                  'RANKING',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Jugadores con más puntos',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Color(0xFF5B6680)),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: entries.isEmpty
                      ? const _EmptyRankingView()
                      : ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: backgroundFor(index),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderFor(index)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    leadingFor(index),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${entry.value}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 38,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Puntos',
                                          style: TextStyle(
                                            color: Color(0xFF5B6680),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (entries.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _confirmClearHistory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2E3A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Borrar Historial'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRankingView extends StatelessWidget {
  const _EmptyRankingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events_outlined, size: 90, color: Color(0xFFBFC5D2)),
            SizedBox(height: 12),
            Text(
              'Aún no hay partidas completadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B6680),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '¡Juega para aparecer en el ranking!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Color(0xFF7C86A0)),
            ),
          ],
        ),
      ),
    );
  }
}

