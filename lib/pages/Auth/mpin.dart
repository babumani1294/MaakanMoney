import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/User/Userscreen_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/constants.dart';
import '../../components/custom_dialog_box.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../phoneController.dart';

class MpinPageWidget extends ConsumerStatefulWidget {
  MpinPageWidget({
    Key? key,
    required this.getMobileNo,
    required this.getMpin,
  }) : super(key: key);
  final String getMobileNo; // Data received from SplashScreen
  final String? getMpin;
  @override
  MpinPageState createState() => MpinPageState();
}

class MpinPageState extends ConsumerState<MpinPageWidget> {
  var verifycode = "";
  ConnectivityResult? data;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<int> passcode = [];

  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          data = ref.watch(connectivityProvider);
          ref.watch(isOtpSent);
          return Scaffold(
            extendBodyBehindAppBar: true,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  //todo:- 15.11.23 new ui for mpin screen
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                        Expanded(
                          flex: 4,
                          child: Stack(children: [
                            SizedBox(
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Colors.transparent),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 50.0, right: 0),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  letterSpacing: 1,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                Constants.appVersion,
                                                style: GlobalTextStyles
                                                    .secondaryText2(
                                                        textColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        txtWeight:
                                                            FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Add more Positioned widgets for additional images
                                    ),
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Stack(children: [
                                          SizedBox(
                                            height: 100.h,
                                            width: 70.w,
                                            child: Image.asset(
                                              'images/final/SecurityCode/MPin.png',
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0, right: 0),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Stack(children: [
                                            Text(
                                              "MPin",
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
                          flex: 5,
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
                                alignment: Alignment.center,
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
                                          children:
                                              List.generate(3, (colIndex) {
                                            int index = rowIndex * 3 + colIndex;
                                            if (index == 9) {
                                              return GestureDetector(
                                                onTap: () async {},
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100.0),
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

                                                if (passcode.length < 4) {
                                                  ref
                                                              .read(isOtpSent
                                                                  .notifier)
                                                              .state ==
                                                          true
                                                      ? () {}()
                                                      : setState(() {
                                                          passcode.add(
                                                              index == 10
                                                                  ? 0
                                                                  : index + 1);
                                                          if (passcode.length ==
                                                              4) {
                                                            print(
                                                                'Passcode: $passcode');

                                                            String
                                                                finalSecCode =
                                                                passcode
                                                                    .join('');

                                                            verifyOtp(
                                                                context,
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
                                                  style:
                                                      TextStyle(fontSize: 20),
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
                                          children:
                                              List.generate(3, (colIndex) {
                                            int index = rowIndex * 3 + colIndex;
                                            return GestureDetector(
                                              onTap: () {
                                                print(
                                                    'Digit tapped: ${index == 10 ? 0 : index + 1}');
                                                if (passcode.length < 4) {
                                                  ref
                                                              .read(isOtpSent
                                                                  .notifier)
                                                              .state ==
                                                          true
                                                      ? () {}()
                                                      : setState(() {
                                                          passcode.add(
                                                              index == 10
                                                                  ? 0
                                                                  : index + 1);
                                                          if (passcode.length ==
                                                              4) {
                                                            print(
                                                                'Passcode: $passcode');
                                                            String
                                                                finalSecCode =
                                                                passcode
                                                                    .join('');

                                                            verifyOtp(
                                                                context,
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
                                                  style:
                                                      TextStyle(fontSize: 20),
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
                                  padding: const EdgeInsets.only(
                                      top: 30.0, right: 0),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(4, (index) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5),
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
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: InkWell(
                                      child: Text(
                                        "forget Mpin?",
                                        selectionColor:
                                            FlutterFlowTheme.of(context)
                                                .primary1,
                                        style: GlobalTextStyles.secondaryText1(
                                            textColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            txtWeight: FontWeight.bold),
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MyPhone()));
                                      },
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                      : Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> verifyOtp(BuildContext context, String? getFinalSecCode) async {
    FocusScope.of(context).unfocus();

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    if (getFinalSecCode!.isNotEmpty) {
      if (getFinalSecCode!.length < 4) {
        Constants.showToast("Please enter a Valid Mpin", ToastGravity.BOTTOM);
      } else {
        if (widget.getMpin == getFinalSecCode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetWidget1(
                getMobile: widget.getMobileNo,
              ),
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
                  title: "Message!",
                  descriptions: "You're not Valid user,Please contact Admin",
                  text: "Ok",
                  isCancel: false,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                );
              });
        }
      }
    } else {
      Constants.showToast("Please enter a OTP", ToastGravity.BOTTOM);
    }
  }
}
