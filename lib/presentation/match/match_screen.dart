import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
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
  Future<void> _openBidDialog({
    required Match match,
    required int roundIndex,
    required int playerIndex,
  }) async {
    final notifier = ref.read(matchProvider.notifier);
    final round = match.rounds[roundIndex];
    final currentBid = match.bids[roundIndex][playerIndex];
    final controller = TextEditingController(text: currentBid?.toString() ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        int? parsed = currentBid;
        bool invalid = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            void recomputeValidation() {
              final bid = parsed;
              if (bid == null) {
                invalid = true;
                return;
              }
              final forbidden = notifier.isBidForbidden(
                roundIndex: roundIndex,
                playerIndex: playerIndex,
                bid: bid,
              );
              final zeroBlocked = notifier.isZeroBlocked(
                roundIndex: roundIndex,
                playerIndex: playerIndex,
                bid: bid,
              );
              invalid = forbidden || zeroBlocked || bid < 0 || bid > round.trickTarget;
            }

            recomputeValidation();

            return AlertDialog(
              title: Text('Pedido de ${match.players[playerIndex].name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ronda: ${round.number}  |  Bazas: ${round.trickTarget}'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Pedido',
                      errorText: invalid ? 'Pedido inválido para esta ronda' : null,
                    ),
                    onChanged: (value) {
                      setModalState(() {
                        parsed = int.tryParse(value);
                      });
                    },
                  ),
                  if (invalid)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Regla activa: el último jugador no puede completar la suma exacta ni violar 000.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: invalid || parsed == null
                      ? null
                      : () {
                          notifier.setBid(
                            roundIndex: roundIndex,
                            playerIndex: playerIndex,
                            bid: parsed!,
                          );
                          Navigator.of(context).pop();
                        },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resolveCurrentRound(Match match) async {
    final currentIndex = match.currentRoundIndex;
    final round = match.rounds[currentIndex];
    final fulfilledValues = List<bool>.filled(match.players.length, false);

    final result = await showDialog<List<bool>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Resolver ronda ${round.number}'),
              content: SingleChildScrollView(
                child: Column(
                  children: List<Widget>.generate(
                    match.players.length,
                    (playerIndex) => CheckboxListTile(
                      value: fulfilledValues[playerIndex],
                      title: Text(match.players[playerIndex].name),
                      subtitle: Text(
                        'Pedido: ${match.bids[currentIndex][playerIndex]}',
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          fulfilledValues[playerIndex] = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(fulfilledValues),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final notifier = ref.read(matchProvider.notifier);
    notifier.resolveRound(roundIndex: currentIndex, roundFulfilled: result);
    notifier.nextRound();

    if (notifier.isGameFinished() && mounted) {
      context.go('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchProvider);
    final notifier = ref.read(matchProvider.notifier);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Partida en juego')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 170 + (match.players.length * 110),
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
                            'Ronda',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                          width: 90,
                          child: Text(
                            'Resolver',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
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
                      final isResolved = match.fulfilled[roundIndex].every((value) => value != null);
                      final canResolve =
                          isCurrentRound && !isResolved && match.bids[roundIndex].every((bid) => bid != null);

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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('R${round.number}'),
                                      Text(
                                        '${round.trickTarget} bazas',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                ...List<Widget>.generate(
                                  match.players.length,
                                  (playerIndex) {
                                    final bid = match.bids[roundIndex][playerIndex];
                                    final fulfilled = match.fulfilled[roundIndex][playerIndex];
                                    final score = match.roundScores[roundIndex][playerIndex];

                                    Color fillColor = Colors.white;
                                    if (fulfilled == true) fillColor = Colors.green.shade100;
                                    if (fulfilled == false) fillColor = Colors.red.shade100;

                                    final isEditable = isCurrentRound && !isResolved;

                                    return SizedBox(
                                      width: 110,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: InkWell(
                                          onTap: isEditable
                                              ? () => _openBidDialog(
                                                    match: match,
                                                    roundIndex: roundIndex,
                                                    playerIndex: playerIndex,
                                                  )
                                              : null,
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            height: 46,
                                            decoration: BoxDecoration(
                                              color: fillColor,
                                              border: Border.all(color: const Color(0xFFD9D9D9)),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              bid == null
                                                  ? '-'
                                                  : score == null
                                                      ? '$bid'
                                                      : '$bid | $score',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: isEditable ? Colors.black : Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: 90,
                                  child: ElevatedButton(
                                    onPressed: canResolve ? () => _resolveCurrentRound(match) : null,
                                    child: const Text('OK'),
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
                        const SizedBox(width: 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
