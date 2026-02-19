import 'package:la_podrida_app/domain/models/player.dart';
import 'package:la_podrida_app/domain/models/round.dart';

class Match {
  const Match({
    required this.players,
    required this.rounds,
    required this.bids,
    required this.fulfilled,
    required this.roundScores,
    required this.currentRoundIndex,
    required this.finished,
  });

  final List<Player> players;
  final List<Round> rounds;
  final List<List<int?>> bids;
  final List<List<bool?>> fulfilled;
  final List<List<int?>> roundScores;
  final int currentRoundIndex;
  final bool finished;

  Match copyWith({
    List<Player>? players,
    List<Round>? rounds,
    List<List<int?>>? bids,
    List<List<bool?>>? fulfilled,
    List<List<int?>>? roundScores,
    int? currentRoundIndex,
    bool? finished,
  }) {
    return Match(
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      bids: bids ?? this.bids,
      fulfilled: fulfilled ?? this.fulfilled,
      roundScores: roundScores ?? this.roundScores,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
      finished: finished ?? this.finished,
    );
  }
}
