import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/login_screen.dart';
import 'package:tripmanager/View/trucks_screen.dart';

class ProfileScreen extends StatelessWidget {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.accentColor,
          title: Text(user?.displayName ?? 'No Name Provided'),
        ),
        body: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TruckScreen(),
                    ),
                  );
                },
                child: ListTile(
                  title: Text("Your Vehicles"),
                  trailing: Icon(Icons.arrow_right),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Divider(),
              ),
              ListTile(
                title: Text("Drivers"),
                trailing: Icon(Icons.arrow_right),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Divider(),
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 44, 43, 43), // Red log-out button
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                onPressed: () {
                  // Show confirmation dialog before logging out
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Log Out"),
                        content: Text("Are you sure you want to log out?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text("Log Out"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 80,
              )
            ],
          ),
        ));
  }
}
