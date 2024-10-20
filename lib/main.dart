import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase import
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmanager/View/login_screen.dart';
import 'package:tripmanager/View/main_screen.dart';
import 'firebase_options.dart'; // This will be generated by Firebase CLI setup

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Firebase is initialized correctly
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialization
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TripManager',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: AuthCheck() // Start with LoginScreen
        );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return BottomNavBar();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
