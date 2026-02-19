import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/match_provider.dart';
import 'package:la_podrida_app/application/providers/match_setup_provider.dart';
import 'package:la_podrida_app/application/providers/settings_provider.dart';
import 'package:la_podrida_app/domain/models/player.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _loadedLastPlayers = false;

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _handleReorder(
    MatchSetupNotifier setupNotifier,
    int oldIndex,
    int newIndex,
  ) {
    _dismissKeyboard();
    setupNotifier.reorderPlayers(oldIndex, newIndex);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<Player> players) {
    final ids = players.map((player) => player.id).toSet();

    final toRemove = _controllers.keys
        .where((id) => !ids.contains(id))
        .toList();
    for (final id in toRemove) {
      _controllers.remove(id)?.dispose();
    }

    for (final player in players) {
      if (_controllers[player.id] == null) {
        _controllers[player.id] = TextEditingController(text: player.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final setupState = ref.watch(matchSetupProvider);
    final setupNotifier = ref.read(matchSetupProvider.notifier);

    if (!_loadedLastPlayers && settings.lastPlayers.isNotEmpty) {
      _loadedLastPlayers = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setupNotifier.initializeWithLastPlayers(settings.lastPlayers);
      });
    }

    _syncControllers(setupState.players);

    final hasInvalidNames = setupState.players.any(
      (player) => player.name.trim().isEmpty,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar partida')),
      body: FadeInUp(
        duration: const Duration(milliseconds: 320),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  itemCount: setupState.players.length,
                  onReorder: (oldIndex, newIndex) {
                    _handleReorder(setupNotifier, oldIndex, newIndex);
                  },
                  onReorderStart: (_) => _dismissKeyboard(),
                  buildDefaultDragHandles: false,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    final player = setupState.players[index];
                    final canRemove =
                        setupState.players.length >
                        MatchSetupNotifier.minPlayers;

                    return Card(
                      key: ValueKey(player.id),
                      child: ListTile(
                        leading: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_indicator),
                        ),
                        title: TextField(
                          controller: _controllers[player.id],
                          onTapOutside: (_) => _dismissKeyboard(),
                          decoration: InputDecoration(
                            labelText: 'Jugador ${index + 1}',
                          ),
                          onChanged: (value) {
                            setupNotifier.updatePlayerName(player.id, value);
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: canRemove
                              ? () => setupNotifier.removePlayer(player.id)
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed:
                    setupState.players.length < MatchSetupNotifier.maxPlayers
                    ? setupNotifier.addPlayer
                    : null,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Agregar jugador'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: hasInvalidNames
                    ? null
                    : () async {
                        final players = setupState.players
                            .map(
                              (player) =>
                                  player.copyWith(name: player.name.trim()),
                            )
                            .toList();

                        await ref
                            .read(settingsProvider.notifier)
                            .setLastPlayers(
                              players.map((player) => player.name).toList(),
                            );

                        ref.read(matchProvider.notifier).startMatch(players);
                        if (context.mounted) {
                          context.push('/match');
                        }
                      },
                child: const Text('Jugar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
