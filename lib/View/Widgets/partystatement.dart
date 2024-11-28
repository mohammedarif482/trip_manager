import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PartyStatement extends StatefulWidget {
  final String tripId; // The tripId or partyId to query the correct trip document

  PartyStatement({Key? key, required this.tripId}) : super(key: key);

  @override
  _PartyStatementState createState() => _PartyStatementState();
}

class _PartyStatementState extends State<PartyStatement> {
  double freightAmount = 0.0;
  String partyName = "";
  String fromLocation = "";
  String toLocation = "";
  String date = "";

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      // Fetch the trip document from the Firestore 'trips' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('trips')  // Specify your collection name
          .doc(widget.tripId)    // Use the tripId (or partyId) to query the document
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        // Convert freightAmount (stored as string) to double
        freightAmount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
        partyName = data['partyName'] ?? 'Unknown Party';
        fromLocation = data['fromLocation'] ?? 'Unknown Location';
        toLocation = data['toLocation'] ?? 'Unknown Location';
        date = data['date'] ?? 'Unknown Date';

        return {
          'advances': data['advances'] ?? [],
          'payments': data['payments'] ?? [],
        };
      } else {
        throw Exception("Trip document does not exist.");
      }
    } catch (e) {
      throw Exception("Error fetching trip data: $e");
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    
    // Fetch data before generating PDF
    final data = await _fetchData();
    final advancesData = data['advances'] ?? [];
    final paymentsData = data['payments'] ?? [];

    double balance = freightAmount; // Start with the freight amount as the initial balance
    final allTransactions = [
      ...advancesData.map((data) {
        double amount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
        balance -= amount; // Subtract amount from balance
        return {
          'date': data['date'],
          'description': 'Trip Advance',
          'paymentMethod': data['paymentMethod'],
          'amount': amount,
          'balance': balance,
        };
      }),
      ...paymentsData.map((data) {
        double amount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
        balance -= amount; // Subtract amount from balance
        return {
          'date': data['date'],
          'description': 'Trip Payment',
          'paymentMethod': data['paymentMethod'],
          'amount': amount,
          'balance': balance,
        };
      }),
    ];

    // Add content to the PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Party Name: $partyName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Freight Amount: $freightAmount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('From Location: $fromLocation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('To Location: $toLocation', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: $date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Statement of Payments and Advances', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            // Creating the table for advances and payments
            pw.Table.fromTextArray(
              headers: ['Date', 'Description', 'Payment Method', 'Amount', 'Balance'],
              data: allTransactions.map((transaction) {
                return [
                  transaction['date'] ?? '',
                  transaction['description'] ?? '',
                  transaction['paymentMethod'] ?? '',
                  '${transaction['amount']}', // Removed the rupee symbol
                  '${transaction['balance']}', // Removed the rupee symbol
                ];
              }).toList(),
            ),
          ],
        );
      },
    ));

    // Save the document
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Statement'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Get the advances and payments data
          final advancesData = snapshot.data?['advances'] ?? [];
          final paymentsData = snapshot.data?['payments'] ?? [];

          // Combine advances and payments into one list and process the amounts and balances
          double balance = freightAmount; // Start with the freight amount as the initial balance
          final List<Map<String, dynamic>> allTransactions = [
            ...advancesData.map((data) {
              double amount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
              balance -= amount; // Subtract amount from balance
              return {
                'date': data['date'],
                'description': 'Trip Advance',
                'paymentMethod': data['paymentMethod'],
                'amount': amount,
                'balance': balance,
              };
            }),
            ...paymentsData.map((data) {
              double amount = double.tryParse(data['amount'] ?? '0') ?? 0.0;
              balance -= amount; // Subtract amount from balance
              return {
                'date': data['date'],
                'description': 'Trip Payment',
                'paymentMethod': data['paymentMethod'],
                'amount': amount,
                'balance': balance,
              };
            }),
          ];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Party Name: $partyName',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Freight Amount: $freightAmount',  // Removed rupee symbol
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'From Location: $fromLocation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'To Location: $toLocation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: $date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Statement of Payments and Advances',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                // Table displaying the payment and advance details
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.green),
                      headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text(' ')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Balance')),
                      ],
                      columnSpacing: 10, // Decrease column spacing
                      rows: allTransactions
                          .map((transaction) => DataRow(cells: [
                                DataCell(Text(transaction['date'] ?? '')),
                                DataCell(Text(transaction['description'] ?? '')),
                                DataCell(Text(transaction['paymentMethod'] ?? '')),
                                DataCell(Text('${transaction['amount']}')), // Removed rupee symbol
                                DataCell(Text('${transaction['balance']}')), // Removed rupee symbol
                              ]))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Button to download the PDF at the bottom
                Center(
                  child: ElevatedButton(
                    onPressed: _generatePDF,
                    child: const Text('Download PDF'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
