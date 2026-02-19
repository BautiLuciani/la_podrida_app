class ScoreCalculator {
  const ScoreCalculator._();

  static int calculate({
    required int bid,
    required bool fulfilled,
    required int pointsPerBaza,
  }) {
    if (fulfilled) {
      return 10 + (bid * pointsPerBaza);
    }
    return bid * pointsPerBaza;
  }
}
