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

  Future<Map<String, dynamic>> _fetchTripDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();
    return doc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        elevation: 2,
        title: Text('Trip Details'),
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
