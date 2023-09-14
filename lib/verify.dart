// ignore_for_file: use_build_context_synchronously, unused_import, must_be_immutable, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/components/custom_dialog_box.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_theme.dart';
import 'package:maaakanmoney/main.dart';
import 'package:maaakanmoney/pages/User/Userscreen_widget.dart';
import 'package:maaakanmoney/pages/budget_copy/budget_copy_widget.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maaakanmoney/phoneController.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyVerify extends ConsumerStatefulWidget {
  MyVerify({
    Key? key,
    @required this.getMobile,
  }) : super(key: key);
  String? getMobile;
  @override
  ConsumerState<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends ConsumerState<MyVerify> {
  var verifycode = "";
  ConnectivityResult? data;
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController _mpinController = TextEditingController();
  TextEditingController _confirmMpinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        data = ref.watch(connectivityProvider);
        ref.watch(isOtpSent);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
              ),
            ),
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 25, right: 25),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/img1.png',
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        const Text(
                          "Phone Verification",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Call Admin and get Security Code to get started!",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        IgnorePointer(
                          ignoring: ref.read(isOtpSent.notifier).state == true
                              ? true
                              : false,
                          child: Pinput(
                            length: 6,
                            showCursor: true,
                            onCompleted: (pin) => print(pin),
                            onChanged: (value) {
                              verifycode = value;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(
                                          data == ConnectivityResult.none
                                              ? 0xFFCCCFD5
                                              : 0xFF0B4D40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: () => verifyOtp(),
                                  child: const Text("Verify Security Code")),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(
                                          data == ConnectivityResult.none
                                              ? 0xFFCCCFD5
                                              : 0xFF0B4D40),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: () async {
                                    final Uri launchUri = Uri(
                                      scheme: 'tel',
                                      path: Constants.adminNo2,
                                    );
                                    await launchUrl(launchUri);
                                  },
                                  child: const Text("Call Admin"))
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    'phone',
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  "Edit Phone Number ?",
                                  style: TextStyle(color: Colors.white),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                ref.read(isOtpSent.notifier).state == true
                    ? const IgnorePointer(
                        ignoring: true,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          content: SizedBox(
                              height: 80,
                              width: 50,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                          child: CircularProgressIndicator(
                                        color: Color(0xFF004D40),
                                      )),
                                    ],
                                  ),
                                  Text(
                                    "Loading",
                                    style: TextStyle(
                                        color: Color(0xFF004D40),
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    if (verifycode.isNotEmpty) {
      if (verifycode.length < 6) {
        Constants.showToast("Please enter a Valid OTP", ToastGravity.BOTTOM);
      } else {
        ref.read(isOtpSent.notifier).state = true;

        final otp = verifycode.trim();

        int? getSecurityCode =
            await isUserVerified(widget.getMobile.toString());

        ref.read(isOtpSent.notifier).state = false;
        if (otp == getSecurityCode.toString()) {
          showDialog(
            context: context,
            builder: (context) => SetMpinDialog(
              getMobile: widget.getMobile,
            ),
          );
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return CustomDialogBox(
                  title: "Alert!",
                  descriptions: "You Entered Invalid Security Code",
                  text: "Ok",
                  isCancel: false,
                  onTap: () {
                    Navigator.of(context).pop();
                    ref.read(isOtpSent.notifier).state = false;
                  },
                );
              });
        }
      }
    } else {
      Constants.showToast("Please enter a Security Code", ToastGravity.BOTTOM);
    }
  }

  Future<int?> isUserVerified(String? phoneNumber) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('mobile', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Phone number does not exist in the Firestore table
      return 000000;
    }

    var user = querySnapshot.docs.first.data() as Map<String, dynamic>?;
    int getUser = user?['securityCode'];
    return getUser;
  }
}

class SetMpinDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<SetMpinDialog> createState() => _SetMpinDialogState();

  SetMpinDialog({
    Key? key,
    @required this.getMobile,
  }) : super(key: key);
  String? getMobile;
}

class _SetMpinDialogState extends ConsumerState<SetMpinDialog> {
  TextEditingController _mpinController = TextEditingController();
  TextEditingController _confirmMpinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set MPIN'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            maxLength: 4,
            controller: _mpinController,
            decoration:
                InputDecoration(labelText: 'Enter MPIN', counterText: ''),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
          TextField(
            maxLength: 4,
            controller: _confirmMpinController,
            decoration:
                InputDecoration(labelText: 'Confirm MPIN', counterText: ''),
            keyboardType: TextInputType.number,
            obscureText: true,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            String mpin = _mpinController.text;
            String confirmMpin = _confirmMpinController.text;

            // Validate MPIN and Confirm MPIN
            if (mpin.isEmpty || mpin.length != 4 || mpin != confirmMpin) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(mpin.length != 4
                      ? 'Please Set four Digit Mpin.'
                      : mpin != confirmMpin
                          ? 'MPIN Mismatched.'
                          : 'Invalid MPIN. Please try again.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              // Save the MPIN to Firestore or any other action
              SharedPreferences prefs1 = await SharedPreferences.getInstance();
              prefs1.setString("Mpin", confirmMpin);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("LoginSuccessuser1", widget.getMobile.toString());
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => BudgetWidget(
              //       getMobile: widget.getMobile,
              //     ),
              //   ),
              // );

              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 600),
                  pageBuilder: (_, __, ___) => BudgetWidget(
                    getMobile: widget.getMobile,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.0, // You can adjust the start scale
                        end: 1.0, // You can adjust the end scale
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            }
          },
          child: Text('Set MPIN'),
        ),
      ],
    );
  }
}
