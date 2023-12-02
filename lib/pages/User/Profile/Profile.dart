import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../components/custom_dialog_box.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_widgets.dart';
import '../../Auth/mpin.dart';
import '../../Auth/phone_auth_widget.dart';

class ProfileScreen extends StatelessWidget {
  final String? userName;
  final String? cashBack;
  final String? netBalance;

  String? loginKey;
  ProfileScreen(
      {required this.userName,
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
                        fontFamily: 'Outfit',
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
                fontFamily: 'Outfit',
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
                  '₹ ' + (netBalance ?? "0.0"), context),
              _buildInfoCard(Icons.currency_rupee, "Cashback",
                  '₹ ' + (cashBack ?? "0.0"), context),
              _buildInfoCard(Icons.phone, "Customer Support Number",
                  Constants.adminNo1 + " / " + Constants.adminNo2, context),
              _buildInfoCard(Icons.email, "Customer Support Email",
                  "maakanmoney@gmail.com", context),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 90.w,
                    height: 6.h,
                    child: FFButtonWidget(
                      onPressed: () async {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialogBox(
                                title: "Hi $userName",
                                descriptions:
                                    "Are you sure, Do you want to logout",
                                text: "Ok",
                                isCancel: true,
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  loginKey =
                                      prefs.getString("LoginSuccessuser1");

                                  if (loginKey == null ||
                                      loginKey == "" ||
                                      loginKey!.isEmpty) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyPhone()),
                                      (route) =>
                                          false, // Remove all routes from the stack
                                    );
                                  } else {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String? mPin = prefs.getString("Mpin");
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MpinPageWidget(
                                              getMobileNo: loginKey ?? "",
                                              getMpin: mPin)),
                                      (route) =>
                                          false, // Remove all routes from the stack
                                    );
                                  }
                                },
                              );
                            });
                      },
                      text: "Logout",
                      options: FFButtonOptions(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: GlobalTextStyles.secondaryText2(
                            txtWeight: FontWeight.bold,
                            txtSize: 16,
                            textColor: FlutterFlowTheme.of(context).secondary),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInfoCard(
    IconData iconData, String? title, String? value, BuildContext getContext) {
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
            color: FlutterFlowTheme.of(getContext).primary,
          ),
          SizedBox(height: 8),
          Text(
            title ?? "",
            style: GlobalTextStyles.secondaryText1(
                textColor: Colors.grey, txtWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            value ?? "",
            style: GlobalTextStyles.secondaryText2(
                textColor: FlutterFlowTheme.of(getContext).primary,
                txtWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
  );
}
