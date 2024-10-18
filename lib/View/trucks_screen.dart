import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';

class TruckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: Icon(Icons.add),
          label: Text("Add Vehicle"),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.accentColor),
      appBar: AppBar(
        backgroundColor: AppColors.accentColor,
        title: Text('Your Vehicles'),
      ),
      body: ListView.builder(
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        vehicles[index]['registration']!,
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
                    vehicles[index]['model']!,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Length'),
                      Text(vehicles[index]['length']!),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Width'),
                      Text(vehicles[index]['width']!),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Capacity'),
                      Text(vehicles[index]['capacity']!),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Edit'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
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

  final List<Map<String, String>> vehicles = [
    {
      'registration': 'KL 57 S 5296',
      'model': 'Tata LPT 1916',
      'length': '6m',
      'width': '13m',
      'capacity': '20m'
    },
    {
      'registration': 'MH 12 AB 1234',
      'model': 'Ashok Leyland 2518',
      'length': '7m',
      'width': '14m',
      'capacity': '25m'
    },
    {
      'registration': 'TN 09 CD 5678',
      'model': 'Eicher Pro 3015',
      'length': '5m',
      'width': '12m',
      'capacity': '18m'
    },
  ];
}
