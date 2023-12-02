// ignore_for_file: must_be_immutable, sort_child_properties_last, prefer_const_constructors, deprecated_member_use_from_same_package

import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/components/custom_dialog_box.dart';
import 'package:maaakanmoney/phoneController.dart';
import 'package:sizer/sizer.dart';

import '../../flutter_flow/form_field_controller.dart';
import '../budget_copy/BudgetCopyController.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/budget_copy/budget_copy_widget.dart';
import 'package:flutter/material.dart';
import 'update_money_model.dart';
export 'update_money_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class UpdateMoneyWidget extends ConsumerStatefulWidget {
  UpdateMoneyWidget({
    Key? key,
    @required this.getMobile,
    @required this.getExistingTotal,
    @required this.getDocId,
    @required this.isSavOrCashback,
  }) : super(key: key);
  String? getMobile;
  double? getExistingTotal;
  String? getDocId;
  bool? isSavOrCashback;
  @override
  _UpdateMoneyWidgetState createState() => _UpdateMoneyWidgetState();
}

class _UpdateMoneyWidgetState extends ConsumerState<UpdateMoneyWidget> {
  bool _isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  bool isDepositSelected = true;
  int amount = 0;

  TextEditingController _dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String? choiceChipsValue;
  FormFieldController<List<String>>? choiceChipsValueController;
  final txtAmount = TextEditingController();
  double value = 1000.0;
  double interestPercent = 1;
  CollectionReference? _collectionReference;
  CollectionReference? _collectionUsers;
  bool swtchMaxIntReached = false;
  bool isMaxIntReached = false;

