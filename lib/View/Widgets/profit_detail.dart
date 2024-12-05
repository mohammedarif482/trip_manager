import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/main.dart';

class ProfitDetail extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String tripId;

  const ProfitDetail({Key? key, required this.tripData, required this.tripId})
      : super(key: key);

  @override
  State<ProfitDetail> createState() => _ProfitDetailState();
}

class _ProfitDetailState extends State<ProfitDetail> {
  final TextEditingController expenseController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAmountRow(
                      'Freight Amount', widget.tripData['amount'], true),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),
                  _buildActionLink('Expenses', () => _showAddChargesDialog()),
                  _buildExpenses(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildExpenses() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        // No document found or doesn't exist
        return _buildAmountRow('Expenses', '₹0', false);
      }

      // Document exists
      var tripData = snapshot.data!.data() as Map<String, dynamic>;
      List expenses =
          tripData.containsKey('expenses') ? tripData['expenses'] : [];

      // Sort the expenses by date
      expenses.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateA.compareTo(dateB); // Sort by date (ascending)
      });

      // Calculate freight amount
      String cleanedString =
          tripData['amount'].replaceAll(RegExp(r'[^0-9]'), '');
      double amount = double.parse(cleanedString);
      double totalExpense = expenses.fold(
          0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));

      // Calculate commission and Bhata
      double commission = amount * 0.04;
      double bhata = amount * 0.20;

      // Calculate profit
      double profit = amount - (totalExpense + commission + bhata);

      if (expenses.isEmpty) {
        return Column(
          children: [
            _buildAmountRow('Expenses', '₹0', false),
            const Divider(height: 32),
            _buildAmountRow('Total Expense', '- ₹$totalExpense', false),
            _buildAmountRow('Commission', '- ₹$commission', false),
            _buildAmountRow('Bhata', '- ₹$bhata', false),
            const Divider(height: 32),
            _buildAmountRow('Profit', '₹$profit', false),
          ],
        );
      }

      return Column(
        children: [
          ...expenses.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> expense = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildAmountRow(
                          expense['expense'],
                          '₹${expense['amount']}',
                          false,
                        ),
                      ),
                      AuthCheck.isDriver != true
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteExpense(
                                    context, expense, widget.tripId, index);
                              },
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${expense['date']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (expense['paidByDriver'] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Paid By Driver',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 32),
          _buildAmountRow('Total Expense', '- ₹$totalExpense', false),
          _buildAmountRow('Commission', '- ₹$commission', false),
          _buildAmountRow('Bhata', '- ₹$bhata', false),
          const Divider(height: 32),
          _buildAmountRow('Profit', '₹$profit', false),
        ],
      );
    },
  );
}



  Widget _buildActionLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.add, color: AppColors.primaryColor, size: 20),
        ],
      ),
    );
  }


  bool isDriver = false;

  // Add a method to check if the current user is a driver
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

