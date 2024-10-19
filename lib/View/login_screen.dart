import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tripmanager/View/main_screen.dart';
import 'package:tripmanager/Utils/constants.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(googleUser?.displayName);
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in cancelled')),
        );
        return;
      }

      // Get the authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if the user already exists in Firestore
      final userRef = _firestore.collection('users').doc(userCredential.user?.uid);
      final userSnapshot = await userRef.get();

      // If user does not exist, create a new user document
      if (!userSnapshot.exists) {
        await userRef.set({
          'name': googleUser.displayName, // Store the user's name
          'role': 'local', // Default role
        });
      }

      // Navigate to the main screen on success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavBar(),
        ),
      );

      print('User signed in: ${userCredential.user?.email}');
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
