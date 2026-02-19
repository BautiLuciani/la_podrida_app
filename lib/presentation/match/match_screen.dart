import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:la_podrida_app/application/providers/match_provider.dart';
import 'package:la_podrida_app/domain/models/match.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  final Set<String> _invalidBidCells = <String>{};
  final Map<String, TextEditingController> _bidControllers =
      <String, TextEditingController>{};
  final Map<String, FocusNode> _bidFocusNodes = <String, FocusNode>{};

  String _cellKey(int roundIndex, int playerIndex) => '${roundIndex}_$playerIndex';

  TextEditingController _getBidController(String key, String text) {
    final controller = _bidControllers[key];
    if (controller != null) {
      return controller;
    }

    final created = TextEditingController(text: text);
    _bidControllers[key] = created;
    return created;
  }

  FocusNode _getBidFocusNode(String key) {
    final focusNode = _bidFocusNodes[key];
    if (focusNode != null) {
      return focusNode;
    }

    final created = FocusNode();
    _bidFocusNodes[key] = created;
    return created;
  }

  @override
  void dispose() {
    for (final controller in _bidControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _bidFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<bool> _confirmExitMatch() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text('Salir de la partida'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Si salis ahora, se va a descartar la partida en curso. ¿Querés continuar?',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC7CBD3),
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Salir'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      ref.read(matchProvider.notifier).clearMatch();
      return true;
    }
    return false;
  }

  Future<void> _handlePopAttempt() async {
    final shouldExit = await _confirmExitMatch();
    if (shouldExit && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _resolveCurrentRound(Match match) async {
    final currentIndex = match.currentRoundIndex;
    final round = match.rounds[currentIndex];
    final fulfilledValues = List<bool?>.filled(match.players.length, null);
    final trickControllers = List<TextEditingController>.generate(
      match.players.length,
      (playerIndex) => TextEditingController(
        text: '',
      ),
    );
    final notifier = ref.read(matchProvider.notifier);

    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.black.withValues(alpha: 0.18)),
                ),
              ),
            ),
            StatefulBuilder(
              builder: (context, setModalState) {
                final hasMissingSelection = fulfilledValues.any((value) => value == null);
                final hasInvalidInput = List<int>.generate(
                  match.players.length,
                  (index) => index,
                ).any((playerIndex) {
                  if (fulfilledValues[playerIndex] != false) return false;
                  final value = int.tryParse(trickControllers[playerIndex].text);
                  return value == null || value < 0 || value > round.trickTarget;
                });

                return Center(
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    title: Text(
                      'Ronda ${round.number}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    content: SizedBox(
                      width: 420,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List<Widget>.generate(match.players.length, (playerIndex) {
                              final bid = match.bids[currentIndex][playerIndex] ?? 0;
                              final decision = fulfilledValues[playerIndex];
                              final isFulfilled = decision == true;
                              final isNotFulfilled = decision == false;

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              match.players[playerIndex].name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text('Pidio: $bid'),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () {
                                                setModalState(() {
                                                  fulfilledValues[playerIndex] = true;
                                                  trickControllers[playerIndex].text = '';
                                                });
                                              },
                                              style: FilledButton.styleFrom(
                                                backgroundColor: isFulfilled
                                                    ? const Color(0xFF17C964)
                                                    : const Color(0xFFE9E9EE),
                                                foregroundColor: isFulfilled
                                                    ? Colors.white
                                                    : const Color(0xFF25314D),
                                              ),
                                              icon: const Icon(Icons.check, size: 16),
                                              label: const Text('Cumplio'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () {
                                                setModalState(() {
                                                  fulfilledValues[playerIndex] = false;
                                                  trickControllers[playerIndex].clear();
                                                });
                                              },
                                              style: FilledButton.styleFrom(
                                                backgroundColor: isNotFulfilled
                                                    ? const Color(0xFFFF3B3B)
                                                    : const Color(0xFFE9E9EE),
                                                foregroundColor: isNotFulfilled
                                                    ? Colors.white
                                                    : const Color(0xFF25314D),
                                              ),
                                              icon: const Icon(Icons.close, size: 16),
                                              label: const Text('No cumplio'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isNotFulfilled) ...[
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: trickControllers[playerIndex],
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            hintText: 'Bazas que se llevo',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC7CBD3),
                                        foregroundColor: Colors.black,
                                      ),
                                      child: const Text('Cancelar'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SizedBox(
                                    height: 46,
                                    child: ElevatedButton(
                                      onPressed: (hasInvalidInput || hasMissingSelection)
                                          ? null
                                          : () {
                                              try {
                                                final normalizedFulfilled = <bool>[];
                                                final normalizedTaken = <int>[];

                                                for (var playerIndex = 0;
                                                    playerIndex < match.players.length;
                                                    playerIndex++) {
                                                  final decision = fulfilledValues[playerIndex];
                                                  if (decision == null) {
                                                    return;
                                                  }

                                                  if (decision) {
                                                    normalizedFulfilled.add(true);
                                                    normalizedTaken.add(
                                                      match.bids[currentIndex][playerIndex] ?? 0,
                                                    );
                                                    continue;
                                                  }

                                                  final parsed = int.tryParse(
                                                    trickControllers[playerIndex].text,
                                                  );
                                                  if (parsed == null ||
                                                      parsed < 0 ||
                                                      parsed > round.trickTarget) {
                                                    return;
                                                  }

                                                  normalizedFulfilled.add(false);
                                                  normalizedTaken.add(parsed);
                                                }

                                                notifier.resolveRound(
                                                  roundIndex: currentIndex,
                                                  roundFulfilled: normalizedFulfilled,
                                                  roundTakenTricks: normalizedTaken,
                                                );
                                                notifier.nextRound();
                                                Navigator.of(context).pop();
                                              } catch (_) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No se pudo guardar la ronda. Intenta nuevamente.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      child: const Text('Guardar'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      for (final controller in trickControllers) {
        controller.dispose();
      }
    });

    if (notifier.isGameFinished() && mounted) {
      context.go('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchProvider);
    final notifier = ref.read(matchProvider.notifier);
    final tableWidth = (match?.players.length ?? 0) * 110 + 180;

    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partida')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/setup'),
            child: const Text('Crear partida'),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handlePopAttempt();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tabla de Juego'),
          centerTitle: true,
        ),
        body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth.toDouble(),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            '#',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ...match.players.map(
                          (player) => SizedBox(
                            width: 110,
                            child: Text(
                              player.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 72,
                          child: Icon(Icons.check, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: match.rounds.length,
                    itemBuilder: (context, roundIndex) {
                      final round = match.rounds[roundIndex];
                      final isCurrentRound =
                          roundIndex == match.currentRoundIndex && !match.finished;
                      final isResolved =
                          match.fulfilled[roundIndex].every((value) => value != null);
                      final canResolve =
                          isCurrentRound &&
                          !isResolved &&
                          match.bids[roundIndex].every((bid) => bid != null);

                      return FadeInUp(
                        duration: const Duration(milliseconds: 280),
                        delay: Duration(milliseconds: 28 * roundIndex),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '${round.trickTarget}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                ...List<Widget>.generate(
                                  match.players.length,
                                  (playerIndex) {
                                    final bid = match.bids[roundIndex][playerIndex];
                                    final fulfilled =
                                        match.fulfilled[roundIndex][playerIndex];
                                    final isEditable = isCurrentRound && !isResolved;
                                    final isStarter = playerIndex == round.starterIndex;
                                    final cellKey = _cellKey(roundIndex, playerIndex);
                                    final hasError = _invalidBidCells.contains(cellKey);

                                    Color fillColor = Colors.white;
                                    if (fulfilled == true) fillColor = Colors.green.shade100;
                                    if (fulfilled == false) fillColor = Colors.red.shade100;
                                    if (hasError) fillColor = Colors.red.shade100;

                                    final expectedText = bid?.toString() ?? '';
                                    final controller =
                                        _getBidController(cellKey, expectedText);
                                    final focusNode = _getBidFocusNode(cellKey);

                                    if (!focusNode.hasFocus &&
                                        !_invalidBidCells.contains(cellKey) &&
                                        controller.text != expectedText) {
                                      controller.text = expectedText;
                                      controller.selection = TextSelection.collapsed(
                                        offset: controller.text.length,
                                      );
                                    }

                                    return SizedBox(
                                      width: 110,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: isEditable
                                              ? () => FocusScope.of(context)
                                                  .requestFocus(focusNode)
                                              : null,
                                          child: Container(
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: fillColor,
                                              border: Border.all(
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: isEditable
                                                      ? TextField(
                                                          controller: controller,
                                                          focusNode: focusNode,
                                                          keyboardType: TextInputType.number,
                                                          textInputAction: TextInputAction.done,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.digitsOnly,
                                                          ],
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            filled: false,
                                                            border: InputBorder.none,
                                                            enabledBorder: InputBorder.none,
                                                            focusedBorder: InputBorder.none,
                                                            disabledBorder: InputBorder.none,
                                                            errorBorder: InputBorder.none,
                                                            focusedErrorBorder:
                                                                InputBorder.none,
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                          ),
                                                          onTapOutside: (_) {
                                                            focusNode.unfocus();
                                                            if (_invalidBidCells
                                                                .contains(cellKey)) {
                                                              setState(() {
                                                                _invalidBidCells
                                                                    .remove(cellKey);
                                                                controller.text =
                                                                    expectedText;
                                                              });
                                                            }
                                                          },
                                                          onChanged: (value) {
                                                            if (value.isEmpty) {
                                                              if (_invalidBidCells
                                                                  .contains(cellKey)) {
                                                                setState(() {
                                                                  _invalidBidCells
                                                                      .remove(cellKey);
                                                                });
                                                              }
                                                              return;
                                                            }

                                                            final parsed =
                                                                int.tryParse(value);
                                                            if (parsed == null) {
                                                              setState(() {
                                                                _invalidBidCells
                                                                    .add(cellKey);
                                                              });
                                                              return;
                                                            }

                                                            final success =
                                                                notifier.setBid(
                                                              roundIndex:
                                                                  roundIndex,
                                                              playerIndex:
                                                                  playerIndex,
                                                              bid: parsed,
                                                            );
                                                            setState(() {
                                                              if (success) {
                                                                _invalidBidCells
                                                                    .remove(cellKey);
                                                              } else {
                                                                _invalidBidCells
                                                                    .add(cellKey);
                                                              }
                                                            });
                                                          },
                                                        )
                                                      : Text(
                                                          bid == null
                                                              ? '-'
                                                              : '$bid',
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                ),
                                                if (isStarter)
                                                  const Positioned(
                                                    right: 6,
                                                    top: 2,
                                                    child: Text(
                                                      '*',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 72,
                                  child: Center(
                                    child: SizedBox(
                                      width: 44,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: canResolve
                                            ? () => _resolveCurrentRound(match)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size.zero,
                                          padding: EdgeInsets.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Icon(Icons.check, size: 18),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ...List<Widget>.generate(
                          match.players.length,
                          (playerIndex) => SizedBox(
                            width: 110,
                            child: Text(
                              notifier.getTotalScore(playerIndex).toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 72),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
