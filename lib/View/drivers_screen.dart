import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriversScreen extends StatelessWidget {
  const DriversScreen({super.key});

  // Fetch the drivers from Firestore where isDriver is true
  Future<List<Map<String, dynamic>>> _getDrivers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDriver', isEqualTo: true) // Filter users where isDriver is true
        .get();

    // Extract the data from the snapshot
    return snapshot.docs.map((doc) {
      return {
        'name': doc['name'], // Assuming the field 'name' exists in the document
      };
    }).toList();
  }

  // Fetch the amount for each driver (based on the transactions)
  Future<double> _getDriverBalance(String driverName) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: driverName) // Filter transactions for the driver
        .get();

    double balance = 0.0;

    // Loop through the transactions and calculate the balance
    for (var doc in snapshot.docs) {
      String amountStr = doc['amount'] ?? '0.0'; // Get amount as string (default to '0.0' if null)
      String type = doc['type'] ?? '';

      // Convert the amount to double
      double amount = double.tryParse(amountStr) ?? 0.0; // Handle conversion failure (fallback to 0.0)

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
        title: Text("Drivers"),
        backgroundColor: Colors.transparent, // No background color for the AppBar
        elevation: 0, // Remove the shadow effect
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDrivers(), // Fetch the drivers data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No drivers found"));
          }

          // Display the list of drivers with their balance
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var driver = snapshot.data![index];
              String driverName = driver['name'];

              return FutureBuilder<double>(
                future: _getDriverBalance(driverName), // Fetch the balance for this driver
                builder: (context, balanceSnapshot) {
                  if (balanceSnapshot.connectionState == ConnectionState.waiting) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(driverName),
                        subtitle: Text("Loading balance..."),
                      ),
                    );
                  }

                  if (balanceSnapshot.hasError) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(driverName),
                        subtitle: Text("Error: ${balanceSnapshot.error}"),
                      ),
                    );
                  }

                  double balance = balanceSnapshot.data ?? 0.0;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Driver's name
                          Text(
                            driverName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0), // Space between name and balance
                          // Balance with the "Balance: " label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Balance: ",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "₹ ${balance.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green, // Green color for balance
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
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
