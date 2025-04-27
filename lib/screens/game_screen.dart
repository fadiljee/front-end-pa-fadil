import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Konten Materi 1'),
            ElevatedButton(
              onPressed: () {
                // Logic to start game
              },
              child: Text('Mulai Game'),
            )
          ],
        ),
      ),
    );
  }
}