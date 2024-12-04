import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
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
      await _updateDriverTransactions(oldDriverName, selectedDriver!, formattedDate); // Use non-nullable selectedDriver
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

Future<void> _updateDriverTransactions(String oldDriverName, String newDriverName, String formattedDate) async {
  try {
    // Query the drivertransactions collection to find transactions matching the old driver name and description
    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: oldDriverName)
        .where('description', isEqualTo: 'Bhata') // match description
        .get();

    print('Found ${transactionSnapshot.docs.length} matching transactions'); // Debugging

    // If matching transactions are found, update them
    if (transactionSnapshot.docs.isNotEmpty) {
      for (var doc in transactionSnapshot.docs) {
        // Get the amount from the trip (make sure it's a string)
        double amount = double.tryParse(amountController.text) ?? 0;
        double newAmount = amount * 0.2;  // 20% of the trip amount

        // Convert the new amount to string format
        String newAmountString = newAmount.toStringAsFixed(2); // to make it in string format with two decimals

        // Prepare the updated transaction data
        await FirebaseFirestore.instance
            .collection('drivertransactions')
            .doc(doc.id)
            .update({
          'driverName': newDriverName, // update to the new driver
          'amount': newAmountString, // update to 20% of the amount as string
          'date': formattedDate, // update to the formatted date 'yyyy-MM-dd'
        });

        print("Updated transaction for driver: $newDriverName with amount: $newAmountString and date: $formattedDate");
      }
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
