import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'materi_detail_screen.dart'; // Import halaman materi detail

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  TextEditingController searchController = TextEditingController(); // Controller untuk pencarian

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to quiz screen
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const QuizScreen()),
      // );
    } else if (index == 1) {
      // Stay on home page
    } else if (index == 2) {
      // To profile page
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk mencari materi berdasarkan judul
  Future<List<dynamic>> searchMateriByTitle(String title) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/materi'), // Ganti dengan IP lokal Anda
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat materi berdasarkan judul');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Header dengan pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.amber),
                const SizedBox(width: 8),
                const Text("Materi", style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                SizedBox(
                  width: 150,
                  height: 36,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.all(8),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Button untuk pencarian materi
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                // Cari materi berdasarkan judul yang dimasukkan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MateriDetailScreen(
                      title: searchController.text, // Kirimkan judul yang dicari
                    ),
                  ),
                );
              }
            },
            child: const Text("Cari Materi"),
          ),
          const SizedBox(height: 16),
          // Daftar materi yang sudah diambil dari API (akan ditampilkan setelah pencarian)
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: searchMateriByTitle(searchController.text), // Ambil data berdasarkan judul
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada materi ditemukan.'));
                } else {
                  final materiList = snapshot.data!;
                  return ListView.builder(
                    itemCount: materiList.length,
                    itemBuilder: (context, index) {
                      final materi = materiList[index];
                      return _buildMateriCard(
                        materi['judul'],
                        Colors.blue[300]!,
                        materi['konten'],
                        materi['id'], // Kirim ID materi yang dipilih
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildMateriCard(String title, Color color, String content, int materiId) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail materi dengan ID
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MateriDetailScreen(
              title: title, // Kirim ID materi yang dipilih
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
