import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/DriverDetail.dart'; // Adjust the import path based on your file structure

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  Future<List<Map<String, dynamic>>> _getDrivers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDriver', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'name': doc['name'],
      };
    }).toList();
  }

  Future<double> _getDriverBalance(String driverName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: driverName)
        .get();

    double balance = 0.0;

    for (var doc in snapshot.docs) {
      String amountStr = doc['amount'] ?? '0.0';
      String type = doc['type'] ?? '';

      double amount = double.tryParse(amountStr) ?? 0.0;

      if (type == 'got') {
        balance += amount;
      } else if (type == 'gave') {
        balance -= amount;
      }
    }

    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drivers"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 24, // Increased font size for top bar title
          fontWeight: FontWeight.bold, // Optional: make the title bold
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDrivers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No drivers found"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var driver = snapshot.data![index];
              String driverName = driver['name'];

              return FutureBuilder<double>(
                future: _getDriverBalance(driverName),
                builder: (context, balanceSnapshot) {
                  if (balanceSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Text("Loading balance..."),
                    );
                  }

                  if (balanceSnapshot.hasError) {
                    return ListTile(
                      title: Text("Error: ${balanceSnapshot.error}"),
                    );
                  }

                  double balance = balanceSnapshot.data ?? 0.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DriverDetail(
                            tripData: {'driverName': driverName},
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon Section
                            CircleAvatar(
                              backgroundColor: const Color.fromARGB(255, 128, 17, 54),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            // Driver Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 177, 43, 34),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Balance:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "₹ ${balance.toStringAsFixed(2)}", // Rupee symbol added
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 81, 182, 114),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
