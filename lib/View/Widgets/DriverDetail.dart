import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'DriverStatement.dart';

class DriverDetail extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const DriverDetail({Key? key, required this.tripData}) : super(key: key);

  @override
  _DriverDetailState createState() => _DriverDetailState();
}

class _DriverDetailState extends State<DriverDetail> {
  final List<Map<String, dynamic>> _transactions = [];
  double _totalDriverGot = 0.0;
  double _totalDriverGave = 0.0;
  double _totalCollected = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Load the transactions for the specific driver by driver name
  Future<void> _loadTransactions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('drivertransactions')
          .where('driverName', isEqualTo: widget.tripData['driverName']) // filter by driverName
          .get();

      setState(() {
        _transactions.clear();  // Clear existing transactions
        _transactions.addAll(snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
        
        _calculateTotals();  // Recalculate totals after loading transactions
      });
    } catch (e) {
      print("Error loading transactions: $e");
    }
  }

  // Calculate total driver got, total driver gave, and the total collected
  void _calculateTotals() {
    _totalDriverGot = 0.0;
    _totalDriverGave = 0.0;

    for (var transaction in _transactions) {
      double amount = double.parse(transaction['amount']);
      if (transaction['type'] == 'got') {
        _totalDriverGot += amount;
      } else if (transaction['type'] == 'gave') {
        _totalDriverGave += amount;
      }
    }

    _totalCollected = _totalDriverGot - _totalDriverGave;  // Calculate total collected
  }

  // Add a new transaction to Firestore
  Future<void> _addTransaction(
    String transactionType, String description, String amount, String date, String paymentMethod) async {
  try {
    final transactionData = {
      'driverName': widget.tripData['driverName'], // Store the driver name
      'description': description,
      'amount': amount,
      'type': transactionType,
      'date': date, // Add the date field
      'paymentMethod': paymentMethod, // Add the payment method field
      'fromtrip': 'false',
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('drivertransactions').add(transactionData);

    setState(() {
      _transactions.add(transactionData); // Add transaction to local list
      _calculateTotals(); // Recalculate totals after adding a new transaction
    });
  } catch (e) {
    print("Error adding transaction: $e");
  }
}


  // Show the dialog for adding a new transaction
  void _showTransactionDialog(String transactionType) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedPaymentMethod;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(transactionType == 'got' ? "Driver Got" : "Driver Gave"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: dateController,
            decoration: InputDecoration(
              labelText: 'Date',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                dateController.text = pickedDate.toLocal().toString().split(' ')[0];
              }
            },
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Payment Method'),
            items: [
              DropdownMenuItem(value: 'Cash', child: Text('Cash')),
              DropdownMenuItem(value: 'UPI', child: Text('UPI')),
              DropdownMenuItem(value: 'Card', child: Text('Card')),
              DropdownMenuItem(value: 'Online', child: Text('Online')),
            ],
            onChanged: (value) {
              selectedPaymentMethod = value;
            },
            value: selectedPaymentMethod,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (descriptionController.text.isNotEmpty &&
                amountController.text.isNotEmpty &&
                dateController.text.isNotEmpty &&
                selectedPaymentMethod != null) {
              _addTransaction(
                transactionType,
                descriptionController.text,
                amountController.text,
                dateController.text,
                selectedPaymentMethod!,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text("Submit"),
        ),
      ],
    ),
  );
}



  // Function to settle transactions for the driver
Future<void> _settleTransactions(String date, String paymentMethod) async {
  try {
    // Convert the amount to a string before storing it in Firestore
    String amountAsString = _totalCollected.toString();

    // Create a new transaction entry
    await FirebaseFirestore.instance.collection('drivertransactions').add({
      'driverName': widget.tripData['driverName'], // Use the driver name from tripData
      'amount': amountAsString, // Store amount as a string
      'type': 'gave', // Transaction type (driver gave the amount)
      'date': date, // Use the selected date
      'paymentMethod': paymentMethod, // Use the selected payment method
      'description': 'Settlement', // Description of the transaction
      'fromTrip': 'false', // Or true if you want to indicate it's from a trip
    });

    setState(() {
      _transactions.clear();  // Clear local transactions
      _totalCollected = 0.0;  // Reset the collected amount locally
    });
  } catch (e) {
    print("Error settling transactions: $e");
  }
}


