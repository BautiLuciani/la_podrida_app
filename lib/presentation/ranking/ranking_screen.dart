import 'dart:io';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/player_avatars_provider.dart';
import 'package:la_podrida_app/application/providers/ranking_provider.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => ref.read(rankingProvider.notifier).loadFromStorage());
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text('Borrar historial'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Se eliminaran todos los datos del ranking.'),
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
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await ref.read(rankingProvider.notifier).clearHistory();
    }
  }

  Future<void> _showRankingInfoDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withValues(alpha: 0.18)),
                  ),
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text(
                  'Como funciona el ranking',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                content: const SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'El ranking se ordena por victorias.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Solo el jugador (o los jugadores empatados) con el mayor puntaje al final de la partida suma 1 punto al ranking.',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Los colores oro, plata y bronce coinciden con los 3 jugadores con más victorias.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String iso) {
    if (iso.isEmpty) return '--/--/----';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '--/--/----';
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final shortYear = (parsed.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$shortYear';
  }

  String _placeLabel(int place) {
    if (place <= 0) return '--';
    return '$place° lugar';
  }

  Color _placeChipColor(int place) {
    if (place == 1) return const Color(0xFFE3AA00);
    if (place == 2) return const Color(0xFF8E97A8);
    if (place == 3) return const Color(0xFFD4702A);
    return const Color(0xFF7C86A0);
  }

  Widget _podiumMedalIcon(int? podiumRank) {
    if (podiumRank == 0) {
      return const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE3AA00), size: 26);
    }
    if (podiumRank == 1) {
      return const Icon(Icons.military_tech_outlined, color: Color(0xFFA7B0BB), size: 24);
    }
    if (podiumRank == 2) {
      return const Icon(Icons.military_tech_outlined, color: Color(0xFFD4702A), size: 24);
    }
    return const SizedBox.shrink();
  }

  Future<void> _showPlayerHistoryDialog(
    String playerName,
    PlayerRankingStats stats,
    int? podiumRank,
  ) async {
    final recentMatches = stats.rankingHistory.reversed.take(12).toList();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withValues(alpha: 0.18)),
                  ),
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (podiumRank != null) ...[
                        _podiumMedalIcon(podiumRank),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        playerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                content: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 2),
                      if (recentMatches.isEmpty)
                        const Text(
                          'Todavia no hay partidas para este jugador.',
                          style: TextStyle(color: Color(0xFF5B6680)),
                        )
                      else
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 280),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: recentMatches.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = recentMatches[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFD1D5DD)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatDate(entry.dateIso),
                                        style: const TextStyle(
                                          color: Color(0xFF5B6680),
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${entry.playersCount} jug.',
                                      style: const TextStyle(
                                        color: Color(0xFF5B6680),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _placeChipColor(entry.place),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _placeLabel(entry.place),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 1))]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.black : const Color(0xFF7C86A0)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.black : const Color(0xFF7C86A0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastMatchTab(String? lastMatchWinner, Map<String, String> avatars) {
    if (lastMatchWinner == null) {
      return const _EmptyRankingView();
    }

    final avatarPath = avatars[lastMatchWinner];

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Última victoria',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7C86A0), fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              lastMatchWinner,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 28),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE3AA00), width: 3),
              ),
              child: ClipOval(
                child: avatarPath != null
                    ? Image.file(
                        File(avatarPath),
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _defaultAvatarIcon(),
                      )
                    : _defaultAvatarIcon(),
              ),
            ),
            if (avatarPath == null) ...[
              const SizedBox(height: 16),
              Text(
                'No hay un avatar para $lastMatchWinner',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7C86A0), fontSize: 15),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatarIcon() {
    return Container(
      color: const Color(0xFFF0F0F2),
      child: const Icon(Icons.person, size: 80, color: Color(0xFFBFC5D2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankingState = ref.watch(rankingProvider);
    final avatars = ref.watch(playerAvatarsProvider);

    final entries = rankingState.statsByPlayer.entries
        .where((e) => e.value.matchesPlayed > 0)
        .toList()
      ..sort((a, b) {
        final winsCompare = b.value.wins.compareTo(a.value.wins);
        if (winsCompare != 0) return winsCompare;
        final winRateCompare = b.value.winRate.compareTo(a.value.winRate);
        if (winRateCompare != 0) return winRateCompare;
        return b.value.matchesPlayed.compareTo(a.value.matchesPlayed);
      });

    final podiumByPlayer = <String, int>{};
    for (var i = 0; i < entries.length && i < 3; i++) {
      podiumByPlayer[entries[i].key] = i;
    }

    Color backgroundFor(String name) {
      final rank = podiumByPlayer[name];
      if (rank == 0) return const Color(0xFFFFF4CC);
      if (rank == 1) return const Color(0xFFF0F2F5);
      if (rank == 2) return const Color(0xFFFFE8D6);
      return Colors.white;
    }

    Color borderFor(String name) {
      final rank = podiumByPlayer[name];
      if (rank == 0) return const Color(0xFFE3AA00);
      if (rank == 1) return const Color(0xFFA7B0BB);
      if (rank == 2) return const Color(0xFFD4702A);
      return const Color(0xFFD3D7DE);
    }

    Widget leadingFor(int index, String name) {
      final rank = podiumByPlayer[name];
      if (rank == 0) return const Icon(Icons.workspace_premium_rounded, color: Color(0xFFE3AA00));
      if (rank == 1) return const Icon(Icons.military_tech_outlined, color: Color(0xFFA7B0BB));
      if (rank == 2) return const Icon(Icons.military_tech_outlined, color: Color(0xFFD4702A));
      return Text(
        '${index + 1}',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30, color: Color(0xFF3A506B)),
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
                    const Spacer(),
                    IconButton(
                      onPressed: _showRankingInfoDialog,
                      tooltip: 'Informacion del ranking',
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.black),
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
                const SizedBox(height: 18),
                // Tab toggle
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          label: 'Última Partida',
                          icon: Icons.emoji_events_rounded,
                          selected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          label: 'Ranking',
                          icon: Icons.leaderboard_rounded,
                          selected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _selectedTab == 0
                      ? _buildLastMatchTab(rankingState.lastMatchWinner, avatars)
                      : entries.isEmpty
                          ? const _EmptyRankingView()
                          : ListView.separated(
                              itemCount: entries.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final stats = entry.value;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _showPlayerHistoryDialog(
                                    entry.key,
                                    stats,
                                    podiumByPlayer[entry.key],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: backgroundFor(entry.key),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderFor(entry.key)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          leadingFor(index, entry.key),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.key,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  '${stats.matchesPlayed} partidas jugadas',
                                                  style: const TextStyle(
                                                    color: Color(0xFF5B6680),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${stats.wins}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 32,
                                                  height: 1,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'Victorias',
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
                                  ),
                                );
                              },
                            ),
                ),
                if (_selectedTab == 1 && entries.isNotEmpty) ...[
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
    return const Padding(
      padding: EdgeInsets.only(bottom: 100),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 90, color: Color(0xFFBFC5D2)),
            SizedBox(height: 12),
            Text(
              'Aun no hay partidas completadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B6680),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Juega para aparecer en el ranking',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Color(0xFF7C86A0)),
            ),
          ],
        ),
      ),
    );
  }
}
