import 'package:flutter/material.dart';
import 'package:tripmanager/Utils/constants.dart';
import 'package:easy_stepper/easy_stepper.dart';

class TripViewScreen extends StatelessWidget {
  const TripViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('Trip Detail'),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: AppColors.primaryColor,
                    labelColor: AppColors.primaryColor,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    tabs: [
                      Tab(text: 'Party'),
                      Tab(text: 'Profit'),
                      Tab(text: 'Driver'),
                      Tab(text: 'More'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              PartyDetail(),
              Container(
                child: Center(
                  child: Text("Profit"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("Driver"),
                ),
              ),
              Container(
                child: Center(
                  child: Text("More"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PartyDetail extends StatefulWidget {
  const PartyDetail({
    super.key,
  });

  @override
  State<PartyDetail> createState() => _PartyDetailState();
}

int activeStep = 1;

class _PartyDetailState extends State<PartyDetail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // StepperDemo(),
        EasyStepper(
          activeStep: activeStep,

          activeStepTextColor: Colors.black87,
          finishedStepTextColor: Colors.black87,
          internalPadding: 0,
          showLoadingAnimation: false,
          stepRadius: 8,
          showStepBorder: false,
          //  lineDotRadius: 1.5,
          steps: [
            EasyStep(
              customStep: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      activeStep >= 0 ? Colors.orange : Colors.white,
                ),
              ),
              title: 'Waiting',
            ),
            EasyStep(
              customStep: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor:
                      activeStep >= 1 ? Colors.orange : Colors.white,
                ),
              ),
              title: 'Order Received',
              topTitle: true,
            ),
            EasyStep(
              customStep: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor:
                      activeStep >= 2 ? Colors.orange : Colors.white,
                ),
              ),
              title: 'Preparing',
            ),
            EasyStep(
              customStep: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor:
                      activeStep >= 3 ? Colors.orange : Colors.white,
                ),
              ),
              title: 'On Way',
              topTitle: true,
            ),
            EasyStep(
              customStep: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 7,
                  backgroundColor:
                      activeStep >= 4 ? Colors.orange : Colors.white,
                ),
              ),
              title: 'Delivered',
            ),
          ],
          onStepReached: (index) => setState(() => activeStep = index),
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Complete Trip',
                  style: TextStyle(color: AppColors.secondaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'View Bill',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Financial Details
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAmountRow('Freight Amount', '₹15,000', true),
                _buildAmountRow('(-) Advance', '₹0', false),
                const SizedBox(height: 4),
                _buildActionLink('Add Advance'),
                _buildAmountRow('(+) Charges', '₹0', false),
                const SizedBox(height: 4),
                _buildActionLink('Add Charges'),
                _buildAmountRow('(-) Payments', '₹0', false),
                const SizedBox(height: 4),
                _buildActionLink('Add Payment'),
                const Divider(height: 32),
                _buildAmountRow('Pending Balance', '₹15,000', false),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Note'),
                      style: TextButton.styleFrom(
                        foregroundColor:AppColors.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color:AppColors.primaryColor),
                      ),
                      child: const Text('Request Money'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Add Load Button
        InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Text(
                  'Add load to this Trip',
                  style: TextStyle(
                    color:AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Icon(Icons.chevron_right, color:AppColors.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildAmountRow(String label, String amount, bool isEditable) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            Text(amount),
            if (isEditable) ...[
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 16, color:AppColors.primaryColor),
            ],
          ],
        ),
      ],
    ),
  );
}

Widget _buildActionLink(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(text, style: const TextStyle(color: AppColors.primaryColor)),
    ),
  );
}