Future<void> _showSettleDialog(BuildContext context) async {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _paymentMethodController = TextEditingController();
  String _paymentMethod = 'Cash'; // Default payment method
  
  // Open the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Settle Transaction'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker
              Text('Select Date'),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'Select Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      // Show date picker
                      DateTime selectedDate = DateTime.now();
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != selectedDate) {
                        _dateController.text = picked.toLocal().toString().split(' ')[0]; // Format the date
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Payment Method Selection
              Text('Select Payment Method'),
              DropdownButton<String>(
                value: _paymentMethod,
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                  });
                },
                items: <String>['Cash', 'UPI','Card', 'Online', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          // Settle Button
          TextButton(
            onPressed: () async {
              // Ensure that both date and payment method are provided
              if (_dateController.text.isNotEmpty && _paymentMethod.isNotEmpty) {
                await _settleTransactions(_dateController.text, _paymentMethod); // Call the function to settle transactions
                Navigator.of(context).pop(); // Close the dialog
              } else {
                // Show an error if required fields are missing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all the fields')),
                );
              }
            },
            child: Text('Settle', style: TextStyle(color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red, // Red color for the settle button
            ),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Info Card
                Container(
                  padding: EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50, // Light blue background
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        widget.tripData['driverName'] ?? 'Driver',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Display the "Collect from Driver" text and the amount in blue
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Collect from Driver', // Header text in black color
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black, // Black color for the text
                        ),
                      ),
                      const SizedBox(height: 4), // Space between the header and the amount
                      Text(
                        '₹${_totalCollected.toStringAsFixed(2)}', // Amount in blue color
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue, // Blue color for the amount
                        ),
                      ),
                    ],
                  ),
                ),

                // Settle Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align the button to the left
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showSettleDialog(context); // Show the dialog when the "Settle" button is pressed
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Set button background color
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                        child: Text(
                          'Settle',
                          style: TextStyle(
                            color: Colors.white, // White text
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Align the button to the left
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to the DriverStatementPage when the button is pressed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverStatementPage(driverName: widget.tripData['driverName']),
                            ),
                          );
                        },
                        icon: Icon(Icons.picture_as_pdf, color: Colors.white), // PDF icon
                        label: Text(
                          'View PDF',
                          style: TextStyle(
                            color: Colors.white, // White text
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // Set button background color
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          ),
                        ),
                      ),
                    ],
                  ),
                ),




                // Header Row for the table
                Container(
                  color: Colors.grey[200], // Light grey background for the header
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "REASON",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "DRIVER GAVE",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "DRIVER GOT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Transactions List
                Column(
                  children: _transactions.map((transaction) {
                    final isDriverGave = transaction['type'] == 'gave';
                    final hasFromTrip = transaction['fromtrip'] == 'true';

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Reason Column
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction['description'] ?? 'No Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  transaction['date'] ?? 'Unknown Date',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${transaction['paymentMethod'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 39, 175, 134),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                if (hasFromTrip)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        'FROM A TRIP',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Driver Gave Column
                          Expanded(
                            flex: 2,
                            child: isDriverGave
                                ? Center(
                                    child: Text(
                                      '- ₹${transaction['amount']}',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Center(child: Text("-")),
                          ),
                          // Driver Got Column
                          Expanded(
                            flex: 2,
                            child: !isDriverGave
                                ? Center(
                                    child: Text(
                                      '₹${transaction['amount']}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Center(child: Text("-")),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),






                ],
              ),
            ),
          ),
          
          // Buttons for adding new transactions (+ Driver Got, - Driver Gave)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _showTransactionDialog('got'),
                child: Text('+ Driver Got'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _showTransactionDialog('gave'),
                child: Text('- Driver Gave'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}