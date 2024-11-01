import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';

class PartyDetail extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String tripId;

  const PartyDetail({Key? key, required this.tripData, required this.tripId})
      : super(key: key);

  @override
  State<PartyDetail> createState() => _PartyDetailState();
}

int activeStep = 1;
final TextEditingController advanceController = TextEditingController();
String advanceAmount = "0"; // Variable to hold the advance amount

class _PartyDetailState extends State<PartyDetail> {
  @override
  void initState() {
    super.initState();
    // Fetch the advance amount when the widget is initialized
    _fetchAdvanceAmount();
  }

  Future<void> _fetchAdvanceAmount() async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId) // Fetch the document for the specific trip
        .get();

    if (doc.exists) {
      // Cast the document data to Map<String, dynamic>
      final data = doc.data() as Map<String, dynamic>?; // Use a nullable Map

      if (data != null && data.containsKey('advanceAmount')) {
        setState(() {
          advanceAmount = data['advanceAmount']?.toString() ?? "0"; // Update advanceAmount with the value from Firestore
        });
      } else {
        // Optionally handle the case where advanceAmount is not present
        setState(() {
          advanceAmount = "0"; // or whatever default value you prefer
        });
      }
    }
  } catch (e) {
    // Handle the error (e.g., show a snackbar)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching advance amount: $e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 18),
          _buildTripInfo(),
          SizedBox(height: 10),
          _buildLocationInfo(),
          EasyStepper(
            activeStep: activeStep,
            activeStepTextColor: Colors.black87,
            finishedStepTextColor: Colors.black87,
            internalPadding: 0,
            showLoadingAnimation: false,
            stepRadius: 8,
            showStepBorder: false,
            steps: _buildStepperSteps(),
            onStepReached: (index) => setState(() => activeStep = index),
          ),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildFinancialDetails(),
          const SizedBox(height: 16),
          _buildAddLoadButton(),
        ],
      ),
    );
  }


  Widget _buildTripInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.person_pin),
          Text(
            widget.tripData['partyName'],
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
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
    );
  }

  List<EasyStep> _buildStepperSteps() {
    return [
      EasyStep(
        customStep: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 25,
            backgroundColor: activeStep >= 0 ? Colors.orange : Colors.white,
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
            backgroundColor: activeStep >= 1 ? Colors.orange : Colors.white,
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
            backgroundColor: activeStep >= 2 ? Colors.orange : Colors.white,
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
            backgroundColor: activeStep >= 3 ? Colors.orange : Colors.white,
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
            backgroundColor: activeStep >= 4 ? Colors.orange : Colors.white,
          ),
        ),
        title: 'Delivered',
      ),
    ];
  }

  Widget _buildActionButtons() {
    return Row(
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
    );
  }

  Widget _buildFinancialDetails() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAmountRow('Freight Amount', widget.tripData['amount'], true),
            const SizedBox(height: 4),
            // Display the Advance Amount here
            _buildAdvanceDisplay(),
            const SizedBox(height: 8),
            const Divider(height: 32),
            const SizedBox(height: 16),
            _buildAdvanceSection(), // Advance Section to add amount
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showAddChargesDialog,
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
    );
  }

 Widget _buildAdvanceDisplay() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Advance',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(
        advanceAmount,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}




  Widget _buildAdvanceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Add Advance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.red),
          onPressed: () => _showAdvanceDialog(),
        ),
      ],
    );
  }

  Widget _buildAddLoadButton() {
    return InkWell(
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
    );
  }

  Widget _buildAmountRow(String label, String amount, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle()),
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

  void _showAdvanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Advance Amount'),
          content: TextField(
            controller: advanceController,
            decoration: const InputDecoration(labelText: 'Enter Advance Amount'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addAdvanceToFirestore,
              child: const Text('Add Advance'),
            ),
          ],
        );
      },
    );
  }

  void _addAdvanceToFirestore() async {
  final String amount = advanceController.text;
  if (amount.isNotEmpty) {
    // Store the advance amount in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('trips') // Ensure this matches your Firestore structure
          .doc(widget.tripId) // The ID of the trip document you want to update
          .update({'advanceAmount': amount}); // Update the advance amount

      // Optional: Notify the user on successful addition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Advance amount added successfully')),
      );

      // Fetch the updated advance amount to update the UI
      await _fetchAdvanceAmount();

    } catch (error) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add advance: $error')),
      );
    }

    advanceController.clear(); // Clear the input field
    Navigator.of(context).pop(); // Close the dialog
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Please enter a valid amount')),
    );
  }
}



  void _showAddChargesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Charge'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: advanceController,
                decoration: const InputDecoration(labelText: 'Charge'),
              ),
              TextField(
                controller: advanceController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add charge functionality
                Navigator.of(context).pop();
              },
              child: const Text('Add Charge'),
            ),
          ],
        );
      },
    );
  }
}
