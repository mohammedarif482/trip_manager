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

    for (var transaction in fetchedTransactions) {
      String monthKey = transaction['month'];

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

  // Define the number of transactions per page
  const int transactionsPerPage = 20;

  // Split transactions into pages
  final pages = List.generate(
    (transactions.length / transactionsPerPage).ceil(),
    (index) => transactions.skip(index * transactionsPerPage).take(transactionsPerPage).toList(),
  );

  // Add each page to the PDF
  for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Driver Info Section (Top-left aligned)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Driver: ${widget.driverName}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Current Balance: Rs ${balance.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, color: PdfColor.fromInt(0xFF4CAF50))),
                ],
              ),
              pw.SizedBox(height: 20),

              // Transaction Table
              pw.Table(
                border: pw.TableBorder.all(width: 0.8, color: PdfColor.fromInt(0xFFBDBDBD)),
                children: [
                  // Header Row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Reason', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Driver Gave (-)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Driver Got (+)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...pages[pageIndex].map((transaction) {
                    bool isMonthlyBalance = transaction['isMonthlyBalance'] ?? false;
                    return pw.TableRow(
                      decoration: isMonthlyBalance
                          ? pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF9C4)) // Light yellow for monthly balance rows
                          : null,
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(transaction['date'] ?? '', style: pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(transaction['description'] ?? '', style: pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(transaction['gave']?.toString() ?? '', style: pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(transaction['got']?.toString() ?? '', style: pw.TextStyle(fontSize: 10)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(transaction['balance']?.toString() ?? '', style: pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              // Footer for page number
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Page ${pageIndex + 1} of ${pages.length}', style: pw.TextStyle(fontSize: 12)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Save and print the PDF
  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
    name: 'Driver_statement.pdf', // File name
  );
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Transactions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Driver Info and Current Balance Cards
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue, size: 40.0),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driverName,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Current Balance: Rs ${balance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable Data Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 8.0, // Reduced spacing between columns
                    dataRowHeight: 40.0, // Adjusted for compactness
                    headingRowHeight: 50.0, // Reduced header height
                    border: TableBorder.all(color: Colors.grey.shade400),
                    headingRowColor: MaterialStateProperty.all(const Color.fromARGB(255, 58, 161, 89)),
                    headingTextStyle: TextStyle(
                      fontSize: screenWidth < 400 ? 10.0 : 12.0, // Smaller header font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    dataTextStyle: TextStyle(
                      fontSize: screenWidth < 400 ? 9.0 : 11.0, // Reduced font size for rows
                    ),
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Gave (-)')),
                      DataColumn(label: Text('Got (+)')),
                      DataColumn(label: Text('Balance')),
                    ],
                    rows: transactions.map((transaction) {
                      bool isMonthlyBalance = transaction['isMonthlyBalance'] ?? false;
                      return DataRow(
                        color: isMonthlyBalance
                            ? MaterialStateProperty.all(Colors.yellow.shade100)
                            : null,
                        cells: [
                          DataCell(Text(transaction['date'] ?? '')),
                          DataCell(Text(transaction['description'] ?? '')),
                          DataCell(Text(transaction['gave']?.toString() ?? '')),
                          DataCell(Text(transaction['got']?.toString() ?? '')),
                          DataCell(Text(transaction['balance']?.toString() ?? '')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Download PDF Button
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ElevatedButton(
                onPressed: _downloadPDF,
                child: Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
