// import 'package:flutter/material.dart';

// class QuizResultScreen extends StatelessWidget {
//   final List<dynamic> kuisData;

//   const QuizResultScreen({super.key, required this.kuisData});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Hasil Kuis')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Quiz selesai!',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: kuisData.length,
//                 itemBuilder: (context, index) {
//                   final soal = kuisData[index];
//                   return ListTile(
//                     title: Text(soal['pertanyaan']),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Jawaban benar: ${soal['jawaban_benar']}'),
//                         Text('Jawaban kamu: ${soal['jawaban_user'] ?? '-'}'),
//                         Text('Skor: ${soal['skor'] ?? 0}'),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Tutup'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
