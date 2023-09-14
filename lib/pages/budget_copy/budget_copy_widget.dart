// ignore_for_file: prefer_interpolation_to_compose_strings, invalid_return_type_for_catch_error, unused_local_variable

import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_widgets.dart';
import 'package:maaakanmoney/pages/chatScreen.dart';
import 'package:maaakanmoney/pages/showMoneyRequest/ShowMoneyRequest.dart';
import 'package:maaakanmoney/phoneController.dart';
import 'package:sizer/sizer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/custom_dialog_box.dart';
import '../../components/search_box.dart';
import '../Auth/phone_auth_widget.dart';
import '../showUser/showUser.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pages/adduser/adduser_widget.dart';
import 'package:flutter/material.dart';
import 'BudgetCopyController.dart';
export 'budget_copy_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class BudgetCopyWidget extends ConsumerStatefulWidget {
  const BudgetCopyWidget({Key? key}) : super(key: key);

  @override
  _BudgetCopyWidgetState createState() => _BudgetCopyWidgetState();
}

class _BudgetCopyWidgetState extends ConsumerState<BudgetCopyWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<User2>? newDataList = [];
  AnimationController? lottieController;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _selectedIndex = 0;
  int _currentIndex = 0;
  bool showbutton = true;
  bool _isNavigationBarVisible = false;
  List<Widget> _containerWidgets = [];

  CollectionReference? _collectionReference;
  CollectionReference? _collectionUsers;

  List<String> imagePaths = [
    'images/background1.png',
    'images/background3.png',
  ];

  String? lastProcessedMessageId;
  @override
  void initState() {
    super.initState();
    // _startTimer();
    _collectionReference =
        FirebaseFirestore.instance.collection('adminDetails');
    _collectionUsers = FirebaseFirestore.instance.collection('users');
    ref
        .read(adminDashListProvider.notifier)
        .txtSearch
        .addListener(onChangedText);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(isRefreshIndicator.notifier).state = false;
      ref.read(isPendingReq.notifier).state = 0;
      ref.read(isPendingCashbckReq.notifier).state = 0;
      ref.read(isPendingMessages.notifier).state = 0;
      ref.read(adminDashListProvider.notifier).getDashboardDetails();
    });

    // addNewFieldToDocuments();
    // renameFieldInDocuments();
    // deleteFieldInDocuments();
    // addNewFieldToTransactions();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (alertcontext) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to Exit'),
            actions: <Widget>[
              TextButton(
                // onPressed: () =>
                //     Navigator.of(context).pop(false), //<-- SEE HERE
                onPressed: () {
                  Navigator.pop(alertcontext);
                },
                child: new Text('No'),
              ),
              TextButton(
                // onPressed: () =>
                //     Navigator.of(context).pop(true), // <-- SEE HERE
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    lottieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //todo:- 16.6.23
    final currentTime = DateTime.now().toLocal();
    final currentHour = currentTime.hour;
    int randomIndex = math.Random().nextInt(imagePaths.length);
    String randomImagePath = imagePaths[randomIndex];

    String greetingText = '';

    if (currentHour >= 6 && currentHour < 12) {
      greetingText = 'Good Morning';
    } else if (currentHour >= 12 && currentHour < 18) {
      greetingText = 'Good Afternoon';
    } else if (currentHour >= 18 || currentHour == 0 || currentHour < 6) {
      greetingText = 'Good Evening';
    } else if (currentHour == 14) {
      greetingText = 'Good Afternoon'; // Custom message for 14 hours
    }

    return WillPopScope(
      onWillPop: () => _onWillPop(),
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
                toolbarHeight: 100,
                title: _selectedIndex == 0
                    ? AnimatedContainer(
                        // color: Colors.white60,
                        duration: const Duration(milliseconds: 500),
                        height: _isNavigationBarVisible ? 50.0 : 60.0,
                        child: !_isNavigationBarVisible
                            ? SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        text: 'Hi..! ',
                                        children: [
                                          TextSpan(
                                            text: "Admin",
                                            style: TextStyle(
                                                fontSize: 23.0,
                                                fontFamily: 'Poppins',
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1),
                                          ),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                        fontSize: 23.0,
                                        letterSpacing: 1.0,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    Text(
                                      greetingText,
                                      style: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                            fontSize: 18.0,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : SearchBox(onChanged: (value) {
                                ref
                                    .read(adminDashListProvider.notifier)
                                    .txtSearch
                                    .text = value;
                              }))
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text.rich(
                              TextSpan(
                                text: 'Hi..! ',
                                children: [
                                  TextSpan(
                                    text: "Admin",
                                    style: TextStyle(
                                        fontSize: 23.0,
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 23.0,
                                letterSpacing: 1.0,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Text(
                              greetingText,
                              style: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                actions: [
                  Consumer(builder: (context, ref, child) {
                    int? isPendingRequest = ref.watch(isPendingReq);
                    int? isPendingCashbckRequest =
                        ref.watch(isPendingCashbckReq);
                    int? isPendingMessage = ref.watch(isPendingMessages);

                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 20.0, 0.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialogBox(
                                      title: "Alert!",
                                      descriptions:
                                          "Are you sure, Do you want to logout",
                                      text: "Ok",
                                      isCancel: true,
                                      onTap: () {
                                        // openAnotherApp("com.phonepe.app");
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyPhone()),
                                          (route) =>
                                              false, // Remove all routes from the stack
                                        );
                                      },
                                    );
                                  });
                            },
                            child: Icon(
                              Icons.logout,
                              color:
                                  FlutterFlowTheme.of(context).primaryBtnText,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
                centerTitle: false,
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
          child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              _toggleNavigationBarVisibility(false);
            } else if (notification.direction == ScrollDirection.reverse) {
              _toggleNavigationBarVisibility(true);
            }
            return true;
          }, child: Consumer(builder: (context, ref, child) {
            ref.read(adminDashListProvider.notifier).data =
                ref.watch(connectivityProvider);
            // AdminDashState getAdminDashList = ref.watch(adminDashListProvider);
            AdminDashState2 getAdminDashList = ref.watch(adminDashListProvider);
            ref.watch(getListItemProvider);
            bool? isRefresh = ref.watch(isRefreshIndicator);
            bool isLoading = false;

            ref.read(adminDashListProvider.notifier).admnTtlCredit = ref
                .read(adminDashListProvider.notifier)
                .userList2!
                .map((val) => val.totalCredit ?? 0.0)
                .fold(
                    0,
                    (previousValue, element) =>
                        (previousValue ?? 0.0) + element ?? 0.0);
            ref.read(adminDashListProvider.notifier).admnTtlDebit = ref
                .read(adminDashListProvider.notifier)
                .userList2!
                .map((val) => val.totalDebit ?? 0.0)
                .fold(
                    0,
                    (previousValue, element) =>
                        (previousValue ?? 0.0) + element ?? 0.0);

            ref.read(adminDashListProvider.notifier).admnTtlIntCredit = ref
                .read(adminDashListProvider.notifier)
                .userList2!
                .map((val) => val.totalIntCredit ?? 0.0)
                .fold(
                    0,
                    (previousValue, element) =>
                        (previousValue ?? 0.0) + element ?? 0.0);

            ref.read(adminDashListProvider.notifier).admnTtlIntDebit = ref
                .read(adminDashListProvider.notifier)
                .userList2!
                .map((val) => val.totalIntDebit ?? 0.0)
                .fold(
                    0,
                    (previousValue, element) =>
                        (previousValue ?? 0.0) + element ?? 0.0);

            ref.read(adminDashListProvider.notifier).totalNet = (ref
                        .read(adminDashListProvider.notifier)
                        .admnTtlCredit ??
                    0.0) -
                (ref.read(adminDashListProvider.notifier).admnTtlDebit ?? 0.0);
//todo:- 1.9.23 changes
            ref.read(adminDashListProvider.notifier).totalNetInt =
                (ref.read(adminDashListProvider.notifier).admnTtlIntCredit ??
                        0.0) -
                    (ref.read(adminDashListProvider.notifier).admnTtlIntDebit ??
                        0.0);

            // isRefreshIndicator = false;

            isLoading = (getAdminDashList.status == ResStatus.loading);
            return Container(
              color: Colors.white,
              height: 100.h,
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 22.h,
                          flexibleSpace: FlexibleSpaceBar(
                            background: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _scrollController,
                              child: Row(
                                children: [
                                  Container(
                                    width: 100.w,
                                    color: FlutterFlowTheme.of(context).primary,
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 0.0, 8.0, 6.0),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Card(
                                          elevation: 18,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        8.0, 8.0, 8.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(12.0,
                                                              10.0, 0.0, 0.0),
                                                      child: Text(
                                                        FFLocalizations.of(
                                                                context)
                                                            .getText(
                                                          'lfgx5yff' /* Net Balance */,
                                                        ),
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .override(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  12.0,
                                                                  0.0),
                                                          child: Text(
                                                            ' ₹' +
                                                                ref
                                                                    .read(adminDashListProvider
                                                                        .notifier)
                                                                    .totalNet!
                                                                    .toString(),
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              fontSize: 25.0,
                                                              letterSpacing:
                                                                  1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        20.0, 15.0, 20.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      FFLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'x2e1wpw3' /* Credited */,
                                                      ),
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                          FFLocalizations.of(
                                                                  context)
                                                              .getText(
                                                            '0qxzch1c' /* Debited */,
                                                          ),
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        18, 10, 18, 0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        print(
                                                            'Button pressed ...');
                                                      },
                                                      text: '₹ ' +
                                                          ref
                                                              .read(
                                                                  adminDashListProvider
                                                                      .notifier)
                                                              .admnTtlCredit
                                                              .toString(),
                                                      options: FFButtonOptions(
                                                        width: 100,
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.95),
                                                          letterSpacing: 0.5,
                                                          fontSize: 15,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    FFButtonWidget(
                                                      onPressed: () {},
                                                      text: '₹ ' +
                                                          ref
                                                              .read(
                                                                  adminDashListProvider
                                                                      .notifier)
                                                              .admnTtlDebit
                                                              .toString(),
                                                      options: FFButtonOptions(
                                                        width: 100,
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.95),
                                                          letterSpacing: 0.5,
                                                          fontSize: 15,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 100.w,
                                    color: FlutterFlowTheme.of(context).primary,
                                    child: Center(
                                      child: ClipPath(
                                        clipper: ImageClipper(),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(8.0, 0.0, 8.0, 6.0),
                                          child: Card(
                                            elevation: 18,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Image.asset(
                                                randomImagePath,
                                                width: 100.w,
                                                height: 100.h,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 100.w,
                                    color: FlutterFlowTheme.of(context).primary,
                                    child: Padding(
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 0.0, 8.0, 6.0),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Card(
                                          elevation: 18,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6.0),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        8.0, 8.0, 8.0, 8.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(12.0,
                                                              10.0, 0.0, 0.0),
                                                      child: Text(
                                                        "Cashback",
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyLarge
                                                                .override(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  letterSpacing:
                                                                      0.5,
                                                                ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                  0.0,
                                                                  10.0,
                                                                  12.0,
                                                                  0.0),
                                                          child: Text(
                                                            ' ₹' +
                                                                ref
                                                                    .read(adminDashListProvider
                                                                        .notifier)
                                                                    .totalNetInt!
                                                                    .toStringAsFixed(
                                                                        2),
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              fontSize: 25.0,
                                                              letterSpacing:
                                                                  1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        20.0, 15.0, 20.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Cashback Credited",
                                                      style:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodyLarge
                                                              .override(
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Text(
                                                          "Cashback Debited",
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: FlutterFlowTheme
                                                                  .of(context)
                                                              .headlineSmall
                                                              .override(
                                                                fontFamily:
                                                                    'Poppins',
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                fontSize: 12.0,
                                                                letterSpacing:
                                                                    0.5,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(
                                                        18, 10, 18, 0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    FFButtonWidget(
                                                      onPressed: () {
                                                        print(
                                                            'Button pressed ...');
                                                      },
                                                      text: '₹ ' +
                                                          ref
                                                              .read(
                                                                  adminDashListProvider
                                                                      .notifier)
                                                              .admnTtlIntCredit!
                                                              .toStringAsFixed(
                                                                  2),
                                                      options: FFButtonOptions(
                                                        width: 100,
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.95),
                                                          letterSpacing: 0.5,
                                                          fontSize: 15,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    FFButtonWidget(
                                                      onPressed: () {},
                                                      text: '₹ ' +
                                                          ref
                                                              .read(
                                                                  adminDashListProvider
                                                                      .notifier)
                                                              .admnTtlIntDebit!
                                                              .toStringAsFixed(
                                                                  2),
                                                      options: FFButtonOptions(
                                                        width: 100,
                                                        height: 40,
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        iconPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                0, 0, 0, 0),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        textStyle: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(.95),
                                                          letterSpacing: 0.5,
                                                          fontSize: 15,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .primary,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _selectedIndex == 0
                            ? SliverLayoutBuilder(
                                builder: (BuildContext context,
                                    SliverConstraints constraints) {
                                  WidgetsBinding.instance!
                                      .addPostFrameCallback((_) {
                                    ref
                                            .read(adminDashListProvider.notifier)
                                            .admnTtlCredit =
                                        ref
                                            .read(
                                                adminDashListProvider.notifier)
                                            .userList2!
                                            .map(
                                                (val) => val.totalCredit ?? 0.0)
                                            .fold(
                                                0,
                                                (previousValue, element) =>
                                                    (previousValue ?? 0.0) +
                                                        element ??
                                                    0.0);
                                    ref
                                            .read(adminDashListProvider.notifier)
                                            .admnTtlDebit =
                                        ref
                                            .read(
                                                adminDashListProvider.notifier)
                                            .userList2!
                                            .map((val) => val.totalDebit ?? 0.0)
                                            .fold(
                                                0,
                                                (previousValue, element) =>
                                                    (previousValue ?? 0.0) +
                                                        element ??
                                                    0.0);

                                    ref
                                            .read(adminDashListProvider.notifier)
                                            .admnTtlIntCredit =
                                        ref
                                            .read(
                                                adminDashListProvider.notifier)
                                            .userList2!
                                            .map((val) =>
                                                val.totalIntCredit ?? 0.0)
                                            .fold(
                                                0,
                                                (previousValue, element) =>
                                                    (previousValue ?? 0.0) +
                                                        element ??
                                                    0.0);

                                    ref
                                            .read(adminDashListProvider.notifier)
                                            .admnTtlIntDebit =
                                        ref
                                            .read(
                                                adminDashListProvider.notifier)
                                            .userList2!
                                            .map((val) =>
                                                val.totalIntDebit ?? 0.0)
                                            .fold(
                                                0,
                                                (previousValue, element) =>
                                                    (previousValue ?? 0.0) +
                                                        element ??
                                                    0.0);

                                    ref
                                        .read(adminDashListProvider.notifier)
                                        .totalNet = (ref
                                                .read(adminDashListProvider
                                                    .notifier)
                                                .admnTtlCredit ??
                                            0.0) -
                                        (ref
                                                .read(adminDashListProvider
                                                    .notifier)
                                                .admnTtlDebit ??
                                            0.0);
// todo:1.9.23 changes
                                    ref
                                        .read(adminDashListProvider.notifier)
                                        .totalNetInt = (ref
                                                .read(adminDashListProvider
                                                    .notifier)
                                                .admnTtlIntCredit ??
                                            0.0) -
                                        (ref
                                                .read(adminDashListProvider
                                                    .notifier)
                                                .admnTtlIntDebit ??
                                            0.0);
                                  });

                                  return SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        // final document = ref
                                        //     .read(
                                        //         adminDashListProvider.notifier)
                                        //     .userList2![index];
                                        final document = ref
                                            .read(getListItemProvider.notifier)
                                            .state![index];

                                        final name = document.name;
                                        final mobile = document.mobile;
                                        final securityCode =
                                            document.getSecurityCode;
                                        final total = document.getNetBal();
                                        final interest =
                                            document.getNetIntBal();

                                        String? getDocId = document.docId;
                                        bool? isMoneyRequest =
                                            document.isMoneyRequest;
                                        double? requestAmnt =
                                            document.requestAmount;
                                        double? requestCashbckAmnt =
                                            document.requestCashbckAmount;

                                        bool? isNotificationByAdmin =
                                            document.isNotificationByAdmin;

                                        String getFinInt = interest == null
                                            ? 0.0.toString()
                                            : interest.toStringAsFixed(2);

                                        return Container(
                                          color: Colors.white.withOpacity(0.95),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              elevation: 4.0,
                                              child: Slidable(
                                                key: const ValueKey(0),
                                                endActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  children: [
                                                    SlidableAction(
                                                      onPressed: (context) {
                                                        String? documentId =
                                                            getDocId;

                                                        showDialog(
                                                            barrierDismissible:
                                                                false,
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return CustomDialogBox(
                                                                title: "Alert!",
                                                                descriptions:
                                                                    "Are you sure, Do you want to delete this User",
                                                                text: "Ok",
                                                                isCancel: true,
                                                                onTap:
                                                                    () async {
                                                                  // User confirmed deletion, proceed with deleting the record

                                                                  if (ref
                                                                          .read(adminDashListProvider
                                                                              .notifier)
                                                                          .data ==
                                                                      ConnectivityResult
                                                                          .none) {
                                                                    Constants.showToast(
                                                                        "No Internet Connection",
                                                                        ToastGravity
                                                                            .BOTTOM);
                                                                    return;
                                                                  }

                                                                  DocumentSnapshot
                                                                      snapshot =
                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'users')
                                                                          .doc(
                                                                              documentId)
                                                                          .get();

                                                                  double?
                                                                      totalCredit;
                                                                  double?
                                                                      totalDebit;
                                                                  double?
                                                                      netTotal;
                                                                  double?
                                                                      totalIntCredit;
                                                                  double?
                                                                      totalIntDebit;
                                                                  double?
                                                                      netIntTotal;

                                                                  if (snapshot
                                                                      .exists) {
                                                                    Map<String,
                                                                            dynamic>
                                                                        data =
                                                                        snapshot.data() as Map<
                                                                            String,
                                                                            dynamic>;
                                                                    totalCredit =
                                                                        data['totalCredit']
                                                                            as double;
                                                                    totalDebit =
                                                                        data['totalDebit']
                                                                            as double;
                                                                    // netTotal = data[
                                                                    //         'netTotal']
                                                                    //     as double;
                                                                    totalIntCredit =
                                                                        data['totalIntCredit']
                                                                            as double;
                                                                    totalIntDebit =
                                                                        data['totalIntDebit']
                                                                            as double;
                                                                    // netIntTotal =
                                                                    //     data['netIntTotal']
                                                                    //         as double;
                                                                  }

                                                                  ref
                                                                      .read(adminDashListProvider
                                                                          .notifier)
                                                                      .firestore
                                                                      .collection(
                                                                          'users')
                                                                      .doc(
                                                                          documentId)
                                                                      .delete()
                                                                      .then(
                                                                          (value) async {
                                                                    QuerySnapshot
                                                                        adminSnapshot =
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection('adminDetails')
                                                                            .get();

                                                                    double?
                                                                        admnTtlCredit;
                                                                    double?
                                                                        admnTtlDebit;
                                                                    double?
                                                                        admnTtlIntCredit;
                                                                    double?
                                                                        admnTtlIntDebit;

                                                                    await Future.forEach(
                                                                        adminSnapshot
                                                                            .docs,
                                                                        (doc) async {
                                                                      Map<String,
                                                                              dynamic>
                                                                          data =
                                                                          doc.data() as Map<
                                                                              String,
                                                                              dynamic>;

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
                                                                    double?
                                                                        getFinalCredit =
                                                                        0.0;
                                                                    double?
                                                                        getFinalIntCredit =
                                                                        0.0;
                                                                    double?
                                                                        getFinalDebit =
                                                                        0.0;
                                                                    double?
                                                                        getFinalIntDedit =
                                                                        0.0;

                                                                    Map<String,
                                                                            dynamic>
                                                                        newAdminData =
                                                                        {};

                                                                    getFinalCredit = admnTtlCredit!
                                                                            .toDouble() -
                                                                        totalCredit!
                                                                            .toDouble();
                                                                    getFinalIntCredit = admnTtlIntCredit!
                                                                            .toDouble() -
                                                                        totalIntCredit!
                                                                            .toDouble();

                                                                    getFinalDebit = admnTtlDebit!
                                                                            .toDouble() -
                                                                        totalDebit!
                                                                            .toDouble();
                                                                    getFinalIntDedit = admnTtlIntDebit!
                                                                            .toDouble() -
                                                                        totalIntDebit!
                                                                            .toDouble();

                                                                    newAdminData =
                                                                        {
                                                                      'totalCredit':
                                                                          getFinalCredit
                                                                              .toDouble(),
                                                                      'totalIntCredit':
                                                                          getFinalIntCredit
                                                                              .toDouble(),
                                                                      'totalDebit':
                                                                          getFinalDebit
                                                                              .toDouble(),
                                                                      'totalIntDebit':
                                                                          getFinalIntDedit
                                                                              .toDouble(),
                                                                    };

                                                                    await updateAdminDetails(
                                                                        newAdminData);
                                                                    Navigator.pop(
                                                                        context); // Close the dialog
                                                                    // Perform any additional actions or show a success message
                                                                  }).catchError(
                                                                          (error) =>
                                                                              print('Failed to delete data: $error'));
                                                                },
                                                              );
                                                            });
                                                      },
                                                      backgroundColor:
                                                          const Color(
                                                              0xFFFE4A49),
                                                      foregroundColor:
                                                          Colors.white,
                                                      icon: Icons.delete,
                                                      label: 'Delete',
                                                    ),
                                                    SlidableAction(
                                                      onPressed: (context) {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ChatScreen(
                                                                  userName: name
                                                                      .toString(),
                                                                  adminId:
                                                                      Constants
                                                                          .adminId,
                                                                  userId:
                                                                      mobile,
                                                                  callNo:
                                                                      mobile,
                                                                  getDocId:
                                                                      getDocId),
                                                            )).then((value) {});
                                                      },
                                                      backgroundColor:
                                                          Colors.lightGreen,
                                                      foregroundColor:
                                                          Colors.white,
                                                      icon: Icons.message,
                                                      label: 'Message',
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: ListTile(
                                                    leading: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Card(
                                                            clipBehavior: Clip
                                                                .antiAliasWithSaveLayer,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary,
                                                            elevation: 6.0,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40.0),
                                                            ),
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          8.0,
                                                                          8.0,
                                                                          8.0,
                                                                          8.0),
                                                              child: Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .white,
                                                                size: 24.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                    title: Text(
                                                      name
                                                          .toString()
                                                          .toUpperCase(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF004D40),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16.0,
                                                          letterSpacing: 0.5),
                                                    ),
                                                    subtitle: Text('$mobile',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12.0,
                                                            letterSpacing:
                                                                0.5)),
                                                    trailing: Container(
                                                      width: 100,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text('$total' + ' ₹',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xFF004D40),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.5)),
                                                          Text(
                                                              '$getFinInt' +
                                                                  ' ₹',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.5)),
                                                        ],
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ShowUserWidget(
                                                              getMobile: mobile,
                                                              getExistingTotal:
                                                                  0.0,
                                                              getDocId:
                                                                  getDocId,
                                                              getUserName: name,
                                                              getUserIndex:
                                                                  index,
                                                              getSecurityCode:
                                                                  securityCode
                                                                      .toString(),
                                                            ),
                                                          )).then((value) {});
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      // childCount: ref
                                      //         .read(adminDashListProvider
                                      //             .notifier)
                                      //         .userList2!
                                      //         .length ??
                                      //     0,
                                      childCount: ref
                                              .read(
                                                  getListItemProvider.notifier)
                                              .state!
                                              .length ??
                                          0,
                                    ),
                                  );
                                },
                              )
                            : _selectedIndex == 1
                                ? SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                        final document = ref
                                            .read(
                                                adminDashListProvider.notifier)
                                            .moneyRequestUsers2?[index];

                                        final name = document?.name;
                                        final mobile = document?.mobile;
                                        final total = document?.getNetBal();
                                        final interest =
                                            document?.getNetIntBal();
                                        String? getDocId = document?.docId;
                                        bool? isMoneyRequest =
                                            document?.isMoneyRequest;
                                        double? requestAmnt =
                                            document?.requestAmount;
                                        double? requestCashbckAmnt =
                                            document?.requestCashbckAmount;

                                        return Container(
                                          color: Colors.white.withOpacity(0.95),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              elevation: 4.0,
                                              child: Slidable(
                                                key: const ValueKey(0),
                                                endActionPane: ActionPane(
                                                  motion: const ScrollMotion(),
                                                  children: [
                                                    Visibility(
                                                      visible: isMoneyRequest!
                                                          ? true
                                                          : false,
                                                      child: SlidableAction(
                                                        onPressed: (context) {
                                                          String? documentId =
                                                              getDocId;

                                                          showDialog(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return CustomDialogBox(
                                                                  title:
                                                                      "Alert!",
                                                                  descriptions:
                                                                      "Are you sure, Have you sent money",
                                                                  text: "Ok",
                                                                  isCancel:
                                                                      true,
                                                                  onTap: () {
                                                                    if (ref
                                                                            .read(adminDashListProvider
                                                                                .notifier)
                                                                            .data ==
                                                                        ConnectivityResult
                                                                            .none) {
                                                                      Constants.showToast(
                                                                          "No Internet Connection",
                                                                          ToastGravity
                                                                              .BOTTOM);
                                                                      return;
                                                                    }
                                                                    ref
                                                                        .read(adminDashListProvider
                                                                            .notifier)
                                                                        .updateData(
                                                                            getDocId,
                                                                            true);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                );
                                                              });
                                                        },
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                        icon: Icons
                                                            .currency_rupee,
                                                        label: isMoneyRequest!
                                                            ? 'paid'
                                                            : "UnPaid",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: ListTile(
                                                    leading: Card(
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      color: isMoneyRequest!
                                                          ? FlutterFlowTheme.of(
                                                                  context)
                                                              .primary
                                                          : FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      elevation: 6.0,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40.0),
                                                      ),
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                    8.0,
                                                                    8.0,
                                                                    8.0,
                                                                    8.0),
                                                        child: Icon(
                                                          Icons.person,
                                                          color: Colors.white,
                                                          size: 24.0,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      name
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF004D40),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                          letterSpacing: 0.5),
                                                    ),
                                                    subtitle: Text(
                                                        '$total' + ' ₹',
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF004D40),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.0,
                                                            letterSpacing:
                                                                0.5)),
                                                    trailing: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                            isMoneyRequest!
                                                                ? 'Requested'
                                                                : "",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .lightGreen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.5)),
                                                        Text(
                                                            isMoneyRequest!
                                                                ? '$requestAmnt' +
                                                                    ' ₹'
                                                                : "",
                                                            style: const TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14.0,
                                                                letterSpacing:
                                                                    0.5)),
                                                      ],
                                                    ),
                                                    onTap: () {},
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      childCount: ref
                                              .read(adminDashListProvider
                                                  .notifier)
                                              .moneyRequestUsers2
                                              ?.length ??
                                          0,
                                    ),
                                  )
                                : _selectedIndex == 2
                                    ? SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                            final document = ref
                                                .read(adminDashListProvider
                                                    .notifier)
                                                .notifications?[index];

                                            final name = document?.name;
                                            final mobile = document?.mobile;
                                            final total = document?.getNetBal();
                                            final interest =
                                                document?.getNetIntBal();
                                            String? getDocId = document?.docId;
                                            bool? isNotificationByAdmin =
                                                document?.isNotificationByAdmin;
                                            double? requestAmnt =
                                                document?.requestAmount;
                                            double? requestCashbckAmount =
                                                document?.requestCashbckAmount;
                                            String getFinInt = interest == null
                                                ? 0.0.toString()
                                                : interest.toStringAsFixed(2);

                                            return Container(
                                              color: Colors.white
                                                  .withOpacity(0.95),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  elevation: 4.0,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: ListTile(
                                                      leading: Card(
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        elevation: 6.0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      40.0),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      8.0,
                                                                      8.0,
                                                                      8.0,
                                                                      8.0),
                                                          child: Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                            size: 24.0,
                                                          ),
                                                        ),
                                                      ),
                                                      title: Text(
                                                        name
                                                            .toString()
                                                            .toUpperCase(),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xFF004D40),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.5),
                                                      ),
                                                      subtitle: Text('$mobile',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.0,
                                                              letterSpacing:
                                                                  0.5)),
                                                      trailing: Container(
                                                        width: 100,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                                '$total' + ' ₹',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFF004D40),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.5)),
                                                            Text(
                                                                '$getFinInt' +
                                                                    ' ₹',
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize:
                                                                        14.0,
                                                                    letterSpacing:
                                                                        0.5)),
                                                          ],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ChatScreen(
                                                                  userName: name
                                                                      .toString(),
                                                                  adminId:
                                                                      Constants
                                                                          .adminId,
                                                                  userId:
                                                                      mobile,
                                                                  callNo:
                                                                      mobile,
                                                                  getDocId:
                                                                      getDocId),
                                                            )).then((value) {});
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          childCount: ref
                                                  .read(adminDashListProvider
                                                      .notifier)
                                                  .notifications
                                                  ?.length ??
                                              0,
                                        ),
                                      )
                                    : _selectedIndex == 3
                                        ? SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              (BuildContext context,
                                                  int index) {
                                                final document = ref
                                                    .read(adminDashListProvider
                                                        .notifier)
                                                    .enquiryList?[index];

                                                final mobile = document?.mobile;

                                                return Container(
                                                  color: Colors.white
                                                      .withOpacity(0.95),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      elevation: 4.0,
                                                      child: Slidable(
                                                        key: const ValueKey(0),
                                                        endActionPane:
                                                            ActionPane(
                                                          motion:
                                                              const ScrollMotion(),
                                                          children: [
                                                            SlidableAction(
                                                              onPressed:
                                                                  (context) async {
                                                                String?
                                                                    contactNo =
                                                                    mobile;
                                                                final Uri
                                                                    launchUri =
                                                                    Uri(
                                                                  scheme: 'tel',
                                                                  path:
                                                                      contactNo,
                                                                );
                                                                await launchUrl(
                                                                    launchUri);
                                                              },
                                                              backgroundColor:
                                                                  const Color(
                                                                      0xFFFE4A49),
                                                              foregroundColor:
                                                                  Colors.white,
                                                              icon:
                                                                  Icons.delete,
                                                              label: 'Call',
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2),
                                                          child: ListTile(
                                                            leading: Card(
                                                              clipBehavior: Clip
                                                                  .antiAliasWithSaveLayer,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              elevation: 6.0,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40.0),
                                                              ),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            8.0,
                                                                            8.0,
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 24.0,
                                                                ),
                                                              ),
                                                            ),
                                                            title: Text(
                                                              mobile
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xFF004D40),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      16.0,
                                                                  letterSpacing:
                                                                      0.5),
                                                            ),
                                                            onTap: () {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              childCount: ref
                                                      .read(
                                                          adminDashListProvider
                                                              .notifier)
                                                      .enquiryList
                                                      ?.length ??
                                                  0,
                                            ),
                                          )
                                        : SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                              (BuildContext context,
                                                  int index) {
                                                final document = ref
                                                        .read(
                                                            adminDashListProvider
                                                                .notifier)
                                                        .cashBckRequestUsers2?[
                                                    index];

                                                final name = document?.name;
                                                final mobile = document?.mobile;
                                                final total =
                                                    document?.getNetBal();
                                                final interest =
                                                    document?.getNetIntBal();
                                                String modifyInt = interest
                                                        ?.toStringAsFixed(2) ??
                                                    '';
                                                String finalInterest =
                                                    modifyInt + ' ₹';
                                                String? getDocId =
                                                    document?.docId;
                                                bool? isCashbckRequest =
                                                    document?.isCashBackRequest;
                                                double? requestAmnt =
                                                    document?.requestAmount;
                                                String? requestCashbckAmnt =
                                                    document
                                                        ?.requestCashbckAmount
                                                        ?.toStringAsFixed(2);
                                                return Container(
                                                  color: Colors.white
                                                      .withOpacity(0.95),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Card(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      elevation: 4.0,
                                                      child: Slidable(
                                                        key: const ValueKey(0),
                                                        endActionPane:
                                                            ActionPane(
                                                          motion:
                                                              const ScrollMotion(),
                                                          children: [
                                                            Visibility(
                                                              visible:
                                                                  isCashbckRequest!
                                                                      ? true
                                                                      : false,
                                                              child:
                                                                  SlidableAction(
                                                                onPressed:
                                                                    (context) {
                                                                  String?
                                                                      documentId =
                                                                      getDocId;

                                                                  showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return CustomDialogBox(
                                                                          title:
                                                                              "Alert!",
                                                                          descriptions:
                                                                              "Are you sure, Have you sent money",
                                                                          text:
                                                                              "Ok",
                                                                          isCancel:
                                                                              true,
                                                                          onTap:
                                                                              () {
                                                                            if (ref.read(adminDashListProvider.notifier).data ==
                                                                                ConnectivityResult.none) {
                                                                              Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
                                                                              return;
                                                                            }
                                                                            ref.read(adminDashListProvider.notifier).updateData(getDocId,
                                                                                false);
                                                                            Navigator.pop(context);
                                                                          },
                                                                        );
                                                                      });
                                                                },
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                icon: Icons
                                                                    .currency_rupee,
                                                                label: isCashbckRequest!
                                                                    ? 'paid'
                                                                    : "UnPaid",
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2),
                                                          child: ListTile(
                                                            leading: Card(
                                                              clipBehavior: Clip
                                                                  .antiAliasWithSaveLayer,
                                                              color: isCashbckRequest!
                                                                  ? FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary
                                                                  : FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                              elevation: 6.0,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40.0),
                                                              ),
                                                              child:
                                                                  const Padding(
                                                                padding:
                                                                    EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                            8.0,
                                                                            8.0,
                                                                            8.0,
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons.person,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 24.0,
                                                                ),
                                                              ),
                                                            ),
                                                            title: Text(
                                                              name
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xFF004D40),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.5),
                                                            ),
                                                            subtitle: Text(
                                                                finalInterest,
                                                                style: const TextStyle(
                                                                    color: Color(
                                                                        0xFF004D40),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14.0,
                                                                    letterSpacing:
                                                                        0.5)),
                                                            trailing: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                    isCashbckRequest!
                                                                        ? 'Requested'
                                                                        : "",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .lightGreen,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            0.5)),
                                                                Text(
                                                                    isCashbckRequest!
                                                                        ? '$requestCashbckAmnt' +
                                                                            ' ₹'
                                                                        : "",
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            14.0,
                                                                        letterSpacing:
                                                                            0.5)),
                                                              ],
                                                            ),
                                                            onTap: () {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              childCount: ref
                                                      .read(
                                                          adminDashListProvider
                                                              .notifier)
                                                      .cashBckRequestUsers2
                                                      ?.length ??
                                                  0,
                                            ),
                                          ),
                      ],
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
                ],
              ),
            );
          })),
        ),
        floatingActionButton: Visibility(
          visible: _isNavigationBarVisible ? true : false,
          child: FloatingActionButton(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdduserWidget(),
                ),
              ).then((value) {
                //todo:- below code refresh firebase records automatically when come back to same screen
                // ref.read(adminDashListProvider.notifier).getDashboardDetails();
              });
            },
            child: Icon(
              Icons.person_add_alt,
              color: FlutterFlowTheme.of(context).primaryBtnText,
              size: 24.0,
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: _isNavigationBarVisible ? 70.0 : 0.0,
          child: Center(
            child: Consumer(builder: (context, ref, child) {
              int? isPendingRequest = ref.watch(isPendingReq);
              int? isPendingCshbckReq = ref.watch(isPendingCashbckReq);
              int? isPendingMessage = ref.watch(isPendingMessages);

              return SingleChildScrollView(
                child: BottomNavigationBar(
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'images/users.png',
                        fit: BoxFit.contain,
                        height: 25,
                        width: 25,
                      ),
                      label: "Users",
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(alignment: Alignment.center, children: [
                        Image.asset(
                          'images/moneyReq.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                        Visibility(
                          visible: isPendingRequest == 0 ? false : true,
                          child: Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      label: "Money Request",
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.95),
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(alignment: Alignment.center, children: [
                        Image.asset(
                          'images/message.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                        Visibility(
                          visible: isPendingMessage == 0 ? false : true,
                          child: Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      label: "Messages",
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.95),
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(alignment: Alignment.center, children: [
                        Image.asset(
                          'images/enquiry.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                      ]),
                      label: "Enquiry",
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.95),
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(alignment: Alignment.center, children: [
                        Image.asset(
                          'images/cashback.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                        Visibility(
                          visible: isPendingRequest == 0 ? false : true,
                          child: Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                "1",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      label: "Cashback",
                      backgroundColor: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.95),
                    )
                  ],
                  type: BottomNavigationBarType.shifting,
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.greenAccent,
                  iconSize: 40,
                  onTap: _onBottomItemTapped,
                  elevation: 5,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  //todo:- add this code snippet for adding new field to firestore collection
  Future<void> addNewFieldToDocuments() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final QuerySnapshot snapshot = await collectionRef.get();

    final List<DocumentSnapshot> documents = snapshot.docs;

    // Loop through each document and add a new field
    for (final DocumentSnapshot document in documents) {
      final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Check if the new field doesn't exist already
      // if (!data.containsKey('requestCashbckAmnt')) {
      //   // Add the new field to the data
      //   data['requestCashbckAmnt'] = 0;
      //
      //   // Update the document with the new field
      //   await document.reference.update(data);
      // }
      // Add the new field to the data
      data['requestCashbckAmnt'] = 0.0;

      // Update the document with the new field
      await document.reference.update(data);
    }
  }

  Future<void> addNewFieldToTransactions() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final QuerySnapshot snapshot = await collectionRef.get();

    final List<DocumentSnapshot> documents = snapshot.docs;

    for (final DocumentSnapshot document in documents) {
      final String userId = document.id;

      // Create a reference to the 'transactions' subcollection
      final CollectionReference transactionRef =
          collectionRef.doc(userId).collection('transaction');

      // Query for all documents within the 'transactions' subcollection
      final QuerySnapshot transactionSnapshot = await transactionRef.get();

      final List<DocumentSnapshot> transactionDocuments =
          transactionSnapshot.docs;

      // Loop through each transaction document and add a new field
      for (final DocumentSnapshot transactionDocument in transactionDocuments) {
        final Map<String, dynamic> data =
            transactionDocument.data() as Map<String, dynamic>;

        // Add the new field to the data
        data['isCashbckDeposit'] = true;

        // Update the transaction document with the new field
        await transactionDocument.reference.update(data);
      }
    }
  }

  //todo:- 28.8.23 to rename existing field
  Future<void> renameFieldInDocuments() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final QuerySnapshot snapshot = await collectionRef.get();

    final List<DocumentSnapshot> documents = snapshot.docs;

    // Loop through each document and rename the existing field
    for (final DocumentSnapshot document in documents) {
      final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      // Check if the old field name exists and the new field name doesn't
      if (data.containsKey('netTotal') &&
          !data.containsKey('isCashbackRequest')) {
        // Create a copy of the data without the old field
        final Map<String, dynamic> updatedData = Map.from(data);
        updatedData['isCashbackRequest'] = updatedData['netTotal'];
        updatedData.remove('netTotal');

        // Update the document with the renamed field
        await document.reference.update(updatedData);
      }
    }
  }

//todo:- 28.8.23 to delete existing field
  Future<void> deleteFieldInDocuments() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('users');

    final QuerySnapshot snapshot = await collectionRef.get();

    final List<DocumentSnapshot> documents = snapshot.docs;

    // Loop through each document and delete the specific field
    for (final DocumentSnapshot document in documents) {
      // Get the document reference
      final DocumentReference docRef = collectionRef.doc(document.id);

      // Update the document by removing the field
      await docRef.update({'netIntTotal': FieldValue.delete()});
    }
  }

  Future<void> _handleRefresh() async {
    // isRefreshIndicator = true;
    ref.read(isRefreshIndicator.notifier).state = true;
    return ref.read(adminDashListProvider.notifier).getDashboardDetails();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 3;

        _scrollToIndex(_currentIndex);
      });
    });
  }

  void _toggleNavigationBarVisibility(bool isVisible) {
    setState(() {
      _isNavigationBarVisible = isVisible;
    });
  }

  void _scrollToIndex(int index) {
    if (index >= 0 && index < 3) {
      _scrollController.animateTo(
        index * 100.w,
        duration: Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBottomItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  SliverPersistentHeader makeHeader(String headerText, bool isShowFilter) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
          minHeight: 50.0,
          maxHeight: 60.0,
          child: Container(
              alignment: Alignment.centerLeft,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      headerText,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ))),
    );
  }

  Future<void> updateAdminDetails(Map<String, dynamic> newData) async {
    QuerySnapshot snapshot = await _collectionReference!.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      String documentId = snapshot.docs.first.id;
      await _collectionReference!.doc(documentId).update(newData);
    }
  }

  void onChangedText() {
    ref.read(getListItemProvider.notifier).state =
        ref.read(adminDashListProvider.notifier).state.success1;

    newDataList = ref
        .read(getListItemProvider.notifier)
        .state!
        .where((i) => i.name!.toLowerCase().contains(ref
            .read(adminDashListProvider.notifier)
            .txtSearch
            .text
            .toLowerCase()))
        .toList();

    ref.read(getListItemProvider.notifier).state = newDataList;
  }

  // void onChangedText() {
  //   String searchQuery =
  //       ref.read(adminDashListProvider.notifier).txtSearch.text.toLowerCase();
  //
  //   List<User2>? originalDataList =
  //       ref.read(getListItemProvider.notifier).state;
  //
  //   if (originalDataList != null) {
  //     newDataList = originalDataList
  //         .where((i) =>
  //             jsonEncode(i).toString().toLowerCase().contains(searchQuery))
  //         .toList();
  //
  //     ref.read(getListItemProvider.notifier).state = newDataList;
  //   }
  // }
}

class ImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Start at the bottom-left corner
    path.quadraticBezierTo(
      // Add a quadratic bezier curve
      size.width / 2, size.height, // Control point and end point
      size.width, size.height - 50, // Control point and end point
    );
    path.lineTo(size.width, 0); // Draw a straight line to the top-right corner
    path.close(); // Close the path to form a closed shape
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double? minHeight;
  final double? maxHeight;
  final Widget? child;

  @override
  double get minExtent => minHeight!;

  @override
  double get maxExtent => math.max(maxHeight!, minHeight!);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
