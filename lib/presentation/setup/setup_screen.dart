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
    final canAddPlayer = setupState.players.length < MatchSetupNotifier.maxPlayers;
    final maxListHeight = MediaQuery.sizeOf(context).height * 0.5;

    return Scaffold(
      body: FadeInUp(
        duration: const Duration(milliseconds: 320),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      label: const Text(
                        'Volver',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: ReorderableListView.builder(
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, _) {
                          return Material(
                            color: Colors.transparent,
                            elevation: 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x24000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                      );
                    },
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: setupState.players.length >= 7
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
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
                          setupState.players.length > MatchSetupNotifier.minPlayers;

                      return Container(
                        key: ValueKey(player.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controllers[player.id],
                                onTapOutside: (_) => _dismissKeyboard(),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                ),
                                onChanged: (value) {
                                  setupNotifier.updatePlayerName(player.id, value);
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: canRemove
                                  ? () => setupNotifier.removePlayer(player.id)
                                  : null,
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.drag_indicator),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: canAddPlayer ? setupNotifier.addPlayer : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: canAddPlayer
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFFE7E7E7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Agregar Jugador',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Icon(Icons.add, size: 28),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
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
      ),
    );
  }
}
