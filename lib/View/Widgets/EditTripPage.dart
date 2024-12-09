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

  // Fetch the old trip data
  DocumentSnapshot oldTripSnapshot = await FirebaseFirestore.instance
      .collection('trips')
      .doc(widget.tripId)
      .get();

  if (!oldTripSnapshot.exists) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Trip not found!'),
        );
      },
    );
    return;
  }

  String? oldAmount = oldTripSnapshot.get('amount');
  String? oldDriverName = oldTripSnapshot.get('driverName');
  String? oldPartyName = oldTripSnapshot.get('partyName');
  String? oldTripDate = oldTripSnapshot.get('date');

  if (oldAmount == null || oldDriverName == null || oldPartyName == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Old trip details are incomplete!'),
        );
      },
    );
    return;
  }

  // Ensure formattedDate is not null
  String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

  final updatedTrip = {
    "partyName": selectedPartyName ?? "", // Provide default value for nullable strings
    "driverName": selectedDriver ?? "", // Provide default value for nullable strings
    "vehicleNumber": selectedVehicleNumber ?? "", // Provide default value for nullable strings
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

    // Update driver transactions and party report if amount, party, or driver changes
    if (oldAmount != amountController.text || 
        oldPartyName != selectedPartyName || 
        oldDriverName != selectedDriver || 
        oldTripDate != formattedDate) {

      if (oldAmount != amountController.text || oldDriverName != selectedDriver || oldTripDate != formattedDate) {
        print("Updating driver transactions...");
        await _updateDriverTransactions(
          oldDriverName: oldDriverName ?? "", // Provide default value for nullable strings
          newDriverName: selectedDriver ?? "", // Provide default value for nullable strings
          oldAmount: oldAmount ?? "0", // Provide default value for nullable strings
          newAmount: amountController.text,
          tripDate: formattedDate,
          oldTripDate: oldTripDate ?? "", // Provide default value for nullable strings
        );
      }

      if (oldPartyName != selectedPartyName || oldAmount != amountController.text) {
        print("Updating party report...");
        await _updatePartyReport(
          oldPartyName: oldPartyName ?? "", // Provide default value for nullable strings
          newPartyName: selectedPartyName ?? "", // Provide default value for nullable strings
          oldAmount: oldAmount ?? "0", // Provide default value for nullable strings
          newAmount: amountController.text,
        );
      }
    } else {
      print("No changes to update in driver transactions or party report.");
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




Future<void> _updatePartyReport({
  required String oldPartyName,
  required String newPartyName,
  required String oldAmount,
  required String newAmount,
}) async {
  try {
    // Update the old party report
    if (oldPartyName != newPartyName) {
      // Fetch the document for the old party
      QuerySnapshot oldPartySnapshot = await FirebaseFirestore.instance
          .collection('partyreport')
          .where('partyName', isEqualTo: oldPartyName)
          .get();

      if (oldPartySnapshot.docs.isNotEmpty) {
        DocumentSnapshot oldPartyReport = oldPartySnapshot.docs.first;
        String oldPartyAmountString = oldPartyReport.get('amount') ?? "0";
        int oldPartyAmount = int.parse(oldPartyAmountString);
        int oldAmountInt = int.parse(oldAmount);

        // Deduct the old amount
        int updatedOldPartyAmount = oldPartyAmount - oldAmountInt;

        // Update the old party's report
        await FirebaseFirestore.instance
            .collection('partyreport')
            .doc(oldPartyReport.id)
            .update({'amount': updatedOldPartyAmount.toString()});

        print("Updated old party report for $oldPartyName");
      } else {
        print("Old party report for $oldPartyName does not exist, skipping update.");
      }
    }

    // Update or create the new party report
    QuerySnapshot newPartySnapshot = await FirebaseFirestore.instance
        .collection('partyreport')
        .where('partyName', isEqualTo: newPartyName)
        .get();

    int newAmountInt = int.parse(newAmount);

    if (newPartySnapshot.docs.isNotEmpty) {
      DocumentSnapshot newPartyReport = newPartySnapshot.docs.first;
      String newPartyAmountString = newPartyReport.get('amount') ?? "0";
      int newPartyAmount = int.parse(newPartyAmountString);

      // Add the new amount
      int updatedNewPartyAmount = newPartyAmount + newAmountInt;

      // Update the new party's report
      await FirebaseFirestore.instance
          .collection('partyreport')
          .doc(newPartyReport.id)
          .update({'amount': updatedNewPartyAmount.toString()});

      print("Updated new party report for $newPartyName");
    } else {
      // Create a new party report if no document is found for the new party
      await FirebaseFirestore.instance.collection('partyreport').add({
        'partyName': newPartyName,
        'amount': newAmountInt.toString(),
      });

      print("Created new party report for $newPartyName with amount: $newAmount");
    }
  } catch (e) {
    print("Error updating party report: $e");
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

Future<void> _updateDriverTransactions({
  required String oldDriverName,
  required String newDriverName,
  required String oldAmount,
  required String newAmount,
  required String tripDate,
  required String oldTripDate,
}) async {
  try {
    print("Old Driver Name: $oldDriverName");
    print("Old Amount: $oldAmount");
    print("Old Trip Date: $oldTripDate");

    // Convert oldTripDate ("4 Dec 2024") to "yyyy-MM-dd" format (e.g., "2024-12-04")
    DateFormat oldDateFormat = DateFormat('d MMM yyyy'); // For "4 Dec 2024"
    DateTime parsedOldTripDate = oldDateFormat.parse(oldTripDate);
    String formattedOldTripDate = DateFormat('yyyy-MM-dd').format(parsedOldTripDate);

    print("Formatted Old Trip Date: $formattedOldTripDate");

    // Ensure old and new amounts are valid and not null
    int oldBhata = (double.parse(oldAmount) * 0.2).round();
    int newBhata = (double.parse(newAmount) * 0.2).round();

    String oldBhataString = oldBhata.toString();
    String newBhataString = newBhata.toString();

    print("Old Bhata: $oldBhataString");
    print("New Bhata: $newBhataString");

    // Query the drivertransactions collection to find the matching transaction
    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('drivertransactions')
        .where('driverName', isEqualTo: oldDriverName)
        .where('date', isEqualTo: formattedOldTripDate) // Use formatted date for comparison
        .get();

    print("Transaction Snapshot: ${transactionSnapshot.docs}");

    if (transactionSnapshot.docs.isNotEmpty) {
      var doc = transactionSnapshot.docs.first;

      // Print out stored values for debugging
      print("Stored Driver Name: ${doc['driverName']}");
      print("Stored Trip Date: ${doc['date']}");

      // Update the transaction
      await FirebaseFirestore.instance
          .collection('drivertransactions')
          .doc(doc.id)
          .update({
        'driverName': newDriverName,
        'amount': newBhataString,
        'date': tripDate, // Update the date to the new trip date
      });

      print("Updated Bhata for driver: $newDriverName to amount: $newBhataString on date: $tripDate");
    } else {
      print("No matching transaction found to update.");
    }
  } catch (e) {
    print("Error updating Bhata: $e");
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
