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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> deleteTrip(String tripId) async {
  try {
    // Fetch the trip details to get driverName, tripAmount, and date
    final tripSnapshot = await FirebaseFirestore.instance.collection('trips').doc(tripId).get();

    if (!tripSnapshot.exists) {
      print('Trip not found');
      return;
    }

    final tripData = tripSnapshot.data()!;
    final driverName = tripData['driverName'];
    final tripAmount = tripData['amount']; // This is a string
    final date = tripData['date'];
    final partyName = tripData['partyName']; // Assuming 'partyName' is stored in the trip document

    // Delete the trip from the 'trips' collection
    await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();

    // Calculate 20% of the trip amount as a string
    int tripAmountInt = int.parse(tripAmount);
    String transactionAmount = (tripAmountInt * 0.2).toInt().toString();

    // Query the 'drivertransactions' collection to find the matching transaction
    final driverTransactionQuery = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: driverName)
        .where('amount', isEqualTo: transactionAmount)
        .where('date', isEqualTo: date)
        .where('description', isEqualTo: 'Bhata') // Ensure description is 'Bhata'
        .get();

    // Delete all matching transactions
    for (var doc in driverTransactionQuery.docs) {
      await FirebaseFirestore.instance
          .collection('drivertransactions')
          .doc(doc.id)
          .delete();
    }

    // Now update the 'partyreport' collection
    final partyReportQuery = await FirebaseFirestore.instance
        .collection('partyreport')
        .where('partyName', isEqualTo: partyName)
        .get();

    if (partyReportQuery.docs.isNotEmpty) {
      // Fetch the first matching party report (assuming partyName is unique in partyreport collection)
      final partyReportDoc = partyReportQuery.docs.first;
      String currentAmountString = partyReportDoc['amount']; // Amount is stored as a string

      // Subtract the trip amount from the current amount
      int currentAmountInt = int.parse(currentAmountString);
      int newAmount = currentAmountInt - tripAmountInt;

      // Update the party report with the new amount
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

    print('Trip and associated driver transaction(s) successfully deleted');
  } on FirebaseException catch (e) {
    print('Error deleting trip or driver transaction: ${e.message}');
    throw Exception('Failed to delete trip or transaction: ${e.message}');
  } catch (e) {
    print('Unexpected error deleting trip: $e');
    throw Exception('An unexpected error occurred while deleting the trip');
  }
}




  // // Optional: Function to delete a trip with additional checks or logging
  // Future<bool> safeDeleteTrip(String tripId, {String? userId}) async {
  //   try {
  //     // Optional: Add additional security check if needed
  //     if (userId != null) {
  //       // Verify the trip belongs to the current user before deletion
  //       DocumentSnapshot tripDoc = await _firestore
  //           .collection('trips')
  //           .doc(tripId)
  //           .get();

  //       if (tripDoc.exists) {
  //         // Assuming the trip document has a 'userId' field
  //         if (tripDoc.get('userId') != userId) {
  //           print('Unauthorized deletion attempt');
  //           return false;
  //         }
  //       }
  //     }

  //     // Perform the deletion
  //     await _firestore.collection('trips').doc(tripId).delete();

  //     return true;
  //   } catch (e) {
  //     print('Error in safe delete trip: $e');
  //     return false;
  //   }
  // }

  Future<Map<String, dynamic>> _fetchTripDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  void _showDeleteConfirmationDialog() {
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
                // _handleDelete();
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
