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
      await FirebaseFirestore.instance.collection('trips').doc(tripId).delete();

      print('Trip successfully deleted');
    } on FirebaseException catch (e) {
      print('Error deleting trip: ${e.message}');
      throw Exception('Failed to delete trip: ${e.message}');
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
