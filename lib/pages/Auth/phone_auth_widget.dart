// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously, prefer_function_declarations_over_variables, non_constant_identifier_names, prefer_final_fields, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_theme.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_widgets.dart';
import 'package:maaakanmoney/pages/User/Userscreen_widget.dart';
import 'package:maaakanmoney/pages/budget_copy/budget_copy_widget.dart';
import 'package:maaakanmoney/phoneController.dart';
import 'package:maaakanmoney/verify.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:tuple/tuple.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/constants.dart';
import '../../components/custom_dialog_box.dart';

class MyPhone extends ConsumerStatefulWidget {
  const MyPhone({Key? key}) : super(key: key);

  static String verifyid = "";
  static String phonenumber = "";

  @override
  _MyPhoneState createState() => _MyPhoneState();
}

class _MyPhoneState extends ConsumerState<MyPhone> {
  TextEditingController countryController = TextEditingController();
  TextEditingController PhoneController = TextEditingController();
  String? verificationId;
  bool isOtpSent = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? loginKey;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ConnectivityResult? data;

  bool _agreedToTerms = false;

  void _navigateToTermsListScreen(bool isPrivacyPol) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => TermsListScreen(
          isPrivacyTapped: isPrivacyPol,
        ),
        transitionsBuilder: (_, animation, __, child) {
          // return FadeTransition(
          //   opacity: animation,
          //   child: child,
          // );

          var scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          return ScaleTransition(
            scale: scaleAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void initState() {
    countryController.text = "+91";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: Consumer(builder: (context, ref, child) {
                  data = ref.watch(connectivityProvider);

                  return Container(
                    margin: const EdgeInsets.only(left: 25, right: 25),
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "We need to register your phone \n before getting started!",
                            style: TextStyle(fontSize: 16, letterSpacing: 1),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: TextField(
                                    enabled: false,
                                    controller: countryController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const Text(
                                  "|",
                                  style: TextStyle(
                                    fontSize: 33,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: TextFormField(
                                  enabled: isOtpSent == true ? false : true,
                                  maxLength: 10,
                                  controller: PhoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(letterSpacing: 1),
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: "Phone",
                                  ),
                                ))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: IgnorePointer(
                              ignoring: isOtpSent == true ? true : false,
                              child: FFButtonWidget(
                                onPressed: _submitForm,
                                text: "Login",
                                options: FFButtonOptions(
                                  width: 270.0,
                                  height: 20.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: Color(data == ConnectivityResult.none
                                      ? 0xFFCCCFD5
                                      : 0xFF020202),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        fontFamily: 'Outfit',
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                      ),
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
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            isOtpSent == true
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
  }

  Future<bool> isNewUser(String phoneNumber) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('mobile', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<bool> isEnquiry(String? phoneNumber) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('Enquiry')
        .where('mobile', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> _submitForm() async {
    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }

    if (PhoneController.text == null || PhoneController.text.isEmpty) {
      Constants.showToast("Please enter a Phone Number", ToastGravity.CENTER);
    } else {
      if (!RegExp(r'^\d{10}$').hasMatch(PhoneController.text)) {
        Constants.showToast(
            "Please enter a valid 10-digit phone number", ToastGravity.CENTER);
      } else {
        if (PhoneController.text.isNotEmpty) {
          FocusScope.of(context).unfocus();

          bool isNewUse = await isNewUser("+91" + PhoneController.text);

          if (PhoneController.text == "0805080508") {
            Constants.isAdmin = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const BudgetCopyWidget(),
              ),
            );
            // Navigator.push(
            //   context,
            //   PageRouteBuilder(
            //     transitionDuration: Duration(milliseconds: 500),
            //     pageBuilder: (_, __, ___) => BudgetCopyWidget(),
            //     transitionsBuilder: (_, animation, __, child) {
            //       return ScaleTransition(
            //         scale: Tween<double>(
            //           begin: 0.0, // You can adjust the start scale
            //           end: 1.0,   // You can adjust the end scale
            //         ).animate(animation),
            //         child: child,
            //       );
            //     },
            //   ),
            // );
          } else {
            Constants.isAdmin = false;
            if (isNewUse) {
              bool isNewEnquiry =
                  await isEnquiry(("+91" + PhoneController.text ?? ""));

              if (isNewEnquiry) {
                String documentId = firestore.collection('Enquiry').doc().id;

                firestore.collection('Enquiry').doc(documentId).set({
                  'mobile': "+91" + PhoneController.text,
                }).then((value) async {
                  Constants.showToast("Our Executive will reach you Shortly!",
                      ToastGravity.BOTTOM);
                }).catchError(
                    (error) => print('Failed to create data: $error'));
              }

//todo:- 238.23 changes adding terms and conditions

              showDialog(
                barrierDismissible: false,
                context:
                    context, // Make sure you have access to the context here
                builder: (BuildContext context) {
                  bool _agreedToTerms =
                      false; // Initialize this based on your needs

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        content: Container(
                          width: 100.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Maaka",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Center(
                                  child: Text(
                                    "Terms and conditions update",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Image.asset(
                                  'images/contract.png',
                                  height: 100,
                                  width: 100,
                                ),
                                SizedBox(height: 15),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: 'Our ',
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'terms and conditions ',
                                        style: TextStyle(
                                            height: 1.5,
                                            color: Colors.blue, // Blue color
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold),
                                        // Add onTap function here for the tap functionality
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _navigateToTermsListScreen(false);
                                          },
                                      ),
                                      TextSpan(
                                        text: 'and ',
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'privacy policy document ',
                                        style: TextStyle(
                                            height: 1.5,
                                            color: Colors.blue, // Blue color
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold),
                                        // Add onTap function here for the tap functionality
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _navigateToTermsListScreen(true);
                                          },
                                      ),
                                      TextSpan(
                                        text: ' have been recently updated.'
                                            ' To continue using our app, please review and agree to our updated terms.',
                                        style: TextStyle(
                                          height: 1.5,
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'I have read and agreed to the terms',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Switch(
                                      value: _agreedToTerms,
                                      onChanged: (value) {
                                        if (value) {
                                          _navigateToTermsListScreen(false);
                                        }

                                        setState(() {
                                          _agreedToTerms = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              children: [
                                _agreedToTerms
                                    ? Text(
                                        "Call us and get Security Code to get Started!",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // Set the desired width
                                  child: _agreedToTerms
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            // showDialog(
                                            //     barrierDismissible: false,
                                            //     context: context,
                                            //     builder:
                                            //         (BuildContext context) {
                                            //       return AlertDialog(
                                            //         title: Center(
                                            //             child: Text(
                                            //                 "Why Maaka Money!")),
                                            //         content: Container(
                                            //           width: 70.w,
                                            //           height: 30.h,
                                            //           decoration: BoxDecoration(
                                            //             // Set the color of the container
                                            //             borderRadius:
                                            //                 BorderRadius.circular(
                                            //                     10), // Set the corner radius
                                            //           ),
                                            //           child: NewUserTracking(
                                            //             getMobile: "+91" +
                                            //                 PhoneController
                                            //                     .text,
                                            //           ),
                                            //         ),
                                            //         actions: [
                                            //           TextButton(
                                            //             onPressed: () {
                                            //               Navigator.pop(
                                            //                   context); // Close the dialog
                                            //             },
                                            //             child: Text("Close"),
                                            //           ),
                                            //         ],
                                            //       );
                                            //     });
                                            final Uri launchUri = Uri(
                                              scheme: 'tel',
                                              path: Constants.adminNo2,
                                            );
                                            await launchUrl(launchUri);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Call Admin",
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            } else {
              final phoneNumber = "+91" + PhoneController.text;
              SharedPreferences prefs = await SharedPreferences.getInstance();
              loginKey = prefs.getString("LoginSuccessuser1");

              //todo:- 238.23 changes adding terms and conditions

              showDialog(
                barrierDismissible: false,
                context:
                    context, // Make sure you have access to the context here
                builder: (BuildContext context) {
                  bool _agreedToTerms =
                      false; // Initialize this based on your needs

                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        content: Container(
                          width: 100.w,
                          height: 55.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Maaka",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Center(
                                  child: Text(
                                    "Terms and conditions update",
                                    style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Image.asset(
                                  'images/contract.png',
                                  height: 100,
                                  width: 100,
                                ),
                                SizedBox(height: 15),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 15),
                                    children: [
                                      TextSpan(
                                        text: 'Our ',
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'terms and conditions ',
                                        style: TextStyle(
                                            height: 1.5,
                                            color: Colors.blue, // Blue color
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold),
                                        // Add onTap function here for the tap functionality
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _navigateToTermsListScreen(false);
                                          },
                                      ),
                                      TextSpan(
                                        text: 'and ',
                                        style: TextStyle(
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'privacy policy document ',
                                        style: TextStyle(
                                            height: 1.5,
                                            color: Colors.blue, // Blue color
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold),
                                        // Add onTap function here for the tap functionality
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _navigateToTermsListScreen(true);
                                          },
                                      ),
                                      TextSpan(
                                        text: ' have been recently updated.'
                                            ' To continue using our app, please review and agree to our updated terms.',
                                        style: TextStyle(
                                          height: 1.5,
                                          color: Colors
                                              .black, // Change this to the desired color
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'I have read and agreed to the terms',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    Switch(
                                      value: _agreedToTerms,
                                      onChanged: (value) {
                                        if (value) {
                                          _navigateToTermsListScreen(false);
                                        }

                                        setState(() {
                                          _agreedToTerms = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              children: [
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width *
                                      0.5, // Set the desired width
                                  child: _agreedToTerms
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            // Navigator.pushReplacement(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => MyVerify(
                                            //       getMobile: "+91" +
                                            //           PhoneController.text,
                                            //     ),
                                            //   ),
                                            // );
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 650),
                                                pageBuilder: (_, __, ___) =>
                                                    MyVerify(
                                                  getMobile: "+91" +
                                                      PhoneController.text,
                                                ),
                                                transitionsBuilder:
                                                    (_, animation, __, child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Get Started",
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(Icons.arrow_forward),
                                            ],
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
          }
        } else {
          Constants.showToast(
              "Please enter a Phone Number", ToastGravity.CENTER);
        }
      }
    }
  }
}

//todo"- 31.7.23 tracking new user

class NewUserTracking extends StatefulWidget {
  @override
  _NewUserTrackingState createState() => _NewUserTrackingState();

  final String? getMobile;

  NewUserTracking({
    required this.getMobile,
  });
}

class _NewUserTrackingState extends State<NewUserTracking> {
  final PageController _pageController = PageController(initialPage: 0);
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final List<Tuple3> contents = [
    Tuple3(
        "Secure and Private:",
        "Maaka ensures the security and privacy of your financial information. You can trust that your data and savings are in safe hands! 💹💳",
        "images/security.png"),
    Tuple3(
        "Interest on Transactions:",
        "Unlike a traditional piggy bank, Maaka doesn't just hold your money; it grows it too! With every transaction, you earn interest, giving your savings an extra boost! 🌳💰",
        "images/interest.png"),
    Tuple3(
        "Building Emergency Fund:",
        "Maaka helps you build a robust emergency fund. By saving small amounts consistently and earning interest, you'll have a safety net ready to handle unexpected expenses! 💰💰",
        "images/emergency.png"),
    Tuple3(
        "Financial Discipline:",
        "Using Maaka encourages better financial habits. The app helps you track your spending, set savings goals, and stay disciplined in achieving them! 💹💳",
        "images/dicipline.png"),
  ];
  bool _isLastPage = false;
  bool _showContactOptions = false;
  ConnectivityResult? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(builder: (context, ref, child) {
        data = ref.watch(connectivityProvider);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _showContactOptions
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text("Call Admin"),
                            onTap: () {
                              // Handle phone call option here
                              print("Call Admin");
                            },
                          ),
                        ],
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: contents.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _isLastPage = page == contents.length - 1;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  contents[index].item1,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Image.asset(
                                  () {
                                    return contents[index].item3;
                                  }(),
                                  width: 200,
                                  height: 200,
                                  errorBuilder:
                                      (context, exception, stackTrace) {
                                    return Image.asset(
                                        width: 120,
                                        height: 120,
                                        "images/error.png");
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Visibility(
              visible: _showContactOptions ? false : true,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_pageController.page != 0) {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      icon: Icon(Icons.arrow_back_ios),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () async {
                        final Uri launchUri = Uri(
                          scheme: 'tel',
                          path: Constants.adminNo2,
                        );
                        await launchUrl(launchUri);
                      },
                      child: Text("Call Executive"),
                    ),
                    SizedBox(width: 5),
                    Visibility(
                      visible: !_isLastPage,
                      child: IconButton(
                        onPressed: () {
                          if (_pageController.page != contents.length - 1) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}

class TermsListScreen extends StatelessWidget {
  static String getPolicy() {
    return """

Privacy Policy

Updated at 2023-07-19

Maaka Money (“we,” “our,” or “us”) is committed to protecting your privacy. This Privacy Policy explains how your personal information is collected, used, and disclosed by Maaka Money.

This Privacy Policy applies to our website, and its associated subdomains (collectively, our “Service”) alongside our application, Maaka Money. By accessing or using our Service, you signify that you have read, understood, and agree to our collection, storage, use, and disclosure of your personal information as described in this Privacy Policy and our Terms of Service.

Definitions and key terms

To help explain things as clearly as possible in this Privacy Policy, every time any of these terms are referenced, are strictly defined as:

  -Cookie: small amount of data generated by a website and saved by your web browser. It is used to identify your browser, provide analytics, remember information about you such as your language preference or login information.
  -Company: when this policy mentions “Company,” “we,” “us,” or “our,” it refers to Maaka Money, that is responsible for your information under this Privacy Policy.
  -Country: where Maaka Money or the owners/founders of Maaka Money are based, in this case is India
  -Customer: refers to the company, organization or person that signs up to use the Maaka Money Service to manage the relationships with your consumers or service users.
  -Device: any internet connected device such as a phone, tablet, computer or any other device that can be used to visit Maaka Money and use the services.
  -IP address: Every device connected to the Internet is assigned a number known as an Internet protocol (IP) address. These numbers are usually assigned in geographic blocks. An IP address can often be used to identify the location from which a device is connecting to the Internet.
  -Personnel: refers to those individuals who are employed by Maaka Money or are under contract to perform a service on behalf of one of the parties.
  -Personal Data: any information that directly, indirectly, or in connection with other information — including a personal identification number — allows for the identification or identifiability of a natural person.
  -Service: refers to the service provided by Maaka Money as described in the relative terms (if available) and on this platform.
  -Third-party service: refers to advertisers, contest sponsors, promotional and marketing partners, and others who provide our content or whose products or services we think may interest you.
  -Website: Maaka Money."’s" site, which can be accessed via this URL: 
  -You: a person or entity that is registered with Maaka Money to use the Services.


  This Privacy Policy was created with Termify.io
  

What Information Do We Collect?

We collect information from you when you visit our app, register on our site, place an order, subscribe to our newsletter, respond to a survey or fill out a form.

 -Phone Numbers
  

How Do We Use The Information We Collect?

Any of the information we collect from you may be used in one of the following ways:

  -To personalize your experience (your information helps us to better respond to your individual needs)
  -To improve our app (we continually strive to improve our app offerings based on the information and feedback we receive from you)
  -To improve customer service (your information helps us to more effectively respond to your customer service requests and support needs)
  -To process transactions
  -To administer a contest, promotion, survey or other site feature
  -To send periodic emails


When does Maaka Money use end user information from third parties?

Maaka Money will collect End User Data necessary to provide the Maaka Money services to our customers.

End users may voluntarily provide us with information they have made available on social media websites. If you provide us with any such information, we may collect publicly available information from the social media websites you have indicated. You can control how much of your information social media websites make public by visiting these websites and changing your privacy settings.


When does Maaka Money use customer information from third parties?

We receive some information from the third parties when you contact us. For example, when you submit your email address to us to show interest in becoming a Maaka Money customer, we receive information from a third party that provides automated fraud detection services to Maaka Money. We also occasionally collect information that is made publicly available on social media websites. You can control how much of your information social media websites make public by visiting these websites and changing your privacy settings.


Do we share the information we collect with third parties?

We may share the information that we collect, both personal and non-personal, with third parties such as advertisers, contest sponsors, promotional and marketing partners, and others who provide our content or whose products or services we think may interest you. We may also share it with our current and future affiliated companies and business partners, and if we are involved in a merger, asset sale or other business reorganization, we may also share or transfer your personal and non-personal information to our successors-in-interest.

  We may engage trusted third party service providers to perform functions and provide services to us, such as hosting and maintaining our servers and the app, database storage and management, e-mail management, storage marketing, credit card processing, customer service and fulfilling orders for products and services you may purchase through the app. We will likely share your personal information, and possibly some non-personal information, with these third parties to enable them to perform these services for us and for you.

  We may share portions of our log file data, including IP addresses, for analytics purposes with third parties such as web analytics partners, application developers, and ad networks. If your IP address is shared, it may be used to estimate general location and other technographics such as connection speed, whether you have visited the app in a shared location, and type of the device used to visit the app. They may aggregate information about our advertising and what you see on the app and then provide auditing, research and reporting for us and our advertisers.   

We may also disclose personal and non-personal information about you to government or law enforcement officials or private parties as we, in our sole discretion, believe necessary or appropriate in order to respond to claims, legal process (including subpoenas), to protect our rights and interests or those of a third party, the safety of the public or any person, to prevent or stop any illegal, unethical, or legally actionable activity, or to otherwise comply with applicable court orders, laws, rules and regulations. 


Where and when is information collected from customers and end users?

Maaka Money will collect personal information that you submit to us. We may also receive personal information about you from third parties as described above.


How Do We Use Your Email Address?

By submitting your email address on this app, you agree to receive emails from us. You can cancel your participation in any of these email lists at any time by clicking on the opt-out link or other unsubscribe option that is included in the respective email. We only send emails to people who have authorized us to contact them, either directly, or through a third party. We do not send unsolicited commercial emails, because we hate spam as much as you do. By submitting your email address, you also agree to allow us to use your email address for customer audience targeting on sites like Facebook, where we display custom advertising to specific people who have opted-in to receive communications from us. Email addresses submitted only through the order processing page will be used for the sole purpose of sending you information and updates pertaining to your order. If, however, you have provided the same email to us through another method, we may use it for any of the purposes stated in this Policy. Note: If at any time you would like to unsubscribe from receiving future emails, we include detailed unsubscribe instructions at the bottom of each email.


How Long Do We Keep Your Information?

We keep your information only so long as we need it to provide Maaka Money to you and fulfill the purposes described in this policy. This is also the case for anyone that we share your information with and who carries out services on our behalf. When we no longer need to use your information and there is no need for us to keep it to comply with our legal or regulatory obligations, we’ll either remove it from our systems or depersonalize it so that we can't identify you.


How Do We Protect Your Information?

We implement a variety of security measures to maintain the safety of your personal information when you place an order or enter, submit, or access your personal information. We offer the use of a secure server. All supplied sensitive/credit information is transmitted via Secure Socket Layer (SSL) technology and then encrypted into our Payment gateway providers database only to be accessible by those authorized with special access rights to such systems, and are required to keep the information confidential. After a transaction, your private information (credit cards, social security numbers, financials, etc.) is never kept on file. We cannot, however, ensure or warrant the absolute security of any information you transmit to Maaka Money or guarantee that your information on the Service may not be accessed, disclosed, altered, or destroyed by a breach of any of our physical, technical, or managerial safeguards.


Could my information be transferred to other countries?

Maaka Money is incorporated in India. Information collected via our website, through direct interactions with you, or from use of our help services may be transferred from time to time to our offices or personnel, or to third parties, located throughout the world, and may be viewed and hosted anywhere in the world, including countries that may not have laws of general applicability regulating the use and transfer of such data. To the fullest extent allowed by applicable law, by using any of the above, you voluntarily consent to the trans-border transfer and hosting of such information.


Is the information collected through the Maaka Money Service secure?

We take precautions to protect the security of your information. We have physical, electronic, and managerial procedures to help safeguard, prevent unauthorized access, maintain data security, and correctly use your information. However, neither people nor security systems are foolproof, including encryption systems. In addition, people can commit intentional crimes, make mistakes or fail to follow policies. Therefore, while we use reasonable efforts to protect your personal information, we cannot guarantee its absolute security. If applicable law imposes any non-disclaimable duty to protect your personal information, you agree that intentional misconduct will be the standards used to measure our compliance with that duty.


Can I update or correct my information?

The rights you have to request updates or corrections to the information Maaka Money collects depend on your relationship with Maaka Money. Personnel may update or correct their information as detailed in our internal company employment policies.

Customers have the right to request the restriction of certain uses and disclosures of personally identifiable information as follows. You can contact us in order to (1) update or correct your personally identifiable information, (2) change your preferences with respect to communications and other information you receive from us, or (3) delete the personally identifiable information maintained about you on our systems (subject to the following paragraph), by cancelling your account. Such updates, corrections, changes and deletions will have no effect on other information that we maintain, or information that we have provided to third parties in accordance with this Privacy Policy prior to such update, correction, change or deletion. To protect your privacy and security, we may take reasonable steps (such as requesting a unique password) to verify your identity before granting you profile access or making corrections. You are responsible for maintaining the secrecy of your unique password and account information at all times.

You should be aware that it is not technologically possible to remove each and every record of the information you have provided to us from our system. The need to back up our systems to protect information from inadvertent loss means that a copy of your information may exist in a non-erasable form that will be difficult or impossible for us to locate. Promptly after receiving your request, all personal information stored in databases we actively use, and other readily searchable media will be updated, corrected, changed or deleted, as appropriate, as soon as and to the extent reasonably and technically practicable.

If you are an end user and wish to update, delete, or receive any information we have about you, you may do so by contacting the organization of which you are a customer.


Sale of Business

We reserve the right to transfer information to a third party in the event of a sale, merger or other transfer of all or substantially all of the assets of Maaka Money or any of its Corporate Affiliates (as defined herein), or that portion of Maaka Money or any of its Corporate Affiliates to which the Service relates, or in the event that we discontinue our business or file a petition or have filed against us a petition in bankruptcy, reorganization or similar proceeding, provided that the third party agrees to adhere to the terms of this Privacy Policy.


Affiliates

We may disclose information (including personal information) about you to our Corporate Affiliates. For purposes of this Privacy Policy, "Corporate Affiliate" means any person or entity which directly or indirectly controls, is controlled by or is under common control with Maaka Money, whether by ownership or otherwise. Any information relating to you that we provide to our Corporate Affiliates will be treated by those Corporate Affiliates in accordance with the terms of this Privacy Policy.


Governing Law

This Privacy Policy is governed by the laws of India without regard to its conflict of laws provision. You consent to the exclusive jurisdiction of the courts in connection with any action or dispute arising between the parties under or in connection with this Privacy Policy except for those individuals who may have rights to make claims under Privacy Shield, or the Swiss-US framework.

The laws of India, excluding its conflicts of law rules, shall govern this Agreement and your use of the app. Your use of the app may also be subject to other local, state, national, or international laws.

By using Maaka Money or contacting us directly, you signify your acceptance of this Privacy Policy. If you do not agree to this Privacy Policy, you should not engage with our website, or use our services. Continued use of the website, direct engagement with us, or following the posting of changes to this Privacy Policy that do not significantly affect the use or disclosure of your personal information will mean that you accept those changes.


Your Consent

We've updated our Privacy Policy to provide you with complete transparency into what is being set when you visit our site and how it's being used. By using our app, registering an account, or making a purchase, you hereby consent to our Privacy Policy and agree to its terms.


Links to Other Websites

This Privacy Policy applies only to the Services. The Services may contain links to other websites not operated or controlled by Maaka Money. We are not responsible for the content, accuracy or opinions expressed in such websites, and such websites are not investigated, monitored or checked for accuracy or completeness by us. Please remember that when you use a link to go from the Services to another website, our Privacy Policy is no longer in effect. Your browsing and interaction on any other website, including those that have a link on our platform, is subject to that website’s own rules and policies. Such third parties may use their own cookies or other methods to collect information about you.


Cookies

Maaka Money uses "Cookies" to identify the areas of our website that you have visited. A Cookie is a small piece of data stored on your computer or mobile device by your web browser. We use Cookies to enhance the performance and functionality of our app but are non-essential to their use. However, without these cookies, certain functionality like videos may become unavailable or you would be required to enter your login details every time you visit the app as we would not be able to remember that you had logged in previously. Most web browsers can be set to disable the use of Cookies. However, if you disable Cookies, you may not be able to access functionality on our website correctly or at all. We never place Personally Identifiable Information in Cookies.


Blocking and disabling cookies and similar technologies

Wherever you're located you may also set your browser to block cookies and similar technologies, but this action may block our essential cookies and prevent our website from functioning properly, and you may not be able to fully utilize all of its features and services. You should also be aware that you may also lose some saved information (e.g. saved login details, site preferences) if you block cookies on your browser. Different browsers make different controls available to you. Disabling a cookie or category of cookie does not delete the cookie from your browser, you will need to do this yourself from within your browser, you should visit your browser's help menu for more information.


Kids' Privacy

We do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.


Changes To Our Privacy Policy

We may change our Service and policies, and we may need to make changes to this Privacy Policy so that they accurately reflect our Service and policies. Unless otherwise required by law, we will notify you (for example, through our Service) before we make changes to this Privacy Policy and give you an opportunity to review them before they go into effect. Then, if you continue to use the Service, you will be bound by the updated Privacy Policy. If you do not want to agree to this or any updated Privacy Policy, you can delete your account.


Third-Party Services

We may display, include or make available third-party content (including data, information, applications and other products services) or provide links to third-party websites or services ("Third- Party Services").
You acknowledge and agree that Maaka Money shall not be responsible for any Third-Party Services, including their accuracy, completeness, timeliness, validity, copyright compliance, legality, decency, quality or any other aspect thereof. Maaka Money does not assume and shall not have any liability or responsibility to you or any other person or entity for any Third-Party Services.
Third-Party Services and links thereto are provided solely as a convenience to you and you access and use them entirely at your own risk and subject to such third parties' terms and conditions.


Contact Us

Don't hesitate to contact us if you have any questions.

 -Via Phone Number:  9360840071 / 9941445471


    """;
  }

  static final List<Tuple2<String, String>> termsData = [
    Tuple2("About Maaka App",
        "Welcome to Maaka App is a digital piggy bank designed to help you save and build an emergency fund. By using the Maaka app, you agree to the following terms."),
    Tuple2("1. Savings and Emergency Fund:",
        "Maaka's main goal is to encourage users to save liquid cash and create an emergency fund. We provide a platform for voluntary savings without imposing daily or mandatory contribution requirements."),
    Tuple2("2. Voluntary Savings Requests:",
        "As the administrator of Maaka, we send random voluntary savings requests via WhatsApp. These requests are not mandatory; you decide when and how much you want to save."),
    Tuple2("3. Withdrawal Flexibility:",
        "You have the freedom to withdraw your saved amount whenever you need it. However, as it's a piggy bank concept, Maaka's administration will act as an intermediary when releasing your savings to your account. This ensures that you use your savings purposefully, rather than spending more than saving."),
    Tuple2("4. Interest on Savings:",
        "For each transaction involving your saved amount, Maaka pays an interest ranging from 0.5% to 1%. Please note that the maximum interest limit per day is restricted to ₹5 (Indian Rupees Five only)."),
    Tuple2("5. Emergency Fund Commitment:",
        "We are committed to growing your emergency fund so that your savings can truly help you when you need it. If We fail to return your requested amount within 24 hours, Maaka promises to pay an additional 0.5% interest on the requested amount."),
  ];
  static final List<Tuple2<String, String>> polData = [
    Tuple2("Maaka Privacy Policy", getPolicy()),
  ];

  final bool isPrivacyTapped; // The data you want to pass

  TermsListScreen({required this.isPrivacyTapped}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: ListView.builder(
        itemCount: isPrivacyTapped ? polData.length : termsData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(isPrivacyTapped
                ? polData[index].item1
                : termsData[index].item1), // Topic
            subtitle: Text(isPrivacyTapped
                ? polData[index].item2
                : termsData[index].item2), // Content
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Dismiss the screen
          },
          child: Text("OK"),
        ),
      ),
    );
  }
}
