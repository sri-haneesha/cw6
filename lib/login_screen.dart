import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'task_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isSignIn = true;

  void _authenticate() async {
    User? user;
    if (_isSignIn) {
      user = await _authService.signIn(
          _emailController.text.trim(), _passwordController.text.trim());
    } else {
      user = await _authService.signUp(
          _emailController.text.trim(), _passwordController.text.trim());
    }

    if (user != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => TaskListScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isSignIn ? "Login Failed" : "Signup Failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignIn ? "Login" : "Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(_isSignIn ? "Login" : "Sign Up"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignIn = !_isSignIn;
                });
              },
              child: Text(_isSignIn ? "Create an account" : "Already have an account? Sign in"),
            ),
          ],
        ),
      ),
    );
  }
}
