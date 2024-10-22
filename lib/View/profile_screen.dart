import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/login_screen.dart';
import 'package:tripmanager/View/vehicles_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String _isDriver = 'false';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        _isDriver = userData.data()?['isDriver']?.toString() ?? 'false';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDriverStatus(bool newStatus) async {
    try {
      String newStatusString = newStatus ? 'true' : 'false';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'isDriver': newStatusString});

      setState(() {
        _isDriver = newStatusString;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Driver status updated successfully')),
      );
    } catch (e) {
      print('Error updating driver status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update driver status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(user?.photoURL ??
                "https://i.pinimg.com/564x/9e/c9/19/9ec919468e1ed8af1002b551f5950a94.jpg"),
          ),
        ),
        backgroundColor: AppColors.accentColor,
        title: Text(user?.displayName ?? 'No Name Provided'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('Driver Status: ', style: TextStyle(fontSize: 18)),
                  //     Switch(
                  //       value: _isDriver == 'true',
                  //       onChanged: (bool value) {
                  //         _updateDriverStatus(value);
                  //       },
                  //     ),
                  //   ],
                  // ),
                  Text(
                    _isDriver == 'true' ? 'You are a driver' : 'You are a Owner',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 20),
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
                      backgroundColor: const Color.fromARGB(255, 44, 43, 43),
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Log Out"),
                            content: Text("Are you sure you want to log out?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
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
                  SizedBox(height: 80)
                ],
              ),
            ),
    );
  }
}
