import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);

class SettingsState {
  const SettingsState({
    required this.blockFourZeros,
    required this.pointsPerBaza,
    required this.lastPlayers,
  });

  final bool blockFourZeros;
  final int pointsPerBaza;
  final List<String> lastPlayers;

  SettingsState copyWith({
    bool? blockFourZeros,
    int? pointsPerBaza,
    List<String>? lastPlayers,
  }) {
    return SettingsState(
      blockFourZeros: blockFourZeros ?? this.blockFourZeros,
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
      pointsPerBaza: 1,
      lastPlayers: <String>[],
    );
  }

  Future<void> loadFromStorage() async {
    final storage = ref.read(localStorageServiceProvider);
    final blockFourZeros = await storage.getBlockFourZeros();
    final pointsPerBaza = await storage.getPointsPerBaza();
    final lastPlayers = await storage.getLastPlayers();

    state = state.copyWith(
      blockFourZeros: blockFourZeros ?? state.blockFourZeros,
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

  Future<void> setLastPlayers(List<String> players) async {
    state = state.copyWith(lastPlayers: players);
    await ref.read(localStorageServiceProvider).saveLastPlayers(players);
  }
}
