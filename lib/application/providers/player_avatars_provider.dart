import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';

final playerAvatarsProvider =
    NotifierProvider<PlayerAvatarsNotifier, Map<String, String>>(PlayerAvatarsNotifier.new);

class PlayerAvatarsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  Future<void> loadFromStorage() async {
    state = await ref.read(localStorageServiceProvider).getPlayerAvatars();
  }

  Future<void> setAvatar(String playerName, String imagePath) async {
    final updated = Map<String, String>.from(state)..[playerName] = imagePath;
    state = updated;
    await ref.read(localStorageServiceProvider).savePlayerAvatars(updated);
  }

  Future<void> removeAvatar(String playerName) async {
    final updated = Map<String, String>.from(state)..remove(playerName);
    state = updated;
    await ref.read(localStorageServiceProvider).savePlayerAvatars(updated);
  }
}
