import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Total Party Balance',
                style: TextStyle(fontSize: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '₹ 15000',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReportsScreen(),
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 30,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text("Reports"),
                        ],
                      ),
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 30,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text("Reports"),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 30,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text("Reports"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Party",
                    style: TextStyle(fontSize: 22),
                  ),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Drivers",
                    style: TextStyle(fontSize: 22),
                  ),
                  Icon(Icons.arrow_right)
                ],
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Vehicles",
                    style: TextStyle(fontSize: 22),
                  ),
                  Icon(Icons.arrow_right)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
