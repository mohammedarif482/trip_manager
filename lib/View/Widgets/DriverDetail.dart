import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Future<void> _addTransaction(String transactionType, String description, String amount) async {
    try {
      final transactionData = {
        'driverName': widget.tripData['driverName'],  // Store the driver name
        'description': description,
        'amount': amount,
        'type': transactionType,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('drivertransactions').add(transactionData);

      setState(() {
        _transactions.add(transactionData);  // Add transaction to local list
        _calculateTotals();  // Recalculate totals after adding a new transaction
      });
    } catch (e) {
      print("Error adding transaction: $e");
    }
  }

  // Show the dialog for adding a new transaction
  void _showTransactionDialog(String transactionType) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

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
                  amountController.text.isNotEmpty) {
                _addTransaction(transactionType, descriptionController.text, amountController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }

  // Function to delete transactions for the driver
  Future<void> _settleTransactions() async {
    try {
      // Delete the driver transactions from Firestore where driverName matches
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('drivertransactions')
          .where('driverName', isEqualTo: widget.tripData['driverName']) // filter by driverName
          .get();

      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance.collection('drivertransactions').doc(doc.id).delete();
      }

      setState(() {
        _transactions.clear();  // Clear local transactions
        _totalCollected = 0.0;  // Reset the collected amount locally
      });
    } catch (e) {
      print("Error deleting transactions: $e");
    }
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_car, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            widget.tripData['driverName'] ?? 'Driver',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.blue,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'On Trip',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Divider(thickness: 1.5),
                  SizedBox(height: 16),
                  
                  // New section: Total Collected
                  Text(
                    'Collected from Driver:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₹${_totalCollected.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _totalCollected >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Settle Button
                  ElevatedButton(
                    onPressed: _settleTransactions,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: Colors.red),  // Red border
                      backgroundColor: Colors.white,  // White background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Settle',
                      style: TextStyle(
                        color: Colors.red,  // Red text
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  Divider(thickness: 1.5),
                  SizedBox(height: 16),
                  
                  Text(
                    'Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: _transactions.map((transaction) {
                      final isDriverGave = transaction['type'] == 'gave';
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(transaction['description'] ?? 'No Description'),
                            Row(
                              children: [
                                Text(
                                  '₹${transaction['amount']}',
                                  style: TextStyle(
                                    color: isDriverGave ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
