// ignore_for_file: must_be_immutable, use_build_context_synchronously, invalid_return_type_for_catch_error, prefer_adjacent_string_concatenation

// import 'dart:html';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/components/custom_dialog_box.dart';
import 'package:maaakanmoney/pages/budget_copy/BudgetCopyController.dart';
import 'package:maaakanmoney/pages/chatScreen.dart';
import 'package:maaakanmoney/pages/showUser/showUserController.dart';
import 'package:maaakanmoney/pages/update_money/update_money_widget.dart';
import 'package:maaakanmoney/phoneController.dart';
import 'package:maaakanmoney/verify.dart';
import 'package:tuple/tuple.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowUserWidget extends ConsumerStatefulWidget {
  ShowUserWidget({
    Key? key,
    @required this.getMobile,
    @required this.getExistingTotal,
    @required this.getDocId,
    @required this.getUserName,
    @required this.getUserIndex,
    @required this.getSecurityCode,
  }) : super(key: key);

  String? getUserName;
  String? getMobile;
  double? getExistingTotal;
  String? getDocId;
  int? getUserIndex;
  String? getSecurityCode;

  @override
  _ShowUserWidgetState createState() => _ShowUserWidgetState();
}

class _ShowUserWidgetState extends ConsumerState<ShowUserWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  //todo:- 3.5.23
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  AnimationController? lottieController;
  ConnectivityResult? data;
  CollectionReference? _collectionReference;
  CollectionReference? _collectionUsers;
  @override
  void initState() {
    super.initState();

    _collectionReference =
        FirebaseFirestore.instance.collection('adminDetails');
    _collectionUsers = FirebaseFirestore.instance.collection('users');

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          ref.read(isUserRefreshIndicator.notifier).state = false;
        }));

    lottieController = AnimationController(vsync: this);

    lottieController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        lottieController!.repeat();
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(showUserListProvider.notifier).getUserListDetails(
          widget.getMobile, widget.getDocId, widget.getUserIndex);
    });
  }

  @override
  void dispose() {
    lottieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        key: scaffoldKey,
        appBar: responsiveVisibility(
          context: context,
          tabletLandscape: false,
          desktop: false,
        )
            ? AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: false,
                toolbarHeight: 110,
                titleSpacing: 0,
                title: Consumer(builder: (context, ref, child) {
                  Tuple4? getUserDetails = ref.watch(getUserNetTotal);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.getUserName.toString().toUpperCase() +
                            " - " +
                            widget.getSecurityCode.toString(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Credited",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                ),
                                Text(
                                  getUserDetails?.item1.toString() ?? "0.0",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Debited",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                ),
                                Text(
                                  getUserDetails?.item2.toString() ?? "0.0",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Net Bal",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                ),
                                Text(
                                  getUserDetails?.item3.toString() ?? "0.0",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Interest",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 15.0,
                                      ),
                                ),
                                Text(
                                  getUserDetails?.item4.toStringAsFixed(2) ??
                                      "0.0",
                                  overflow: TextOverflow.ellipsis,
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  PopupMenuButton(itemBuilder: (context) {
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.add,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text("Add Money")
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.add,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text("Cashback")
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.message,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text("Contact")
                          ],
                        ),
                      ),
                    ];
                  }, onSelected: (value) async {
                    if (value == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateMoneyWidget(
                              getMobile: widget.getMobile,
                              getDocId: widget.getDocId,
                              getExistingTotal: widget.getExistingTotal,
                              isSavOrCashback: true),
                        ),
                      ).then((value) {
                        //todo:- below code refresh firebase records automatically when come back to same screen

                        // ref
                        //     .read(showUserListProvider.notifier)
                        //     .getUserListDetails(widget.getMobile);
                      });
                    } else if (value == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateMoneyWidget(
                              getMobile: widget.getMobile,
                              getDocId: widget.getDocId,
                              getExistingTotal: widget.getExistingTotal,
                              isSavOrCashback: false),
                        ),
                      ).then((value) {
                        //todo:- below code refresh firebase records automatically when come back to same screen

                        // ref
                        //     .read(showUserListProvider.notifier)
                        //     .getUserListDetails(widget.getMobile);
                      });
                    } else if (value == 2) {
                      //todo:30.6.23 - chat creation

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                userName: widget.getUserName,
                                adminId: Constants.adminId,
                                userId: widget.getMobile,
                                callNo: widget.getMobile,
                                getDocId: widget.getDocId),
                          )).then((value) {});
                    }
                  }),
                ],
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
          child: Consumer(builder: (context, ref, child) {
            data = ref.watch(connectivityProvider);
            bool? isRefresh = ref.watch(isUserRefreshIndicator);
            ShowUserListState getUserTransList =
                ref.watch(showUserListProvider);
            bool isLoading = false;
            isLoading = (getUserTransList.status == ResStatus.loading);
            return Stack(children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.read(isUserRefreshIndicator.notifier).state = true;
                  // ref
                  //     .read(showUserListProvider.notifier)
                  //     .getUserNetBal(widget.getUserIndex);

                  //todo:- 13.7.23 altering mistaken total in admin details and user details

                  Map<String, dynamic> newAdminData = {};

                  Map<String, dynamic> newUserData = {};

                  Tuple4? getUserDetails =
                      ref.read(getUserNetTotal.notifier).state;

                  try {
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.getDocId)
                        .get();

                    double? totalCredit = 0.0;
                    double? totalDebit = 0.0;
                    double? netTotal = 0.0;
                    double? totalIntCredit = 0.0;
                    double? totalIntDebit = 0.0;
                    double? netIntTotal = 0.0;

                    if (snapshot.exists) {
                      Map<String, dynamic> data =
                          snapshot.data() as Map<String, dynamic>;
                      totalCredit = data['totalCredit'] as double;
                      totalDebit = data['totalDebit'] as double;

                      totalIntCredit = data['totalIntCredit'] as double;
                      totalIntDebit = data['totalIntDebit'] as double;

//todo:-  if got user details, then get admin details

                      double? admnTtlCredit;
                      double? admnTtlDebit;
                      double? admnTtlIntCredit;
                      double? admnTtlIntDebit;

                      QuerySnapshot adminSnapshot = await FirebaseFirestore
                          .instance
                          .collection('adminDetails')
                          .get();

                      if (adminSnapshot != null &&
                          adminSnapshot.docs.isNotEmpty) {
                        await Future.forEach(adminSnapshot.docs, (doc) async {
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;

                          admnTtlCredit = data['totalCredit'] as double;
                          admnTtlDebit = data['totalDebit'] as double;
                          admnTtlIntCredit = data['totalIntCredit'] as double;
                          admnTtlIntDebit = data['totalIntDebit'] as double;
                        });

//todo:- if got user and admin details successfully then follow
                        if (getUserDetails.item1 == totalCredit) {
                          if (getUserDetails.item2 == totalDebit) {
                          } else {
                            newUserData = {
                              'totalDebit': getUserDetails.item2,
                            };

                            double? getadmnTotalDebit =
                                admnTtlDebit! - totalDebit!;
                            double? getFinalTotalDebit =
                                getadmnTotalDebit! + getUserDetails.item2!;

                            newAdminData = {
                              'totalCredit': getFinalTotalDebit,
                            };

                            await updateUserDetails(newUserData, snapshot);
                            await updateAdminDetails(newAdminData);
                          }
                        } else {
                          newUserData = {
                            'totalCredit': getUserDetails.item1,
                          };

                          double? getadmnTotalCredit =
                              admnTtlCredit! - totalCredit!;
                          double? getFinalTotalCredit =
                              getadmnTotalCredit! + getUserDetails.item1!;

                          newAdminData = {
                            'totalCredit': getFinalTotalCredit,
                          };

                          await updateUserDetails(newUserData, snapshot);
                          await updateAdminDetails(newAdminData);
                        }

                        if (getUserDetails.item4 == totalIntCredit) {
                        } else {
                          newUserData = {
                            'totalIntCredit': getUserDetails.item4,
                          };

                          double? getadmnTotalIntCredit =
                              admnTtlIntCredit! - totalIntCredit!;
                          double? getFinalTotalIntCredit =
                              getadmnTotalIntCredit! + getUserDetails.item4!;

                          newAdminData = {
                            'totalIntCredit': getFinalTotalIntCredit,
                          };

                          await updateUserDetails(newUserData, snapshot);
                          await updateAdminDetails(newAdminData);
                        }
                      }
                    } else {
                      // Handle the case when adminSnapshot is null or has no documents
                      print('adminSnapshot is null or has no documents.');
                    }
                  } catch (e) {
                    // Handle the network failure or unexpected error
                    print('An error occurred: $e');
                    // Display an error message to the user or perform appropriate error handling
                  }

                  return ref
                      .read(showUserListProvider.notifier)
                      .getUserListDetails(widget.getMobile, widget.getDocId,
                          widget.getUserIndex);
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ref
                        .read(adminDashListProvider.notifier)
                        .userList2?[widget.getUserIndex ?? 0]
                        .transactions
                        .length,
                    itemBuilder: (context, index) {
                      final document = ref
                          .read(adminDashListProvider.notifier)
                          .userList2?[widget.getUserIndex ?? 0]
                          .transactions;
                      final amount = document?[index].amount;
                      final transType = document?[index].isDeposit;
                      final date = document?[index].date;
                      final mobile = document?[index].mobile;
                      final transDocId = document?[index].transDocId;
                      final interest = document?[index].interest;

                      String getFinInt = interest == null
                          ? 0.0.toString()
                          : interest.toStringAsFixed(2);

                      return Slidable(
                          key: const ValueKey(0),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  // String documentId =
                                  //     documents[index].id;

                                  if (widget.getMobile == mobile) {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Alert!",
                                            descriptions:
                                                "Are you sure, Do you want delete this record",
                                            text: "Ok",
                                            isCancel: true,
                                            onTap: () async {
                                              try {
                                                Navigator.pop(
                                                    context); // Close the dialog
                                                // Simulating some asynchronous operation
                                                await Future.delayed(
                                                    const Duration(seconds: 0));
                                                // User confirmed deletion, proceed with deleting the record

                                                firestore
                                                    .collection('users')
                                                    .doc(widget.getDocId)
                                                    .collection('transaction')
                                                    .doc(transDocId)
                                                    .delete()
                                                    .then((_) async {
                                                  if (index >= 0 &&
                                                      index <
                                                          ref
                                                              .read(
                                                                  adminDashListProvider
                                                                      .notifier)
                                                              .userList2![widget
                                                                      .getUserIndex ??
                                                                  0]
                                                              .transactions
                                                              .length) {
                                                    ref
                                                        .read(
                                                            adminDashListProvider
                                                                .notifier)
                                                        .userList2?[widget
                                                                .getUserIndex ??
                                                            0]
                                                        .transactions
                                                        .removeAt(index);
                                                    print(
                                                        'Row deleted successfully!');
                                                  } else {
                                                    print(
                                                        'Invalid row number. Deletion failed.');
                                                  }

                                                  DocumentSnapshot snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(widget.getDocId)
                                                          .get();

                                                  double? totalCredit;
                                                  double? totalDebit;
                                                  double? netTotal;
                                                  double? totalIntCredit;
                                                  double? totalIntDebit;
                                                  double? netIntTotal;

                                                  if (snapshot.exists) {
                                                    Map<String, dynamic> data =
                                                        snapshot.data() as Map<
                                                            String, dynamic>;
                                                    totalCredit =
                                                        data['totalCredit']
                                                            as double;
                                                    totalDebit =
                                                        data['totalDebit']
                                                            as double;
                                                    netTotal = data['netTotal']
                                                        as double;
                                                    totalIntCredit =
                                                        data['totalIntCredit']
                                                            as double;
                                                    totalIntDebit =
                                                        data['totalIntDebit']
                                                            as double;
                                                    netIntTotal =
                                                        data['netIntTotal']
                                                            as double;
                                                  }

                                                  QuerySnapshot adminSnapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'adminDetails')
                                                          .get();

                                                  double? admnTtlCredit;
                                                  double? admnTtlDebit;
                                                  double? admnTtlIntCredit;
                                                  double? admnTtlIntDebit;

                                                  await Future.forEach(
                                                      adminSnapshot.docs,
                                                      (doc) async {
                                                    Map<String, dynamic> data =
                                                        doc.data() as Map<
                                                            String, dynamic>;

                                                    admnTtlCredit =
                                                        data['totalCredit']
                                                            as double;
                                                    admnTtlDebit =
                                                        data['totalDebit']
                                                            as double;
                                                    admnTtlIntCredit =
                                                        data['totalIntCredit']
                                                            as double;
                                                    admnTtlIntDebit =
                                                        data['totalIntDebit']
                                                            as double;
                                                  });

                                                  //todo:- updating new values to admin table, and user document
                                                  //todo:- admin set
                                                  double? getFinalCredit = 0.0;
                                                  double? getFinalIntCredit =
                                                      0.0;
                                                  double? getFinalDebit = 0.0;
                                                  double? getFinalIntDedit =
                                                      0.0;
//todo:- user set
                                                  double? getFinalUsrCredit =
                                                      0.0;
                                                  double? getFinalUsrIntCredit =
                                                      0.0;
                                                  double? getFinalUsrDebit =
                                                      0.0;
                                                  double? getFinalUsrIntDedit =
                                                      0.0;

                                                  double? getFinalNetTotal =
                                                      0.0;
                                                  double? getFinalNetIntTotal =
                                                      0.0;

                                                  Map<String, dynamic>
                                                      newAdminData = {};

                                                  Map<String, dynamic>
                                                      newUserData = {};

                                                  if (transType == true) {
                                                    //todo:- admin set
                                                    getFinalCredit =
                                                        admnTtlCredit!
                                                                .toDouble() -
                                                            amount!.toDouble();
                                                    getFinalIntCredit =
                                                        admnTtlIntCredit!
                                                                .toDouble() -
                                                            interest!
                                                                .toDouble();

//todo:- user set
                                                    getFinalUsrCredit =
                                                        totalCredit!
                                                                .toDouble() -
                                                            amount!.toDouble();
                                                    getFinalUsrIntCredit =
                                                        totalIntCredit!
                                                                .toDouble() -
                                                            interest!
                                                                .toDouble();

                                                    //todo:- check once

                                                    newAdminData = {
                                                      'totalCredit':
                                                          getFinalCredit,
                                                      'totalIntCredit':
                                                          getFinalIntCredit,
                                                    };

                                                    newUserData = {
                                                      'totalCredit':
                                                          getFinalUsrCredit,
                                                      'totalIntCredit':
                                                          getFinalUsrIntCredit,
                                                      // 'netTotal': getFinalNetTotal,
                                                      // 'netIntTotal': getFinalNetIntTotal,
                                                    };

                                                    await updateAdminDetails(
                                                        newAdminData);
                                                    await updateUserDetails(
                                                        newUserData, snapshot);
                                                  } else {
                                                    //todo: admin set
                                                    getFinalDebit =
                                                        admnTtlDebit!
                                                                .toDouble() -
                                                            amount!.toDouble();
                                                    getFinalIntDedit =
                                                        admnTtlIntDebit!
                                                                .toDouble() -
                                                            interest!
                                                                .toDouble();

                                                    //todo:- user set
                                                    getFinalUsrDebit =
                                                        totalDebit!.toDouble() -
                                                            amount!.toDouble();
                                                    getFinalUsrIntDedit =
                                                        totalIntDebit!
                                                                .toDouble() -
                                                            interest!
                                                                .toDouble();

                                                    newAdminData = {
                                                      'totalDebit':
                                                          getFinalDebit,
                                                      'totalIntDebit':
                                                          getFinalIntDedit,
                                                    };

                                                    newUserData = {
                                                      'totalDebit':
                                                          getFinalUsrDebit,
                                                      'totalIntDebit':
                                                          getFinalUsrIntDedit,
                                                      // 'netTotal': getFinalNetTotal,
                                                      // 'netIntTotal': getFinalNetIntTotal,
                                                    };

                                                    await updateAdminDetails(
                                                        newAdminData);
                                                    await updateUserDetails(
                                                        newUserData, snapshot);
                                                  }
                                                }).catchError((error) {
                                                  print('$error');
                                                });
                                              } catch (error) {
                                                print(error);
                                              }
                                            },
                                          );
                                        });
                                  }
                                },
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                8.0, 0.0, 8.0, 2.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              color: Colors.white,
                              elevation: 6.0,
                              shadowColor: Colors.white,
                              child: ListTile(
                                leading: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 6.0,
                                  color: transType == true
                                      ? FlutterFlowTheme.of(context).primary
                                      : Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      transType == true
                                          ? Icons.arrow_forward
                                          : Icons.arrow_back,
                                      color: Colors.white,
                                      size: 24.0,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  transType == true ? "Deposit" : "Withdraw",
                                  style: TextStyle(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      letterSpacing: 1),
                                ),
                                subtitle: Text(date.toString().toUpperCase(),
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                        letterSpacing: 0.5)),
                                trailing: Container(
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        transType == true
                                            ? "+" + '$amount' + ' ₹'
                                            : "-" + '$amount' + ' ₹',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: transType == true
                                              ? FlutterFlowTheme.of(context)
                                                  .primary
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            transType == true ? true : false,
                                        child: Text(
                                          transType == true
                                              ? "+" + '$getFinInt' + ' ₹'
                                              : '',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: transType == true
                                                ? Colors.grey
                                                : Colors.red,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14.0,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                            ),
                          ));
                    },
                  ),
                ),
              ),
              isLoading
                  ? isRefresh == true
                      ? Container()
                      : Container(
                          color: Colors.transparent,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: isRefresh == true
                                ? Colors.transparent
                                : FlutterFlowTheme.of(context).primary,
                          )),
                        )
                  : Container()
            ]);
          }),
        ),
      ),
    );
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
}
