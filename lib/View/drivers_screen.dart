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
        title: Text("Drivers"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDrivers(),
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

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var driver = snapshot.data![index];
              String driverName = driver['name'];

              return FutureBuilder<double>(
                future: _getDriverBalance(driverName),
                builder: (context, balanceSnapshot) {
                  if (balanceSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(driverName),
                      subtitle: Text("Loading balance..."),
                    );
                  }

                  if (balanceSnapshot.hasError) {
                    return ListTile(
                      title: Text(driverName),
                      subtitle: Text("Error: ${balanceSnapshot.error}"),
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
                            Text(
                              driverName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
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
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