void _showAddChargesDialog() async {
  DateTime selectedDate = DateTime.now();
  bool isPaidByDriver = false; // Local for now
  String selectedPaymentMethod = "Cash"; // Default payment method

  // Check the user role and set the initial state of 'Paid by Driver' switch
  await _checkUserRole(); // Ensure user role is checked before showing the dialog
  isPaidByDriver = isDriver; // Set switch state based on user role

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Charges'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: expenseController,
                  decoration: const InputDecoration(
                    labelText: 'Expense',
                  ),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:'),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "${selectedDate.toLocal()}".split(' ')[0],
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  items: const [
                    DropdownMenuItem(value: "Cash", child: Text("Cash")),
                    DropdownMenuItem(value: "UPI", child: Text("UPI")),
                    DropdownMenuItem(value: "Online", child: Text("Online")),
                    DropdownMenuItem(
                        value: "Bank Transfer", child: Text("Bank Transfer")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paid by Driver:'),
                    Switch(
                      value: isPaidByDriver,
                      onChanged: (bool value) {
                        setState(() {
                          isPaidByDriver = value;
                        });
                      },
                      activeColor: AppColors.primaryColor,
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
                  _addChargeToFirestore(
                    selectedDate, 
                    isPaidByDriver, 
                    selectedPaymentMethod
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}


  void _addChargeToFirestore(
      DateTime selectedDate, bool isPaidByDriver, String paymentMethod) async {
    String expense = expenseController.text.trim();
    String amount = amountController.text.trim();
    String tripId = widget.tripId;

    if (expense.isNotEmpty && amount.isNotEmpty) {
      try {
        DocumentReference tripDocRef =
            FirebaseFirestore.instance.collection('trips').doc(tripId);

        // Format the selectedDate to "YYYY-MM-DD"
        String formattedDate =
            "${selectedDate.year.toString().padLeft(4, '0')}-${(selectedDate.month).toString().padLeft(2, '0')}-${(selectedDate.day).toString().padLeft(2, '0')}";

        // Get the trip document
        DocumentSnapshot docSnapshot = await tripDocRef.get();

        if (docSnapshot.exists) {
          // Add charge to trips collection
          await tripDocRef.update({
            'expenses': FieldValue.arrayUnion([
              {
                'expense': expense,
                'amount': double.parse(amount),
                'date': formattedDate, // Store formatted date as string
                'paidByDriver': isPaidByDriver,
                'paymentMethod': paymentMethod,
              }
            ])
          });

          // If paid by driver, add to drivertransactions collection
          if (isPaidByDriver) {
            String driverName =
                widget.tripData['driverName'] ?? "Unknown Driver";

            await FirebaseFirestore.instance
                .collection('drivertransactions')
                .add({
              'date': formattedDate, // Use formatted date
              'amount': amount, // String format
              'description': expense, // Expense description
              'driverName': driverName,
              'fromtrip': 'true',
              'type': 'gave',
              'paymentMethod': paymentMethod, // Payment method
            });
          }
        } else {
          // If the trip document doesn't exist, create it
          await tripDocRef.set({
            'expenses': [
              {
                'expense': expense,
                'amount': double.parse(amount),
                'date': formattedDate, // Store formatted date as string
                'paidByDriver': isPaidByDriver,
                'paymentMethod': paymentMethod,
              }
            ]
          });
        }

        // Clear the fields
        expenseController.clear();
        amountController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Charge added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding charge: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
    }
  }

  Widget _buildAmountRow(String label, String amount, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(),
          ),
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
}

void _deleteExpense(BuildContext context, Map<String, dynamic> expense,
    String tripId, int expenseIndex) async {
  try {
    DocumentReference tripDocRef =
        FirebaseFirestore.instance.collection('trips').doc(tripId);

    // Use the expense date from the 'expense' map, which is in the correct format
    String formattedDate = expense['date'];

    // Update the `trips` collection to remove the specific expense
    await tripDocRef.update({
      'expenses': FieldValue.arrayRemove([expense]),
    });

    // If the expense is paid by the driver, remove the corresponding entry in `drivertransactions`
    if (expense['paidByDriver'] == true) {
      // Ensure the expense amount is a string (if it's a number, convert it to string)
      String expenseAmountString = expense['amount'].toString();

      // Query for matching driver transaction by amount (as string), date, and description
      QuerySnapshot driverTransactionsSnapshot = await FirebaseFirestore
          .instance
          .collection('drivertransactions')
          .where('date',
              isEqualTo: formattedDate) // Use formatted date for matching
          .where('amount', isEqualTo: expenseAmountString) // Match as string
          .where('description',
              isEqualTo:
                  expense['expense']) // Ensure matching expense description
          .where('fromtrip',
              isEqualTo: 'true') // Ensure it's related to the trip
          .get();

      // Check if we have any matching documents
      if (driverTransactionsSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in driverTransactionsSnapshot.docs) {
          await doc.reference.delete(); // Delete the matching transaction
        }

        // Notify the user that the transaction was deleted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Driver transaction deleted successfully!')),
        );
      } else {
        // If no matching transaction is found, notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No matching driver transaction found!')),
        );
      }
    }

    // Notify the user that the expense was deleted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expense #$expenseIndex deleted successfully!')),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error deleting expense: $e')),
    );
  }
}
