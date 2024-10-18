import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/main_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final TextEditingController _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to AGT!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Enter your mobile number to continue',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryColor, // Set button color to red
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15), // Button padding
                ),
                onPressed: () {
                  String number = _numberController.text;
                  if (number.isNotEmpty && number.length == 10) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BottomNavBar(),
                      ),
                    );
                    print('Number entered: $number');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Please enter a valid 10-digit number"),
                    ));
                  }
                },
                child: Text(
                  "Login",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(

            //     onPressed: () {
            //       String number = _numberController.text;
            //       if (number.isNotEmpty && number.length == 10) {
            //         // Handle login logic here
            //         print('Number entered: $number');
            //       } else {
            //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //           content: Text("Please enter a valid 10-digit number"),
            //         ));
            //       }
            //     },
            //     child: Text("Login"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
