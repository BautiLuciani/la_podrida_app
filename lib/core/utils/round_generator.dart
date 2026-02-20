class RoundGenerator {
  const RoundGenerator._();

  static List<int> generate(
    int playerCount, {
    required bool extraRound,
  }) {
    final rounds = <int>[];

    rounds.addAll(List<int>.generate(7, (index) => index + 1));
    rounds.addAll(List<int>.filled(playerCount, 7));
    rounds.addAll(List<int>.generate(7, (index) => 7 - index));
    if (extraRound) {
      rounds.add(1);
    }

    return rounds;
  }
}
