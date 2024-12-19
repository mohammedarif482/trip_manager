import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
                    title: "Party Revenue",
                    icon: Icons.account_balance_wallet_rounded, // Unique icon for Party Revenue
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PartyRevenueReportScreen(),
                        ),
                      );
                    },
                  ),


                  ReportTitleCard(
                    title: "Party Balance",
                    icon: Icons.payments,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PartyBalanceReportScreen(),
                        ),
                      );
                    },
                  ),

                  ReportTitleCard(
                    title: "Profit/Loss Report",
                    icon: Icons.analytics,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfitLossReportScreen(),
                        ),
                      );
                    },
                  ),
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





class ProfitLossReportScreen extends StatefulWidget {
  const ProfitLossReportScreen({super.key});

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  late Future<List<Map<String, dynamic>>> profitLossData;

  @override
  void initState() {
    super.initState();
    profitLossData = fetchProfitLossData();
  }

  Future<List<Map<String, dynamic>>> fetchProfitLossData() async {
    final List<Map<String, dynamic>> data = [];
    try {
      final partySnapshot = await FirebaseFirestore.instance.collection('partyreport').get();
      final partyNames = partySnapshot.docs.map((doc) => doc['partyName'] as String).toList();

      for (String partyName in partyNames) {
        final tripsSnapshot = await FirebaseFirestore.instance
            .collection('trips')
            .where('partyName', isEqualTo: partyName)
            .get();

        double totalRevenue = 0.0;
        double totalExpenses = 0.0;

        for (var tripDoc in tripsSnapshot.docs) {
          final tripData = tripDoc.data();

          double tripRevenue = double.tryParse(tripData['amount'] ?? '0') ?? 0.0;
          totalRevenue += tripRevenue;

          final List<dynamic> expenses = tripData['expenses'] ?? [];
          for (var expense in expenses) {
            double expenseAmount = double.tryParse(expense['amount']?.toString() ?? '0') ?? 0.0;
            totalExpenses += expenseAmount;
          }
        }

        double profit = totalRevenue - totalExpenses;

        data.add({
          'partyName': partyName,
          'revenue': totalRevenue,
          'expense': totalExpenses,
          'profit': profit,
        });
      }
    } catch (e) {
      print('Error fetching profit/loss data: $e');
    }

    return data;
  }

  // Function to generate the PDF
 
Future<void> _generatePdf(List<Map<String, dynamic>> data) async {
  final pdf = pw.Document();
  const int rowsPerPage = 20; // Set the number of rows per page to avoid overflow

  // Add a page for the report
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Profit/Loss Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey,  // Correct usage of PdfColors without 'pw'
              ),
            ),
            pw.SizedBox(height: 20),
            _buildTableHeader(),
            pw.Divider(),
            pw.ListView.builder(
              itemCount: (data.length / rowsPerPage).ceil(),
              itemBuilder: (context, pageIndex) {
                int startIndex = pageIndex * rowsPerPage;
                int endIndex = startIndex + rowsPerPage;

                List<Map<String, dynamic>> pageData = data.sublist(
                    startIndex, endIndex > data.length ? data.length : endIndex);

                return pw.Table.fromTextArray(
                  context: context,
                  data: [
                    // Headers for the page
                    ['Party Name', 'Revenue', 'Expense', 'Profit'],
                    // Data rows
                    ...pageData.map((row) => [
                      row['partyName'],
                      row['revenue'].toStringAsFixed(2),
                      row['expense'].toStringAsFixed(2),
                      row['profit'].toStringAsFixed(2),
                    ])
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey300,  // Correct color constant usage
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.centerRight,
                  },
                  rowDecoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.black, width: 0.5),
                    ),
                  ),
                );
              },
            ),
            pw.SizedBox(height: 20),
            _buildTotalsRow(data),
          ],
        );
      },
    ),
  );

  // Save and open the PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

