import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tripmanager/View/main_screen.dart';
import 'package:tripmanager/Utils/constants.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: '957647225907-dv0kjimvoms4jb64s8pt8eoam0bjaih6.apps.googleusercontent.com', // Replace with your actual client ID
);

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BottomNavBar(),
          ),
        );
        print('User signed in: ${googleUser.email}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in cancelled')),
        );
      }
    } catch (error) {
      print('Google Sign-In failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: () => _handleGoogleSignIn(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
