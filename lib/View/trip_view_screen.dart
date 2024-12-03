import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripmanager/View/Widgets/party_detail.dart';
import 'package:tripmanager/View/Widgets/profit_detail.dart';
import 'package:tripmanager/View/Widgets/DriverDetail.dart'; // Import the new widget

class TripDetailScreen extends StatefulWidget {
  final String tripId;

  const TripDetailScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isDriver = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkUserRole();  // Check if the current user is a driver
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            isDriver = userDoc.data()!['isDriver'] ?? false;
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<Map<String, dynamic>> _fetchTripDetails() async {
  try {
    final tripSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId) // Use the tripId passed to the widget
        .get();

    if (!tripSnapshot.exists) {
      throw Exception('Trip not found');
    }

    return tripSnapshot.data()!;
  } catch (e) {
    print('Error fetching trip details: $e');
    throw Exception('Failed to load trip details: $e');
  }
}


  Future<void> deleteTrip(String tripId) async {
    // Prevent deletion if the user is a driver
    if (isDriver) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Drivers are not allowed to delete trips'),
      ));
      return;
    }

    try {
      final tripSnapshot = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();
      if (!tripSnapshot.exists) {
        print('Trip not found');
        return;
      }

      final tripData = tripSnapshot.data()!;
      final driverName = tripData['driverName'];
      final advances = tripData['advances'] ?? [];
      final payments = tripData['payments'] ?? [];
      final partyName = tripData['partyName'];
      final tripAmount = tripData['amount']; // This is a string

      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();

      for (var advance in advances) {
        if (advance['receivedByDriver'] == true) {
          final driverTransactionQuery = await FirebaseFirestore.instance
              .collection('drivertransactions')
              .where('driverName', isEqualTo: driverName)
              .where('amount', isEqualTo: advance['amount'])
              .where('date', isEqualTo: advance['date'])
              .where('paymentMethod', isEqualTo: advance['paymentMethod'])
              .where('description', isEqualTo: 'Trip advance')
              .get();

          for (var doc in driverTransactionQuery.docs) {
            await FirebaseFirestore.instance
                .collection('drivertransactions')
                .doc(doc.id)
                .delete();
          }
        }
      }

      for (var payment in payments) {
        if (payment['receivedByDriver'] == true) {
          final driverTransactionQuery = await FirebaseFirestore.instance
              .collection('drivertransactions')
              .where('driverName', isEqualTo: driverName)
              .where('amount', isEqualTo: payment['amount'])
              .where('date', isEqualTo: payment['date'])
              .where('paymentMethod', isEqualTo: payment['paymentMethod'])
              .where('description', isEqualTo: 'Trip payment')
              .get();

          for (var doc in driverTransactionQuery.docs) {
            await FirebaseFirestore.instance
                .collection('drivertransactions')
                .doc(doc.id)
                .delete();
          }
        }
      }

      int tripAmountInt = int.parse(tripAmount);
      String transactionAmount = (tripAmountInt * 0.2).toInt().toString();

      final bhataTransactionQuery = await FirebaseFirestore.instance
          .collection('drivertransactions')
          .where('driverName', isEqualTo: driverName)
          .where('amount', isEqualTo: transactionAmount)
          .where('description', isEqualTo: 'Bhata')
          .get();

      for (var doc in bhataTransactionQuery.docs) {
        await FirebaseFirestore.instance
            .collection('drivertransactions')
            .doc(doc.id)
            .delete();
      }

      final partyReportQuery = await FirebaseFirestore.instance
          .collection('partyreport')
          .where('partyName', isEqualTo: partyName)
          .get();

      if (partyReportQuery.docs.isNotEmpty) {
        final partyReportDoc = partyReportQuery.docs.first;
        String currentAmountString = partyReportDoc['amount'];

        int currentAmountInt = int.parse(currentAmountString);
        int newAmount = currentAmountInt - tripAmountInt;

        await FirebaseFirestore.instance
            .collection('partyreport')
            .doc(partyReportDoc.id)
            .update({
          'amount': newAmount.toString(),
        });

        print('Party report updated with new amount');
      } else {
        print('No matching party report found for partyName: $partyName');
      }

      print('Trip and associated transactions successfully deleted');
    } catch (e) {
      print('Error deleting trip or associated transactions: $e');
      throw Exception('Failed to delete trip or transactions: ${e.toString()}');
    }
  }

  void _showDeleteConfirmationDialog() {
    if (isDriver) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Drivers cannot delete trips.'),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this item? '
            'This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                deleteTrip(widget.tripId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        elevation: 2,
        title: Text('Trip Details'),
        actions: [
          if (!isDriver) // Hide delete option if the user is a driver
            PopupMenuButton<String>(
              onSelected: (String choice) {
                if (choice == 'delete') {
                  _showDeleteConfirmationDialog();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'Delete',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
        ],
        bottom: TabBar(
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          controller: _tabController,
          tabs: [
            Tab(text: 'Party'),
            Tab(text: 'Profit'),
            Tab(text: 'Driver'),
            Tab(text: 'More'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchTripDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tripData = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: PartyDetail(
                  tripData: tripData,
                  tripId: widget.tripId,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: ProfitDetail(
                  tripData: tripData,
                  tripId: widget.tripId,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DriverDetail(
                  tripData: tripData,
                ),
              ),
              Container(
                child: Center(
                  child: Text("More"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

