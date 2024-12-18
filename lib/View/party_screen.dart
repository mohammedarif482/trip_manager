import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'partyStatement.dart'; // Import the partyStatement.dart file

class PartyScreen extends StatefulWidget {
  @override
  _PartyScreenState createState() => _PartyScreenState();
}

class _PartyScreenState extends State<PartyScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(_updateSearchQuery);
  }

  // Update the search query when the user types in the search bar
  void _updateSearchQuery() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Party Details",
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.red[700]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Party Name',
                prefixIcon: Icon(Icons.search, color: Colors.red[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('partydetails')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.red[700]),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No Party Details Available",
                      style: TextStyle(fontSize: 18, color: Colors.red[700]),
                    ),
                  );
                }

                final partyDetails = snapshot.data!.docs.where((party) {
                  final partyName = party['partyName']?.toLowerCase() ?? '';
                  return partyName.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: partyDetails.length,
                  itemBuilder: (context, index) {
                    final party = partyDetails[index];
                    final partyName = party['partyName'] ?? "Unknown";
                    final address = party['address'] ?? "No Address";
                    final phone = party['phone'] ?? "No Phone";

                    return GestureDetector(
                      onTap: () {
                        // Navigate to PartyStatement when the party card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PartyStatement(partyName: partyName),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.business, color: Colors.red[700]),
                                  SizedBox(width: 8),
                                  Text(
                                    partyName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.red[700]),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.phone, color: Colors.red[700]),
                                  SizedBox(width: 8),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red[700]),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('partydetails')
                                        .doc(party.id)
                                        .delete();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Party deleted successfully"),
                                        backgroundColor: Colors.red[700],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final partyNameController = TextEditingController();
              final addressController = TextEditingController();
              final phoneController = TextEditingController();

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  "Add Party",
                  style: TextStyle(color: Colors.red[700]),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: partyNameController,
                        decoration: InputDecoration(
                          labelText: "Party Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel", style: TextStyle(color: Colors.red[700])),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final partyName = partyNameController.text.trim();
                      final address = addressController.text.trim();
                      final phone = phoneController.text.trim();

                      if (partyName.isNotEmpty &&
                          address.isNotEmpty &&
                          phone.isNotEmpty) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('partydetails')
                              .add({
                            'partyName': partyName,
                            'address': address,
                            'phone': phone,
                            'timestamp': FieldValue.serverTimestamp(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Party added successfully!"),
                              backgroundColor: Colors.red[700],
                            ),
                          );
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add party: $e"),
                              backgroundColor: Colors.red[700],
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please fill all fields!"),
                            backgroundColor: Colors.red[700],
                          ),
                        );
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Colors.red[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Party",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
