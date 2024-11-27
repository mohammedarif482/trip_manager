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
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Padding inside the table
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.redAccent,
                    ),
                    headingTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Increased font size for headers
                    ),
                    columnSpacing: 12,
                    dataRowHeight: 50,
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
                            index % 2 == 0 ? Colors.grey[100] : Colors.grey[200],
                          ),
                          cells: [
                            DataCell(
                              Text(
                                row['partyName'],
                                style: TextStyle(fontSize: 14), // Slightly increased font size
                              ),
                            ),
                            DataCell(
                              Text(
                                row['revenue'].toStringAsFixed(2),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                row['expense'].toStringAsFixed(2),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DataCell(
                              Text(
                                row['profit'].toStringAsFixed(2),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        );
                      }).toList(),

                      // Total Row
                      DataRow(
                        color: MaterialStateProperty.all(Colors.greenAccent),
                        cells: [
                          DataCell(
                            Text(
                              "Totals",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          DataCell(Text(totalRevenue.toStringAsFixed(2))),
                          DataCell(Text(totalExpenses.toStringAsFixed(2))),
                          DataCell(Text(totalProfit.toStringAsFixed(2))),
                        ],
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
    final List<Map<String, dynamic>> balances = [];
    final partyReportSnapshot =
        await FirebaseFirestore.instance.collection('partyreport').get();

    for (var partyDoc in partyReportSnapshot.docs) {
      final partyName = partyDoc['partyName'];

      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('partyName', isEqualTo: partyName)
          .get();

      num totalBalance = 0;
      for (var tripDoc in tripsSnapshot.docs) {
        final tripData = tripDoc.data();
        final num amount = num.tryParse(tripData['amount'] ?? '0') ?? 0;
        final num advanceAmount =
            num.tryParse(tripData['advanceAmount'] ?? '0') ?? 0;

        num paymentsTotal = 0;
        if (tripData['payments'] != null) {
          for (var payment in tripData['payments']) {
            paymentsTotal += num.tryParse(payment['amount'] ?? '0') ?? 0;
          }
        }

        totalBalance += amount - (advanceAmount + paymentsTotal);
      }

      balances.add({
        'partyName': partyName,
        'balance': totalBalance,
      });
    }

    setState(() {
      partyBalances = balances;
      filteredBalances = balances;
      isLoading = false; // Data is fully loaded
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Party Balance Report"),
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
            padding: const EdgeInsets.all(8.0),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                DropdownButton<String>(
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
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
                : filteredBalances.isEmpty
                    ? Center(child: Text("No results found.")) // Show when no results
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
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                style: const TextStyle(
                                  fontSize: 16,
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
  List<Map<String, dynamic>> filteredData = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Party Revenue Report"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search, Filter, and Sort Row
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03, vertical: 8),
              child: Row(
                children: [
                  // Search Bar
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
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Filter Dropdown
                  Container(
                    width: screenWidth * 0.25,
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedFilter = newValue ?? 'All';
                        });
                      },
                      items: <String>['All', 'By Revenue', 'By Trips']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Sort Dropdown
                  Container(
                    width: screenWidth * 0.25,
                    child: DropdownButton<String>(
                      value: selectedSort,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSort = newValue ?? 'Party Name';
                        });
                      },
                      items: <String>['Party Name', 'Revenue', 'Trips']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  // Sort Order (Ascending/Descending)
                  IconButton(
                    icon: Icon(isAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        isAscending = !isAscending;
                      });
                    },
                  ),
                ],
              ),
            ),
            // FutureBuilder for data fetching
            Container(
              height: screenHeight * 0.7, // Limit height for table
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchPartyRevenueData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  final data = snapshot.data ?? [];
                  final filteredData = applyFiltersAndSort(data);

                  final int totalTrips = filteredData.fold(0,
                      (sum, item) => sum + (item['trips'] as int));
                  final int totalRevenue = filteredData.fold(0,
                      (sum, item) => sum + (item['revenue'] as int));

                  return Column(
                    children: [
                      // Table Header
                      Container(
                        color: Colors.red, // Red background for header
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Party/Customer Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white), // White font
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Trips",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Revenue",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table content
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final party = filteredData[index];
                            return Container(
                              color: index % 2 == 0
                                  ? Colors.grey[100]
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(party['partyName'] ?? 'N/A'),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      party['trips'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "₹${party['revenue']}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      // Total Row at the bottom of the table
                      Container(
                        color: Colors.green, // Green background for total row
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Total",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                totalTrips.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "₹${totalRevenue}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch combined data
  Future<List<Map<String, dynamic>>> fetchPartyRevenueData() async {
    final partyCollection = FirebaseFirestore.instance.collection('partyreport');
    final tripsCollection = FirebaseFirestore.instance.collection('trips');

    // Fetch party report data
    final partySnapshot = await partyCollection.get();
    final List<Map<String, dynamic>> partyData = partySnapshot.docs.map((doc) {
      // Process the amount field
      final rawAmount = doc['amount'] as String;
      final cleanAmount = rawAmount.replaceAll(RegExp(r'[₹, ]'), '');
      final revenue = int.tryParse(cleanAmount) ?? 0; // Convert to int, fallback to 0 if invalid

      return {
        'partyName': doc['partyName'],
        'revenue': revenue,
      };
    }).toList();

    // Fetch trips data and calculate counts
    for (var party in partyData) {
      final partyName = party['partyName'];
      final tripsSnapshot =
          await tripsCollection.where('partyName', isEqualTo: partyName).get();
      party['trips'] = tripsSnapshot.size; // Count documents for this party
    }

    return partyData;
  }

  // Apply search, filter, and sort to the data
  List<Map<String, dynamic>> applyFiltersAndSort(List<Map<String, dynamic>> data) {
    // Apply search filter
    var filteredData = data.where((party) {
      return party['partyName']
          .toString()
          .toLowerCase()
          .contains(searchQuery);
    }).toList();

    // Apply selected filter
    if (selectedFilter == 'By Revenue') {
      filteredData = filteredData
          .where((party) => party['revenue'] > 0)
          .toList();
    } else if (selectedFilter == 'By Trips') {
      filteredData = filteredData.where((party) => party['trips'] > 0).toList();
    }

    // Sort data based on selected sort option
    if (selectedSort == 'Party Name') {
      filteredData.sort((a, b) => a['partyName']
          .toString()
          .compareTo(b['partyName'].toString()));
    } else if (selectedSort == 'Revenue') {
      filteredData.sort((a, b) => a['revenue'].compareTo(b['revenue']));
    } else if (selectedSort == 'Trips') {
      filteredData.sort((a, b) => a['trips'].compareTo(b['trips']));
    }

    // Reverse order if descending
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
