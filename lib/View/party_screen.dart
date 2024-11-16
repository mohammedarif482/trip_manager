import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Party Details"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partydetails')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Party Details Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Retrieve and display party details
          final partyDetails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: partyDetails.length,
            itemBuilder: (context, index) {
              final party = partyDetails[index];
              final partyName = party['partyName'] ?? "Unknown";
              final address = party['address'] ?? "No Address";
              final phone = party['phone'] ?? "No Phone";

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    partyName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text("Address: $address"),
                      Text("Phone: $phone"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Delete document from Firestore
                      await FirebaseFirestore.instance
                          .collection('partydetails')
                          .doc(party.id)
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Party deleted successfully"),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show dialog to add new party
          showDialog(
            context: context,
            builder: (context) {
              final partyNameController = TextEditingController();
              final addressController = TextEditingController();
              final phoneController = TextEditingController();

              return AlertDialog(
                title: Text("Add Party"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: partyNameController,
                        decoration: InputDecoration(
                          labelText: "Party Name",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text("Cancel"),
                  ),
                  ElevatedButton(
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
                            ),
                          );
                          Navigator.of(context).pop(); // Close dialog
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to add party: $e"),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please fill all fields!"),
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
        icon: Icon(Icons.add),
        label: Text("Add Party"),
      ),
    );
  }
}
