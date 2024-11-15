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
  bool _hasAdvance = false;
  String advanceAmount = '0';
  String paymentAmount = '0';
  List<String> paymentAmounts = []; // Initialize an empty list for payment amounts
  List<String> paymentList = [];
  String pendingBalance = '0';


  @override
  void initState() {
    super.initState();
    // Fetch the advance amount when the widget is initialized
    _fetchAdvanceAmount();
    _fetchPaymentAmount();
    _fetchPayments();
    _fetchTripStatus();
    
  }
  Future<void> _fetchPayments() async {
  try {
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();

    if (tripDoc.exists && tripDoc.data() != null) {
      var data = tripDoc.data() as Map<String, dynamic>;
      List<dynamic> payments = data['payments'] ?? [];
      setState(() {
        paymentAmounts = payments.map((payment) => payment['amount'].toString()).toList();
      });
    } else {
      setState(() {
        paymentAmounts = []; // Reset payment list if no data
      });
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching payments: $error')),
    );
  }
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

  bool _isTripCompleted = false;

  Widget _buildActionButtons() {
  return Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: _isTripCompleted ? null : _completeTrip,  // Disable if trip is completed
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.secondaryColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            _isTripCompleted ? 'Completed' : 'Complete Trip',  // Change text based on trip status
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

// Function to handle the trip completion
Future<void> _completeTrip() async {
  try {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .update({'status': 'Trip Completed'});  // Update status to "Trip Completed"

    setState(() {
      _isTripCompleted = true;  // Update state to reflect trip is completed
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip marked as completed')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error completing trip: $e')),
    );
  }
}

// Fetch trip status when building the widget to disable the button if completed
void _fetchTripStatus() async {
  try {
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();

    if (tripDoc.exists) {
      var data = tripDoc.data() as Map<String, dynamic>;
      setState(() {
        _isTripCompleted = data['status'] == 'Trip Completed';  // Check if trip status is 'Trip Completed'
      });
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching trip status: $error')),
    );
  }
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
          _buildAmountRow('Freight Amount', '₹ ${widget.tripData['amount']}', true),
          const SizedBox(height: 4),
          _buildAmountRow('Advance', '₹ $advanceAmount', true),
          const SizedBox(height: 8),
          const Divider(height: 32),
          const SizedBox(height: 16),

          _buildAdvanceSection(),

          // Display Payments List directly under Advance section
          _buildPaymentsList(),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending Balance',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                '₹ $pendingBalance',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
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

Widget _buildPaymentsList() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (!snapshot.hasData || snapshot.data!.data() == null) {
        return const Text('No payments available.');
      }

      final tripData = snapshot.data!.data() as Map<String, dynamic>;
      final payments = tripData['payments'] ?? [];

      if (payments.isEmpty) {
        return const SizedBox(); // No payments to display
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Payments',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...payments.map<Widget>((payment) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment:'),
                Text(
                  '₹ ${payment['amount']}',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            );
          }).toList(),
        ],
      );
    },
  );
}



 Widget _buildAdvanceDisplay() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
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
      ),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: paymentAmounts.map((payment) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(payment, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          );
        }).toList(),
      ),
    ],
  );
}



