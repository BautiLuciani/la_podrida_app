import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/application/providers/settings_provider.dart';
import 'package:la_podrida_app/core/utils/round_generator.dart';
import 'package:la_podrida_app/domain/logic/score_calculator.dart';
import 'package:la_podrida_app/domain/models/match.dart';
import 'package:la_podrida_app/domain/models/player.dart';
import 'package:la_podrida_app/domain/models/round.dart';

final matchProvider = NotifierProvider<MatchNotifier, Match?>(MatchNotifier.new);

class MatchNotifier extends Notifier<Match?> {
  @override
  Match? build() {
    return null;
  }

  void startMatch(List<Player> players) {
    final roundsData = RoundGenerator.generate(players.length);
    final rounds = List<Round>.generate(
      roundsData.length,
      (index) => Round(
        number: index + 1,
        trickTarget: roundsData[index],
        starterIndex: index % players.length,
      ),
    );

    final bids = List<List<int?>>.generate(
      rounds.length,
      (_) => List<int?>.filled(players.length, null),
    );
    final fulfilled = List<List<bool?>>.generate(
      rounds.length,
      (_) => List<bool?>.filled(players.length, null),
    );
    final scores = List<List<int?>>.generate(
      rounds.length,
      (_) => List<int?>.filled(players.length, null),
    );

    state = Match(
      players: players,
      rounds: rounds,
      bids: bids,
      fulfilled: fulfilled,
      roundScores: scores,
      currentRoundIndex: 0,
      finished: false,
    );
  }

  bool setBid({
    required int roundIndex,
    required int playerIndex,
    required int bid,
  }) {
    final current = state;
    if (current == null || current.finished) return false;
    if (roundIndex < 0 || roundIndex >= current.rounds.length) return false;
    if (playerIndex < 0 || playerIndex >= current.players.length) return false;

    final trickTarget = current.rounds[roundIndex].trickTarget;
    if (bid < 0 || bid > trickTarget) return false;
    if (isBidForbidden(roundIndex: roundIndex, playerIndex: playerIndex, bid: bid)) {
      return false;
    }
    if (isZeroBlocked(roundIndex: roundIndex, playerIndex: playerIndex, bid: bid)) {
      return false;
    }

    final bids = current.bids.map((row) => [...row]).toList();
    bids[roundIndex][playerIndex] = bid;
    state = current.copyWith(bids: bids);
    return true;
  }

  bool isBidForbidden({
    required int roundIndex,
    required int playerIndex,
    required int bid,
  }) {
    final current = state;
    if (current == null) return false;

    final round = current.rounds[roundIndex];
    final row = current.bids[roundIndex];
    final playerCount = current.players.length;
    final biddingOrder = List<int>.generate(
      playerCount,
      (index) => (round.starterIndex + index) % playerCount,
    );

    final pending = biddingOrder.where((index) => row[index] == null || index == playerIndex).toList();
    if (pending.isEmpty || pending.last != playerIndex) {
      return false;
    }

    final sum = biddingOrder.fold<int>(
      0,
      (total, index) {
        if (index == playerIndex) return total + bid;
        return total + (row[index] ?? 0);
      },
    );
    return sum == round.trickTarget;
  }

  bool isZeroBlocked({
    required int roundIndex,
    required int playerIndex,
    required int bid,
  }) {
    final current = state;
    if (current == null || bid != 0) return false;
    if (!ref.read(settingsProvider).blockFourZeros) return false;
    if (roundIndex < 3) return false;

    for (var index = roundIndex - 3; index < roundIndex; index++) {
      if (current.bids[index][playerIndex] != 0) {
        return false;
      }
    }
    return true;
  }

  void resolveRound({
    required int roundIndex,
    required List<bool> roundFulfilled,
  }) {
    final current = state;
    if (current == null || current.finished) return;
    if (roundFulfilled.length != current.players.length) return;

    final bids = current.bids[roundIndex];
    if (bids.any((bid) => bid == null)) return;

    final fulfilled = current.fulfilled.map((row) => [...row]).toList();
    final roundScores = current.roundScores.map((row) => [...row]).toList();

    for (var playerIndex = 0; playerIndex < current.players.length; playerIndex++) {
      final didFulfill = roundFulfilled[playerIndex];
      fulfilled[roundIndex][playerIndex] = didFulfill;
      roundScores[roundIndex][playerIndex] = calculatePoints(
        bid: bids[playerIndex]!,
        fulfilled: didFulfill,
      );
    }

    state = current.copyWith(
      fulfilled: fulfilled,
      roundScores: roundScores,
    );
  }

  int calculatePoints({
    required int bid,
    required bool fulfilled,
  }) {
    final pointsPerBaza = ref.read(settingsProvider).pointsPerBaza;
    return ScoreCalculator.calculate(
      bid: bid,
      fulfilled: fulfilled,
      pointsPerBaza: pointsPerBaza,
    );
  }

  void nextRound() {
    final current = state;
    if (current == null || current.finished) return;

    final index = current.currentRoundIndex;
    final isResolved = current.fulfilled[index].every((value) => value != null);
    if (!isResolved) return;

    final nextIndex = index + 1;
    if (nextIndex >= current.rounds.length) {
      state = current.copyWith(
        currentRoundIndex: current.rounds.length,
        finished: true,
      );
      return;
    }

    state = current.copyWith(currentRoundIndex: nextIndex);
  }

  int getTotalScore(int playerIndex) {
    final current = state;
    if (current == null) return 0;

    var total = 0;
    for (final row in current.roundScores) {
      total += row[playerIndex] ?? 0;
    }
    return total;
  }

  bool isGameFinished() {
    return state?.finished ?? false;
  }

  void clearMatch() {
    state = null;
  }
}
