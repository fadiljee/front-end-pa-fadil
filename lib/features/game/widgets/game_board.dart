import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';

/// Widget papan permainan ular tangga 6x5 dengan penomoran zig-zag.
class GameBoard extends StatelessWidget {
  final GameController controller;
  final Animation<double> playerAnimation;

  const GameBoard({
    super.key,
    required this.controller,
    required this.playerAnimation,
  });

  int _calculateBoxNumber(int index) {
    final cols = controller.boardColumns;
    final row = index ~/ cols;
    final col = index % cols;
    final invertedRow = (controller.boardSize - 1) ~/ cols - row;

    if (invertedRow % 2 == 0) {
      return invertedRow * cols + col + 1;
    }
    return invertedRow * cols + (cols - 1 - col) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.boardSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.boardColumns,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemBuilder: (context, index) {
            final cols = controller.boardColumns;
            final row = index ~/ cols;
            final col = index % cols;
            final invertedRow = (controller.boardSize - 1) ~/ cols - row;
            final boxNumber = _calculateBoxNumber(index);

            final hasLadder = controller.ladders.containsKey(boxNumber);
            final hasSnake = controller.snakes.containsKey(boxNumber);

            return AnimatedBuilder(
              animation: playerAnimation,
              builder: (context, child) {
                final hasPlayer1 = controller.player1Position == boxNumber;
                final hasPlayer2 =
                    controller.isTwoPlayer &&
                    controller.player2Position == boxNumber;
                final isCurrentPlayerHere =
                    (hasPlayer1 && controller.currentPlayer == 1) ||
                    (hasPlayer2 && controller.currentPlayer == 2);
                final scale =
                    isCurrentPlayerHere ? playerAnimation.value : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (invertedRow + col) % 2 == 0
                              ? const Color(0xFFE0F2F1)
                              : const Color(0xFFB2DFDB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "$boxNumber",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                        if (hasLadder) _BoardMarker(emoji: "🪜"),
                        if (hasSnake) _BoardMarker(emoji: "🐍"),
                        if (hasPlayer1 && hasPlayer2)
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PlayerPawn(player: 1),
                              _PlayerPawn(player: 2),
                            ],
                          )
                        else if (hasPlayer1)
                          const _PlayerPawn(player: 1)
                        else if (hasPlayer2)
                          const _PlayerPawn(player: 2),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BoardMarker extends StatelessWidget {
  final String emoji;

  const _BoardMarker({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: 24,
        shadows: [
          Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
    );
  }
}

class _PlayerPawn extends StatelessWidget {
  final int player;

  const _PlayerPawn({required this.player});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: player == 1 ? Colors.blue.shade700 : Colors.red.shade700,
      radius: 14,
      child: Text(
        "P$player",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