Widget _buildPaymentList() {
  return ListView.builder(
    itemCount: paymentList.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text('Payment: ${paymentList[index]}'),
      );
    },
  );
}




 Widget _buildAdvanceSection() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        advanceAmount == '0' || advanceAmount.isEmpty ? 'Add Advance' : 'Add Payment',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
      TextButton(
        onPressed: () {
          if (advanceAmount == '0' || advanceAmount.isEmpty) {
            _showAdvanceDialog(); // Show dialog to add advance
          } else {
            _showAdvanceDialog(); // Show dialog to add payment
          }
        },
        child: const Text(
          '+',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 20,
          ),
        ),
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
 Future<void> _fetchPaymentAmount() async {
  try {
    DocumentSnapshot tripDoc = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();

    if (tripDoc.exists && tripDoc.data() != null) {
      var data = tripDoc.data() as Map<String, dynamic>;
      setState(() {
        advanceAmount = data['advanceAmount']?.toString() ?? '0';
        paymentAmounts = data['payments'] != null
            ? List<String>.from(data['payments'].map((payment) => payment['amount']?.toString() ?? '0'))
            : [];
        _hasAdvance = true;
      });
      _calculatePendingBalance(); // Calculate pending balance after fetching
    } else {
      setState(() {
        advanceAmount = '0';
        paymentAmounts = [];
        _hasAdvance = false;
      });
      _calculatePendingBalance(); // Ensure balance is recalculated
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching payment amount: $error')),
    );
  }
}




  void _calculatePendingBalance() {
  // Fetch the freight amount from the 'amount' field in the trip data
  final int freightAmount = int.tryParse(widget.tripData['amount']?.toString() ?? '0') ?? 0;
  final int advanceAmountInt = int.tryParse(advanceAmount) ?? 0;

  // Sum up all payments from the payments array
  final int totalPayments = paymentAmounts.fold<int>(
    0,
    (sum, payment) => sum + (int.tryParse(payment) ?? 0),
  );

  // Set pending balance to freightAmount if no payments or advance are present
  int calculatedPendingBalance;
  if (advanceAmountInt == 0 && totalPayments == 0) {
    calculatedPendingBalance = freightAmount;
  } else {
    calculatedPendingBalance = freightAmount - (advanceAmountInt + totalPayments);
  }

  setState(() {
    pendingBalance = calculatedPendingBalance.toString();
  });
}
  



  void _showAdvanceDialog() {
  bool isAddingAdvance = advanceAmount == '0' || advanceAmount.isEmpty;
  bool isReceivedByDriver = false; // Track switch state

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return AlertDialog(
            title: Text(isAddingAdvance ? 'Add Advance' : 'Add Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Adjust size to fit the content
              children: [
                TextField(
                  controller: advanceController,
                  decoration: const InputDecoration(labelText: 'Enter Amount'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Received by Driver'),
                    Switch(
                      value: isReceivedByDriver,
                      onChanged: (bool newValue) {
                        setStateDialog(() {
                          isReceivedByDriver = newValue; // Update the switch state within the dialog
                        });
                      },
                    ),
                  ],
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
                  if (isAddingAdvance) {
                    _addAdvanceToFirestore(isReceivedByDriver); // Pass the switch state
                  } else {
                    _addPaymentToFirestore(isReceivedByDriver); // Pass the switch state
                  }
                },
                child: Text(isAddingAdvance ? 'Add Advance' : 'Add Payment'),
              ),
            ],
          );
        },
      );
    },
  );
}





  void _addAdvanceToFirestore(bool isReceivedByDriver) async {
  final String amount = advanceController.text;
  if (amount.isNotEmpty) {
    try {
      // Update the trip with advance amount
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({'advanceAmount': amount}); // Update only advanceAmount

      // If the switch is on, also update the driverTransactions collection
      if (isReceivedByDriver) {
        // Fetch the driver name from the trip document
        final tripDoc = await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .get();

        // Make sure the driver name exists in the document
        final driverName = tripDoc.exists && tripDoc.data()?.containsKey('driverName') == true
            ? tripDoc['driverName']
            : 'Unknown Driver'; // Default value in case driverName is missing

        final timestamp = FieldValue.serverTimestamp(); // Use server timestamp for consistency

        // Add to driverTransactions collection
        await FirebaseFirestore.instance.collection('drivertransactions').add({
          'amount': amount,
          'description': 'Trip advance',
          'driverName': driverName, // Use the real driver name here
          'timestamp': timestamp,
          'type': 'got', // The transaction type is "got"
        });
      }

      // Set state to indicate an advance exists
      setState(() {
        _hasAdvance = true; // Update state to indicate an advance exists
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Advance amount added successfully')),
      );

      // Refresh payment list and pending balance
      await _fetchPaymentAmount();

      advanceController.clear();
      Navigator.of(context).pop();
    } catch (error) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add advance: $error')),
      );
    }
  } else {
    // Show message if the amount is empty
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid amount')),
    );
  }
}





  void _addPaymentToFirestore(bool isReceivedByDriver) async {
  final String amount = advanceController.text;
  if (amount.isNotEmpty) {
    try {
      Map<String, dynamic> newPayment = {
        'amount': amount,
        'receivedByDriver': isReceivedByDriver, // Include the flag for payment
      };

      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({
        'payments': FieldValue.arrayUnion([newPayment]), // Add to payments array
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment amount added successfully')),
      );

      advanceController.clear();

      // Refresh payment list and pending balance
      await _fetchPaymentAmount();

      setState(() {
        // Trigger UI update for the payment list and pending balance
      });

      Navigator.of(context).pop(); // Close the dialog if necessary
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add payment: $error')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid amount')),
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
