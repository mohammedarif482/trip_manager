import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tripmanager/Model/driver_model.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/home_screen.dart';
import 'package:tripmanager/View/login_screen.dart';
import 'package:tripmanager/View/profile_screen.dart';
import 'package:tripmanager/View/transactions_screen.dart';
import 'package:tripmanager/View/trucks_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
