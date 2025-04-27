import 'package:flutter/material.dart';
import 'materi_detail_screen.dart';
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFD9C5F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.edit_note, size: 30), // kuis
            Icon(Icons.home, size: 30),
            Icon(Icons.person, size: 30),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background ungu atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Color(0xFFD9C5F2),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(80),
                ),
              ),
            ),
          ),

          // Konten utama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 20,
                      color: Colors.amber,
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      "Quis",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 24),

                // List Kuis
                QuizCard(title: "quis materi 1", color: Color(0xFF76A9C9)),
                QuizCard(title: "quis materi 2", color: Color(0xFFB4E197)),
                QuizCard(title: "quis materi 3", color: Color(0xFF76A9C9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  final String title;
  final Color color;

  const QuizCard({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info Kuis
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text("waktu: 20 menit"),
              Text("jumlah: 10"),
            ],
          ),

          // Tombol mulai
          ElevatedButton(
            onPressed: () {
              // Navigasi ke halaman soal kuis
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.black),
              ),
            ),
            child: Text("mulai"),
          ),
        ],
      ),
    );
  }
}
