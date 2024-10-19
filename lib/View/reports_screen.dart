import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(" Reports"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: AppColors.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Truck Revenue\nReport",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: AppColors.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Party Revenue\nReport",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                color: AppColors.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Party Balance\nReport",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: AppColors.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Driver Balance\nReport",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.accentColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
