import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                ),
              ),
              Container(
                child: Center(
                  child: Text("Profit"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Driver"),
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

class PartyDetail extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const PartyDetail({Key? key, required this.tripData}) : super(key: key);

  @override
  State<PartyDetail> createState() => _PartyDetailState();
}

int activeStep = 1;

class _PartyDetailState extends State<PartyDetail> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 18,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person_pin,
                ),
                Text(
                  widget.tripData['partyName'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),

          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.tripData['fromLocation'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_right_alt_rounded),
              Text(
                widget.tripData['toLocation'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          EasyStepper(
            activeStep: activeStep,

            activeStepTextColor: Colors.black87,
            finishedStepTextColor: Colors.black87,
            internalPadding: 0,
            showLoadingAnimation: false,
            stepRadius: 8,
            showStepBorder: false,
            //  lineDotRadius: 1.5,
            steps: [
              EasyStep(
                customStep: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        activeStep >= 0 ? Colors.orange : Colors.white,
                  ),
                ),
                title: 'Waiting',
              ),
              EasyStep(
                customStep: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor:
                        activeStep >= 1 ? Colors.orange : Colors.white,
                  ),
                ),
                title: 'Order Received',
                topTitle: true,
              ),
              EasyStep(
                customStep: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor:
                        activeStep >= 2 ? Colors.orange : Colors.white,
                  ),
                ),
                title: 'Preparing',
              ),
              EasyStep(
                customStep: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor:
                        activeStep >= 3 ? Colors.orange : Colors.white,
                  ),
                ),
                title: 'On Way',
                topTitle: true,
              ),
              EasyStep(
                customStep: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor:
                        activeStep >= 4 ? Colors.orange : Colors.white,
                  ),
                ),
                title: 'Delivered',
              ),
            ],
            onStepReached: (index) => setState(() => activeStep = index),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Complete Trip',
                    style: TextStyle(color: AppColors.secondaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'View Bill',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Financial Details
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAmountRow('Freight Amount', '₹15,000', true),
                  _buildAmountRow('(-) Advance', '₹0', false),
                  const SizedBox(height: 4),
                  _buildActionLink('Add Advance'),
                  _buildAmountRow('(+) Charges', '₹0', false),
                  const SizedBox(height: 4),
                  _buildActionLink('Add Charges'),
                  _buildAmountRow('(-) Payments', '₹0', false),
                  const SizedBox(height: 4),
                  _buildActionLink('Add Payment'),
                  const Divider(height: 32),
                  _buildAmountRow('Pending Balance', '₹15,000', false),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Note'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                        child: const Text('Request Money'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add Load Button
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Text(
                    'Add load to this Trip',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAmountRow(String label, String amount, bool isEditable) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text(amount),
            if (isEditable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 16, color: AppColors.primaryColor),
            ],
          ],
        ),
      ],
    ),
  );
}

Widget _buildActionLink(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primaryColor)),
    ),
  );
}
