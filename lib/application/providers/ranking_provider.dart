import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';
import 'package:la_podrida_app/domain/models/match.dart';

final rankingProvider =
    NotifierProvider<RankingNotifier, RankingState>(RankingNotifier.new);

class RankingState {
  const RankingState({
    required this.statsByPlayer,
  });

  final Map<String, PlayerRankingStats> statsByPlayer;

  RankingState copyWith({
    Map<String, PlayerRankingStats>? statsByPlayer,
  }) {
    return RankingState(
      statsByPlayer: statsByPlayer ?? this.statsByPlayer,
    );
  }
}

class PlayerRankingStats {
  const PlayerRankingStats({
    required this.totalPoints,
    required this.matchesPlayed,
    required this.wins,
  });

  final int totalPoints;
  final int matchesPlayed;
  final int wins;

  double get averagePoints => matchesPlayed == 0 ? 0 : totalPoints / matchesPlayed;
  double get winRate => matchesPlayed == 0 ? 0 : wins / matchesPlayed;

  PlayerRankingStats copyWith({
    int? totalPoints,
    int? matchesPlayed,
    int? wins,
  }) {
    return PlayerRankingStats(
      totalPoints: totalPoints ?? this.totalPoints,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
    );
  }

  Map<String, int> toJson() {
    return <String, int>{
      'totalPoints': totalPoints,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
    };
  }

  factory PlayerRankingStats.fromJson(Map<String, int> json) {
    return PlayerRankingStats(
      totalPoints: json['totalPoints'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
    );
  }
}

class RankingNotifier extends Notifier<RankingState> {
  @override
  RankingState build() {
    return const RankingState(statsByPlayer: <String, PlayerRankingStats>{});
  }

  Future<void> loadFromStorage() async {
    final stored = await ref.read(localStorageServiceProvider).getRankingStats();
    final parsed = stored.map(
      (key, value) => MapEntry(key, PlayerRankingStats.fromJson(value)),
    );
    state = state.copyWith(statsByPlayer: parsed);
  }

  Future<void> addMatchResult(Match match) async {
    final storage = ref.read(localStorageServiceProvider);
    final stored = await storage.getRankingStats();
    final updated = stored.map(
      (key, value) => MapEntry(key, PlayerRankingStats.fromJson(value)),
    );

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
    final winnerScore = playerScores.isNotEmpty ? playerScores.first.score : 0;

    int? previousScore;
    int? previousEarnedPoints;

    for (var index = 0; index < playerScores.length; index++) {
      final playerScore = playerScores[index];
      final playerName = playerScore.name;
      if (playerName.isEmpty) continue;

      final previous = updated[playerName] ??
          const PlayerRankingStats(totalPoints: 0, matchesPlayed: 0, wins: 0);
      final isWinner = playerScore.score == winnerScore;
      final earnedPoints = (previousScore != null && playerScore.score == previousScore)
          ? previousEarnedPoints!
          : totalPlayers - index;

      updated[playerName] = previous.copyWith(
        totalPoints: previous.totalPoints + earnedPoints,
        matchesPlayed: previous.matchesPlayed + 1,
        wins: previous.wins + (isWinner ? 1 : 0),
      );

      previousScore = playerScore.score;
      previousEarnedPoints = earnedPoints;
    }

    final serializable = updated.map((key, value) => MapEntry(key, value.toJson()));
    await storage.saveRankingStats(serializable);
    state = state.copyWith(statsByPlayer: updated);
  }

  Future<void> clearHistory() async {
    await ref.read(localStorageServiceProvider).clearRankingPoints();
    state = state.copyWith(statsByPlayer: <String, PlayerRankingStats>{});
  }
}
