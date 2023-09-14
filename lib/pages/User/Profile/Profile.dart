import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maaakanmoney/components/constants.dart';

import '../../../flutter_flow/flutter_flow_theme.dart';

class ProfileScreen extends StatelessWidget {
  final String? userName;
  final String? greetingText;
  final String? cashBack;
  final String? netBalance;

  ProfileScreen(
      {required this.userName,
      required this.greetingText,
      required this.cashBack,
      required this.netBalance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: true,
        toolbarHeight: 90,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                // text: 'Hi..! ',
                children: [
                  TextSpan(
                    text: userName,
                    style: const TextStyle(
                        fontSize: 23.0,
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1),
                  ),
                ],
              ),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontSize: 23.0,
                letterSpacing: 1.0,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              greetingText ?? "",
              style: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(Icons.account_balance_wallet, "Net Balance",
                  '₹ ' + (netBalance ?? "0.0")),
              _buildInfoCard(
                  Icons.currency_rupee, "Cashback", '₹ ' + (cashBack ?? "0.0")),
              _buildInfoCard(Icons.phone, "Customer Support Number",
                  Constants.adminNo1 + " / " + Constants.adminNo2),
              _buildInfoCard(Icons.email, "Customer Support Email",
                  "maakanmoney@gmail.com"),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInfoCard(IconData iconData, String? title, String? value) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            iconData,
            size: 40,
            color: Colors.blueGrey,
          ),
          SizedBox(height: 8),
          Text(
            title ?? "",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            value ?? "",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}
