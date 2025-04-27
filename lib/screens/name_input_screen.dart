import 'package:flutter/material.dart';
import 'home_screen.dart'; // pastikan ini 
import 'package:http/http.dart' as http;
import 'dart:convert';

class NameInputScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  NameInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2ECE6),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selamat datang!!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Masukkan NISN anda',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  String nisn = _controller.text;
                  if (nisn.isNotEmpty) {
                    // Kirim request ke API Laravel untuk login
                    final response = await http.post(
                      Uri.parse('http://127.0.0.1:8000/api/login'), // Ganti dengan IP lokal kamu
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({'nisn': nisn}),
                    );

                     // Debugging: Cek status code dan body dari response
                      print("Response Status Code: ${response.statusCode}");
                      print("Response Body: ${response.body}");

                    // Cek status code 200, jika sukses
                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      String message = data['message'];
                      print('Success: $message');
                      
                      // Konversi nisn menjadi String
                      String nisn = data['data_siswa']['nisn'].toString();  // Mengonversi dari int ke String
                      String nama = data['data_siswa']['nama'];
                      
                      print('NISN: $nisn');
                      print('Nama: $nama');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(userName: nama),
                        ),
                      );
                    } else {
                      final data = jsonDecode(response.body);
                      String message = data['message'];
                      print('Error: $message');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }

                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('NISN tidak boleh kosong')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[100],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
