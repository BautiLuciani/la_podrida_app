import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:la_podrida_app/data/services/local_storage_service.dart';

final savedPlayersProvider =
    NotifierProvider<SavedPlayersNotifier, List<String>>(SavedPlayersNotifier.new);

class SavedPlayersNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  Future<void> loadFromStorage() async {
    state = await ref.read(localStorageServiceProvider).getSavedPlayers();
  }

  Future<void> setAll(List<String> names) async {
    state = names;
    await ref.read(localStorageServiceProvider).saveSavedPlayers(names);
  }
}
