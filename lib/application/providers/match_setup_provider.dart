import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/domain/models/player.dart';

final matchSetupProvider =
    NotifierProvider<MatchSetupNotifier, MatchSetupState>(MatchSetupNotifier.new);

class MatchSetupState {
  const MatchSetupState({
    required this.players,
  });

  final List<Player> players;

  MatchSetupState copyWith({
    List<Player>? players,
  }) {
    return MatchSetupState(
      players: players ?? this.players,
    );
  }
}

class MatchSetupNotifier extends Notifier<MatchSetupState> {
  static const int minPlayers = 3;
  static const int maxPlayers = 7;
  int _idCounter = 0;

  @override
  MatchSetupState build() {
    return MatchSetupState(
      players: List<Player>.generate(
        minPlayers,
        (index) => _newPlayer('Jugador ${index + 1}'),
      ),
    );
  }

  Player _newPlayer(String name) {
    _idCounter += 1;
    return Player(id: 'p$_idCounter', name: name);
  }

  void initializeWithLastPlayers(List<String> names) {
    if (names.length < minPlayers) return;
    final normalized = names
        .map((name) => name.trim().isEmpty ? 'Jugador' : name.trim())
        .toList(growable: false);

    state = MatchSetupState(
      players: normalized.take(maxPlayers).map(_newPlayer).toList(),
    );
  }

  void addPlayer() {
    if (state.players.length >= maxPlayers) return;

    final updated = [...state.players, _newPlayer('Jugador ${state.players.length + 1}')];
    state = state.copyWith(players: updated);
  }

  void removePlayer(String playerId) {
    if (state.players.length <= minPlayers) return;

    final updated = state.players.where((player) => player.id != playerId).toList();
    state = state.copyWith(players: updated);
  }

  void updatePlayerName(String playerId, String name) {
    final updatedName = name.trim();
    final updated = state.players
        .map((player) => player.id == playerId ? player.copyWith(name: updatedName) : player)
        .toList();
    state = state.copyWith(players: updated);
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final players = [...state.players];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = players.removeAt(oldIndex);
    players.insert(newIndex, item);
    state = state.copyWith(players: players);
  }
}
