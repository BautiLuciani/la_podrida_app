import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        const SizedBox(height: 24),
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
