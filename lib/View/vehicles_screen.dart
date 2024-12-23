import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TruckScreen extends StatefulWidget {
  @override
  State<TruckScreen> createState() => _TruckScreenState();
}

class _TruckScreenState extends State<TruckScreen> {
  TextEditingController searchController = TextEditingController();
  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController lenghtController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController regNumberController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  List<Map<String, String>> vehicles = [];
  Future<List<Map<String, dynamic>>>? _vehiclesData;

  @override
  void initState() {
    super.initState();
    _loadVehicles(); // Initial load of vehicles
  }

  // Function to fetch vehicles from Firestore
  Future<List<Map<String, dynamic>>> _fetchVehicles() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('vehicles').get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id, // Add document ID
        "capacity": doc['capacity'],
        "length": doc['length'],
        "model": doc['model'],
        "registration": doc['registration'],
        "width": doc['width'],
      };
    }).toList();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _vehiclesData = _fetchVehicles(); // Reload vehicles
    });
  }

  Future<void> _deleteVehicle(String documentId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content:
                const Text('Are you sure you want to delete this vehicle?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(documentId)
            .delete();

        await _loadVehicles();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle successfully deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting vehicle: $e')),
      );
    }
  }

  void _showAddVehicle() {
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
                  "Add New Vehicle",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: regNumberController,
                  inputFormatters: [VehicleNumberFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Registration Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: vehicleNameController,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: lenghtController,
                  decoration: InputDecoration(
                    labelText: 'Length',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Width',
                    border: OutlineInputBorder(),
                  ),
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
                      onPressed: () async {
                        final newVehicle = {
                          'registration': regNumberController.text,
                          'model': vehicleNameController.text,
                          'capacity': capacityController.text,
                          'length': lenghtController.text,
                          'width': widthController.text,
                        };

                        await FirebaseFirestore.instance
                            .collection('vehicles')
                            .add(newVehicle);

                        regNumberController.clear();
                        vehicleNameController.clear();
                        capacityController.clear();
                        lenghtController.clear();
                        widthController.clear();

                        await _loadVehicles();

                        Navigator.pop(context);
                      },
                      child: Text("Add Vehicle"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVehicle,
        icon: Icon(Icons.add),
        label: Text("Add Vehicle"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.accentColor,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: Text('Your Vehicles'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _vehiclesData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching vehicles.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No vehicles available.'));
                } else {
                  final vehicles = snapshot.data!;

                  return RefreshIndicator(
                    onRefresh: _loadVehicles, // Swipe down to refresh
                    child: ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicles[index];
                        return Card(
                          elevation: 4,
                          color: AppColors.accentColor,
                          margin: EdgeInsets.all(10),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      vehicle['registration']!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Icon(Icons.local_shipping),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  vehicle['model']!,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Length'),
                                    Text(vehicle['length']!),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Width'),
                                    Text(vehicle['width']!),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Capacity'),
                                    Text(vehicle['capacity']!),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _deleteVehicle(vehicle['id']!),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VehicleNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final regex = RegExp(r'^([A-Z]{0,2})(\d{0,2})([A-Z]{0,2})(\d{0,4})$');
    final match =
        regex.firstMatch(newValue.text.toUpperCase().replaceAll(' ', ''));

    String formattedText = '';
    if (match != null) {
      final part1 = match.group(1) ?? '';
      final part2 = match.group(2) ?? '';
      final part3 = match.group(3) ?? '';
      final part4 = match.group(4) ?? '';

      if (part1.isNotEmpty) formattedText += part1;
      if (part2.isNotEmpty) formattedText += ' $part2';
      if (part3.isNotEmpty) formattedText += ' $part3';
      if (part4.isNotEmpty) formattedText += ' $part4';
    }

    return TextEditingValue(
      text: formattedText.trim(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
