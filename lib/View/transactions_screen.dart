// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:tripmanager/Utils/constants.dart';

// class Transaction {
//   final String name;
//   final double amount;
//   final DateTime date;
//   final String purpose;
//   final bool isExpense;

//   Transaction({
//     required this.name,
//     required this.amount,
//     required this.date,
//     required this.purpose,
//     required this.isExpense,
//   });
// }

// class TransactionScreen extends StatefulWidget {
//   @override
//   _TransactionScreenState createState() => _TransactionScreenState();
// }

// class _TransactionScreenState extends State<TransactionScreen> {
//   // Filter states
//   RangeValues _amountRange = RangeValues(0, 100000);
//   String? _selectedName;
//   String? _selectedPurpose;
//   DateTimeRange? _selectedDateRange;
//   String? _transactionType;

//   List<Transaction> _filteredTransactions = [];
//   final _nameController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _purposeController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isExpense = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.accentColor,
//         title: Text('Transactions'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_list),
//             onPressed: _showFilterBottomSheet,
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//           onPressed: _showAddTransactionSheet,
//           icon: Icon(Icons.add),
//           label: Text("Add Trasaction"),
//           backgroundColor: AppColors.primaryColor,
//           foregroundColor: AppColors.accentColor),
//       body: ListView.builder(
//         padding: EdgeInsets.symmetric(vertical: 12),
//         itemCount: _filteredTransactions.length,
//         itemBuilder: (context, index) {
//           final transaction = _filteredTransactions[index];
//           return TransactionCard(transaction: transaction);
//         },
//       ),
//     );
//   }

//   final List<Transaction> _allTransactions = [
//     Transaction(
//       name: 'John Doe',
//       amount: 15000,
//       date: DateTime.now(),
//       purpose: 'Advance',
//       isExpense: true,
//     ),
//     Transaction(
//       name: 'Sarah Smith',
//       amount: 25000,
//       date: DateTime.now().subtract(Duration(days: 1)),
//       purpose: 'Salary',
//       isExpense: false,
//     ),
//     Transaction(
//       name: 'Alice Johnson',
//       amount: 5000,
//       date: DateTime.now().subtract(Duration(days: 2)),
//       purpose: 'Groceries',
//       isExpense: true,
//     ),
//     Transaction(
//       name: 'Bob Brown',
//       amount: 12000,
//       date: DateTime.now().subtract(Duration(days: 3)),
//       purpose: 'Rent',
//       isExpense: true,
//     ),
//     Transaction(
//       name: 'Emily Davis',
//       amount: 18000,
//       date: DateTime.now().subtract(Duration(days: 4)),
//       purpose: 'Consulting',
//       isExpense: false,
//     ),
//     Transaction(
//       name: 'Michael Lee',
//       amount: 8000,
//       date: DateTime.now().subtract(Duration(days: 5)),
//       purpose: 'Utilities',
//       isExpense: true,
//     ),
//     Transaction(
//       name: 'Jessica Taylor',
//       amount: 30000,
//       date: DateTime.now().subtract(Duration(days: 6)),
//       purpose: 'Investment Return',
//       isExpense: false,
//     ),
//     Transaction(
//       name: 'David Wilson',
//       amount: 7000,
//       date: DateTime.now().subtract(Duration(days: 7)),
//       purpose: 'Transportation',
//       isExpense: true,
//     ),
//     Transaction(
//       name: 'Linda Garcia',
//       amount: 22000,
//       date: DateTime.now().subtract(Duration(days: 8)),
//       purpose: 'Freelance Project',
//       isExpense: false,
//     ),
//     Transaction(
//       name: 'Paul Martinez',
//       amount: 9500,
//       date: DateTime.now().subtract(Duration(days: 9)),
//       purpose: 'Dining Out',
//       isExpense: true,
//     ),
//   ];
// }

// class TransactionCard extends StatelessWidget {
//   const TransactionCard({
//     super.key,
//     required this.transaction,
//   });

