import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import untuk FilteringTextInputFormatter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 17, color: const Color.fromARGB(255, 30, 29, 29)),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Gradients can be used too
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/logo.jpg'), // Your logo
                
              ),
              SizedBox(height: 30),

              // NISN TextField
              _buildTextField(
                controller: nisnController,
                hintText: 'Enter your NISN',
                icon: Icons.perm_identity, // Icon for user identity
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Only numbers
                ],
              ),
              SizedBox(height: 20),

              // Password TextField
              // _buildTextField(
              //   controller: passwordController,
              //   hintText: 'Enter your password',
              //   icon: Icons.lock,
              //   obscureText: true,
              // ),
              // SizedBox(height: 30),

              // Sign In Button
              _buildSignInButton(),
              SizedBox(height: 20),

              // Social Media Login
              // _buildSocialLoginButtons(),
              // SizedBox(height: 10),

              // Sign Up link
              // TextButton(
              //   onPressed: () {
              //     // Go to Sign Up page
              //   },
              //   child: Text(
              //     "Don't have an account? Sign up",
              //     style: TextStyle(color: Colors.white, fontSize: 14),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, bool obscureText = false, List<TextInputFormatter>? inputFormatters}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputFormatters == null ? TextInputType.text : TextInputType.number, // Only numbers for NISN
        inputFormatters: inputFormatters, // Apply number input formatter for NISN
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 16, 16, 16)),
          hintText: hintText,
          hintStyle: TextStyle(color: const Color.fromARGB(255, 25, 25, 26)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: () {
        // Login function
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        backgroundColor: Colors.blue, // Blue color for the button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        shadowColor: Colors.blue.withOpacity(0.5),
        elevation: 5,
      ),
      child: Text(
        'Sign In',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  // Widget _buildSocialLoginButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       IconButton(
  //         icon: Icon(Icons.golf_course, color: Colors.white),
  //         onPressed: () {
  //           // Google Sign In
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.facebook, color: Colors.white),
  //         onPressed: () {
  //           // Facebook Sign In
  //         },
  //       ),
  //       IconButton(
  //         icon: Icon(Icons.twitter, color: Colors.white),
  //         onPressed: () {
  //           // Twitter Sign In
  //         },
  //       ),
  //     ],
  //   );
  // }
}
