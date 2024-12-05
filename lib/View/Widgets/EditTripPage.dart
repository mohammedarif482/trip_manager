import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditTripPage extends StatefulWidget {
  final String tripId;

  EditTripPage({required this.tripId});

  @override
  _EditTripPageState createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  final TextEditingController fromLocationController = TextEditingController();
  final TextEditingController toLocationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController partyNameController = TextEditingController(); // Add this for Autocomplete

  String? selectedDriver;
  String? selectedVehicleNumber;
  String? selectedPartyName;
  DateTime selectedDate = DateTime.now();

  List<String> vehicleNumbers = [];
  List<String> partyNames = [];
  List<Map<String, dynamic>> drivers = [];

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
    _fetchVehicleNumbers();
    _fetchPartyNames();
    _fetchDrivers();
  }

  Future<void> _fetchTripDetails() async {
    try {
      DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .doc(widget.tripId)
          .get();

      if (tripSnapshot.exists) {
        var tripData = tripSnapshot.data() as Map<String, dynamic>;
        setState(() {
          fromLocationController.text = tripData['fromLocation'] ?? '';
          toLocationController.text = tripData['toLocation'] ?? '';
          amountController.text = tripData['amount'] ?? '';
          selectedDriver = tripData['driverName'];
          selectedVehicleNumber = tripData['vehicleNumber'];
          selectedPartyName = tripData['partyName'];
          selectedDate = _parseDateString(tripData['date']);
          partyNameController.text = selectedPartyName ?? '';  // Set the selected Party Name in the controller
        });
      }
    } catch (e) {
      print("Error fetching trip details: $e");
    }
  }

  DateTime _parseDateString(String dateString) {
    try {
      List<String> dateParts = dateString.split(' ');
      int day = int.parse(dateParts[0]);
      int month = _getMonthIndex(dateParts[1]);
      int year = int.parse(dateParts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now();
    }
  }

  int _getMonthIndex(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[month] ?? 1;
  }

  Future<void> _fetchVehicleNumbers() async {
    try {
      QuerySnapshot vehicleSnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();
      setState(() {
        vehicleNumbers = vehicleSnapshot.docs
            .map((doc) => doc['registration'].toString())
            .toList();
      });
    } catch (e) {
      print("Error fetching vehicle numbers: $e");
    }
  }

  Future<void> _fetchPartyNames() async {
    try {
      QuerySnapshot partySnapshot =
          await FirebaseFirestore.instance.collection('partydetails').get();
      setState(() {
        partyNames = partySnapshot.docs
            .map((doc) => doc['partyName'].toString())
            .toList();
      });
    } catch (e) {
      print("Error fetching party names: $e");
    }
  }

  Future<void> _fetchDrivers() async {
    try {
      QuerySnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isDriver', isEqualTo: true)
          .get();

      setState(() {
        drivers = driverSnapshot.docs
            .map((doc) => {'name': doc['name'], 'id': doc.id})
            .toList();
      });
    } catch (e) {
      print("Error fetching drivers: $e");
    }
  }

  Future<void> _updateTrip() async {
  if (selectedDriver == null ||
      selectedVehicleNumber == null ||
      selectedPartyName == null ||
      fromLocationController.text.isEmpty ||
      toLocationController.text.isEmpty ||
      amountController.text.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Please fill all fields'),
        );
      },
    );
    return;
  }

  // Fetch the old driver name from the trips collection before the update
  String? oldDriverName = await _fetchOldDriverName();
  if (oldDriverName == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Old driver name not found!'),
        );
      },
    );
    return;
  }

  // Convert selected date to 'yyyy-MM-dd' format for driver transactions
  String formattedDate =
      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  print('Formatted Date for transactions: $formattedDate'); // Debugging

  final updatedTrip = {
    "partyName": selectedPartyName,
    "driverName": selectedDriver,
    "vehicleNumber": selectedVehicleNumber,
    "fromLocation": fromLocationController.text,
    "toLocation": toLocationController.text,
    "date": "${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}",
    "amount": amountController.text,
    "updatedAt": FieldValue.serverTimestamp(),
  };

  try {
    // Update the trip details
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .update(updatedTrip);

    print("Trip updated successfully!");

    // If the driver name has changed, update transactions for the old driver
    if (oldDriverName != selectedDriver) {
      print("Driver name changed, updating driver transactions...");
      await _updateDriverTransactions(
        oldDriverName,             // Old driver name
        selectedDriver!,           // New driver name
        amountController.text,     // Trip amount
        formattedDate              // Formatted trip date
      );
    } else {
      print("Driver name did not change, skipping transaction update.");
    }

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Trip successfully updated!'),
        );
      },
    );
  } catch (e) {
    print("Error updating trip: $e");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Failed to update trip'),
        );
      },
    );
  }
}


