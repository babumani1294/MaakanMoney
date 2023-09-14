import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/components/custom_dialog_box.dart';
import 'package:maaakanmoney/pages/budget_copy/budget_copy_widget.dart';
import 'package:maaakanmoney/phoneController.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adduser_model.dart';
export 'adduser_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AdduserWidget extends ConsumerStatefulWidget {
  const AdduserWidget({Key? key}) : super(key: key);

  @override
  _AdduserWidgetState createState() => _AdduserWidgetState();
}

class _AdduserWidgetState extends ConsumerState<AdduserWidget> {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _userName;
  String? _phoneNumber;

  TextEditingController? txtUserName;
  TextEditingController? txtphneName;
  String? Function(BuildContext, String?)? cityController1Validator;
  // State field(s) for city widget.
  TextEditingController? txtMobileNo;
  String? Function(BuildContext, String?)? cityController2Validator;

  ConnectivityResult? data;

  /// Initialization and disposal methods.

  @override
  void initState() {
    txtUserName ??= TextEditingController();
    txtMobileNo ??= TextEditingController();
    txtphneName ??= TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    // txtUserName?.dispose();
    // txtMobileNo?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: responsiveVisibility(
          context: context,
          tabletLandscape: false,
          desktop: false,
        )
            ? AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                title: Text(
                  FFLocalizations.of(context).getText(
                    '3usdhnov' /* Add user */,
                  ),
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme.of(context).primaryBtnText,
                        fontSize: 18.0,
                      ),
                ),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                elevation: 0,
              )
            : null,
        body: SafeArea(
          child: Consumer(builder: (context, ref, child) {
            data = ref.watch(connectivityProvider);

            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 25.0, 0.0, 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E3E7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 50.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 10.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'uzh1m0n9' /* MM00026 */,
                        ),
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF049A50),
                              fontSize: 16.0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 10.0, 20.0, 16.0),
                      child: TextFormField(
                        controller: txtUserName,
                        textCapitalization: TextCapitalization.words,
                        obscureText: false,
                        decoration: InputDecoration(
                          labelText: FFLocalizations.of(context).getText(
                            '0nbq1nrp' /* NAME */,
                          ),
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF57636C),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF57636C),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E3E7),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF004D40),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 24.0, 0.0, 24.0),
                        ),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF14181B),
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                        // validator:
                        //     _model.cityController1Validator.asValidator(context),

                        validator: _validateUserName,
                        onSaved: (value) => _userName = value,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 10.0, 20.0, 16.0),
                      child: TextFormField(
                        controller: txtMobileNo,
                        textCapitalization: TextCapitalization.words,
                        obscureText: false,
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: FFLocalizations.of(context).getText(
                            'jfu76k1i' /* MOBILE NUMBER */,
                          ),
                          labelStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF57636C),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                          hintStyle:
                              FlutterFlowTheme.of(context).labelMedium.override(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF57636C),
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFE0E3E7),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFF004D40),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Color(0xFFFF5963),
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 24.0, 0.0, 24.0),
                        ),
                        maxLength: 10,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF14181B),
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                        keyboardType: TextInputType.phone,
                        // validator:
                        //     _model.cityController2Validator.asValidator(context),
                        validator: _validatePhoneNumber,
                        onSaved: (value) => _phoneNumber = value,
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.05),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 24.0, 0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: _submitForm,
                          text: FFLocalizations.of(context).getText(
                            'jdq9v5wm' /* Add User */,
                          ),
                          options: FFButtonOptions(
                            width: 270.0,
                            height: 50.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleMedium
                                .override(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            elevation: 2.0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          10.0, 30.0, 10.0, 10.0),
                      child: Text(
                        FFLocalizations.of(context).getText(
                          'l3nh6fz4' /* User will receive an SMS with ... */,
                        ),
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                              fontFamily: 'Poppins',
                              color: const Color(0xFF049A50),
                              fontSize: 13.0,
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
    );
  }

  //todo:-2.6.23 / creating new user to firestore
  void AddUser(
    String? getName,
    String? getMobile,
  ) {
    String documentId = fireStore.collection('users').doc().id;
    int? randomCode = generateRandomCode();

    fireStore.collection('users').doc(documentId).set({
      'name': getName,
      'mobile': getMobile,
      'total': 0.0,
      'isVerified': false,
      'isMoneyRequest': false,
      'notificationByAdmin': true,
      'requestAmnt': 0.0,
      'totalCredit': 0.0,
      'totalDebit': 0.0,
      'netTotal': 0.0,
      'totalIntCredit': 0.0,
      'totalIntDebit': 0.0,
      'netIntTotal': 0.0,
      'securityCode': randomCode ?? 000000,
      'isCashbackRequest': false,
      'requestCashbckAmnt': 0.0,
    }).then((value) {
      setState(() {
        txtUserName.text = "";
        txtMobileNo.text = "";
      });

      Constants.showToast("User Added Successfully", ToastGravity.BOTTOM);

      // Navigator.pop(context);
    }).catchError((error) => print('Failed to create data: $error'));
  }

  int? generateRandomCode() {
    final random = Random();
    int? code = random.nextInt(900000) +
        100000; // Generates a random number between 100000 and 999999
    return code;
  }

  Future<bool> isNewUser(String phoneNumber) async {
    QuerySnapshot querySnapshot = await fireStore
        .collection('users')
        .where('mobile', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      if (data == ConnectivityResult.none) {
        Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
        return;
      }

      bool isNewCust = await isNewUser("+91" + txtMobileNo.text);

      if (isNewCust) {
        AddUser(txtUserName.text, "+91" + txtMobileNo.text);
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return CustomDialogBox(
                title: "Alert!",
                descriptions: "User Already Added",
                text: "Ok",
                isCancel: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetCopyWidget(),
                    ),
                  );
                },
              );
            });
      }
    }
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a user name';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
}
