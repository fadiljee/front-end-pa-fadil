import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

/// Panel status posisi pemain, nilai dadu, dan jumlah lemparan.
class GameStatusCard extends StatelessWidget {
  final GameController controller;

  const GameStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatusColumn(
              icon: Icons.person,
              label: "Pemain 1",
              value: controller.player1Position.toString(),
              color: Colors.blue.shade700,
              isActive: controller.currentPlayer == 1,
            ),
            if (controller.isTwoPlayer)
              _StatusColumn(
                icon: Icons.person,
                label: "Pemain 2",
                value: controller.player2Position.toString(),
                color: Colors.red.shade700,
                isActive: controller.currentPlayer == 2,
              ),
            _StatusColumn(
              icon: Icons.casino,
              label: "Dadu",
              value: controller.diceValue.toString(),
              color: Colors.grey.shade700,
            ),
            _StatusColumn(
              icon: Icons.score,
              label: "Lemparan",
              value: controller.throwCount.toString(),
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isActive;

  const _StatusColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel skor terbaik untuk mode 1 pemain.
class GameLeaderboardCard extends StatelessWidget {
  final int bestScore;

  const GameLeaderboardCard({super.key, required this.bestScore});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.star,
          color: Theme.of(context).colorScheme.secondary,
          size: 32,
        ),
        title: const Text(
          "Skor Terbaik",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text("Jumlah lemparan paling sedikit"),
        trailing: Text(
          bestScore == 0 ? "-" : bestScore.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
