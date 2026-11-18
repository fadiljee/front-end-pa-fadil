import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

/// Panel kontrol dadu, tombol lempar dadu, kembali, dan reset.
class GameControls extends StatelessWidget {
  final GameController controller;
  final AnimationController diceController;
  final Animation<double> diceAnimation;
  final VoidCallback onRollDice;
  final VoidCallback onBack;
  final VoidCallback onReset;

  const GameControls({
    super.key,
    required this.controller,
    required this.diceController,
    required this.diceAnimation,
    required this.onRollDice,
    required this.onBack,
    required this.onReset,
  });

  static const _diceIcons = <int, IconData>{
    1: Icons.filter_1,
    2: Icons.filter_2,
    3: Icons.filter_3,
    4: Icons.filter_4,
    5: Icons.filter_5,
    6: Icons.filter_6,
  };

  @override
  Widget build(BuildContext context) {
    final isBusy = controller.isDiceRolling || controller.isWaitingAnswer;

    return Column(
      children: [
        AnimatedBuilder(
          animation: diceController,
          builder: (context, child) {
            return Transform.rotate(
              angle: diceAnimation.value * 2 * pi,
              child: Transform.scale(
                scale: 1 + (diceAnimation.value * 0.2),
                child: Icon(
                  _diceIcons[controller.diceValue] ?? Icons.filter_6,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: isBusy ? null : onRollDice,
          icon: const Icon(Icons.casino_outlined),
          label: Text(
            controller.isDiceRolling
                ? "Mengacak..."
                : controller.isWaitingAnswer
                ? "Menunggu Jawaban..."
                : "Lempar Dadu! (P${controller.currentPlayer})",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali"),
                onPressed: onBack,
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                onPressed: onReset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