//   final Transaction transaction;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Card(
//         color: AppColors.accentColor,
//         elevation: 4,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15),
//           side: BorderSide(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 4),
//           child: ListTile(
//             leading: CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.blue.shade50,
//               child: Text(
//                 transaction.name[0],
//                 style: TextStyle(
//                   color: Colors.blue.shade900,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//             title: Text(
//               transaction.name,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 4),
//                 Text(
//                   DateFormat('dd MMM yyyy').format(transaction.date),
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 Text(
//                   transaction.purpose,
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//             trailing: Text(
//               '${transaction.isExpense ? "- " : "+ "}₹${transaction.amount.toStringAsFixed(0)}',
//               style: TextStyle(
//                 color: transaction.isExpense
//                     ? Colors.red.shade700
//                     : Colors.green.shade700,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripmanager/Model/temp_data.dart';
import 'package:tripmanager/Utils/constants.dart';

class Transaction {
  final String name;
  final double amount;
  final DateTime date;
  final String purpose;
  final bool isExpense;

  Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.purpose,
    required this.isExpense,
  });
}

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // Filter states remain the same
  RangeValues _amountRange = RangeValues(0, 100000);
  String? _selectedName;
  String? _selectedPurpose;
  DateTimeRange? _selectedDateRange;
  String? _transactionType;

  List<Transaction> _filteredTransactions = [];
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isExpense = true;

  // Convert DummyData into Transactions
  List<Transaction> _convertDummyDataToTransactions() {
    List<Transaction> transactions = [];

    // Add expenses as transactions
    for (var expense in DummyData.expenses) {
      // Find the driver name for this expense
      var trip =
          DummyData.trips.firstWhere((trip) => trip.tripId == expense.tripId);
      var driver =
          DummyData.users.firstWhere((user) => user.userId == trip.driverId);

      transactions.add(Transaction(
        name: driver.name,
        amount: expense.amount.toDouble(),
        date: expense.addedAt,
        purpose: expense.expenseType,
        isExpense: true,
      ));
    }

    // Add completed trips as earnings
    for (var trip
        in DummyData.trips.where((trip) => trip.status == 'completed')) {
      var driver =
          DummyData.users.firstWhere((user) => user.userId == trip.driverId);
      var route =
          DummyData.routes.firstWhere((route) => route.routeId == trip.routeId);

      transactions.add(Transaction(
        name: driver.name,
        amount: trip.amount.toDouble(),
        date: trip.endDate,
        purpose: '${route.source} to ${route.destination}',
        isExpense: false,
      ));
    }

    // Sort transactions by date, most recent first
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  @override
  void initState() {
    super.initState();
    _allTransactions = _convertDummyDataToTransactions();
    _filteredTransactions = List.from(_allTransactions);
  }

  void _showAddTransactionSheet() {
    // Reset form values
    _nameController.clear();
    _amountController.clear();
    _purposeController.clear();
    _selectedDate = DateTime.now();
    _isExpense = true;
    @override
    void initState() {
      super.initState();
      _filteredTransactions = List.from(_allTransactions);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Transaction Type Toggle
                Row(
                  children: [
                    Text('Transaction Type:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    ChoiceChip(
                      label: Text('Expense'),
                      selected: _isExpense,
                      onSelected: (selected) {
                        setModalState(() => _isExpense = selected);
                      },
                    ),
                    SizedBox(width: 10),
                    ChoiceChip(
                      label: Text('Earning'),
                      selected: !_isExpense,
                      onSelected: (selected) {
                        setModalState(() => _isExpense = !selected);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Name Field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),

                // Amount Field
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                SizedBox(height: 16),

                // Purpose Field
                TextField(
                  controller: _purposeController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                SizedBox(height: 16),

                // Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.calendar_today),
                  title: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}'),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _amountController.text.isNotEmpty &&
                        _purposeController.text.isNotEmpty) {
                      setState(() {
                        _allTransactions.add(
                          Transaction(
                            name: _nameController.text,
                            amount: double.parse(_amountController.text),
                            date: _selectedDate,
                            purpose: _purposeController.text,
                            isExpense: _isExpense,
                          ),
                        );
                        _filteredTransactions = List.from(_allTransactions);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaction added successfully'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Add Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        bool amountFilter = transaction.amount >= _amountRange.start &&
            transaction.amount <= _amountRange.end;

        bool nameFilter =
            _selectedName == null || transaction.name == _selectedName;

        bool purposeFilter =
            _selectedPurpose == null || transaction.purpose == _selectedPurpose;

        bool dateFilter = _selectedDateRange == null ||
            (transaction.date.isAfter(_selectedDateRange!.start) &&
                transaction.date.isBefore(_selectedDateRange!.end));

        bool typeFilter = _transactionType == null ||
            (_transactionType == 'Expense' && transaction.isExpense) ||
            (_transactionType == 'Earning' && !transaction.isExpense);

        return amountFilter &&
            nameFilter &&
            purposeFilter &&
            dateFilter &&
            typeFilter;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _amountRange = RangeValues(0, 100000);
      _selectedName = null;
      _selectedPurpose = null;
      _selectedDateRange = null;
      _transactionType = null;
      _filteredTransactions = List.from(_allTransactions);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _resetFilters();
                      Navigator.pop(context);
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Amount Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RangeSlider(
                      values: _amountRange,
                      min: 0,
                      max: 100000,
                      divisions: 100,
                      labels: RangeLabels(
                        '₹${_amountRange.start.round()}',
                        '₹${_amountRange.end.round()}',
                      ),
                      onChanged: (RangeValues values) {
                        setModalState(() {
                          _amountRange = values;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedName,
                      hint: Text('Select Name'),
                      items: _allTransactions
                          .map((e) => e.name)
                          .toSet()
                          .map((name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedName = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Purpose',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedPurpose,
                      hint: Text('Select Purpose'),
                      items: _allTransactions
                          .map((e) => e.purpose)
                          .toSet()
                          .map((purpose) => DropdownMenuItem(
                                value: purpose,
                                child: Text(purpose),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedPurpose = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedDateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'),
                      onTap: () async {
                        final DateTimeRange? dateRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedDateRange,
                        );
                        if (dateRange != null) {
                          setModalState(() {
                            _selectedDateRange = dateRange;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Transaction Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _transactionType,
                      hint: Text('Select Type'),
                      items: ['Expense', 'Earning']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _transactionType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Existing build method remains the same
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.accentColor,
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionSheet,
        icon: Icon(Icons.add),
        label: Text("Add Transaction"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.accentColor,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12),
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return TransactionCard(transaction: transaction);
        },
      ),
    );
  }

  late final List<Transaction> _allTransactions;
}

// TransactionCard widget remains exactly the same
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: AppColors.accentColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                transaction.name[0],
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            title: Text(
              transaction.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  transaction.purpose,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            trailing: Text(
              '${transaction.isExpense ? "- " : "+ "}₹${transaction.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: transaction.isExpense
                    ? Colors.red.shade700
                    : Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
