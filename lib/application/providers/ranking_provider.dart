import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';
import 'package:la_podrida_app/domain/models/match.dart';

final rankingProvider =
    NotifierProvider<RankingNotifier, RankingState>(RankingNotifier.new);

class RankingState {
  const RankingState({
    required this.statsByPlayer,
    this.lastMatchWinner,
  });

  final Map<String, PlayerRankingStats> statsByPlayer;
  final String? lastMatchWinner;

  RankingState copyWith({
    Map<String, PlayerRankingStats>? statsByPlayer,
    String? lastMatchWinner,
  }) {
    return RankingState(
      statsByPlayer: statsByPlayer ?? this.statsByPlayer,
      lastMatchWinner: lastMatchWinner ?? this.lastMatchWinner,
    );
  }
}

class PlayerRankingStats {
  const PlayerRankingStats({
    required this.totalPoints,
    required this.matchesPlayed,
    required this.wins,
    required this.rankingHistory,
  });

  final int totalPoints;
  final int matchesPlayed;
  final int wins;
  final List<RankingMatchHistoryEntry> rankingHistory;

  double get averagePoints => matchesPlayed == 0 ? 0 : totalPoints / matchesPlayed;
  double get winRate => matchesPlayed == 0 ? 0 : wins / matchesPlayed;

  PlayerRankingStats copyWith({
    int? totalPoints,
    int? matchesPlayed,
    int? wins,
    List<RankingMatchHistoryEntry>? rankingHistory,
  }) {
    return PlayerRankingStats(
      totalPoints: totalPoints ?? this.totalPoints,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      rankingHistory: rankingHistory ?? this.rankingHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalPoints': totalPoints,
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'rankingHistory': rankingHistory.map((entry) => entry.toJson()).toList(),
    };
  }

  factory PlayerRankingStats.fromJson(Map<String, dynamic> json) {
    final parsedHistory = <RankingMatchHistoryEntry>[];
    if (json['rankingHistory'] is List) {
      final rawHistory = json['rankingHistory'] as List<dynamic>;
      for (final entry in rawHistory) {
        if (entry is num) {
          parsedHistory.add(
            RankingMatchHistoryEntry(
              dateIso: '',
              playersCount: 0,
              place: 0,
              rankingPoints: entry.toInt(),
            ),
          );
          continue;
        }
        if (entry is Map<String, dynamic>) {
          parsedHistory.add(RankingMatchHistoryEntry.fromJson(entry));
        }
      }
    }

    return PlayerRankingStats(
      totalPoints: json['totalPoints'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      wins: json['wins'] ?? 0,
      rankingHistory: parsedHistory,
    );
  }
}

class RankingMatchHistoryEntry {
  const RankingMatchHistoryEntry({
    required this.dateIso,
    required this.playersCount,
    required this.place,
    required this.rankingPoints,
  });

  final String dateIso;
  final int playersCount;
  final int place;
  final int rankingPoints;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dateIso': dateIso,
      'playersCount': playersCount,
      'place': place,
      'rankingPoints': rankingPoints,
    };
  }

  factory RankingMatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return RankingMatchHistoryEntry(
      dateIso: json['dateIso'] as String? ?? '',
      playersCount: (json['playersCount'] as num?)?.toInt() ?? 0,
      place: (json['place'] as num?)?.toInt() ?? 0,
      rankingPoints: (json['rankingPoints'] as num?)?.toInt() ?? 0,
    );
  }
}

class RankingNotifier extends Notifier<RankingState> {
  @override
  RankingState build() {
    return const RankingState(statsByPlayer: <String, PlayerRankingStats>{});
  }

  Future<void> loadFromStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final stored = await storage.getRankingStats();
    final parsed = stored.map(
      (key, value) => MapEntry(key, PlayerRankingStats.fromJson(value)),
    );
    final lastMatchWinner = await storage.getLastMatchWinner();
    state = RankingState(
      statsByPlayer: parsed,
      lastMatchWinner: lastMatchWinner,
    );
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
    final winnerName = playerScores.isNotEmpty ? playerScores.first.name.trim() : null;

    int? previousScore;
    int currentPlace = 0;

    for (var index = 0; index < playerScores.length; index++) {
      final playerScore = playerScores[index];
      final playerName = playerScore.name;
      if (playerName.isEmpty) continue;

      if (previousScore == null || playerScore.score != previousScore) {
        currentPlace = index + 1;
      }

      final previous = updated[playerName] ??
          const PlayerRankingStats(
            totalPoints: 0,
            matchesPlayed: 0,
            wins: 0,
            rankingHistory: <RankingMatchHistoryEntry>[],
          );
      final isWinner = playerScore.score == winnerScore;
      final earnedPoints = isWinner ? 1 : 0;
      final updatedHistory = List<RankingMatchHistoryEntry>.from(previous.rankingHistory)
        ..add(
          RankingMatchHistoryEntry(
            dateIso: DateTime.now().toIso8601String(),
            playersCount: totalPlayers,
            place: currentPlace,
            rankingPoints: earnedPoints,
          ),
        );

      updated[playerName] = previous.copyWith(
        totalPoints: previous.totalPoints + earnedPoints,
        matchesPlayed: previous.matchesPlayed + 1,
        wins: previous.wins + (isWinner ? 1 : 0),
        rankingHistory: updatedHistory,
      );

      previousScore = playerScore.score;
    }

    final serializable = updated.map((key, value) => MapEntry(key, value.toJson()));
    await storage.saveRankingStats(serializable);

    if (winnerName != null && winnerName.isNotEmpty) {
      await storage.saveLastMatchWinner(winnerName);
    }

    state = RankingState(
      statsByPlayer: updated,
      lastMatchWinner: winnerName ?? state.lastMatchWinner,
    );
  }

  Future<void> clearHistory() async {
    await ref.read(localStorageServiceProvider).clearRankingPoints();
    state = const RankingState(statsByPlayer: <String, PlayerRankingStats>{});
  }
}
