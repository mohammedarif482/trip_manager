import 'package:flutter/material.dart';
import 'package:tripmanager/View/main_screen.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/Services/auth_service.dart'; // Import the new AuthService

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _handleGoogleSignIn() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
      } else if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Sign-in cancelled or failed')),
        );
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Failed to sign in')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build method remains the same
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to OGT!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Sign in with your Google account to continue',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: Icon(Icons.login, color: Colors.white),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
