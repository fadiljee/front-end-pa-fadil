import 'package:flutter/material.dart';

/// Menampilkan dialog kemenangan saat pemain mencapai kotak terakhir.
Future<void> showWinDialog(
  BuildContext context, {
  required int player,
  required bool isTwoPlayer,
  required int throwCount,
  required int bestScore,
}) {
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder:
        (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  "✨ SELAMAT PEMAIN $player! ✨",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (!isTwoPlayer)
                  Text(
                    "Kamu menang dalam $throwCount lemparan!\nSkor Terbaik: $bestScore",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.celebration),
                  label: const Text("Main Lagi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