// Table header builder
pw.Widget _buildTableHeader() {
  return pw.Row(
    children: [
      pw.Expanded(child: pw.Text('Party Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(child: pw.Text('Revenue', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(child: pw.Text('Expense', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      pw.Expanded(child: pw.Text('Profit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
    ],
  );
}

// Totals row builder
pw.Widget _buildTotalsRow(List<Map<String, dynamic>> data) {
  double totalRevenue = data.fold(0.0, (sum, row) => sum + row['revenue']);
  double totalExpenses = data.fold(0.0, (sum, row) => sum + row['expense']);
  double totalProfit = data.fold(0.0, (sum, row) => sum + row['profit']);

  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text('Totals', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(
        '${totalRevenue.toStringAsFixed(2)} / '
        '${totalExpenses.toStringAsFixed(2)} / '
        '${totalProfit.toStringAsFixed(2)}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profit/Loss Report", style: TextStyle(fontSize: 20)),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: profitLossData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          double totalRevenue = data.fold(0.0, (sum, row) => sum + row['revenue']);
          double totalExpenses = data.fold(0.0, (sum, row) => sum + row['expense']);
          double totalProfit = data.fold(0.0, (sum, row) => sum + row['profit']);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Padding inside the table
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header text
                      Text(
                        'Profit/Loss Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Table
                      DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.blueGrey[700]!,
                        ),
                        headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        columnSpacing: 16,
                        dataRowHeight: 60,
                        dividerThickness: 1,
                        columns: const [
                          DataColumn(label: Text('Party Name')),
                          DataColumn(label: Text('Revenue')),
                          DataColumn(label: Text('Expense')),
                          DataColumn(label: Text('Profit')),
                        ],
                        rows: [
                          ...data.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> row = entry.value;

                            return DataRow(
                              color: MaterialStateProperty.all(
                                index % 2 == 0 ? Colors.blueGrey[50] : Colors.blueGrey[100],
                              ),
                              cells: [
                                DataCell(
                                  Text(
                                    row['partyName'],
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row['revenue'].toStringAsFixed(2),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row['expense'].toStringAsFixed(2),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row['profit'].toStringAsFixed(2),
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),

                          // Total Row
                          DataRow(
                            color: MaterialStateProperty.all(Colors.blueGrey[200]),
                            cells: [
                              DataCell(
                                Text(
                                  "Totals",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              DataCell(Text(
                                  totalRevenue.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                              )),
                              DataCell(Text(
                                  totalExpenses.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                              )),
                              DataCell(Text(
                                  totalProfit.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                              )),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _generatePdf(data);
                        },
                        child: Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueGrey[800],
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



class PartyBalanceReportScreen extends StatefulWidget {
  const PartyBalanceReportScreen({super.key});

  @override
  State<PartyBalanceReportScreen> createState() =>
      _PartyBalanceReportScreenState();
}

class _PartyBalanceReportScreenState extends State<PartyBalanceReportScreen> {
  List<Map<String, dynamic>> partyBalances = [];
  List<Map<String, dynamic>> filteredBalances = [];
  String searchQuery = "";
  String filter = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPartyBalances();
  }

  Future<void> _fetchPartyBalances() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> balances = [];
    final partyReportSnapshot =
        await FirebaseFirestore.instance.collection('partyreport').get();

    for (var partyDoc in partyReportSnapshot.docs) {
      final partyName = partyDoc['partyName'];

      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('partyName', isEqualTo: partyName)
          .snapshots();

      tripsSnapshot.listen((tripSnapshot) {
        num totalBalance = 0;

        for (var tripDoc in tripSnapshot.docs) {
          final tripData = tripDoc.data();
          final num amount = num.tryParse(tripData['amount'] ?? '0') ?? 0;

          num advanceTotal = 0;
          if (tripData['advances'] != null) {
            for (var advance in tripData['advances']) {
              advanceTotal += num.tryParse(advance['amount'] ?? '0') ?? 0;
            }
          }

          num paymentsTotal = 0;
          if (tripData['payments'] != null) {
            for (var payment in tripData['payments']) {
              paymentsTotal += num.tryParse(payment['amount'] ?? '0') ?? 0;
            }
          }

          totalBalance += amount - (advanceTotal + paymentsTotal);
        }

        balances.add({
          'partyName': partyName,
          'balance': totalBalance,
        });

        setState(() {
          partyBalances = balances;
          filteredBalances = balances;
          isLoading = false;
        });
      });
    }
  }

  void _filterBalances() {
    setState(() {
      filteredBalances = partyBalances.where((party) {
        final matchesSearch = party['partyName']
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        final matchesFilter = filter == "All" ||
            (filter == "Positive" && party['balance'] > 0) ||
            (filter == "Cleared" && party['balance'] <= 0);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Party Balance Report', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Party Name', 'Balance'],
                data: filteredBalances.map((party) {
                  return [
                    party['partyName'],
                    NumberFormat('#,##0.00').format(party['balance']),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Row(
          children: [
            Icon(Icons.account_balance, size: 30),
            SizedBox(width: 8),
            Text("Party Balance Report"),
          ],
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      searchQuery = value;
                      _filterBalances();
                    },
                    decoration: InputDecoration(
                      hintText: "Search for a Party",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  width: 150,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: filter,
                    onChanged: (value) {
                      if (value != null) {
                        filter = value;
                        _filterBalances();
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: "All",
                        child: Text("All"),
                      ),
                      DropdownMenuItem(
                        value: "Positive",
                        child: Text("Positive Balance"),
                      ),
                      DropdownMenuItem(
                        value: "Cleared",
                        child: Text("Cleared Balance"),
                      ),
                    ],
                    style: TextStyle(color: Colors.black),
                    underline: SizedBox(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredBalances.isEmpty
                    ? Center(child: Text("No results found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: filteredBalances.length,
                        itemBuilder: (context, index) {
                          final party = filteredBalances[index];
                          final balance = party['balance'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: balance > 0 ? Colors.green[50] : Colors.red[50],
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    balance > 0 ? Colors.green : Colors.red,
                                child: Icon(
                                  balance > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                party['partyName'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                balance > 0
                                    ? "Amount to Receive"
                                    : "Amount Cleared",
                                style: TextStyle(
                                  color: balance > 0
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Text(
                                NumberFormat.currency(
                                        locale: 'en_IN', symbol: '₹')
                                    .format(balance),
                                style: TextStyle(
                                  color: balance > 0
                                      ? Colors.green
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _generatePdf,
              child: Text("Download PDF"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16), backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}





class PartyRevenueReportScreen extends StatefulWidget {
  const PartyRevenueReportScreen({super.key});

  @override
  _PartyRevenueReportScreenState createState() =>
      _PartyRevenueReportScreenState();
}

class _PartyRevenueReportScreenState extends State<PartyRevenueReportScreen> {
  String searchQuery = '';
  String selectedFilter = 'All';
  String selectedSort = 'Party Name';
  bool isAscending = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Party Revenue Report"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          // Search, Filter, and Sort Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by Party Name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedFilter,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue ?? 'All';
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'By Revenue', child: Text('By Revenue')),
                    DropdownMenuItem(value: 'By Trips', child: Text('By Trips')),
                  ],
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedSort,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSort = newValue ?? 'Party Name';
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'Party Name', child: Text('Party Name')),
                    DropdownMenuItem(value: 'Revenue', child: Text('Revenue')),
                    DropdownMenuItem(value: 'Trips', child: Text('Trips')),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      isAscending = !isAscending;
                    });
                  },
                ),
              ],
            ),
          ),
          // Revenue Table Section
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(  
              future: fetchPartyRevenueData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final data = snapshot.data ?? [];
                final filteredData = applyFiltersAndSort(data);

                final totalTrips = filteredData.fold<int>(0, (sum, item) => sum + (item['trips'] as int));
                final totalRevenue = filteredData.fold<int>(0, (sum, item) => sum + (item['revenue'] as int));

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue[700]!),
                      headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      columns: const [
                        DataColumn(label: Text("Party/Customer Name")),
                        DataColumn(label: Text("Trips")),
                        DataColumn(label: Text("Revenue")),
                      ],
                      rows: [
                        for (final party in filteredData)
                          DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                                (states) => filteredData.indexOf(party).isEven ? Colors.grey[100] : Colors.transparent),
                            cells: [
                              DataCell(Text(party['partyName'] ?? 'N/A')),
                              DataCell(Text(party['trips'].toString(), textAlign: TextAlign.end)),
                              DataCell(Text(
                                "₹${NumberFormat("#,##0").format(party['revenue'])}",
                                textAlign: TextAlign.end,
                              )),
                            ],
                          ),
                        DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>((states) => Colors.green[100]),
                          cells: [
                            const DataCell(Text(
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text(
                              totalTrips.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            )),
                            DataCell(Text(
                              "₹${NumberFormat("#,##0").format(totalRevenue)}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.end,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fetch combined data
  Future<List<Map<String, dynamic>>> fetchPartyRevenueData() async {
    final partyCollection = FirebaseFirestore.instance.collection('partyreport');
    final tripsCollection = FirebaseFirestore.instance.collection('trips');

    final partySnapshot = await partyCollection.get();
    final List<Map<String, dynamic>> partyData = partySnapshot.docs.map((doc) {
      final rawAmount = doc['amount'] as String;
      final cleanAmount = rawAmount.replaceAll(RegExp(r'[₹, ]'), '');
      final revenue = int.tryParse(cleanAmount) ?? 0;

      return {
        'partyName': doc['partyName'],
        'revenue': revenue,
      };
    }).toList();

    for (var party in partyData) {
      final partyName = party['partyName'];
      final tripsSnapshot = await tripsCollection.where('partyName', isEqualTo: partyName).get();
      party['trips'] = tripsSnapshot.size;
    }

    return partyData;
  }

  // Apply search, filter, and sort to the data
  List<Map<String, dynamic>> applyFiltersAndSort(List<Map<String, dynamic>> data) {
    var filteredData = data.where((party) {
      return party['partyName'].toString().toLowerCase().contains(searchQuery);
    }).toList();

    if (selectedFilter == 'By Revenue') {
      filteredData = filteredData.where((party) => party['revenue'] > 0).toList();
    } else if (selectedFilter == 'By Trips') {
      filteredData = filteredData.where((party) => party['trips'] > 0).toList();
    }

    if (selectedSort == 'Party Name') {
      filteredData.sort((a, b) => a['partyName'].toString().compareTo(b['partyName'].toString()));
    } else if (selectedSort == 'Revenue') {
      filteredData.sort((a, b) => a['revenue'].compareTo(b['revenue']));
    } else if (selectedSort == 'Trips') {
      filteredData.sort((a, b) => a['trips'].compareTo(b['trips']));
    }

    if (!isAscending) {
      filteredData = filteredData.reversed.toList();
    }

    return filteredData;
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
