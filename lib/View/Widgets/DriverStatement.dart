import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    for (var doc in snapshot.docs) {
      var data = doc.data();

      // Get the type and amount as string
      String type = data['type'] ?? '';
      String amountStr = data['amount'] ?? '0';

      // Parse the amount string into a double
      double amount = double.tryParse(amountStr) ?? 0.0;

      if (type == 'gave') {
        fetchedTransactions.add({
          'date': data['date'],
          'description': data['description'],
          'gave': amount,
          'got': 0.0,
        });
        currentBalance -= amount;
      } else if (type == 'got') {
        fetchedTransactions.add({
          'date': data['date'],
          'description': data['description'],
          'gave': 0.0,
          'got': amount,
        });
        currentBalance += amount;
      }

      // Add the balance for the current row
      fetchedTransactions.last['balance'] = currentBalance;
    }

    setState(() {
      transactions = fetchedTransactions;
      balance = currentBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Driver Transactions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Card for displaying driver's name and icon
            Card(
              elevation: 5, // Slight shadow for card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.person, // Icon for the driver (person icon)
                      color: Colors.blue,
                      size: 40.0,
                    ),
                    SizedBox(width: 12.0),
                    Text(
                      widget.driverName, // Display the driver's name
                      style: TextStyle(
                        fontSize: 14.0, // Slightly larger font for name
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Table with dynamic width adjustments based on screen size
            LayoutBuilder(
              builder: (context, constraints) {
                double availableWidth = constraints.maxWidth;

                // Adjust column width more accurately
                double columnWidth = availableWidth * 0.12; // Slightly smaller width
                double largerColumnWidth = availableWidth * 0.18; // Adjust for "Driver Gave" and "Driver Got"

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Allow horizontal scrolling if needed
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white, // Set background to white for the table
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 0.0, // Remove spacing between columns
                        decoration: BoxDecoration(
                          color: Colors.green, // Green background for the entire header row
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        columns: [
                          DataColumn(
                            label: Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                              alignment: Alignment.centerLeft, // Align text to the left
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0, // Adjusted font size for header
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                              alignment: Alignment.centerLeft, // Align text to the left
                              child: Text(
                                'Reason',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0, // Adjusted font size for header
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: largerColumnWidth,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                              alignment: Alignment.centerLeft, // Align text to the left
                              child: Text(
                                'Driver Gave (-)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0, // Adjusted font size for header
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: largerColumnWidth,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                              alignment: Alignment.centerLeft, // Align text to the left
                              child: Text(
                                'Driver Got (+)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0, // Adjusted font size for header
                                ),
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              width: columnWidth,
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                              alignment: Alignment.centerLeft, // Align text to the left
                              child: Text(
                                'Balance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0, // Adjusted font size for header
                                ),
                              ),
                            ),
                          ),
                        ],
                        rows: List.generate(transactions.length, (index) {
                          var transaction = transactions[index];

                          // Alternating row colors between white and light grey
                          Color rowColor = index % 2 == 0 ? Colors.white : Colors.grey[200]!;

                          return DataRow(
                            color: MaterialStateProperty.all(rowColor),
                            cells: [
                              DataCell(Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['date'] ?? '',
                                  style: TextStyle(fontSize: 9.0),
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                                ),
                              )),
                              DataCell(Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['description'] ?? '',
                                  style: TextStyle(fontSize: 9.0),
                                  overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                                ),
                              )),
                              DataCell(Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['gave'].toString(),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 9.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                              DataCell(Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['got'].toString(),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 9.0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                              DataCell(Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  transaction['balance'].toStringAsFixed(2),
                                  style: TextStyle(fontSize: 9.0),
                                ),
                              )),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              'Current Balance: \$${balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
