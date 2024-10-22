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
          Expanded(
            // To make the GridView take available vertical space
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: [
                  ReportTilteCard(
                    title: "Truck Revenue",
                    icon: Icons.library_books_rounded,
                  ),
                  ReportTilteCard(
                    title: "Party Revenue",
                    icon: Icons.report,
                  ),
                  ReportTilteCard(
                    title: "Party Balance",
                    icon: Icons.report,
                  ),
                  ReportTilteCard(
                    title: "Supplier Balance",
                    icon: Icons.report,
                  ),
                  ReportTilteCard(
                    title: "Transaction Report",
                    icon: Icons.report,
                  ),
                  // ReportTilteCard(title: ""),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportTilteCard extends StatelessWidget {
  const ReportTilteCard({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      // color: const Color.fromARGB(255, 255, 251, 230),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: AppColors.primaryColor,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryColor, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
