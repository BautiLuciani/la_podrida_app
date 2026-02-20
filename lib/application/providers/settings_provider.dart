import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsState {
  const SettingsState({
    required this.blockFourZeros,
    required this.extraRound,
    required this.pointsPerBaza,
    required this.lastPlayers,
  });

  final bool blockFourZeros;
  final bool extraRound;
  final int pointsPerBaza;
  final List<String> lastPlayers;

  SettingsState copyWith({
    bool? blockFourZeros,
    bool? extraRound,
    int? pointsPerBaza,
    List<String>? lastPlayers,
  }) {
    return SettingsState(
      blockFourZeros: blockFourZeros ?? this.blockFourZeros,
      extraRound: extraRound ?? this.extraRound,
      pointsPerBaza: pointsPerBaza ?? this.pointsPerBaza,
      lastPlayers: lastPlayers ?? this.lastPlayers,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState(
      blockFourZeros: true,
      extraRound: false,
      pointsPerBaza: 1,
      lastPlayers: <String>[],
    );
  }

  Future<void> loadFromStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final blockFourZeros = await storage.getBlockFourZeros();
    final extraRound = await storage.getExtraRound();
    final pointsPerBaza = await storage.getPointsPerBaza();
    final lastPlayers = await storage.getLastPlayers();

    state = state.copyWith(
      blockFourZeros: blockFourZeros ?? state.blockFourZeros,
      extraRound: extraRound ?? state.extraRound,
      pointsPerBaza: pointsPerBaza ?? state.pointsPerBaza,
      lastPlayers: lastPlayers,
    );
  }

  Future<void> toggleBlockFourZeros() async {
    final updated = !state.blockFourZeros;
    state = state.copyWith(blockFourZeros: updated);
    await ref.read(localStorageServiceProvider).saveBlockFourZeros(updated);
  }

  Future<void> setPointsPerBaza(int value) async {
    if (value < 1) return;
    state = state.copyWith(pointsPerBaza: value);
    await ref.read(localStorageServiceProvider).savePointsPerBaza(value);
  }

  Future<void> toggleExtraRound() async {
    final updated = !state.extraRound;
    state = state.copyWith(extraRound: updated);
    await ref.read(localStorageServiceProvider).saveExtraRound(updated);
  }

  Future<void> setLastPlayers(List<String> players) async {
    state = state.copyWith(lastPlayers: players);
    await ref.read(localStorageServiceProvider).saveLastPlayers(players);
  }
}
