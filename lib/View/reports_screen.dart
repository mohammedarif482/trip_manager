import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
                  ReportTitleCard(
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
                  ReportTitleCard(
                      title: "Party Revenue", icon: Icons.report, onTap: () {}),
                  ReportTitleCard(
                      title: "Party Balance", icon: Icons.report, onTap: () {}),
                  ReportTitleCard(
                      title: "Supplier Balance",
                      icon: Icons.report,
                      onTap: () {}),
                  ReportTitleCard(
                      title: "Transaction Report",
                      icon: Icons.report,
                      onTap: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportTitleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ReportTitleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

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
  _TruckRevenueReportScreenState createState() =>
      _TruckRevenueReportScreenState();
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

  int safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    }
    return 0;
  }

  Future<List<TruckReport>> fetchTruckReports() async {
    List<TruckReport> truckReports = [];

    try {
      QuerySnapshot vehicleSnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();

      for (var vehicleDoc in vehicleSnapshot.docs) {
        String truckNo = vehicleDoc['registration'] ?? '';
        int totalRevenue = 0;
        int totalExpenses = 0;

        QuerySnapshot tripSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where('vehicleNumber', isEqualTo: truckNo)
            .get();

        for (var tripDoc in tripSnapshot.docs) {
          Map<String, dynamic> tripData =
              tripDoc.data() as Map<String, dynamic>;

          totalRevenue += safeParseInt(tripData['amount']);

          if (tripData.containsKey('expenses') && tripData['expenses'] is List) {
            List expenses = tripData['expenses'];
            for (var expense in expenses) {
              if (expense is Map) {
                totalExpenses += safeParseInt(expense['amount']);
              }
            }
          }
        }

        int profit = totalRevenue - totalExpenses;
        truckReports.add(TruckReport(
          truckNo: truckNo,
          revenue: totalRevenue,
          expenses: totalExpenses,
          profit: profit,
        ));
      }
    } catch (e) {
      print('Error fetching truck reports: $e');
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

          int totalRevenue =
              snapshot.data!.fold(0, (sum, item) => sum + item.revenue);
          int totalExpenses =
              snapshot.data!.fold(0, (sum, item) => sum + item.expenses);
          int totalProfit =
              snapshot.data!.fold(0, (sum, item) => sum + item.profit);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryCard(
                        title: 'Total Revenue',
                        value: formatCurrency(totalRevenue)),
                    SummaryCard(
                        title: 'Total Expenses',
                        value: formatCurrency(totalExpenses)),
                    SummaryCard(
                        title: 'Total Profit',
                        value: formatCurrency(totalProfit)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
  horizontalMargin: 10,
  columnSpacing: 12, // Reduce spacing between columns
  headingRowColor: MaterialStateProperty.all(Colors.red),
  columns: [
    DataColumn(
      label: Text('Truck No',
          style: TextStyle(color: Colors.white)),
    ),
    DataColumn(
      label: Text('Revenue',
          style: TextStyle(color: Colors.white)),
    ),
    DataColumn(
      label: Text('Expenses',
          style: TextStyle(color: Colors.white)),
    ),
    DataColumn(
      label: Padding(
        padding: const EdgeInsets.only(right: 10.0), // Shift Profit label left
        child: Text('Profit',
            style: TextStyle(color: Colors.white)),
      ),
    ),
  ],
  rows: snapshot.data!.asMap().entries.map((entry) {
    int index = entry.key;
    TruckReport report = entry.value;

    return DataRow(
      color: MaterialStateProperty.all(
          index.isEven ? Colors.grey[100] : Colors.grey[300]),
      cells: [
        DataCell(Text(
          report.truckNo,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
        )),
        DataCell(Text("₹${formatCurrency(report.revenue)}")),
        DataCell(Text("₹${formatCurrency(report.expenses)}")),
        DataCell(
          Padding(
            padding: const EdgeInsets.only(right: 10.0), // Shift Profit cell content left
            child: Text("₹${formatCurrency(report.profit)}"),
          ),
        ),
      ],
    );
  }).toList(),
)
,
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 14)),
            Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
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

  TruckReport({
    required this.truckNo,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });
}
