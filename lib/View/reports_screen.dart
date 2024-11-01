import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Reports"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: [
                  ReportTilteCard(
                    title: "Truck Revenue",
                    icon: Icons.library_books_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TruckRevenueReportScreen(),
                        ),
                      );
                    },
                  ),
                  ReportTilteCard(title: "Party Revenue", icon: Icons.report, onTap: () {}),
                  ReportTilteCard(title: "Party Balance", icon: Icons.report, onTap: () {}),
                  ReportTilteCard(title: "Supplier Balance", icon: Icons.report, onTap: () {}),
                  ReportTilteCard(title: "Transaction Report", icon: Icons.report, onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportTilteCard extends StatelessWidget {
  const ReportTilteCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(icon, size: 30, color: AppColors.primaryColor),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryColor, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TruckRevenueReportScreen extends StatefulWidget {
  @override
  _TruckRevenueReportScreenState createState() => _TruckRevenueReportScreenState();
}

class _TruckRevenueReportScreenState extends State<TruckRevenueReportScreen> {
  late Future<List<TruckReport>> _truckReports;

  @override
  void initState() {
    super.initState();
    _truckReports = fetchTruckReports();
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(amount);
  }

  Future<List<TruckReport>> fetchTruckReports() async {
    List<TruckReport> truckReports = [];

    // Fetch all vehicles
    QuerySnapshot vehicleSnapshot = await FirebaseFirestore.instance.collection('vehicles').get();

    for (var vehicleDoc in vehicleSnapshot.docs) {
      String truckNo = vehicleDoc['registration'];
      int totalRevenue = 0;
      int totalExpenses = 0;

      // Fetch all trips for the current vehicle
      QuerySnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('vehicleNumber', isEqualTo: truckNo)
          .get();

      for (var tripDoc in tripSnapshot.docs) {
        // Parse trip amount safely
        int tripAmount = int.parse(tripDoc['amount'].toString().replaceAll(RegExp(r'[^\d]'), ''));
        totalRevenue += tripAmount;

        // Check if 'expenses' exists and is a List
        final Map<String, dynamic>? data = tripDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('expenses') && data['expenses'] is List) {
          List expenses = data['expenses'];

          // Sum the amounts in the 'expenses' array
          for (var expense in expenses) {
            if (expense is Map && expense.containsKey('amount')) {
              int expenseAmount = expense['amount'];
              totalExpenses += expenseAmount;
            }
          }
        }
      }

      int profit = totalRevenue - totalExpenses;
      truckReports.add(TruckReport(truckNo: truckNo, revenue: totalRevenue, expenses: totalExpenses, profit: profit));
    }

    return truckReports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Truck Revenue Report")),
      body: FutureBuilder<List<TruckReport>>(
        future: _truckReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data available"));
          }

          // Summarize total revenue, expenses, and profit
          int totalRevenue = snapshot.data!.fold(0, (sum, item) => sum + item.revenue);
          int totalExpenses = snapshot.data!.fold(0, (sum, item) => sum + item.expenses);
          int totalProfit = snapshot.data!.fold(0, (sum, item) => sum + item.profit);

          return Column(
            children: [
              // Summary Row
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryCard(title: 'Total Revenue', value: formatCurrency(totalRevenue)),
                    SummaryCard(title: 'Total Expenses', value: formatCurrency(totalExpenses)),
                    SummaryCard(title: 'Total Profit', value: formatCurrency(totalProfit)),
                  ],
                ),
              ),
              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.red), // Header background color
                    columns: [
                      DataColumn(
                        label: Text(
                          'Truck No',
                          style: TextStyle(color: Colors.white), // Header text color
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Revenue',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Expenses',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Profit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    rows: snapshot.data!.asMap().entries.map((entry) {
                      int index = entry.key;
                      TruckReport report = entry.value;

                      return DataRow(
                        color: MaterialStateProperty.all(index.isEven ? Colors.grey[100] : Colors.grey[300]), // Alternating row colors
                        cells: [
                          DataCell(Text(report.truckNo)),
                          DataCell(Text("₹${formatCurrency(report.revenue)}")),
                          DataCell(Text("₹${formatCurrency(report.expenses)}")),
                          DataCell(Text("₹${formatCurrency(report.profit)}")),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}





class SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class TruckReport {
  final String truckNo;
  final int revenue;
  final int expenses;
  final int profit;

  TruckReport({required this.truckNo, required this.revenue, required this.expenses, required this.profit});
}
