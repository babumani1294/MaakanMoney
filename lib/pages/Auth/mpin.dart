import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/User/Userscreen_widget.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';

import '../../components/constants.dart';
import '../../components/custom_dialog_box.dart';
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

  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Consumer(
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
                            "Welcome Back",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Please enter Mpin!",
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
                              length: 4,
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
                            width: 50.w,
                            child: Column(
                              children: [
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(
                                            data == ConnectivityResult.none
                                                ? 0xFFCCCFD5
                                                : 0xFF020202),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onPressed: () => verifyOtp(context),
                                    child: const Text("Login")),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  child: Text("forget Mpin?"),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MyPhone()));
                                  },
                                ),
                              ],
                            ),
                          ),
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
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16.0), // Adjust the padding as needed
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "App Version - ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            Constants.appVersion,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> verifyOtp(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    if (verifycode.isNotEmpty) {
      if (verifycode.length < 4) {
        Constants.showToast("Please enter a Valid Mpin", ToastGravity.BOTTOM);
      } else {
        if (widget.getMpin == verifycode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BudgetWidget(
                getMobile: widget.getMobileNo,
              ),
            ),
          );
        } else {
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
