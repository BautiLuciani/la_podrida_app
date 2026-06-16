class ScoreCalculator {
  const ScoreCalculator._();

  static int calculate({
    required int bid,
    required bool fulfilled,
    required int pointsPerBazaGanada,
    required int pointsPerBazaPerdida,
  }) {
    if (fulfilled) {
      return 10 + (bid * pointsPerBazaGanada);
    }
    return bid * pointsPerBazaPerdida;
  }
}
