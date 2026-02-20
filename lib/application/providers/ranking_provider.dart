import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';
import 'package:la_podrida_app/domain/models/match.dart';

final rankingProvider =
    NotifierProvider<RankingNotifier, RankingState>(RankingNotifier.new);

class RankingState {
  const RankingState({
    required this.pointsByPlayer,
  });

  final Map<String, int> pointsByPlayer;

  RankingState copyWith({
    Map<String, int>? pointsByPlayer,
  }) {
    return RankingState(
      pointsByPlayer: pointsByPlayer ?? this.pointsByPlayer,
    );
  }
}

class RankingNotifier extends Notifier<RankingState> {
  @override
  RankingState build() {
    return const RankingState(pointsByPlayer: <String, int>{});
  }

  Future<void> loadFromStorage() async {
    final stored = await ref.read(localStorageServiceProvider).getRankingPoints();
    state = state.copyWith(pointsByPlayer: stored);
  }

  Future<void> addMatchResult(Match match) async {
    final storage = ref.read(localStorageServiceProvider);
    final updated = Map<String, int>.from(await storage.getRankingPoints());

    final playerScores = List<({String name, int score})>.generate(
      match.players.length,
      (playerIndex) {
        var total = 0;
        for (final row in match.roundScores) {
          total += row[playerIndex] ?? 0;
        }
        return (name: match.players[playerIndex].name.trim(), score: total);
      },
    )..sort((a, b) => b.score.compareTo(a.score));

    final totalPlayers = playerScores.length;
    for (var index = 0; index < playerScores.length; index++) {
      final playerName = playerScores[index].name;
      if (playerName.isEmpty) continue;

      final earnedPoints = totalPlayers - index;
      updated[playerName] = (updated[playerName] ?? 0) + earnedPoints;
    }

    await storage.saveRankingPoints(updated);
    state = state.copyWith(pointsByPlayer: updated);
  }

  Future<void> clearHistory() async {
    await ref.read(localStorageServiceProvider).clearRankingPoints();
    state = state.copyWith(pointsByPlayer: <String, int>{});
  }
}
