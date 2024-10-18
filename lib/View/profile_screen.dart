import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/trucks_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.accentColor,
          title: Text('Admin'),
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
                            onPressed: () {
                              // Perform the log-out action here
                              Navigator.of(context).pop(); // Close the dialog
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Logged out successfully"),
                              ));
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
