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
final TextEditingController expenseController = TextEditingController();
final TextEditingController amountController = TextEditingController();

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
                  _buildAmountRow(
                      'Freight Amount', widget.tripData['amount'], true),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),

                  const SizedBox(height: 8),

                  const Divider(height: 32),
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

  // Widget _buildExpenses() {
  //   return StreamBuilder<DocumentSnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection('trips')
  //         .doc(widget.tripId)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularProgressIndicator();
  //       }

  //       if (!snapshot.hasData || !snapshot.data!.exists) {
  //         // No document found or doesn't exist
  //         return _buildAmountRow('Expenses', '₹0', false);
  //       }

  //       // Document exists
  //       var tripData = snapshot.data!.data() as Map<String, dynamic>;
  //       List expenses =
  //           tripData.containsKey('expenses') ? tripData['expenses'] : [];
  //       // Calculate total expenses

  //       String cleanedString =
  //           tripData['amount'].replaceAll(RegExp(r'[^0-9]'), '');
  //       double amount = double.parse(cleanedString);
  //       double totalExpense = expenses.fold(
  //           0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));

  //       // Calculate pending balance
  //       double pendingBalance = amount - totalExpense;

  //       if (expenses.isEmpty) {
  //         return _buildAmountRow('Expenses', '₹0', false);
  //       }

  //       return Column(
  //         children: [
  //           ...expenses.map((expense) {
  //             return _buildAmountRow(
  //               expense['expense'],
  //               '₹${expense['amount']}',
  //               false,
  //             );
  //           }).toList(),
  //           _buildAmountRow('Total Expense', '₹$totalExpense', false),
  //           const Divider(height: 32),
  //           _buildAmountRow('Pending Balance', '₹$pendingBalance', false),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _buildActionLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.add, color: AppColors.primaryColor, size: 20),
        ],
      ),
    );
  }

  void _showAddChargesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addChargeToFirestore();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addChargeToFirestore() async {
    String expense = expenseController.text.trim();
    String amount = amountController.text.trim();
    String tripId = widget.tripId;

    if (expense.isNotEmpty && amount.isNotEmpty) {
      try {
        DocumentReference tripDocRef =
            FirebaseFirestore.instance.collection('trips').doc(tripId);
        DocumentSnapshot docSnapshot = await tripDocRef.get();

        if (docSnapshot.exists) {
          await tripDocRef.update({
            'expenses': FieldValue.arrayUnion([
              {
                'expense': expense,
                'amount': double.parse(amount),
              }
            ])
          });
        } else {
          await tripDocRef.set({
            'charges': [
              {
                'expense': expense,
                'amount': double.parse(amount),
              }
            ],
          });
        }

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
    }
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
          style: TextStyle(
              // fontWeight: FontWeight.bold,
              ),
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
