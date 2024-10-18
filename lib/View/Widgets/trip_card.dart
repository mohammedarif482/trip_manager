import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/trip_view_screen.dart';

class TripCard extends StatelessWidget {
  final Map<String, dynamic> tripData;

  const TripCard({Key? key, required this.tripData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripViewScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: AppColors.accentColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      tripData['amount'],
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  tripData['vehicleNumber'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['fromLocation'],
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.arrow_right_alt_rounded),
                    Text(
                      tripData['toLocation'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['date'],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripData['status'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.local_shipping,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
