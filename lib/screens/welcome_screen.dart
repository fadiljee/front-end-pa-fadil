import 'package:flutter/material.dart';
import 'name_input_screen.dart';
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 42, 113, 164),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('images/logo.jpg'), // Your logo
            ),
            
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NameInputScreen()));
              },
              child: Text('start'),
            ),
            SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}