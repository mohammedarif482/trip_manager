import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/Widgets/partystatement.dart';
import 'package:tripmanager/main.dart';

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
String advanceAmount = "0";

class _PartyDetailState extends State<PartyDetail> {
  bool _hasAdvance = false;
  String advanceAmount = '0';
  String paymentAmount = '0';
  List<String> paymentAmounts = [];
  List<String> paymentList = [];
  String pendingBalance = '0';

  @override
  void initState() {
    super.initState();
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
          paymentAmounts =
              payments.map((payment) => payment['amount'].toString()).toList();
        });
      } else {
        setState(() {
          paymentAmounts = [];
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching payments: $error')),
      );
    }
  }

  Future<void> addEndDateToTrip() async {
    try {
      DocumentReference tripDoc =
          FirebaseFirestore.instance.collection('trips').doc(widget.tripId);

      await tripDoc.update({
        'endDate': DateTime.now(),
      });

      print("End date added successfully");
    } catch (e) {
      print("Failed to add end date: $e");
    }
  }

  Future<void> _fetchAdvanceAmount() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('advanceAmount')) {
          setState(() {
            advanceAmount = data['advanceAmount']?.toString() ?? "0";
          });
        } else {
          setState(() {
            advanceAmount = "0";
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching advance amount: $e')),
      );
    }
  }

  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {}
  }

  void _showConfirmationDialog() async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('Do you want to proceed to the next step?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentStep < 3) {
                print(stepLabels[_currentStep]);
                _changeTripStatus(stepLabels[_currentStep + 1]);
              } else {}
              Navigator.pop(context, true);
            }, // Confirm
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _nextStep(); // Go to the next step only if confirmed
    }
  }

  final stepLabels = [
    'Trip Received',
    'On the Way',
    'Delivered',
    'Trip Completed'
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 18),
          _buildTripInfo(),
          SizedBox(height: 10),
          _buildLocationInfo(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: _currentStep >= index
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: _currentStep >= index
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stepLabels[index],
                        style: TextStyle(
                          color: _currentStep >= index
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (index != 3)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 26),
                      child: Container(
                        width: 22,
                        height: 2,
                        color: _currentStep > index
                            ? AppColors.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),
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

  bool tripStatus = false;
  final buttonLabels = [
    'Trip Received',
    'Trip Started',
    'Delivered',
    'Complete Trip'
  ];
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (_currentStep < 3) {
                _showConfirmationDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Trip already Completed')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.secondaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              _currentStep == 3
                  ? "Trip Completed"
                  : buttonLabels[_currentStep + 1],
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

  Future<void> _changeTripStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip marked as $status')),
      );
      if (status == "Trip Completed") {
        addEndDateToTrip();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing trip: $e')),
      );
    }
  }

  void _fetchTripStatus() async {
    try {
      DocumentSnapshot tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (tripDoc.exists) {
        var data = tripDoc.data() as Map<String, dynamic>;
        //  stepLabels
        print(data['status']);
        for (var i = 0; i < stepLabels.length; i++) {
          if (data['status'] == stepLabels[i]) {
            _currentStep = i;
          } else {}
        }
        setState(() {
          // _isTripCompleted = data['status'] ==
          // 'Trip Completed'; // Check if trip status is 'Trip Completed'
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching trip status: $error')),
      );
    }
  }

  Widget _buildFinancialDetails() {
    final List<Map<String, dynamic>> advanceData =
        List<Map<String, dynamic>>.from(widget.tripData['advances'] ?? []);
    final List<Map<String, dynamic>> paymentData =
        List<Map<String, dynamic>>.from(widget.tripData['payments'] ?? []);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmountRow(
                'Freight Amount', '₹ ${widget.tripData['amount']}', true),
            const SizedBox(height: 4),
            if (advanceData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Advances:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed:
                            _showAdvanceDialog, // Function to add advances
                        tooltip: 'Add Advance',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: advanceData.map((advance) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹ ${advance['amount']}',
                                      style: TextStyle(fontSize: 16)),
                                  AuthCheck.isDriver != true
                                      ? IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteAdvance(advance),
                                          tooltip: 'Delete Advance',
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${advance['date']}',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('${advance['paymentMethod']}',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No advances added yet.',
                      style: TextStyle(color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAdvanceDialog,
                    tooltip: 'Add Advance',
                  ),
                ],
              ),
            const SizedBox(height: 8),
            const Divider(height: 32),
            const SizedBox(height: 16),
            if (paymentData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payments:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed:
                            _showPaymentDialog, // Function to add payments
                        tooltip: 'Add Payment',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.grey.shade100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: paymentData.map((payment) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹ ${payment['amount']}',
                                      style: TextStyle(fontSize: 16)),
                                  AuthCheck.isDriver != true
                                      ? IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deletePayment(payment),
                                          tooltip: 'Delete Payment',
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${payment['date']}',
                                      style: TextStyle(color: Colors.grey)),
                                  Text('${payment['paymentMethod']}',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('No payments made yet.',
                      style: TextStyle(color: Colors.grey)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showPaymentDialog,
                    tooltip: 'Add Payment',
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Balance',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  '₹ $pendingBalance',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartyStatement(
                            tripId: widget.tripId), // Passing dynamic tripId
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryColor),
                  ),
                  child: const Text('Show Statement'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAdvance(Map<String, dynamic> advance) async {
    try {
      // Remove from the 'advances' field in the 'trips' collection
      final tripRef =
          FirebaseFirestore.instance.collection('trips').doc(widget.tripId);
      await tripRef.update({
        'advances': FieldValue.arrayRemove([advance])
      });

      // Check and remove from the 'drivertransactions' collection
      final driverTransactionsRef =
          FirebaseFirestore.instance.collection('drivertransactions');
      final querySnapshot = await driverTransactionsRef
          .where('description', isEqualTo: 'Trip advance')
          .where('date', isEqualTo: advance['date'])
          .where('amount', isEqualTo: advance['amount'])
          .where('paymentMethod', isEqualTo: advance['paymentMethod'])
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Update the local list and UI
      setState(() {
        // Remove the deleted advance from the displayed list
        widget.tripData['advances']
            .remove(advance); // Update the tripData in widget
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Advance deleted successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete advance.')),
      );
      print(
          "Error deleting advance: $error"); // Optionally log the error for debugging
    }
  }

  Future<void> _deletePayment(Map<String, dynamic> payment) async {
    try {
      // Remove from the 'advances' field in the 'trips' collection
      final tripRef =
          FirebaseFirestore.instance.collection('trips').doc(widget.tripId);
      await tripRef.update({
        'payments': FieldValue.arrayRemove([payment])
      });

      // Check and remove from the 'drivertransactions' collection
      final driverTransactionsRef =
          FirebaseFirestore.instance.collection('drivertransactions');
      final querySnapshot = await driverTransactionsRef
          .where('description', isEqualTo: 'Trip payment')
          .where('date', isEqualTo: payment['date'])
          .where('amount', isEqualTo: payment['amount'])
          .where('paymentMethod', isEqualTo: payment['paymentMethod'])
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      // Update the local list and UI
      setState(() {
        // Remove the deleted advance from the displayed list
        widget.tripData['payments']
            .remove(payment); // Update the tripData in widget
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment deleted successfully.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete Payment.')),
      );
      print(
          "Error deleting Payment: $error"); // Optionally log the error for debugging
    }
  }

  Widget _buildAddLoadButton() {
    return InkWell(
      onTap: () async {
        try {
          await FirebaseFirestore.instance
              .collection('trips')
              .doc(widget
                  .tripId) // Ensure you have the tripId to update the correct trip
              .update({
            'status':
                'Trip Not Completed', // Update the status to "Trip Not Completed"
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip marked as incomplete')),
          );

          setState(() {});
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update trip status: $e')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: const [
            Text(
              'Mark Trip as Incomplete',
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
      // Fetch trip data from Firestore
      DocumentSnapshot tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (tripDoc.exists && tripDoc.data() != null) {
        var data =
            tripDoc.data() as Map<String, dynamic>; // Cast Firestore data

        // Safely retrieve and calculate the total of 'amount' from the 'advances' array
        final List<dynamic>? advances =
            data['advances']; // Get the 'advances' field as List
        final int totalAdvances = advances?.fold<int>(
              0,
              (sum, advance) {
                // Make sure 'advance' is a Map and 'amount' is properly converted to int
                final amount =
                    int.tryParse(advance['amount']?.toString() ?? '0') ?? 0;
                return sum + amount;
              },
            ) ??
            0; // Default to 0 if 'advances' is null

        // Safely retrieve payment amounts (if available) and store them as List<String>
        final List<dynamic>? payments = data['payments'];
        final List<String> paymentAmounts = payments != null
            ? List<String>.from(
                payments.map((payment) => payment['amount']?.toString() ?? '0'),
              )
            : [];

        // Set state with the calculated values
        setState(() {
          this.paymentAmounts = paymentAmounts; // Update the payment amounts
          _hasAdvance = true; // We now have advances
        });

        // Recalculate the pending balance after fetching the data
        _calculatePendingBalance(totalAdvances);
      } else {
        // Handle case when trip document doesn't exist or has no data
        setState(() {
          paymentAmounts = [];
          _hasAdvance = false;
        });

        // Ensure the pending balance is recalculated when no data is found
        _calculatePendingBalance(0); // No advances or payments found
      }
    } catch (error) {
      // Show error message if fetching payment data fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching payment amount: $error')),
      );
    }
  }

  void _calculatePendingBalance(int totalAdvances) {
    final int freightAmount =
        int.tryParse(widget.tripData['amount']?.toString() ?? '0') ?? 0;

    // Calculate total payments
    final int totalPayments = paymentAmounts.fold<int>(
      0,
      (sum, payment) => sum + (int.tryParse(payment) ?? 0),
    );

    // Calculate pending balance
    int calculatedPendingBalance =
        freightAmount - (totalAdvances + totalPayments);

    // Update state with calculated balance
    setState(() {
      pendingBalance = calculatedPendingBalance.toString();
    });
  }

  void _showAdvanceDialog() {
    TextEditingController advanceController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    bool isReceivedByDriver = false;
    String selectedPaymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Add Advance'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: advanceController,
                      decoration: const InputDecoration(
                          labelText: 'Enter Advance Amount'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        print('Amount field changed: $value');
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Received by Driver'),
                        Switch(
                          value: isReceivedByDriver,
                          onChanged: (bool newValue) {
                            setStateDialog(() {
                              isReceivedByDriver = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedPaymentMethod,
                      onChanged: (String? newValue) {
                        setStateDialog(() {
                          selectedPaymentMethod = newValue!;
                        });
                      },
                      items: <String>[
                        'Cash',
                        'UPI',
                        'Credit Card',
                        'Bank Transfer'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration:
                          const InputDecoration(labelText: 'Select Date'),
                      readOnly: true, // Prevent typing, show date picker on tap
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          setStateDialog(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String enteredAmount = advanceController.text.trim();
                    String enteredDate = dateController.text.trim();

                    print('Entered Amount: $enteredAmount');
                    print('Entered Date: $enteredDate');

                    if (enteredAmount.isEmpty || enteredDate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter a valid amount and date')),
                      );
                    } else {
                      _addAdvanceToFirestore(isReceivedByDriver,
                          selectedPaymentMethod, enteredDate, enteredAmount);
                      _fetchAdvanceAmount();
                      Navigator.of(context)
                          .pop(); // Close the dialog after adding
                    }
                  },
                  child: const Text('Add Advance'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentDialog() {
    bool isReceivedByDriver = false; // Track switch state
    TextEditingController paymentController =
        TextEditingController(); // Controller for payment amount field
    TextEditingController dateController =
        TextEditingController(); // Controller for date field
    String selectedPaymentMethod = 'Cash'; // Default payment method

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Add Payment'),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min, // Adjust size to fit the content
                children: [
                  TextField(
                    controller: paymentController,
                    decoration:
                        const InputDecoration(labelText: 'Enter Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Received by Driver'),
                      Switch(
                        value: isReceivedByDriver,
                        onChanged: (bool newValue) {
                          setStateDialog(() {
                            isReceivedByDriver = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Select Date'),
                    readOnly: true, // Prevent typing, only allow date picker
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setStateDialog(() {
                          dateController.text = "${pickedDate.toLocal()}"
                              .split(' ')[0]; // Format as YYYY-MM-DD
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setStateDialog(() {
                        selectedPaymentMethod = newValue!;
                      });
                    },
                    items: <String>[
                      'Cash',
                      'UPI',
                      'Credit Card',
                      'Bank Transfer'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    isExpanded: true,
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
                    String enteredAmount = paymentController.text.trim();
                    String enteredDate = dateController.text.trim();

                    if (enteredAmount.isEmpty || enteredDate.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter a valid amount and date')),
                      );
                    } else {
                      _addPaymentToFirestore(
                        isReceivedByDriver,
                        selectedPaymentMethod,
                        enteredDate,
                        enteredAmount,
                      );
                      Navigator.of(context)
                          .pop(); // Close the dialog after adding
                    }
                  },
                  child: const Text('Add Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addAdvanceToFirestore(
      bool isReceivedByDriver,
      String selectedPaymentMethod,
      String enteredDate,
      String enteredAmount) async {
    if (enteredAmount.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .update({
          'advanceAmount': enteredAmount,
          'advances': FieldValue.arrayUnion([
            {
              'amount': enteredAmount,
              'receivedByDriver': isReceivedByDriver,
              'paymentMethod': selectedPaymentMethod,
              'date': enteredDate,
            }
          ])
        }); // Update only advanceAmount and add to 'advances' array
        if (isReceivedByDriver) {
          final tripDoc = await FirebaseFirestore.instance
              .collection('trips')
              .doc(widget.tripId)
              .get();
          final driverName = tripDoc.exists &&
                  tripDoc.data()?.containsKey('driverName') == true
              ? tripDoc['driverName']
              : 'Unknown Driver'; // Default value in case driverName is missing
          final timestamp = FieldValue
              .serverTimestamp(); // Use server timestamp for consistency
          await FirebaseFirestore.instance
              .collection('drivertransactions')
              .add({
            'amount': enteredAmount,
            'description': 'Trip advance',
            'driverName': driverName, // Use the real driver name here
            'timestamp': timestamp,
            'paymentMethod': selectedPaymentMethod,
            'date': enteredDate,
            'fromtrip': 'true',
            'type': 'got', // The transaction type is "got"
          });
        }
        setState(() {
          _hasAdvance = true; // Update state to indicate an advance exists
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Advance amount added successfully')),
        );
        await _fetchPaymentAmount();

        advanceController.clear();
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add advance: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  void _addPaymentToFirestore(
      bool isReceivedByDriver,
      String selectedPaymentMethod,
      String enteredDate,
      String enteredAmount) async {
    if (enteredAmount.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .update({
          'paymentAmount': enteredAmount,
          'payments': FieldValue.arrayUnion([
            {
              'amount': enteredAmount,
              'receivedByDriver': isReceivedByDriver,
              'paymentMethod': selectedPaymentMethod,
              'date': enteredDate,
            }
          ])
        }); // Update only paymentAmount and add to 'payments' array

        if (isReceivedByDriver) {
          final tripDoc = await FirebaseFirestore.instance
              .collection('trips')
              .doc(widget.tripId)
              .get();

          final driverName = tripDoc.exists &&
                  tripDoc.data()?.containsKey('driverName') == true
              ? tripDoc['driverName']
              : 'Unknown Driver'; // Default value in case driverName is missing

          final timestamp = FieldValue
              .serverTimestamp(); // Use server timestamp for consistency

          await FirebaseFirestore.instance
              .collection('drivertransactions')
              .add({
            'amount': enteredAmount,
            'description': 'Trip payment',
            'driverName': driverName, // Use the real driver name here
            'timestamp': timestamp,
            'paymentMethod': selectedPaymentMethod,
            'date': enteredDate,
            'fromtrip': 'true',
            'type': 'got', // The transaction type is "received"
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Payment amount added successfully')),
        );
        await _fetchPaymentAmount();

        advanceController.clear();
        Navigator.of(context).pop();
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
