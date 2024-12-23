import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:tripmanager/View/reports_screen.dart';
import 'package:tripmanager/View/vehicles_screen.dart';
import 'package:tripmanager/View/party_screen.dart';
import 'package:tripmanager/View/drivers_screen.dart';
import 'package:tripmanager/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  num totalPartyBalance = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPartyBalance();
  }

  Future<void> _fetchPartyBalance() async {
    num totalBalance = 0;

    final partyReportSnapshot =
        await FirebaseFirestore.instance.collection('partyreport').get();

    for (var partyDoc in partyReportSnapshot.docs) {
      final partyName = partyDoc['partyName'];

      final tripsSnapshot = await FirebaseFirestore.instance
          .collection('trips')
          .where('partyName', isEqualTo: partyName)
          .get();

      for (var tripDoc in tripsSnapshot.docs) {
        final tripData = tripDoc.data();

        final num amount = num.tryParse(tripData['amount'] ?? '0') ?? 0;
        final num advanceAmount =
            num.tryParse(tripData['advanceAmount'] ?? '0') ?? 0;

        num paymentsTotal = 0;
        if (tripData['payments'] != null) {
          for (var payment in tripData['payments']) {
            paymentsTotal += num.tryParse(payment['amount'] ?? '0') ?? 0;
          }
        }

        totalBalance += amount - (advanceAmount + paymentsTotal);
      }
    }

    setState(() {
      totalPartyBalance = totalBalance;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Total Party Balance',
                style: TextStyle(fontSize: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      '₹ ${NumberFormat.currency(locale: 'en_IN', symbol: '').format(totalPartyBalance)}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
            ),
            const SizedBox(height: 10),
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
                          SizedBox(height: 16),
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
                        SizedBox(height: 16),
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
                        SizedBox(height: 16),
                        Text("Reports"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // if (AuthCheck.isDriver == false)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PartyScreen(),
                  ),
                );
              },
              child: Container(
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
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DriversScreen(), // Navigate to DriversScreen
                  ),
                );
              },
              child: Container(
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
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TruckScreen(),
                  ),
                );
              },
              child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
