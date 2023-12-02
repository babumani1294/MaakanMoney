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
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import 'flutter_flow/flutter_flow_widgets.dart';

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
  List<int> passcode = [];

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
                color: Colors.transparent,
              ),
            ),
            elevation: 0,
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FlutterFlowTheme.of(context).primary1,
                        FlutterFlowTheme.of(context).primary2
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   'assets/images/img1.png',
                      //   width: 150,
                      //   height: 150,
                      // ),
                      // const SizedBox(
                      //   height: 25,
                      // ),
                      // const Text(
                      //   "Phone Verification",
                      //   style: TextStyle(
                      //       fontSize: 22, fontWeight: FontWeight.bold),
                      // ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // const Text(
                      //   "Call Admin and get Security Code to get started!",
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      // const SizedBox(
                      //   height: 30,
                      // ),
                      // IgnorePointer(
                      //   ignoring: ref.read(isOtpSent.notifier).state == true
                      //       ? true
                      //       : false,
                      //   child: Pinput(
                      //     length: 6,
                      //     showCursor: true,
                      //     onCompleted: (pin) => print(pin),
                      //     onChanged: (value) {
                      //       verifycode = value;
                      //     },
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 20,
                      // ),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: Column(
                      //     children: [
                      //       ElevatedButton(
                      //           style: ElevatedButton.styleFrom(
                      //               backgroundColor: Color(
                      //                   data == ConnectivityResult.none
                      //                       ? 0xFFCCCFD5
                      //                       : 0xFF0B4D40),
                      //               shape: RoundedRectangleBorder(
                      //                   borderRadius:
                      //                       BorderRadius.circular(10))),
                      //           onPressed: () => verifyOtp(),
                      //           child: const Text("Verify Security Code")),
                      //       ElevatedButton(
                      //           style: ElevatedButton.styleFrom(
                      //               backgroundColor: Color(
                      //                   data == ConnectivityResult.none
                      //                       ? 0xFFCCCFD5
                      //                       : 0xFF0B4D40),
                      //               shape: RoundedRectangleBorder(
                      //                   borderRadius:
                      //                       BorderRadius.circular(10))),
                      //           onPressed: () async {
                      //             final Uri launchUri = Uri(
                      //               scheme: 'tel',
                      //               path: Constants.adminNo2,
                      //             );
                      //             await launchUrl(launchUri);
                      //           },
                      //           child: const Text("Call Admin"))
                      //     ],
                      //   ),
                      // ),
                      // Row(
                      //   children: [
                      //     TextButton(
                      //         onPressed: () {
                      //           Navigator.pushNamedAndRemoveUntil(
                      //             context,
                      //             'phone',
                      //             (route) => false,
                      //           );
                      //         },
                      //         child: const Text(
                      //           "Edit Phone Number ?",
                      //           style: TextStyle(color: Colors.white),
                      //         ))
                      //   ],
                      // )
                      Expanded(
                        flex: 5,
                        child: Stack(children: [
                          SizedBox(
                            child: Container(
                              decoration:
                                  BoxDecoration(color: Colors.transparent),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Stack(children: [
                                        Image.asset(
                                          'images/final/SecurityCode/Security.png',
                                        ),
                                      ]),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 20.0, right: 0),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Stack(children: [
                                          Text(
                                            "Security Code",
                                            style:
                                                GlobalTextStyles.primaryText2(
                                              textColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondary,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),

                      Expanded(
                        flex: 6,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100.w /
                                      2), // Bottom-left corner is rounded
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Colors.transparent,
                                height: 40.h,
                                width: 80.w,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(4, (rowIndex) {
                                    if (rowIndex == 3) {
                                      // Last row with 0
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List.generate(3, (colIndex) {
                                          int index = rowIndex * 3 + colIndex;
                                          if (index == 9) {
                                            return GestureDetector(
                                              onTap: () async {
                                                final Uri launchUri = Uri(
                                                  scheme: 'tel',
                                                  path: Constants.adminNo2,
                                                );
                                                await launchUrl(launchUri);
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Icon(
                                                  Icons.call,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          } else if (index == 11) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (passcode.isNotEmpty) {
                                                  setState(() {
                                                    passcode.removeLast();
                                                  });
                                                }
                                              },
                                              child: Container(
                                                height: 50,
                                                width: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                ),
                                                child: Icon(
                                                  Icons.clear,
                                                  size: 20,
                                                ),
                                              ),
                                            );
                                          }
                                          return GestureDetector(
                                            onTap: () {
                                              print(
                                                  'Digit tapped: ${index == 10 ? 0 : index + 1}');

                                              if (passcode.length < 6) {
                                                ref
                                                            .read(isOtpSent
                                                                .notifier)
                                                            .state ==
                                                        true
                                                    ? () {}()
                                                    : setState(() {
                                                        passcode.add(index == 10
                                                            ? 0
                                                            : index + 1);
                                                        if (passcode.length ==
                                                            6) {
                                                          print(
                                                              'Passcode: $passcode');

                                                          String finalSecCode =
                                                              passcode.join('');

                                                          verifyOtp(
                                                              finalSecCode ??
                                                                  "");
                                                        }
                                                      });
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    spreadRadius: 8,
                                                    blurRadius: 5,
                                                    offset: Offset(0,
                                                        3), // changes the position of the shadow
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                index == 10
                                                    ? '0'
                                                    : '${index + 1}', // 0 for the last cell
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    } else {
                                      // Regular rows
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List.generate(3, (colIndex) {
                                          int index = rowIndex * 3 + colIndex;
                                          return GestureDetector(
                                            onTap: () {
                                              print(
                                                  'Digit tapped: ${index == 10 ? 0 : index + 1}');
                                              if (passcode.length < 6) {
                                                ref
                                                            .read(isOtpSent
                                                                .notifier)
                                                            .state ==
                                                        true
                                                    ? () {}()
                                                    : setState(() {
                                                        passcode.add(index == 10
                                                            ? 0
                                                            : index + 1);
                                                        if (passcode.length ==
                                                            6) {
                                                          print(
                                                              'Passcode: $passcode');
                                                          String finalSecCode =
                                                              passcode.join('');

                                                          verifyOtp(
                                                              finalSecCode ??
                                                                  "");
                                                        }
                                                      });
                                              }
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 50,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    spreadRadius: 8,
                                                    blurRadius: 5,
                                                    offset: Offset(3,
                                                        4), // changes the position of the shadow
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                '${index + 1}', // Index starts from 0, so add 1
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                          );
                                        }),
                                      );
                                    }
                                  }),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 50.0, right: 0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(6, (index) {
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: index < passcode.length
                                              ? FlutterFlowTheme.of(context)
                                                  .primary1
                                              : Colors.transparent,
                                          border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary2),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              // Add more Positioned widgets for additional images
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Future<void> verifyOtp(String? getFinalSecCode) async {
    FocusScope.of(context).unfocus();

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    if (getFinalSecCode!.isNotEmpty) {
      if (getFinalSecCode!.length < 6) {
        Constants.showToast("Please enter a Valid OTP", ToastGravity.BOTTOM);
      } else {
        ref.read(isOtpSent.notifier).state = true;

        final otp = getFinalSecCode.trim();

        int? getSecurityCode =
            await isUserVerified(widget.getMobile.toString());

        ref.read(isOtpSent.notifier).state = false;
        if (otp == getSecurityCode.toString()) {
          // showDialog(
          //   context: context,
          //   builder: (context) => SetMpinDialog(
          //     getMobile: widget.getMobile,
          //   ),
          // );

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => MpinSetUp(
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
        } else {
          if (passcode.isNotEmpty) {
            setState(() {
              passcode.clear();
            });
          }
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

//todo:- 15.11.23 Mpin setup screen

class MpinSetUp extends ConsumerStatefulWidget {
  MpinSetUp({
    Key? key,
    @required this.getMobile,
  }) : super(key: key);
  String? getMobile;

  @override
  MpinSetUpState createState() => MpinSetUpState();
}

class MpinSetUpState extends ConsumerState<MpinSetUp> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController _mpinController = TextEditingController();
  TextEditingController _confirmMpinController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(children: [
            Form(
                key: formKey,
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Maaka",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          color: FlutterFlowTheme.of(context)
                                              .primary1,
                                        ),
                                      ),
                                    ),

                                    // Add more Positioned widgets for additional images
                                  ),
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0, right: 0),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "Set MPin",
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Add more Positioned widgets for additional images
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(height: 16.0),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: _mpinController,
                                      obscureText: true,
                                      onChanged: (value) {},
                                      decoration: InputDecoration(
                                        labelText: "Enter MPin",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                      ),
                                      style: TextStyle(
                                          letterSpacing: 1, fontSize: 16),
                                      maxLength: 4,
                                    ),
                                    SizedBox(height: 16.0),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      controller: _confirmMpinController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: "Confirm MPin",
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(14.0),
                                        ),
                                        filled: false,
                                        fillColor: Colors.grey.shade50,
                                      ),
                                      style: TextStyle(
                                          letterSpacing: 1, fontSize: 16),
                                      maxLength: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Stack(alignment: Alignment.center, children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Align(
                                        alignment: Alignment.topCenter,
                                        child: SizedBox(
                                          width: 50.w,
                                          height: 6.h,
                                          child: IgnorePointer(
                                            ignoring: isOtpSent == true
                                                ? true
                                                : false,
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                String mpin =
                                                    _mpinController.text;
                                                String confirmMpin =
                                                    _confirmMpinController.text;

                                                // Validate MPIN and Confirm MPIN
                                                if (mpin.isEmpty ||
                                                    mpin.length != 4 ||
                                                    mpin != confirmMpin) {
                                                  showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CustomDialogBox(
                                                          title: "Message!",
                                                          descriptions: mpin
                                                                      .length !=
                                                                  4
                                                              ? 'Please Set four Digit Mpin.'
                                                              : mpin !=
                                                                      confirmMpin
                                                                  ? 'MPIN Mismatched.'
                                                                  : 'Invalid MPIN. Please try again.',
                                                          text: "Ok",
                                                          isCancel: false,
                                                          onTap: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        );
                                                      });
                                                } else {
                                                  // Save the MPIN to Firestore or any other action
                                                  SharedPreferences prefs1 =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs1.setString(
                                                      "Mpin", confirmMpin);
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.setString(
                                                      "LoginSuccessuser1",
                                                      widget.getMobile
                                                          .toString());
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
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  600),
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              BudgetWidget1(
                                                        getMobile:
                                                            widget.getMobile,
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return ScaleTransition(
                                                          scale: Tween<double>(
                                                            begin:
                                                                0.0, // You can adjust the start scale
                                                            end:
                                                                1.0, // You can adjust the end scale
                                                          ).animate(animation),
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              },
                                              text: "Set MPin",
                                              options: FFButtonOptions(
                                                width: 270.0,
                                                height: 20.0,
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 0.0),
                                                iconPadding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        0.0, 0.0, 0.0, 0.0),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary1,
                                                textStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleMedium
                                                        .override(
                                                          fontFamily: 'Outfit',
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                elevation: 2.0,
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Add more Positioned widgets for additional images
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}
