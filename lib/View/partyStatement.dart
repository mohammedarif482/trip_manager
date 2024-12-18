import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PartyStatement extends StatefulWidget {
  final String partyName;

  PartyStatement({required this.partyName});

  @override
  _PartyStatementState createState() => _PartyStatementState();
}

class _PartyStatementState extends State<PartyStatement> {
  List<Map<String, dynamic>> transactions = [];
  int initialAmount = 0; // Starting balance from partyreport
  int totalAmount = 0; // Total amount (sum of direct amounts)
  int balanceAmount = 0; // Balance calculated for the top display
  bool isLoading = true; // To control the loading state

  @override
  void initState() {
    super.initState();
    _fetchPartyStatement();
  }

  Future<void> _fetchPartyStatement() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      int advancesAndPaymentsTotal = 0;

      // Fetch initial amount from partyreport collection
      final partyReportSnapshot = await FirebaseFirestore.instance
          .collection('partyreport')
          .where('partyName', isEqualTo: widget.partyName)
          .get();

      if (partyReportSnapshot.docs.isNotEmpty) {
        final partyReportData = partyReportSnapshot.docs.first.data();
        final partyAmountStr = partyReportData['amount'] ?? "0";
        initialAmount = int.tryParse(partyAmountStr) ?? 0;
      }

      // Fetch transactions from the trips collection
      final snapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('partyName', isEqualTo: widget.partyName)
          .get();

      List<Map<String, dynamic>> allTransactions = [];
      bool hasTransactions = false; // Flag to track if there are transactions

      for (var trip in snapshot.docs) {
        final data = trip.data();

        // Direct amount from the trip
        final tripAmountStr = data['amount'] ?? "0";
        final tripAmount = int.tryParse(tripAmountStr) ?? 0;
        totalAmount += tripAmount;

        // Process advances
        final advances = data.containsKey('advances') ? data['advances'] : [];
        for (var advance in advances) {
          final amountStr = advance['amount'] ?? "0";
          final amount = int.tryParse(amountStr) ?? 0;
          advancesAndPaymentsTotal += amount;
          hasTransactions = true;

          allTransactions.add({
            'date': advance['date'] ?? "Unknown",
            'amount': amount,
            'description': "Advance: ${advance['paymentMethod'] ?? 'Cash'}",
          });
        }

        // Process payments
        final payments = data.containsKey('payments') ? data['payments'] : [];
        for (var payment in payments) {
          final amountStr = payment['amount'] ?? "0";
          final amount = int.tryParse(amountStr) ?? 0;
          advancesAndPaymentsTotal += amount;
          hasTransactions = true;

          allTransactions.add({
            'date': payment['date'] ?? "Unknown",
            'amount': amount,
            'description': "Payment: ${payment['paymentMethod'] ?? 'Cash'}",
          });
        }
      }

      // Calculate balance amount for the top display
      balanceAmount = initialAmount - advancesAndPaymentsTotal;

      setState(() {
        transactions = allTransactions;
        isLoading = false; // Stop loading
        // If no transactions found, handle empty state
        if (!hasTransactions) {
          transactions = [];
        }
      });
    } catch (e) {
      print('Error fetching party statement: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Generate table rows with calculated balances
  List<List<String>> _generateTableRows() {
    List<List<String>> rows = [];
    int runningBalance = totalAmount;

    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final amount = (transaction['amount'] ?? 0) as int;

      // Calculate balance for the current row
      runningBalance -= amount;

      rows.add([
        transaction['date'] ?? "Unknown",
        transaction['description'] ?? "N/A",
        amount.toString(),
        runningBalance.toString(),
      ]);
    }

    return rows;
  }

  // Create PDF document
  Future<void> _createPdf() async {
    final pdf = pw.Document();

    // Get the current date in the format: yyyy-MM-dd
    final String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Set the PDF file name with the party name and generated date
    final String fileName = '${widget.partyName}_Statement_$currentDate.pdf';

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Party Name: ${widget.partyName}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Total Amount: ${totalAmount}', style: pw.TextStyle(fontSize: 16)),
            pw.Text('Balance Amount: ${balanceAmount}', style: pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            // Only generate the table if there are transactions
            if (transactions.isNotEmpty)
              pw.Table.fromTextArray(
                context: context,
                headers: ['Date', 'Description', 'Amount', 'Balance'],
                data: _generateTableRows(),
              ),
            // If there are no transactions, display a message instead
            if (transactions.isEmpty)
              pw.Text("No transactions available.", style: pw.TextStyle(fontSize: 16)),
          ],
        );
      },
    ));

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Party Statement for ${widget.partyName}"),
        backgroundColor: const Color.fromARGB(255, 180, 166, 166),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.red[700]))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount section
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "$totalAmount",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Balance Amount section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Balance Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "$balanceAmount",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Table layout (even if empty, we display the structure)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(color: Colors.black, width: 1),
                        columnWidths: {
                          0: FlexColumnWidth(1), // Date column
                          1: FlexColumnWidth(2), // Description column
                          2: FlexColumnWidth(1), // Amount column
                          3: FlexColumnWidth(1), // Balance column
                        },
                        children: [
                          // Header row with red background and white text
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 244, 54, 101), // Red background
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Description',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Amount',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Balance',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Data rows with balance calculations (or empty if no transactions)
                          ..._generateTableRows().map((row) {
                            return TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(row[0]),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(row[1]),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(row[2]),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(row[3]),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Button to generate PDF
                  Center(
                    child: ElevatedButton(
                      onPressed: _createPdf,
                      child: Text('Generate PDF '),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
