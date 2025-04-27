import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';

class MateriDetailScreen extends StatefulWidget {
  final String title; // Mengambil judul untuk pencarian materi

  const MateriDetailScreen({super.key, required this.title});

  @override
  _MateriDetailScreenState createState() => _MateriDetailScreenState();
}

class _MateriDetailScreenState extends State<MateriDetailScreen> {
  bool isLoading = true;
  String content = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMateriDetail();
  }

  // Fungsi untuk mencari materi berdasarkan judul
  Future<void> fetchMateriDetail() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/materi/cari?judul=${widget.title}'), // Ganti dengan IP lokal Anda
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          content = data[0]['konten']; // Ambil konten dari hasil pencarian pertama
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil data materi. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoading ? "Loading..." : widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Loading indicator
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage)) // Pesan error jika API gagal
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(content, style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Aksi untuk mulai game
                        },
                        child: const Text("Mulai Game"),
                      ),
                    ],
                  ),
      ),
    );
  }
}
