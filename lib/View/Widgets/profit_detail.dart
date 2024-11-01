import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';

class ProfitDetail extends StatefulWidget {
  final Map<String, dynamic> tripData;
  final String tripId;

  const ProfitDetail({Key? key, required this.tripData, required this.tripId})
      : super(key: key);

  @override
  State<ProfitDetail> createState() => _ProfitDetailState();
}

int activeStep = 1;
final TextEditingController expenseController = TextEditingController();
final TextEditingController amountController = TextEditingController();

class _ProfitDetailState extends State<ProfitDetail> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 245, 245),
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
        // Calculate total expenses

        String cleanedString =
            tripData['amount'].replaceAll(RegExp(r'[^0-9]'), '');
        double amount = double.parse(cleanedString);
        double totalExpense = expenses.fold(
            0.0, (sum, expense) => sum + (expense['amount'] ?? 0.0));

        // Calculate pending balance
        double pendingBalance = amount - totalExpense;

        if (expenses.isEmpty) {
          return Column(
            children: [
              _buildAmountRow('Expenses', '₹0', false),
              const Divider(height: 32),
              // _buildAmountRow('Pending Balance', '₹$pendingBalance', false),
              _buildAmountRow('Total Expense', '- ₹$totalExpense', false),
              _buildAmountRow('Commision', '- ₹${amount * 0.04}', false),
              const Divider(height: 32),
              _buildAmountRow('Profit',
                  '${amount - (totalExpense + amount * 0.04)}', false),
            ],
          );
        }

        return Column(
          children: [
            ...expenses.map((expense) {
              return _buildAmountRow(
                expense['expense'],
                '₹${expense['amount']}',
                false,
              );
            }).toList(),

            const Divider(height: 32),
            // _buildAmountRow('Pending Balance', '₹$pendingBalance', false),
            _buildAmountRow('Total Expense', '- ₹$totalExpense', false),
            _buildAmountRow('Commision', '- ₹${amount * 0.04}', false),
            const Divider(height: 32),
            _buildAmountRow(
                'Profit', '${amount - (totalExpense + amount * 0.04)}', false),
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
