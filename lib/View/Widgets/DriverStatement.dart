import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class DriverStatementPage extends StatefulWidget {
  final String driverName;

  DriverStatementPage({required this.driverName});

  @override
  _DriverStatementPageState createState() => _DriverStatementPageState();
}

class _DriverStatementPageState extends State<DriverStatementPage> {
  late List<Map<String, dynamic>> transactions = [];
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: widget.driverName)
        .get();

    List<Map<String, dynamic>> fetchedTransactions = [];
    double currentBalance = 0.0;
    String? lastMonth = null;

    // Extract data and sort by date
    for (var doc in snapshot.docs) {
      var data = doc.data();

      String type = data['type'] ?? '';
      String amountStr = data['amount'] ?? '0';
      double amount = double.tryParse(amountStr) ?? 0.0;

      String dateStr = data['date'] ?? '';
      DateTime? date = DateTime.tryParse(dateStr);
      if (date == null) continue;

      String monthKey = DateFormat('yyyy-MM').format(date);

      fetchedTransactions.add({
        'date': DateFormat('yyyy-MM-dd').format(date),
        'description': data['description'],
        'gave': type == 'gave' ? amount : 0.0,
        'got': type == 'got' ? amount : 0.0,
        'month': monthKey,
        'dateTime': date,
      });
    }

    // Sort by month and then by date
    fetchedTransactions.sort((a, b) {
      int monthComparison = a['month'].compareTo(b['month']);
      if (monthComparison != 0) return monthComparison;
      return a['dateTime'].compareTo(b['dateTime']);
    });

    List<Map<String, dynamic>> finalTransactions = [];
    double monthlyBalance = 0.0;

    // Process transactions row by row
    for (var transaction in fetchedTransactions) {
      String monthKey = transaction['month'];

      // Check if a new month has started
      if (lastMonth != null && lastMonth != monthKey) {
        // Add a monthly balance row for the previous month
        finalTransactions.add({
          'date': '',
          'description': 'Monthly Balance ($lastMonth)',
          'gave': null,
          'got': null,
          'balance': monthlyBalance,
          'isMonthlyBalance': true,
        });
      }

      // Update balance based on "gave" and "got"
      double gave = transaction['gave'] ?? 0.0;
      double got = transaction['got'] ?? 0.0;

      currentBalance = currentBalance - gave + got;
      monthlyBalance = currentBalance;

      // Add the transaction to the final list
      finalTransactions.add({
        'date': transaction['date'],
        'description': transaction['description'],
        'gave': gave,
        'got': got,
        'balance': currentBalance,
        'isMonthlyBalance': false,
      });

      lastMonth = monthKey;
    }

    // Add the final monthly balance row for the last month
    if (lastMonth != null) {
      finalTransactions.add({
        'date': '',
        'description': 'Monthly Balance ($lastMonth)',
        'gave': null,
        'got': null,
        'balance': monthlyBalance,
        'isMonthlyBalance': true,
      });
    }

    setState(() {
      transactions = finalTransactions;
      balance = currentBalance; // Final cumulative balance
    });
  }


  Future<void> _downloadPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Driver Transactions: ${widget.driverName}', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Current Balance: ₹${balance.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(children: [
                    pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Driver Gave (-)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Driver Got (+)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]),
                  ...transactions.map((transaction) {
                    bool isMonthlyBalance = transaction['isMonthlyBalance'] ?? false;
                    return pw.TableRow(
                      decoration: isMonthlyBalance
                          ? pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF9C4)) // Light yellow color
                          : null,
                      children: [
                        pw.Text(transaction['date'] ?? ''),
                        pw.Text(transaction['description'] ?? ''),
                        pw.Text(transaction['gave']?.toString() ?? ''),
                        pw.Text(transaction['got']?.toString() ?? ''),
                        pw.Text(transaction['balance']?.toString() ?? ''),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Driver_statement.pdf', // File name set here
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double headerFontSize = screenWidth < 400 ? 9.0 : 10.0; // Further reduced header font size
    double rowFontSize = headerFontSize - 2.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Transactions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Current balance display just above the table
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      widget.driverName,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Current balance display
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Current Balance: ',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for text
                      ),
                    ),
                    Text(
                      'Rs ${balance.toStringAsFixed(2)}', // Using rupees symbol
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Green color for amount
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: DataTable(
                    columnSpacing: 12.0,
                    dataRowHeight: 60.0, // Adjusted row height for larger font
                    headingRowHeight: 70.0, // Adjusted header row height
                    headingRowColor: MaterialStateProperty.all(Colors.red), // Set header row color to red
                    headingTextStyle: TextStyle(
                      fontSize: 16.0, // Increased header font size
                      color: Colors.white, // White text for contrast
                      fontWeight: FontWeight.bold,
                    ),
                    dataTextStyle: TextStyle(
                      fontSize: 14.0, // Increased row font size
                      color: Colors.black, // Default row text color
                    ),
                    columns: [
                      DataColumn(label: Text('Date', style: TextStyle(fontSize: 16.0))), // Adjusted font size
                      DataColumn(label: Text('Description', style: TextStyle(fontSize: 16.0))),
                      DataColumn(label: Text('Gave (-)', style: TextStyle(fontSize: 16.0))),
                      DataColumn(label: Text('Got (+)', style: TextStyle(fontSize: 16.0))),
                      DataColumn(label: Text('Balance', style: TextStyle(fontSize: 16.0))),
                    ],
                    rows: transactions.map((transaction) {
                      bool isMonthlyBalance = transaction['isMonthlyBalance'] ?? false;
                      return DataRow(
                        color: isMonthlyBalance
                            ? MaterialStateProperty.all(Colors.yellow.shade100) // Light yellow for monthly balance
                            : null,
                        cells: [
                          DataCell(Text(transaction['date'] ?? '', style: TextStyle(fontSize: 14.0))),
                          DataCell(Text(transaction['description'] ?? '', style: TextStyle(fontSize: 14.0))),
                          DataCell(Text(transaction['gave']?.toString() ?? '', style: TextStyle(fontSize: 14.0))),
                          DataCell(Text(transaction['got']?.toString() ?? '', style: TextStyle(fontSize: 14.0))),
                          DataCell(Text(transaction['balance']?.toString() ?? '', style: TextStyle(fontSize: 14.0))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                onPressed: _downloadPDF,
                child: Text('Download PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

