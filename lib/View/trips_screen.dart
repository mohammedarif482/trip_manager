import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Model/temp_data.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/Widgets/trip_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<Map<String, dynamic>> filteredTrips = [];
  TextEditingController searchController = TextEditingController();
  RangeValues amountRange = RangeValues(1000, 50000);
  String? selectedDriver;
  String? selectedVehicle;
  String? selectedPlace;
  String? selectedVehicleNumber;
  String? selectedPartyName;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController fromLocationController = TextEditingController();
  final TextEditingController toLocationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController partyController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  Future<List<Map<String, dynamic>>>? _tripsData;
  Future<List<Map<String, dynamic>>>? _tripsCompletedData;

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Fetch user details
      final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userSnapshot.exists) {
        throw Exception("User document not found");
      }

      final Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      if (userData == null) {
        throw Exception("User data is null");
      }

      final String userName = userData['name'] ?? '';
      final bool isDriver = userData['isDriver'] ?? false;

      Query query = FirebaseFirestore.instance.collection('trips');

      if (isDriver) {
        query = query.where('driverName', isEqualTo: userName);
      }

      final QuerySnapshot snapshot = await query.get();

      final trips = snapshot.docs.map((doc) {
        final Map<String, dynamic> tripData =
            doc.data() as Map<String, dynamic>;

        return {
          "tripId": doc.id,
          "partyName": tripData['partyName'],
          "driverName": tripData['driverName'],
          "vehicleNumber": tripData['vehicleNumber'],
          "fromLocation": tripData['fromLocation'],
          "toLocation": tripData['toLocation'],
          "date": tripData['date'],
          "status": tripData['status'],
          "amount": tripData['amount'],
          "endDate": tripData['endDate'] != null
              ? (tripData['endDate'] as Timestamp).toDate()
              : null,
        };
      }).toList();

      if (!isDriver) {
        return trips
            .where((trip) => trip['status'] != 'Trip Completed')
            .toList();
      }

      return trips;
    } catch (e) {
      print("Error fetching trips: $e");
      rethrow;
    }
  }

  // Future<List<Map<String, dynamic>>> _fetchCompletedTrips() async {
  //   final String? userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) {
  //     throw Exception("User not logged in");
  //   }
  //   final DocumentSnapshot userSnapshot =
  //       await FirebaseFirestore.instance.collection('users').doc(userId).get();
  //   final Map<String, dynamic>? userData =
  //       userSnapshot.data() as Map<String, dynamic>?;
  //   if (userData == null) {
  //     throw Exception("User data not found");
  //   }
  //   final String userName = userData['name'] ?? '';
  //   final bool isDriver = userData['isDriver'] ?? false;
  //   Query query = FirebaseFirestore.instance.collection('trips');
  //   if (isDriver) {
  //     query = query.where('driverName', isEqualTo: userName);
  //   }
  //   query = query.where('status', isEqualTo: 'Trip Completed');
  //   final QuerySnapshot snapshot = await query.get();
  //   return snapshot.docs.map((doc) {
  //     return {
  //       "tripId": doc.id,
  //       "partyName": doc['partyName'],
  //       "driverName": doc['driverName'],
  //       "vehicleNumber": doc['vehicleNumber'],
  //       "fromLocation": doc['fromLocation'],
  //       "toLocation": doc['toLocation'],
  //       "date": doc['date'],
  //       "status": doc['status'],
  //       "amount": doc['amount'],
  //     };
  //   }).toList();
  // }
  Future<List<Map<String, dynamic>>> _fetchCompletedTrips() async {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in");
    }
    final DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final Map<String, dynamic>? userData =
        userSnapshot.data() as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception("User data not found");
    }
    final String userName = userData['name'] ?? '';
    final bool isDriver = userData['isDriver'] ?? false;
    Query query = FirebaseFirestore.instance.collection('trips');
    if (isDriver) {
      query = query.where('driverName', isEqualTo: userName);
    }
    query = query.where('status', isEqualTo: 'Trip Completed');
    final QuerySnapshot snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final Map<String, dynamic> tripData = doc.data() as Map<String, dynamic>;
      return {
        "tripId": doc.id,
        "partyName": tripData['partyName'],
        "driverName": tripData['driverName'],
        "vehicleNumber": tripData['vehicleNumber'],
        "fromLocation": tripData['fromLocation'],
        "toLocation": tripData['toLocation'],
        "date": tripData['date'],
        "status": tripData['status'],
        "amount": tripData['amount'],
        "endDate": tripData['endDate'] != null
            ? (tripData['endDate'] as Timestamp).toDate()
            : null, 
      };
    }).toList();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _tripsData = _fetchTrips();
      _tripsCompletedData = _fetchCompletedTrips();
    });
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<Map<String, dynamic>> drivers = [];
  String? selected_Driver;

  Future<void> _fetchDrivers() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDriver', isEqualTo: true)
        .get();

    setState(() {
      drivers = snapshot.docs.map((doc) {
        return {
          "name": doc['name'], 
        };
      }).toList();
    });
  }

  void _addNewTrip() async {
    if (selected_Driver == null ||
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

    final newTrip = {
      "partyName": selectedPartyName.toString(),
      "driverName": selected_Driver.toString(),
      "vehicleNumber": selectedVehicleNumber.toString(),
      "fromLocation": fromLocationController.text,
      "toLocation": toLocationController.text,
      "date":
          "${selectedDate.day} ${_getMonth(selectedDate.month)} ${selectedDate.year}",
      "status": "Trip Started",
      "amount": "${amountController.text}",
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('trips').add(newTrip);
      final partyReportQuery = await FirebaseFirestore.instance
          .collection('partyreport')
          .where('partyName', isEqualTo: selectedPartyName)
          .get();

      if (partyReportQuery.docs.isNotEmpty) {
        DocumentSnapshot existingParty = partyReportQuery.docs.first;
        double currentAmount =
            double.parse(existingParty['amount'].replaceAll('₹ ', ''));
        double newAmount = currentAmount +
            double.parse(amountController.text.replaceAll('₹ ', ''));

        await FirebaseFirestore.instance
            .collection('partyreport')
            .doc(existingParty.id)
            .update({
          'amount': '₹ $newAmount',
        });
      } else {
        await FirebaseFirestore.instance.collection('partyreport').add({
          'partyName': selectedPartyName.toString(),
          'amount': '₹ ${amountController.text}',
        });
      }

      vehicleNumberController.clear();
      fromLocationController.clear();
      toLocationController.clear();
      amountController.clear();
      selectedPartyName = null;
      selected_Driver = null;
      selectedVehicleNumber = null;

      Navigator.pop(context); 
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context)
                .pop(true); 
          });
          return AlertDialog(
            content: Text('Trip successfully added!'),
          );
        },
      );
    } catch (e) {
      print("Error adding trip: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context)
                .pop(true); // Close the error dialog after 2 seconds
          });
          return AlertDialog(
            content: Text('Failed to add trip'),
          );
        },
      );
    }
  }

  List<Map<String, dynamic>> _filterTrips(List<Map<String, dynamic>> trips) {
    final searchQuery = searchController.text.toLowerCase();
    return trips.where((trip) {
      return trip['partyName'].toString().toLowerCase().contains(searchQuery) ||
          trip['driverName'].toString().toLowerCase().contains(searchQuery) ||
          trip['fromLocation'].toString().toLowerCase().contains(searchQuery) ||
          trip['toLocation'].toString().toLowerCase().contains(searchQuery) ||
          trip['vehicleNumber'].toString().toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
    _tripsData = _fetchTrips();
    _tripsCompletedData = _fetchCompletedTrips();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            title: const Text(
              'Trip Manager',
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: 'Search trips...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: _showFilterSheet,
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    indicatorColor: AppColors.primaryColor,
                    labelColor: AppColors.primaryColor,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    tabs: [
                      Tab(text: 'Assigned'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddTripSheet,
            icon: Icon(Icons.add),
            label: Text("Add Trip"),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.accentColor,
          ),
          body: TabBarView(
            children: [
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _tripsData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching trips.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No trips available.'));
                  } else {
                    final trips = snapshot.data!;
                    final filteredTrips = _filterTrips(trips);

                    return RefreshIndicator(
                      onRefresh: _loadTrips,
                      child: filteredTrips.isEmpty
                          ? Center(child: Text('No matching trips found'))
                          : ListView.builder(
                              itemCount: filteredTrips.length,
                              itemBuilder: (context, index) {
                                final trip = filteredTrips[index];
                                return TripCard(trip: trip);
                              },
                            ),
                    );
                  }
                },
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _tripsCompletedData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching trips.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No completed trips available.'));
                  } else {
                    final trips = snapshot.data!;
                    final filteredTrips = _filterTrips(trips);

                    return RefreshIndicator(
                      onRefresh: _loadTrips,
                      child: filteredTrips.isEmpty
                          ? Center(child: Text('No matching trips found'))
                          : ListView.builder(
                              itemCount: filteredTrips.length,
                              itemBuilder: (context, index) {
                                final trip = filteredTrips[index];
                                return TripCard(trip: trip);
                              },
                            ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTripSheet() async {
    vehicleNumberController.clear();
    fromLocationController.clear();
    toLocationController.clear();
    amountController.clear();
    selected_Driver = null;
    selectedPartyName = null; 
    selectedDate = DateTime.now(); 

    List<String> vehicleNumbers = [];
    List<String> partyNames = [];
    bool isDriver = false; 

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          isDriver = userDoc['isDriver'] ?? false;
        }
      }

      QuerySnapshot vehicleSnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();
      vehicleNumbers = vehicleSnapshot.docs
          .map((doc) => doc['registration'].toString())
          .toList();

      QuerySnapshot partySnapshot =
          await FirebaseFirestore.instance.collection('partydetails').get();
      partyNames =
          partySnapshot.docs.map((doc) => doc['partyName'].toString()).toList();
    } catch (e) {
      print("Error fetching data: $e");
    }

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
                  "Add New Trip",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    return partyNames.where((party) {
                      return party.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    }).toList();
                  },
                  onSelected: (String selected) {
                    setState(() {
                      selectedPartyName =
                          selected; // Set the selected party name
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

                // DropdownButton for selecting driver
                DropdownButtonFormField<String>(
                  value: selected_Driver,
                  hint: Text('Select Driver'),
                  items: drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver['name'],
                      child: Text(driver['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selected_Driver = value; // Update the selected driver
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Driver Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // DropdownButton for selecting vehicle number from Firestore
                DropdownButtonFormField<String>(
                  value: selectedVehicleNumber,
                  hint: Text('Select Vehicle Number'),
                  items: vehicleNumbers.map((number) {
                    return DropdownMenuItem<String>(
                      value: number,
                      child: Text(number),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleNumber =
                          value; // Update the selected vehicle number
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Vehicle Number',
                    border: OutlineInputBorder(),
                  ),
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // Date Picker
                ListTile(
                  title: Text("Select Date"),
                  subtitle: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isDriver
                          ? null // Disable button for drivers
                          : _addNewTrip, // Enable only for non-drivers
                      child: Text("Add Trip"),
                    ),
                  ],
                ),
                if (isDriver) // Optional: Show a message if the user is a driver
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Drivers are not allowed to add trips.",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Filter Trips",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text("Amount Range"),
                  RangeSlider(
                    values: amountRange,
                    min: 1000,
                    max: 50000,
                    divisions: 10,
                    labels: RangeLabels(
                      amountRange.start.round().toString(),
                      amountRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        amountRange = values;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Select Driver"),
                  DropdownButton<String>(
                    value: selectedDriver,
                    items: DummyData.users
                        .where((user) => user.role == 'driver')
                        .map((user) {
                      return DropdownMenuItem<String>(
                        value: user.name,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedDriver = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Select Vehicle"),
                  DropdownButton<String>(
                    value: selectedVehicle,
                    items: DummyData.vehicles.map((vehicle) {
                      return DropdownMenuItem<String>(
                        value: vehicle.vehicleNumber,
                        child: Text(vehicle.vehicleNumber),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedVehicle = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Select Place"),
                  DropdownButton<String>(
                    value: selectedPlace,
                    items: DummyData.routes
                        .map((route) => route.source)
                        .toSet()
                        .map((place) {
                      return DropdownMenuItem<String>(
                        value: place,
                        child: Text(place),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedPlace = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Reset Filters"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Apply Filters"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
