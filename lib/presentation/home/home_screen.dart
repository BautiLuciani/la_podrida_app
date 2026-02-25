import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showHowToPlayDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(color: Colors.black.withValues(alpha: 0.18)),
                  ),
                ),
              ),
            ),
            Center(
              child: AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text(
                  '¿Cómo jugar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                content: const SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Elegi los jugadores y arranca la partida.',
                        style: TextStyle(color: Color(0xFF25314D)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. En cada ronda, cada jugador dice cuantas bazas cree que va a ganar.',
                        style: TextStyle(color: Color(0xFF25314D)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. Cuando termina la ronda, marca si cada jugador cumplio o no.',
                        style: TextStyle(color: Color(0xFF25314D)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '4. Si no cumplio, carga cuantas bazas realmente hizo.',
                        style: TextStyle(color: Color(0xFF25314D)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '5. La app calcula los puntos automaticamente. Al final, gana el que mas puntos tiene.',
                        style: TextStyle(color: Color(0xFF25314D)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.18),
            ),
          ),
          SafeArea(
            child: FadeIn(
              duration: const Duration(milliseconds: 350),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),
                        const Text(
                          'LA PODRIDA',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 34),
                        SizedBox(
                          width: 180,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => context.push('/setup'),
                            child: const Text(
                              'JUGAR',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 180,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => _showHowToPlayDialog(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'REGLAS',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 180,
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 64,
                                  child: OutlinedButton(
                                    onPressed: () => context.push('/settings'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.black54),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Icon(Icons.settings_outlined, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 64,
                                  child: OutlinedButton(
                                    onPressed: () => context.push('/ranking'),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.black54),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Icon(Icons.workspace_premium_rounded, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 4),
                        const Text(
                          'Creado por BLB',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
