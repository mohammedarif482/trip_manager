import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripmanager/Model/temp_data.dart';
import 'package:tripmanager/Model/trip_model.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/Widgets/trip_card.dart';

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

  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController fromLocationController = TextEditingController();
  final TextEditingController toLocationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController partyController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    filteredTrips = _convertTripsToMap(DummyData.trips);
    _fetchDrivers();
  }

  List<Map<String, dynamic>> _convertTripsToMap(List<Trip> trips) {
    return trips.map((trip) {
      final driver =
          DummyData.users.firstWhere((user) => user.userId == trip.driverId);
      final vehicle =
          DummyData.vehicles.firstWhere((v) => v.vehicleId == trip.vehicleId);
      final route =
          DummyData.routes.firstWhere((r) => r.routeId == trip.routeId);

      return {
        "name": driver.name,
        "vehicleNumber": vehicle.vehicleNumber,
        "fromLocation": route.source,
        "toLocation": route.destination,
        "date":
            "${trip.startDate.day} ${_getMonth(trip.startDate.month)} ${trip.startDate.year}",
        "status": trip.status == 'in_progress'
            ? 'Trip In Progress'
            : trip.status == 'completed'
                ? 'Trip Completed'
                : trip.status == 'pending'
                    ? 'Trip Started'
                    : 'Trip Cancelled',
        "amount": "₹ ${trip.amount.toString()}",
      };
    }).toList();
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

  List<Map<String, dynamic>> drivers = []; // List to hold drivers
  String? selected_Driver; // The selected driver

  Future<void> _fetchDrivers() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('isDriver',
            isEqualTo: true) // Only get documents where isDriver == true
        .get();

    setState(() {
      drivers = snapshot.docs.map((doc) {
        return {
          "name": doc['name'], // Get the driver's name from the document
        };
      }).toList();
    });
  }

 void _addNewTrip() async {
  if (selectedDriver == null || // Check if driver is selected
      vehicleNumberController.text.isEmpty ||
      fromLocationController.text.isEmpty ||
      toLocationController.text.isEmpty ||
      amountController.text.isEmpty ||
      partyController.text.isEmpty) {  // Added party name check
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  // Create new trip in the format expected by Firestore
  final newTrip = {
    "partyName": partyController.text,  // Party name
    "driverName": selectedDriver, // Make sure this is a string
    "vehicleNumber": vehicleNumberController.text,
    "fromLocation": fromLocationController.text,
    "toLocation": toLocationController.text,
    "date":
        "${selectedDate.day} ${_getMonth(selectedDate.month)} ${selectedDate.year}",
    "status": "Trip Started",
    "amount": "₹ ${amountController.text}",
    "createdAt": FieldValue.serverTimestamp(), // Add a timestamp
  };

  // Store the new trip in Firestore
  try {
    await FirebaseFirestore.instance.collection('trips').add(newTrip);

    setState(() {
      filteredTrips.insert(0, newTrip); // Optionally update the local list
    });

    // Clear controllers after successful storage
    vehicleNumberController.clear();
    fromLocationController.clear();
    toLocationController.clear();
    amountController.clear();
    partyController.clear();
    selectedDriver = null;

    // Close the dialog after adding the trip
    Navigator.pop(context); 

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip added successfully')),
    );
  } catch (e) {
    // Handle error (you may choose to log it)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding trip: $e')),
    );
  }
}





  void _showAddTripSheet() {
  // Clear previous values before showing the dialog
  vehicleNumberController.clear();
  fromLocationController.clear();
  toLocationController.clear();
  amountController.clear();
  partyController.clear();
  selectedDriver = null;
  selectedDate = DateTime.now(); // Reset to the current date if needed

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
              TextField(
                controller: partyController,
                decoration: InputDecoration(
                  labelText: 'Party Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // DropdownButton for selecting driver
              DropdownButtonFormField<String>(
                value: selectedDriver, // Keep track of the selected driver
                hint: Text('Select Driver'),
                items: drivers.map((driver) {
                  return DropdownMenuItem<String>(
                    value: driver['name'], // The driver name
                    child: Text(driver['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDriver = value; // Update the selected driver
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Driver Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: vehicleNumberController,
                decoration: InputDecoration(
                  labelText: 'Vehicle Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: fromLocationController,
                decoration: InputDecoration(
                  labelText: 'From Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: toLocationController,
                decoration: InputDecoration(
                  labelText: 'To Location',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text("Select Date"),
                subtitle: Text(
                  "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _addNewTrip,
                    child: Text("Add Trip"),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}




  void _searchTrips(String query) {
    final results = _convertTripsToMap(DummyData.trips).where((trip) {
      final name = trip['name'].toString().toLowerCase();
      final vehicleNumber = trip['vehicleNumber'].toString().toLowerCase();
      final fromLocation = trip['fromLocation'].toString().toLowerCase();
      final toLocation = trip['toLocation'].toString().toLowerCase();
      final date = trip['date'].toString().toLowerCase();
      final status = trip['status'].toString().toLowerCase();
      final amount = trip['amount'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) ||
          vehicleNumber.contains(searchQuery) ||
          fromLocation.contains(searchQuery) ||
          toLocation.contains(searchQuery) ||
          date.contains(searchQuery) ||
          status.contains(searchQuery) ||
          amount.contains(searchQuery);
    }).toList();

    setState(() {
      filteredTrips = results;
    });
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
                          _resetFilters();
                          Navigator.pop(context);
                        },
                        child: Text("Reset Filters"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _applyFilters();
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

  void _resetFilters() {
    setState(() {
      amountRange = RangeValues(1000, 50000);
      selectedDriver = null;
      selectedVehicle = null;
      selectedPlace = null;
      filteredTrips = _convertTripsToMap(DummyData.trips);
    });
  }

  void _applyFilters() {
    final filtered = _convertTripsToMap(DummyData.trips).where((trip) {
      final tripAmount =
          int.parse(trip['amount'].replaceAll(RegExp(r'[^\d]'), ''));
      final inAmountRange =
          tripAmount >= amountRange.start && tripAmount <= amountRange.end;

      final matchesDriver =
          selectedDriver == null || trip['name'] == selectedDriver;
      final matchesVehicle =
          selectedVehicle == null || trip['vehicleNumber'] == selectedVehicle;
      final matchesPlace =
          selectedPlace == null || trip['fromLocation'] == selectedPlace;

      return inAmountRange && matchesDriver && matchesVehicle && matchesPlace;
    }).toList();

    setState(() {
      filteredTrips = filtered;
    });
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
            title: GestureDetector(
              // onTap: () {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(builder: (context) => CustomStepper()),
              //   );
              // },
              child: Text(
                'Trip Manager',
              ),
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
                            onChanged: _searchTrips,
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
              ListView.builder(
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  return TripCard(tripData: filteredTrips[index]);
                },
              ),
              ListView.builder(
                itemCount: filteredTrips.length,
                itemBuilder: (context, index) {
                  return TripCard(tripData: filteredTrips[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