  ConnectivityResult? data;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
        }));

    _collectionReference =
        FirebaseFirestore.instance.collection('adminDetails');
    _collectionUsers = FirebaseFirestore.instance.collection('users');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          title: Text(
            widget.isSavOrCashback == true ? 'Savings' : 'Cashback',
            style: TextStyle(
              color: Colors.white, // Set the desired text color here
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
            ),
          ),
          elevation: 0,
        ),
        // backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          child: IgnorePointer(
            ignoring: _isLoading ? true : false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer(builder: (context, ref, child) {
                data = ref.watch(connectivityProvider);

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      color: Colors.teal,
                      fillColor: FlutterFlowTheme.of(context).primary,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              'Deposit',
                              style: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .override(
                                      fontFamily: 'Outfit',
                                      color: isDepositSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12.0,
                                      letterSpacing: 2),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Withdrawal',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                    fontFamily: 'Outfit',
                                    color: isDepositSelected
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 2),
                          ),
                        ),
                      ],
                      isSelected: [
                        isDepositSelected,
                        !isDepositSelected,
                      ],
                      onPressed: (index) {
                        setState(() {
                          isDepositSelected = index == 0;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '₹  ',
                          style: TextStyle(
                              fontSize: 33,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 24.0, 0.0, 0.0),
                          child: Container(
                            color: Colors.transparent,
                            height: 100,
                            width: 250,
                            child: TextFormField(
                              maxLines: null,
                              controller: txtAmount,
                              autofocus: true,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 40.0,
                                  letterSpacing: 1),
                              decoration: const InputDecoration(),
                              onChanged: (value) {
                                // setState(() {
                                //   amount = int.parse(value);
                                // });
                              },
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50.0, right: 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Text(
                              'Is maximum interest is reached?',
                              style: TextStyle(),
                            ),
                          ),
                          Switch(
                            value: swtchMaxIntReached,
                            onChanged: (value) {
                              if (!swtchMaxIntReached) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      // setState(() {
                                      //   _isLoading = false;
                                      // });
                                      return CustomDialogBox(
                                        title: "Message!",
                                        descriptions:
                                            "Are you sure, is Maximum interest Reached?",
                                        text: "yes",
                                        isCancel: false,
                                        isNo: true,
                                        onNoTap: () {
                                          setState(() {
                                            swtchMaxIntReached = false;
                                            isMaxIntReached = false;
                                          });
                                          Navigator.pop(context);
                                        },
                                        onTap: () {
                                          setState(() {
                                            isMaxIntReached = value;
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              }

                              if (swtchMaxIntReached) {
                                isMaxIntReached = false;
                              }

                              setState(() {
                                swtchMaxIntReached = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _dateController,

                        onTap: _selectDate,
                        readOnly: true,
                        textInputAction: TextInputAction.none,
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "DATE",
                          // ...
                        ),
                        // ...
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 32.0),
                      child: Center(
                          child: SizedBox(
                        height: 7.h,
                        width: 50.w,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () => addTransaction(widget.isSavOrCashback),
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(widget.isSavOrCashback == true
                                  ? 'Update Money'
                                  : 'Update Cashback'),
                        ),
                      )),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  //todo:-8.6.23 adding timestamp to records
//   void addTransaction(
//       bool? isDeposit, String? getMobile, int? getAmount) async {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.getDocId)
//         .get();
//
//     var totalCredit;
//     var totalDebit;
//     var netTotal;
//     var totalIntCredit;
//     var totalIntDebit;
//     var netIntTotal;
//
//     if (snapshot.exists) {
//       Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
//       totalCredit = data['totalCredit'];
//       totalDebit = data['totalDebit'];
//       netTotal = data['netTotal'];
//       totalIntCredit = data['totalIntCredit'];
//       totalIntDebit = data['totalIntDebit'];
//       netIntTotal = data['netIntTotal'];
//     }
//
//     // String getNetBal = await fetchUserNetBal();
//
//     if (!isDeposit!) {
//       double getFinalAmount = getAmount!.toDouble();
//       // double? getFinalNetBal = getNetBal ?? 0.0;
//       double? getFinalNetBal = totalCredit ?? 0.0;
//       double? getFinalNetBal2 = totalDebit ?? 0.0;
//
//       if (getFinalAmount > getFinalNetBal!) {
//         showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (BuildContext context) {
//               return CustomDialogBox(
//                 title: "Message!",
//                 descriptions: "Entered amount Greater than User's Netbalance",
//                 text: "Ok",
//                 isCancel: false,
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               );
//             });
//         return;
//       }
//
//       if ((getFinalNetBal2! + getFinalAmount) > getFinalNetBal!) {
//         showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (BuildContext context) {
//               return CustomDialogBox(
//                 title: "Message!",
//                 descriptions: "Entered amounan User's Netbalance",
//                 text: "Ok",
//                 isCancel: false,
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               );
//             });
//         return;
//       }
//     }
//
//     if (data == ConnectivityResult.none) {
//       Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Simulating some asynchronous operation
//       // await Future.delayed(Duration(seconds: 2));
//       double? getInterest = 0.0;
//
//       if (isDeposit!) {
//         getInterest =
//             await calculateInterest(getAmount!.toDouble(), interestPercent);
//       }
//
//       Timestamp timestamp = Timestamp.fromDate(selectedDate);
//
//       try {
//         //todo:- adding transaction inside user's table
//         fireStore
//             .collection('users')
//             .doc(widget.getDocId)
//             .collection('transaction')
//             .add({
//           'mobile': getMobile,
//           'isDeposit': isDeposit == true ? true : false,
//           'amount': getAmount,
//           'interest': getInterest,
//           'date': DateFormat('yyyy-MM-dd')
//               .format(selectedDate), // Only date in 'yyyy-MM-dd' format
//           // 'timestamp': DateTime.now(),
//           'timestamp': timestamp,
//         }).then((_) async {
//           setState(() {
//             txtAmount.text = "";
//           });
//
//           Constants.showToast(
//               "Transaction Added Successfully", ToastGravity.BOTTOM);
//
//           QuerySnapshot adminSnapshot =
//               await FirebaseFirestore.instance.collection('adminDetails').get();
//
//           var admnTtlCredit;
//           var admnTtlDebit;
//           var admnTtlIntCredit;
//           var admnTtlIntDebit;
//
//           await Future.forEach(adminSnapshot.docs, (doc) async {
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//
//             admnTtlCredit = data['totalCredit'];
//             admnTtlDebit = data['totalDebit'];
//             admnTtlIntCredit = data['totalIntCredit'];
//             admnTtlIntDebit = data['totalIntDebit'];
//           });
//
//           //todo:- updating new values to admin table, and user document
//           //todo:- admin set
//           double? getFinalCredit = 0.0;
//           double? getFinalIntCredit = 0.0;
//           double? getFinalDebit = 0.0;
//           double? getFinalIntDedit = 0.0;
// //todo:- user set
//           double? getFinalUsrCredit = 0.0;
//           double? getFinalUsrIntCredit = 0.0;
//           double? getFinalUsrDebit = 0.0;
//           double? getFinalUsrIntDedit = 0.0;
//
//           double? getFinalNetTotal = 0.0;
//           double? getFinalNetIntTotal = 0.0;
//
//           Map<String, dynamic> newAdminData = {};
//
//           Map<String, dynamic> newUserData = {};
//
//           // getFinalNetTotal = totalCredit! - totalDebit!;
//           // getFinalNetIntTotal = totalIntCredit! - totalIntDebit!;
//
//           if (isDeposit) {
//             //todo:- admin set
//             getFinalCredit = admnTtlCredit!.toDouble() + getAmount!.toDouble();
//             getFinalIntCredit =
//                 admnTtlIntCredit!.toDouble() + getInterest!.toDouble();
//
// //todo:- user set
//             getFinalUsrCredit = totalCredit!.toDouble() + getAmount!.toDouble();
//             getFinalUsrIntCredit =
//                 totalIntCredit!.toDouble() + getInterest!.toDouble();
//
//             //todo:- check once
//             getFinalNetTotal = getFinalUsrCredit! - getFinalUsrDebit!;
//             getFinalNetIntTotal = getFinalUsrIntCredit! - getFinalUsrIntDedit!;
//
//             newAdminData = {
//               'totalCredit': getFinalCredit?.toDouble(),
//               'totalIntCredit': getFinalIntCredit?.toDouble(),
//             };
//
//             newUserData = {
//               'totalCredit': getFinalUsrCredit.toDouble(),
//               'totalIntCredit': getFinalUsrIntCredit.toDouble(),
//               // 'netTotal': getFinalNetTotal,
//               // 'netIntTotal': getFinalNetIntTotal,
//             };
//
//             await updateAdminDetails(newAdminData);
//             await updateUserDetails(newUserData, snapshot);
//           } else {
//             //todo: admin set
//             getFinalDebit = admnTtlDebit!.toDouble() + getAmount!.toDouble();
//             getFinalIntDedit =
//                 admnTtlIntDebit!.toDouble() + getInterest!.toDouble();
//
//             //todo:- user set
//             getFinalUsrDebit = totalDebit!.toDouble() + getAmount!.toDouble();
//             getFinalUsrIntDedit =
//                 totalIntDebit!.toDouble() + getInterest!.toDouble();
//
//             //todo:- check once
//             getFinalNetTotal = getFinalUsrCredit - getFinalUsrDebit!;
//             getFinalNetIntTotal = getFinalUsrIntCredit - getFinalUsrIntDedit!;
//
//             newAdminData = {
//               'totalDebit': getFinalDebit?.toDouble(),
//               'totalIntDebit': getFinalIntDedit?.toDouble(),
//             };
//
//             newUserData = {
//               'totalDebit': getFinalUsrDebit.toDouble(),
//               'totalIntDebit': getFinalUsrIntDedit.toDouble(),
//               // 'netTotal': getFinalNetTotal,
//               // 'netIntTotal': getFinalNetIntTotal,
//             };
//
//             await updateAdminDetails(newAdminData);
//             await updateUserDetails(newUserData, snapshot);
//           }
//
//           // getFinalNetTotal = getFinalUsrCredit - getFinalUsrDebit!;
//           // getFinalNetIntTotal = getFinalUsrIntCredit - getFinalUsrIntDedit!;
//
//           //todo:- check once
//           // newUserData = {
//           //   'netTotal': getFinalNetTotal,
//           //   'netIntTotal': getFinalNetIntTotal,
//           //   // Add more fields and their new values
//           // };
//
//           Map<String, dynamic> aaa = {
//             'totalCredit': 0.0,
//             'totalIntCredit': 0.0,
//             'totalDebit': 0.0,
//             'totalIntDebit': 0.0,
//           };
//
//           Map<String, dynamic> bbb = {
//             'totalCredit': 0.0,
//             'totalDebit': 0.0,
//             'netTotal': 0.0,
//             'totalIntCredit': 0.0,
//             'totalIntDebit': 0.0,
//             'netIntTotal': 0.0,
//             // Add more fields and their new values
//           };
//
//           // await updateAdminDetails(newAdminData);
//           // await updateUserDetails(newUserData, snapshot);
//
//           // await updateAdminDetails(aaa);
//           // await updateUserDetails(bbb, snapshot);
//         }).catchError((error) {
//           print('$error');
//         });
//       } catch (error) {
//         // Handle the error
//         print('Error retrieving user details: $error');
//       }
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

  void addTransaction(bool? isSavOrCashback) async {
    FocusScope.of(context).unfocus();

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }

    if (isSavOrCashback!) {
      amount = txtAmount.text.isEmpty ? 0 : int.parse(txtAmount.text);
      if (amount != 0) {
        setState(() {
          _isLoading = true;
        });

        amount = int.parse(txtAmount.text);

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.getDocId)
            .get();

        var totalCredit;
        var totalDebit;
        var netTotal;
        var totalIntCredit;
        var totalIntDebit;
        var netIntTotal;

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          totalCredit = data['totalCredit'];
          totalDebit = data['totalDebit'];
          netTotal = data['netTotal'];
          totalIntCredit = data['totalIntCredit'];
          totalIntDebit = data['totalIntDebit'];
          netIntTotal = data['netIntTotal'];
        }

        // String getNetBal = await fetchUserNetBal();

        if (!isDepositSelected!) {
          double getFinalAmount = amount!.toDouble();
          // double? getFinalNetBal = getNetBal ?? 0.0;
          double? getFinalNetBal = totalCredit ?? 0.0;
          double? getFinalNetBal2 = totalDebit ?? 0.0;

          double? getFinalCashbckBal = totalIntCredit ?? 0.0;
          double? getFinalCashbckBal2 = totalIntDebit ?? 0.0;

          //todo:-below code is to check savings money withdrawal eligibility
          if (getFinalAmount > getFinalNetBal!) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  // setState(() {
                  //   _isLoading = false;
                  // });
                  return CustomDialogBox(
                    title: "Message!",
                    descriptions:
                        "Entered amount Greater than User's Netbalance",
                    text: "Ok",
                    isCancel: false,
                    onTap: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                });
            return;
          }

          if ((getFinalNetBal2! + getFinalAmount) > getFinalNetBal!) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  // setState(() {
                  //   _isLoading = false;
                  // });
                  return CustomDialogBox(
                    title: "Message!",
                    descriptions: "Entered amount  User's Netbalance",
                    text: "Ok",
                    isCancel: false,
                    onTap: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                });
            return;
          }
        }

        if (data == ConnectivityResult.none) {
          Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
          return;
        }

        try {
          // Simulating some asynchronous operation
          // await Future.delayed(Duration(seconds: 2));

          double? getInterest = 0.0;
          //todo:-25.9.23 adding random interest between 0.5% to 1% interest for each transaction
          interestPercent = await generateRandomInterest();
          if (isDepositSelected!) {
            getInterest =
                await calculateInterest(amount!.toDouble(), interestPercent);
          }

          Timestamp timestamp = Timestamp.fromDate(selectedDate);

          try {
            //todo:- adding transaction inside user's table
            fireStore
                .collection('users')
                .doc(widget.getDocId)
                .collection('transaction')
                .add({
              'mobile': widget.getMobile,
              'isDeposit': isDepositSelected == true ? true : false,
              'isCashbckDeposit': true,
              'amount': amount,
              'interest': getInterest,
              'date': DateFormat('yyyy-MM-dd')
                  .format(selectedDate), // Only date in 'yyyy-MM-dd' format
              // 'timestamp': DateTime.now(),
              'timestamp': timestamp,
            }).then((_) async {
              setState(() {
                txtAmount.text = "";
                _isLoading = false;
                swtchMaxIntReached = false;
                isMaxIntReached = false;
              });

              Constants.showToast(
                  "Transaction Added Successfully", ToastGravity.BOTTOM);

              QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
                  .collection('adminDetails')
                  .get();

              var admnTtlCredit;
              var admnTtlDebit;
              var admnTtlIntCredit;
              var admnTtlIntDebit;

              await Future.forEach(adminSnapshot.docs, (doc) async {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                admnTtlCredit = data['totalCredit'];
                admnTtlDebit = data['totalDebit'];
                admnTtlIntCredit = data['totalIntCredit'];
                admnTtlIntDebit = data['totalIntDebit'];
              });

              //todo:- updating new values to admin table, and user document
              //todo:- admin set
              double? getFinalCredit = 0.0;
              double? getFinalIntCredit = 0.0;
              double? getFinalDebit = 0.0;
              double? getFinalIntDedit = 0.0;
//todo:- user set
              double? getFinalUsrCredit = 0.0;
              double? getFinalUsrIntCredit = 0.0;
              double? getFinalUsrDebit = 0.0;
              double? getFinalUsrIntDedit = 0.0;

              double? getFinalNetTotal = 0.0;
              double? getFinalNetIntTotal = 0.0;

              Map<String, dynamic> newAdminData = {};

              Map<String, dynamic> newUserData = {};

              // getFinalNetTotal = totalCredit! - totalDebit!;
              // getFinalNetIntTotal = totalIntCredit! - totalIntDebit!;

              if (isDepositSelected) {
                //todo:- admin set
                getFinalCredit = admnTtlCredit!.toDouble() + amount!.toDouble();
                getFinalIntCredit =
                    admnTtlIntCredit!.toDouble() + getInterest!.toDouble();

//todo:- user set
                getFinalUsrCredit =
                    totalCredit!.toDouble() + amount!.toDouble();
                getFinalUsrIntCredit =
                    totalIntCredit!.toDouble() + getInterest!.toDouble();

                //todo:- check once
                getFinalNetTotal = getFinalUsrCredit! - getFinalUsrDebit!;
                getFinalNetIntTotal =
                    getFinalUsrIntCredit! - getFinalUsrIntDedit!;

                newAdminData = {
                  'totalCredit': getFinalCredit?.toDouble(),
                  'totalIntCredit': getFinalIntCredit?.toDouble(),
                };

                newUserData = {
                  'totalCredit': getFinalUsrCredit.toDouble(),
                  'totalIntCredit': getFinalUsrIntCredit.toDouble(),
                  // 'netTotal': getFinalNetTotal,
                  // 'netIntTotal': getFinalNetIntTotal,
                };

                await updateAdminDetails(newAdminData);
                await updateUserDetails(newUserData, snapshot);
              } else {
                //todo: admin set
                getFinalDebit = admnTtlDebit!.toDouble() + amount!.toDouble();
                getFinalIntDedit =
                    admnTtlIntDebit!.toDouble() + getInterest!.toDouble();

                //todo:- user set
                getFinalUsrDebit = totalDebit!.toDouble() + amount!.toDouble();
                getFinalUsrIntDedit =
                    totalIntDebit!.toDouble() + getInterest!.toDouble();

                //todo:- check once
                getFinalNetTotal = getFinalUsrCredit - getFinalUsrDebit!;
                getFinalNetIntTotal =
                    getFinalUsrIntCredit - getFinalUsrIntDedit!;

                newAdminData = {
                  'totalDebit': getFinalDebit?.toDouble(),
                  'totalIntDebit': getFinalIntDedit?.toDouble(),
                };

                newUserData = {
                  'totalDebit': getFinalUsrDebit.toDouble(),
                  'totalIntDebit': getFinalUsrIntDedit.toDouble(),
                  // 'netTotal': getFinalNetTotal,
                  // 'netIntTotal': getFinalNetIntTotal,
                };

                await updateAdminDetails(newAdminData);
                await updateUserDetails(newUserData, snapshot);
              }

              // getFinalNetTotal = getFinalUsrCredit - getFinalUsrDebit!;
              // getFinalNetIntTotal = getFinalUsrIntCredit - getFinalUsrIntDedit!;

              //todo:- check once
              // newUserData = {
              //   'netTotal': getFinalNetTotal,
              //   'netIntTotal': getFinalNetIntTotal,
              //   // Add more fields and their new values
              // };

              Map<String, dynamic> aaa = {
                'totalCredit': 0.0,
                'totalIntCredit': 0.0,
                'totalDebit': 0.0,
                'totalIntDebit': 0.0,
              };

              Map<String, dynamic> bbb = {
                'totalCredit': 0.0,
                'totalDebit': 0.0,
                'netTotal': 0.0,
                'totalIntCredit': 0.0,
                'totalIntDebit': 0.0,
                'netIntTotal': 0.0,
                // Add more fields and their new values
              };

              // await updateAdminDetails(newAdminData);
              // await updateUserDetails(newUserData, snapshot);

              // await updateAdminDetails(aaa);
              // await updateUserDetails(bbb, snapshot);
            }).catchError((error) {
              print('$error');
            });
          } catch (error) {
            // Handle the error
            setState(() {
              _isLoading = false;
            });
            print('Error retrieving user details: $error');
          }
        } catch (error) {
          setState(() {
            _isLoading = false;
          });
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        Constants.showToast(
            txtAmount.text.isEmpty
                ? "Please Enter Amount"
                : "Please Enter Valid Amount",
            ToastGravity.BOTTOM);
        return;
      }
    } else {
//todo:- 31.8.23 , it is executed if admin enters for adding cashback details for user

      double amount =
          txtAmount.text.isEmpty ? 0.0 : double.parse(txtAmount.text);

      if (amount != 0) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.getDocId)
            .get();

        var totalCredit;
        var totalDebit;
        var netTotal;
        var totalIntCredit;
        var totalIntDebit;
        var netIntTotal;

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          totalCredit = data['totalCredit'];
          totalDebit = data['totalDebit'];
          netTotal = data['netTotal'];
          totalIntCredit = data['totalIntCredit'];
          totalIntDebit = data['totalIntDebit'];
          netIntTotal = data['netIntTotal'];
        }

        // String getNetBal = await fetchUserNetBal();

        if (!isDepositSelected!) {
          double getFinalAmount = amount!.toDouble();
          // double? getFinalNetBal = getNetBal ?? 0.0;
          double? getFinalNetBal = totalCredit ?? 0.0;
          double? getFinalNetBal2 = totalDebit ?? 0.0;

          double? getFinalCashbckBal = totalIntCredit ?? 0.0;
          double? getFinalCashbckBal2 = totalIntDebit ?? 0.0;

          //todo:- 31.8.23 - below code is to check cashback money withdrawal eligibility
          if (getFinalAmount > getFinalCashbckBal!) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return CustomDialogBox(
                    title: "Message!",
                    descriptions:
                        "Entered amount Greater than User's Cashback balance",
                    text: "Ok",
                    isCancel: false,
                    onTap: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                });
            return;
          }

          if ((getFinalCashbckBal2! + getFinalAmount) > getFinalCashbckBal!) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  // setState(() {
                  //   _isLoading = false;
                  // });
                  return CustomDialogBox(
                    title: "Message!",
                    descriptions: "Entered amount  User's Cashback balance",
                    text: "Ok",
                    isCancel: false,
                    onTap: () {
                      setState(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                });
            return;
          }
        }

        if (isDepositSelected) {
          Constants.showToast(
              "Deposit Click panna sema adi vanguva!!", ToastGravity.BOTTOM);
          return;
        } else {
          Timestamp timestamp = Timestamp.fromDate(selectedDate);

          try {
            //todo:- adding transaction inside user's table
            fireStore
                .collection('users')
                .doc(widget.getDocId)
                .collection('cashbacks')
                .add({
              'mobile': widget.getMobile,
              'isCashbckDeposit': isDepositSelected == true ? true : false,
              'amount': amount,
              'date': DateFormat('yyyy-MM-dd')
                  .format(selectedDate), // Only date in 'yyyy-MM-dd' format
              // 'timestamp': DateTime.now(),
              'timestamp': timestamp,
            }).then((_) async {
              setState(() {
                txtAmount.text = "";
                _isLoading = false;
              });

              Constants.showToast(
                  "Transaction Added Successfully", ToastGravity.BOTTOM);

//todo:- user set
              double? getFinalUsrCredit = 0.0;
              double? getFinalUsrIntCredit = 0.0;
              double? getFinalUsrDebit = 0.0;
              double? getFinalUsrIntDedit = 0.0;

              double? getFinalNetTotal = 0.0;
              double? getFinalNetIntTotal = 0.0;

              Map<String, dynamic> newAdminData = {};

              Map<String, dynamic> newUserData = {};

              if (isDepositSelected) {
//todo:- user set
//                getFinalUsrCredit =
//                    totalCredit!.toDouble() + amount!.toDouble();
//                getFinalUsrIntCredit =
//                    totalIntCredit!.toDouble() + amount!.toDouble();
//
//
//
//                newUserData = {
//                  'totalCredit': getFinalUsrCredit?.toDouble(),
//                  'totalIntCredit': getFinalUsrIntCredit?.toDouble(),
//                  // 'netTotal': getFinalNetTotal,
//                  // 'netIntTotal': getFinalNetIntTotal,
//                };
//
//
//                await updateUserDetails(newUserData, snapshot);
              } else {
                //todo:- user set
                getFinalUsrDebit = totalDebit!.toDouble() + amount!.toDouble();
                getFinalUsrIntDedit =
                    totalIntDebit!.toDouble() + amount!.toDouble();

                newUserData = {
                  // 'totalDebit': getFinalUsrDebit?.toDouble(),
                  'totalIntDebit': getFinalUsrIntDedit?.toDouble(),
                  // 'netTotal': getFinalNetTotal,
                  // 'netIntTotal': getFinalNetIntTotal,
                };

                await updateUserDetails(newUserData, snapshot);
              }
            }).catchError((error) {
              print('$error');
            });
          } catch (error) {
            // Handle the error
            setState(() {
              _isLoading = false;
            });
            print('Error retrieving user details: $error');
          }
        }
      } else {
        Constants.showToast(
            txtAmount.text.isEmpty
                ? "Please Enter Amount"
                : "Please Enter Valid Amount",
            ToastGravity.BOTTOM);
        return;
      }
    }
  }

  Future<double> generateRandomInterest() async {
    final random = Random();
    double interest = (random.nextInt(21) + 10) /
        100; // Generates a random interest between 0.1% and 0.3%
    return interest;
  }

  Future<void> updateAdminDetails(Map<String, dynamic> newData) async {
    QuerySnapshot snapshot = await _collectionReference!.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      String documentId = snapshot.docs.first.id;
      await _collectionReference!.doc(documentId).update(newData);
    }
  }

  Future<void> updateUserDetails(
      Map<String, dynamic> newData, DocumentSnapshot snapshot) async {
    // QuerySnapshot snapshot = await _collectionReference!.limit(1).get();
    // FirebaseFirestore.instance.collection('adminDetails');
    if (snapshot.id.isNotEmpty) {
      String documentId = snapshot.id;
      await _collectionUsers!
          .doc(documentId)
          .update(newData)
          .then((value) => null);
    }
  }

  //todo:-8.6.23 / handling date selection
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  Future<String> fetchUserNetBal() async {
    QuerySnapshot userSnapshot = await fireStore.collection('users').get();

    String total = await calculateNetBalances2(widget.getMobile);

    return total;
  }

  Future<double?> calculateInterest(double value, double interestPercent) {
    if (value > 100) {
      return Future.value(0.0);
    }

    if (isMaxIntReached) {
      return Future.value(0.0);
    }

    double? interest = value * (interestPercent / 100);

    if (interest == null) {
      return Future.value(double.parse(0.00000.toStringAsFixed(3)));
    }

    return Future.value(double.parse(interest.toStringAsFixed(3)));
  }

  Future<String> calculateNetBalances(String? getUserNumber) async {
    List<Transaction> transactions = await getTransactions();

    String netBalances = "";

    double netBalance = 0;
    transactions.forEach((transaction) {
      if (transaction.mobile == getUserNumber) {
        if (transaction.isDeposit == true) {
          netBalance += transaction.amount;
        } else {
          netBalance -= transaction.amount;
        }
      }
      netBalances = netBalance.toString();
    });

    return netBalances;
  }

  Future<String> calculateNetBalances2(String? getUserNumber) async {
    List<Transaction2> transactions = await getTransactions2();

    String netBalances = "";

    double netBalance = 0;
    transactions.forEach((transaction) {
      if (transaction.isDeposit == true) {
        netBalance += transaction.amount ?? 0.0;
      } else {
        netBalance -= transaction.amount ?? 0.0;
      }

      netBalances = netBalance.toString();
    });

    return netBalances;
  }

  Future<List<Transaction>> getTransactions() async {
    QuerySnapshot transactionSnapshot =
        await fireStore.collection('transactions').get();

    List<Transaction> transactions = [];
    transactionSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Transaction transaction = Transaction(
        amount: data['amount'],
        date: data['date'],
        isDeposit: data['isDeposit'],
        mobile: data['mobile'],
      );
      transactions.add(transaction);
    });

    return transactions;
  }

  Future<List<Transaction2>> getTransactions2() async {
    QuerySnapshot transactionSnapshot = await fireStore
        .collection('users')
        .doc(widget.getDocId)
        .collection('transaction')
        .orderBy('timestamp')
        .get();

    List<Transaction2> transactions = [];
    transactionSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Transaction2 transaction = Transaction2(
          amount: data['amount'] ?? 0,
          date: data['date'],
          isDeposit: data['isDeposit'],
          mobile: data['mobile'],
          interest: data['interest'] ?? 0.00,
          transDocId: doc.id);
      transactions.add(transaction);
    });

    return transactions;
  }
}

class Transaction {
  int amount;
  String date;
  bool isDeposit;
  String mobile;

  Transaction({
    required this.amount,
    required this.date,
    required this.isDeposit,
    required this.mobile,
  });
}