Future<String?> _fetchOldDriverName() async {
  try {
    // Fetch the document from the trips collection using the trip ID
    DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripId)
        .get();

    // Check if the document exists and retrieve the driverName
    if (tripSnapshot.exists) {
      String? oldDriverName = tripSnapshot.get('driverName');
      print("Old Driver Name: $oldDriverName"); // Debugging
      return oldDriverName;
    } else {
      throw Exception("Trip not found");
    }
  } catch (e) {
    print("Error fetching old driver name: $e");
    return null;
  }
}

Future<void> _updateDriverTransactions(
  String oldDriverName,
  String newDriverName,
  String tripAmountString,
  String tripDateString, // Can be in either "4 Dec 2024" or "2024-12-06"
) async {
  try {
    // Debugging: Log the raw date string
    print('Raw trip date string: "$tripDateString"');

    // Convert trip amount to double and calculate 20%
    double tripAmount = double.tryParse(tripAmountString) ?? 0;
    int targetAmount = (tripAmount * 0.2).round(); // 20% rounded to nearest integer
    String targetAmountString = targetAmount.toString(); // Convert to string

    DateTime parsedTripDate;
    // Handle dynamic date format parsing
    try {
      if (tripDateString.contains('-')) {
        // If the string is in "yyyy-MM-dd" format
        parsedTripDate = DateFormat('yyyy-MM-dd').parse(tripDateString.trim());
      } else {
        // If the string is in "d MMM yyyy" format
        parsedTripDate = DateFormat('d MMM yyyy').parse(tripDateString.trim());
      }
    } catch (e) {
      print('Error parsing trip date string: $tripDateString. Exception: $e');
      throw FormatException(
          'Invalid date format for trip date: "$tripDateString".');
    }

    // Convert parsed date to "2024-12-06" format for Firestore queries
    String formattedTripDate = DateFormat('yyyy-MM-dd').format(parsedTripDate);

    // Debugging: Log the formatted date
    print('Converted trip date: $formattedTripDate');

    // Query the drivertransactions collection
    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: oldDriverName)
        .where('description', isEqualTo: 'Bhata') // Match description
        .where('amount', isEqualTo: targetAmountString) // Match 20% of trip amount
        .where('date', isEqualTo: formattedTripDate) // Match formatted date
        .get();

    print('Found ${transactionSnapshot.docs.length} matching transactions');

    // If matching transactions are found, update only the first one
    if (transactionSnapshot.docs.isNotEmpty) {
      var doc = transactionSnapshot.docs.first;

      // Update the transaction data
      await FirebaseFirestore.instance
          .collection('drivertransactions')
          .doc(doc.id)
          .update({
        'driverName': newDriverName, // Update to the new driver
        'amount': targetAmountString, // Ensure integer string format
        'date': formattedTripDate, // Already formatted date
      });

      print(
          "Updated transaction for driver: $newDriverName with amount: $targetAmountString and date: $formattedTripDate");
    } else {
      print("No matching transactions found for driver: $oldDriverName");
    }
  } catch (e) {
    print("Error updating driver transaction: $e");
  }
}
















  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Trip'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showAddTripSheet,
          child: Text('Edit Trip'),
        ),
      ),
    );
  }

  // Add the edit trip sheet with the updated Autocomplete and Dropdown for selected values
  void _showAddTripSheet() async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Trip",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Party Name Autocomplete
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: selectedPartyName ?? ''),
                  optionsBuilder: (textEditingValue) {
                    return partyNames.where((party) {
                      return party.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    }).toList();
                  },
                  onSelected: (String selected) {
                    setState(() {
                      selectedPartyName = selected;
                    });
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        labelText: 'Party Name',
                        hintText: 'Select or Type Party Name',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                // Driver Name Dropdown
                DropdownButtonFormField<String>(
                  value: selectedDriver,
                  hint: Text('Select Driver'),
                  decoration: InputDecoration(
                    labelText: 'Driver Name',  // Add this line to set the header
                    border: OutlineInputBorder(),
                  ),
                  items: drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver['name'],
                      child: Text(driver['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDriver = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                // Vehicle Number Dropdown with header
                Text("Vehicle Number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: selectedVehicleNumber,
                  hint: Text('Select Vehicle Number'),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: vehicleNumbers.map((vehicle) {
                    return DropdownMenuItem<String>(
                      value: vehicle,
                      child: Text(vehicle),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleNumber = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                // From Location TextField
                TextField(
                  controller: fromLocationController,
                  decoration: InputDecoration(
                    labelText: 'From Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // To Location TextField
                TextField(
                  controller: toLocationController,
                  decoration: InputDecoration(
                    labelText: 'To Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Amount TextField
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                // Date Picker
                ListTile(
                  title: Text("Date"),
                  trailing: Text("${selectedDate.day}-${selectedDate.month}-${selectedDate.year}"),
                  onTap: _selectDate,
                ),
                SizedBox(height: 16),
                // Update and Cancel Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _updateTrip,
                      child: Text('Update Trip'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Cancel and dismiss sheet
                      },
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}
