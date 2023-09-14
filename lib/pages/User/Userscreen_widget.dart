// ignore_for_file: must_be_immutable, avoid_print, unused_label, prefer_interpolation_to_compose_strings, library_private_types_in_public_api, unused_local_variable

import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:maaakanmoney/components/ReusableWidget/ReusableCard.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/pages/Auth/mpin.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/User/UserScreen_Notifer.dart';
import 'package:maaakanmoney/pages/showUser/showUserController.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sizer/sizer.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/custom_dialog_box.dart';
import '../../components/search_box.dart';
import '../../phoneController.dart';
import '../budget_copy/BudgetCopyController.dart';
import '../chatScreen.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'Profile/Profile.dart';
import 'budget_model.dart';
export 'budget_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetWidget extends ConsumerStatefulWidget {
  BudgetWidget({
    Key? key,
    @required this.getMobile,
    @required this.getDocId,
  }) : super(key: key);
  String? getMobile;
  String? getDocId;

  @override
  _BudgetWidgetState createState() => _BudgetWidgetState();
}

class _BudgetWidgetState extends ConsumerState<BudgetWidget>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final txtReqAmount = TextEditingController();
  String? loginKey;

//todo:- 3.5.23
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  AnimationController? lottieController;
  String? lastProcessedMessageId;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  int _currentIndex = 0;
  int _selectedIndex = 0;
  List<Widget> _containerWidgets = [];
  bool _isNavigationBarVisible = false;
  bool isSavAmntReq = false;

  List<String> imagePaths = [
    'images/background1.png',
    'images/background3.png',
  ];

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
  void initState() {
    super.initState();

    _startTimer();

    lottieController = AnimationController(vsync: this);

    lottieController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        lottieController!.repeat();
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(isUserRefreshIndicator.notifier).state = false;
      ref.read(txtPaidStatus.notifier).state = false;
      ref.read(txtCashbckPaidStatus.notifier).state = false;
      ref.read(UserDashListProvider.notifier).getUserDetails(widget.getMobile);

      // _startListeningForNewMessages();
    });
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
    int randomIndex = math.Random().nextInt(imagePaths.length);
    String randomImagePath = imagePaths[randomIndex];
    //todo:- 16.6.23
    final currentTime = DateTime.now();
    final currentHour = currentTime.hour;

    String? greetingText = '';

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
      child: Consumer(builder: (context, ref, child) {
        ref.read(UserDashListProvider.notifier).data =
            ref.watch(connectivityProvider);
        bool? isRefresh = ref.watch(isUserRefreshIndicator);
        UserDashListState getUserTransList = ref.watch(UserDashListProvider);

        bool isLoading = false;
        isLoading = (getUserTransList.status == ResStatus.loading);

        return Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primary,
          appBar: responsiveVisibility(
            context: context,
            tabletLandscape: false,
            desktop: false,
          )
              ? AppBar(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 90,
                  leading: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 200),
                          pageBuilder: (_, __, ___) => ProfileScreen(
                            userName:
                                ref.read(UserDashListProvider.notifier).getUser,
                            greetingText: greetingText,
                            cashBack: ref
                                .read(UserDashListProvider.notifier)
                                .getTotalIntCredit
                                .toStringAsFixed(2),
                            netBalance: ref
                                .read(UserDashListProvider.notifier)
                                .getNetbalance
                                .toStringAsFixed(2),
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors
                            .blueGrey, // You can set your desired color here
                      ),
                      child: Icon(
                        Icons.person,
                        color:
                            Colors.black, // You can set your desired color here
                      ),
                    ),
                  ),
                  title: _selectedIndex == 0
                      ? AnimatedContainer(
                          // color: Colors.white60,
                          duration: const Duration(milliseconds: 500),
                          height: _isNavigationBarVisible ? 50.0 : 60.0,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    // text: 'Hi..! ',
                                    children: [
                                      TextSpan(
                                        text: ref
                                            .read(UserDashListProvider.notifier)
                                            .getUser,
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
                                  greetingText ?? "",
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
                          ))
                      : _selectedIndex == 1
                          ? SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      // text: 'Hi..! ',
                                      children: [
                                        TextSpan(
                                          text: "Congratulations",
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
                                    "Your Cashback Awaits – Enjoy!",
                                    style: FlutterFlowTheme.of(context)
                                        .titleSmall
                                        .override(
                                          fontFamily: 'Poppins',
                                          color: Colors.white,
                                          fontSize: 14.0,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : AnimatedContainer(
                              // color: Colors.white60,
                              duration: const Duration(milliseconds: 500),
                              height: _isNavigationBarVisible ? 50.0 : 60.0,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        // text: 'Hi..! ',
                                        children: [
                                          TextSpan(
                                            text: ref
                                                .read(UserDashListProvider
                                                    .notifier)
                                                .getUser,
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
                                      greetingText ?? "",
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
                              )),
                  actions: [
                    Row(
                      children: [
                        PopupMenuButton(itemBuilder: (context) {
                          return [
                            PopupMenuItem<int>(
                              value: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.share,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    size: 24.0,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text("Share app")
                                ],
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 2,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color:
                                        FlutterFlowTheme.of(context).secondary,
                                    size: 24.0,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text("Logout")
                                ],
                              ),
                            ),
                          ];
                        }, onSelected: (value) async {
                          if (value == 0) {
                            _showBottomSheet(context, 0);
                          } else if (value == 1) {
                            //todo:-1.08.23 uncomment below code
                            shareApp(context);
                          } else if (value == 2) {
                            //todo:-30.6.2023
                            //todo:- phone call launcher
                            // final Uri launchUri = Uri(
                            //   scheme: 'tel',
                            //   path: "+919360840071",
                            // );
                            // await launchUrl(launchUri);
                            //todo:- chat creation
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
                                            await SharedPreferences
                                                .getInstance();
                                        String? mPin = prefs.getString("Mpin");
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MpinPageWidget(
                                                      getMobileNo:
                                                          loginKey ?? "",
                                                      getMpin: mPin)),
                                          (route) =>
                                              false, // Remove all routes from the stack
                                        );
                                      }
                                    },
                                  );
                                });
                          }
                        }),
                      ],
                    ),
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
              },
              child: Container(
                color: Colors.white,
                height: 100.h,
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: CustomScrollView(
                        slivers: [
                          _selectedIndex == 0
                              ? SliverAppBar(
                                  automaticallyImplyLeading: false,
                                  expandedHeight: 22.h,
                                  flexibleSpace: FlexibleSpaceBar(
                                    background: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      controller: _scrollController,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 100.w,
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            child: Center(
                                              child: ClipPath(
                                                clipper: ImageClipper(),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 0.0, 8.0, 6.0),
                                                  child: Card(
                                                    elevation: 18,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
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
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .fromSTEB(
                                                      8.0, 0.0, 8.0, 6.0),
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Card(
                                                  elevation: 18,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6.0),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(8.0,
                                                                8.0, 8.0, 8.0),
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
                                                                      .fromSTEB(
                                                                      12.0,
                                                                      10.0,
                                                                      0.0,
                                                                      0.0),
                                                              child: Text(
                                                                FFLocalizations.of(
                                                                        context)
                                                                    .getText(
                                                                  'lfgx5yff' /* Net Balance */,
                                                                ),
                                                                style: FlutterFlowTheme.of(
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
                                                                            .read(UserDashListProvider.notifier)
                                                                            .getNetbalance
                                                                            .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      fontSize:
                                                                          25.0,
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
                                                                20.0,
                                                                15.0,
                                                                20.0,
                                                                0.0),
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
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyLarge
                                                                  .override(
                                                                    fontFamily:
                                                                        'Poppins',
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    fontSize:
                                                                        12.0,
                                                                    letterSpacing:
                                                                        0.5,
                                                                  ),
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: [
                                                                Text(
                                                                  FFLocalizations.of(
                                                                          context)
                                                                      .getText(
                                                                    '0qxzch1c' /* Debited */,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .headlineSmall
                                                                      .override(
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        fontSize:
                                                                            12.0,
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
                                                                      .read(UserDashListProvider
                                                                          .notifier)
                                                                      .getTotalCredit
                                                                      .toString(),
                                                              options:
                                                                  FFButtonOptions(
                                                                width: 100,
                                                                height: 40,
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                iconPadding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .95),
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontSize: 15,
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                            FFButtonWidget(
                                                              onPressed: () {},
                                                              text: '₹ ' +
                                                                  ref
                                                                      .read(UserDashListProvider
                                                                          .notifier)
                                                                      .getTotalDebit
                                                                      .toString(),
                                                              options:
                                                                  FFButtonOptions(
                                                                width: 100,
                                                                height: 40,
                                                                padding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                iconPadding:
                                                                    const EdgeInsetsDirectional
                                                                        .fromSTEB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                textStyle:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          .95),
                                                                  letterSpacing:
                                                                      0.5,
                                                                  fontSize: 15,
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .primary,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
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
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                            child: Center(
                                              child: ClipPath(
                                                clipper: ImageClipper(),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 0.0, 8.0, 6.0),
                                                  child: Card(
                                                    elevation: 18,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
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
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : _selectedIndex == 1
                                  ? SliverAppBar(
                                      automaticallyImplyLeading: false,
                                      expandedHeight: 22.h,
                                      flexibleSpace: FlexibleSpaceBar(
                                        background: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 100.w,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Center(
                                                  child: ClipPath(
                                                    clipper: ImageClipper(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8.0,
                                                              0.0, 8.0, 6.0),
                                                      child: Card(
                                                        elevation: 18,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 0.0, 8.0, 6.0),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Card(
                                                      elevation: 18,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    8.0,
                                                                    8.0,
                                                                    8.0,
                                                                    8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          12.0,
                                                                          10.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    "Cashback",
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
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
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0.0,
                                                                          10.0,
                                                                          12.0,
                                                                          0.0),
                                                                      child:
                                                                          Text(
                                                                        ' ₹' +
                                                                            ref.read(UserDashListProvider.notifier).getNetIntbalance.toStringAsFixed(2),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontSize:
                                                                              25.0,
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
                                                                    20.0,
                                                                    15.0,
                                                                    20.0,
                                                                    0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Cashback Credited",
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.5,
                                                                      ),
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Text(
                                                                      "Cashback Debited",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            fontSize:
                                                                                12.0,
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
                                                                    18,
                                                                    10,
                                                                    18,
                                                                    0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {},
                                                                  text: '₹ ' +
                                                                      ref
                                                                          .read(UserDashListProvider
                                                                              .notifier)
                                                                          .getTotalIntCredit
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {},
                                                                  text: '₹ ' +
                                                                      ref
                                                                          .read(UserDashListProvider
                                                                              .notifier)
                                                                          .getTotalIntDebit
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Center(
                                                  child: ClipPath(
                                                    clipper: ImageClipper(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8.0,
                                                              0.0, 8.0, 6.0),
                                                      child: Card(
                                                        elevation: 18,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : SliverAppBar(
                                      automaticallyImplyLeading: false,
                                      expandedHeight: 22.h,
                                      flexibleSpace: FlexibleSpaceBar(
                                        background: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          controller: _scrollController,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 100.w,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 0.0, 8.0, 6.0),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Card(
                                                      elevation: 18,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    8.0,
                                                                    8.0,
                                                                    8.0,
                                                                    8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          12.0,
                                                                          10.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    FFLocalizations.of(
                                                                            context)
                                                                        .getText(
                                                                      'lfgx5yff' /* Net Balance */,
                                                                    ),
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
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
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0.0,
                                                                          10.0,
                                                                          12.0,
                                                                          0.0),
                                                                      child:
                                                                          Text(
                                                                        ' ₹' +
                                                                            ref.read(UserDashListProvider.notifier).getNetbalance.toString(),
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontSize:
                                                                              25.0,
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
                                                                    20.0,
                                                                    15.0,
                                                                    20.0,
                                                                    0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
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
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.5,
                                                                      ),
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Text(
                                                                      FFLocalizations.of(
                                                                              context)
                                                                          .getText(
                                                                        '0qxzch1c' /* Debited */,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            fontSize:
                                                                                12.0,
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
                                                                    18,
                                                                    10,
                                                                    18,
                                                                    0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        'Button pressed ...');
                                                                  },
                                                                  text: '₹ ' +
                                                                      ref
                                                                          .read(
                                                                              UserDashListProvider.notifier)
                                                                          .getTotalCredit
                                                                          .toString(),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {},
                                                                  text: '₹ ' +
                                                                      ref
                                                                          .read(
                                                                              UserDashListProvider.notifier)
                                                                          .getTotalDebit
                                                                          .toString(),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Center(
                                                  child: ClipPath(
                                                    clipper: ImageClipper(),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsetsDirectional
                                                              .fromSTEB(8.0,
                                                              0.0, 8.0, 6.0),
                                                      child: Card(
                                                        elevation: 18,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      6.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(0.0),
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
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .fromSTEB(
                                                          8.0, 0.0, 8.0, 6.0),
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Card(
                                                      elevation: 18,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                    8.0,
                                                                    8.0,
                                                                    8.0,
                                                                    8.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          12.0,
                                                                          10.0,
                                                                          0.0,
                                                                          0.0),
                                                                  child: Text(
                                                                    "Cashback",
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyLarge
                                                                        .override(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontFamily:
                                                                              'Poppins',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
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
                                                                      padding: const EdgeInsetsDirectional
                                                                          .fromSTEB(
                                                                          0.0,
                                                                          10.0,
                                                                          12.0,
                                                                          0.0),
                                                                      child:
                                                                          Text(
                                                                        ' ₹' +
                                                                            ref.read(UserDashListProvider.notifier).getNetIntbalance.toStringAsFixed(2),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primary,
                                                                          fontSize:
                                                                              25.0,
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
                                                                    20.0,
                                                                    15.0,
                                                                    20.0,
                                                                    0.0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "Cashback Credited",
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyLarge
                                                                      .override(
                                                                        fontFamily:
                                                                            'Poppins',
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primary,
                                                                        fontSize:
                                                                            12.0,
                                                                        letterSpacing:
                                                                            0.5,
                                                                      ),
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Text(
                                                                      "Cashback Debited",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .end,
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .headlineSmall
                                                                          .override(
                                                                            fontFamily:
                                                                                'Poppins',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            fontSize:
                                                                                12.0,
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
                                                                    18,
                                                                    10,
                                                                    18,
                                                                    0),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {},
                                                                  text: '₹ ' +
                                                                      ref
                                                                          .read(UserDashListProvider
                                                                              .notifier)
                                                                          .getTotalIntCredit
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
                                                                          .primary,
                                                                      width: 1,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                FFButtonWidget(
                                                                  onPressed:
                                                                      () {},
                                                                  text: '₹ ' +
                                                                      "0.0",
                                                                  options:
                                                                      FFButtonOptions(
                                                                    width: 100,
                                                                    height: 40,
                                                                    padding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    iconPadding:
                                                                        const EdgeInsetsDirectional
                                                                            .fromSTEB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .primary,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              .95),
                                                                      letterSpacing:
                                                                          0.5,
                                                                      fontSize:
                                                                          15,
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: FlutterFlowTheme.of(
                                                                              context)
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
                          //todo:- future implementation(adding new sections)
                          // makeHeader('Do more with Maakan Money', false),
                          // SliverToBoxAdapter(
                          //   child: Container(
                          //     height: 15.h,
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(0.0),
                          //       child: Card(
                          //         color: Colors.white,
                          //         elevation: 0,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(0),
                          //           side: BorderSide(
                          //               color: Colors.transparent, width: 1),
                          //         ),
                          //         child: ListView.builder(
                          //           scrollDirection: Axis.horizontal,
                          //           itemCount: 4,
                          //           itemBuilder: (context, index) {
                          //             return Container(
                          //               child: ReusableCertificateSection(
                          //                 getText: "dfg",
                          //                 getImage: "BOND",
                          //                 getTextColor: Colors.black,
                          //                 getIconColor: Colors.black,
                          //                 onTap: () {},
                          //               ),
                          //             );
                          //           },
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          makeHeader('Transactions', true),
                          _selectedIndex == 0
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      final document = ref
                                          .read(UserDashListProvider.notifier)
                                          .transList?[index];
                                      final amount = document?.amount;
                                      final transType = document?.isDeposit;
                                      final date = document?.date;
                                      final mobile = document?.mobile;
                                      final docId = document?.docId;
                                      final interest = document?.interest;

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
                                                  BorderRadius.circular(6.0),
                                            ),
                                            color: Colors.white,
                                            elevation: 4.0,
                                            child: ListTile(
                                              leading: Card(
                                                color: transType == true
                                                    ? FlutterFlowTheme.of(
                                                            context)
                                                        .primary
                                                    : FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                elevation: 6.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
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
                                                transType == true
                                                    ? "Deposit"
                                                    : "Withdrawn",
                                                style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                    letterSpacing: 1),
                                              ),
                                              subtitle: Text(
                                                  date.toString().toUpperCase(),
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.5)),
                                              trailing: Container(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      transType == true
                                                          ? "+" +
                                                              '$amount' +
                                                              ' ₹'
                                                          : "-" +
                                                              '$amount' +
                                                              ' ₹',
                                                      style: TextStyle(
                                                        color: transType == true
                                                            ? FlutterFlowTheme
                                                                    .of(context)
                                                                .primary
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: transType == true
                                                          ? true
                                                          : false,
                                                      child: Text(
                                                        transType == true
                                                            ? "+" +
                                                                '$getFinInt' +
                                                                ' ₹'
                                                            : '',
                                                        style: TextStyle(
                                                          color:
                                                              transType == true
                                                                  ? Colors.grey
                                                                  : Colors.red,
                                                          fontWeight:
                                                              FontWeight.normal,
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
                                        ),
                                      );
                                    },
                                    childCount: ref
                                            .read(UserDashListProvider.notifier)
                                            .transList
                                            ?.length ??
                                        0,
                                  ),
                                )
                              : _selectedIndex == 1
                                  ? SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          final document = ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .cashBackList?[index];
                                          final amount = document?.amount;
                                          final date = document?.date;
                                          final mobile = document?.mobile;
                                          final docId = document?.docId;

                                          return Container(
                                            color:
                                                Colors.white.withOpacity(0.95),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                                color: Colors.white,
                                                elevation: 4.0,
                                                child: ListTile(
                                                  leading: Card(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .secondary,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    elevation: 6.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        Icons.arrow_back,
                                                        color: Colors.white,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    "Cashback",
                                                    style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                        letterSpacing: 1),
                                                  ),
                                                  subtitle: Text(
                                                      date
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.5)),
                                                  trailing: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          "+" +
                                                              '$amount' +
                                                              ' ₹',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {},
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: ref
                                                .read(UserDashListProvider
                                                    .notifier)
                                                .cashBackList
                                                ?.length ??
                                            0,
                                      ),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          final document = ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .transList?[index];
                                          final amount = document?.amount;
                                          final transType = document?.isDeposit;
                                          final date = document?.date;
                                          final mobile = document?.mobile;
                                          final docId = document?.docId;
                                          final interest = document?.interest;

                                          String getFinInt = interest == null
                                              ? 0.0.toString()
                                              : interest.toStringAsFixed(2);

                                          return Container(
                                            color:
                                                Colors.white.withOpacity(0.95),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.0),
                                                ),
                                                color: Colors.white,
                                                elevation: 4.0,
                                                child: ListTile(
                                                  leading: Card(
                                                    color: transType == true
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .primary
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    clipBehavior: Clip
                                                        .antiAliasWithSaveLayer,
                                                    elevation: 6.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        transType == true
                                                            ? Icons
                                                                .arrow_forward
                                                            : Icons.arrow_back,
                                                        color: Colors.white,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    transType == true
                                                        ? "Deposit"
                                                        : "Withdrawn",
                                                    style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                        letterSpacing: 1),
                                                  ),
                                                  subtitle: Text(
                                                      date
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.5)),
                                                  trailing: Container(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          transType == true
                                                              ? "+" +
                                                                  '$amount' +
                                                                  ' ₹'
                                                              : "-" +
                                                                  '$amount' +
                                                                  ' ₹',
                                                          style: TextStyle(
                                                            color: transType ==
                                                                    true
                                                                ? FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                : Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              transType == true
                                                                  ? true
                                                                  : false,
                                                          child: Text(
                                                            transType == true
                                                                ? "+" +
                                                                    '$getFinInt' +
                                                                    ' ₹'
                                                                : '',
                                                            style: TextStyle(
                                                              color: transType ==
                                                                      true
                                                                  ? Colors.grey
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 14.0,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () {},
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        childCount: ref
                                                .read(UserDashListProvider
                                                    .notifier)
                                                .transList
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
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: _isNavigationBarVisible ? true : false,
            child: FloatingActionButton(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              onPressed: () {
                // shareApp(context);
                _showBottomSheet(context, 0);
              },
              child: Icon(
                Icons.currency_rupee_outlined,
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
                          'images/savings.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                        label: "Savings",
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset(
                          'images/cashback.png',
                          fit: BoxFit.contain,
                          height: 25,
                          width: 25,
                        ),
                        label: "Cashback",
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Stack(alignment: Alignment.topRight, children: [
                          Image.asset(
                            'images/message.png',
                            fit: BoxFit.contain,
                            height: 25,
                            width: 25,
                          ),
                          Visibility(
                            visible: ref
                                .read(UserDashListProvider.notifier)
                                .isNotificationByAdmin,
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
                        label: "Message",
                        backgroundColor: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.95),
                      ),
                      BottomNavigationBarItem(
                        icon: Stack(alignment: Alignment.center, children: [
                          Image.asset(
                            'images/download.png',
                            fit: BoxFit.contain,
                            height: 25,
                            width: 25,
                          ),
                        ]),
                        label: "Withdraw",
                        backgroundColor: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.95),
                      ),
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
        );
      }),
    );
  }

  void _toggleNavigationBarVisibility(bool isVisible) {
    setState(() {
      _isNavigationBarVisible = isVisible;
    });
  }

  void _onBottomItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      //todo:- 28.8.23 - based on index selected, showing money request option saving / cashback
      if (_selectedIndex == 0) {
        isSavAmntReq = true;
      } else if (_selectedIndex == 1) {
        isSavAmntReq = false;
      }

      if (_selectedIndex == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userName: "Admin",
                adminId: Constants.adminId,
                userId: widget.getMobile,
                callNo: Constants.adminNo1,
                getDocId: ref.read(UserDashListProvider.notifier).getDocId,
              ),
            )).then((value) {
          // ref
          //     .read(UserDashListProvider.notifier)
          //     .getUserDetails(widget.getMobile);
        });
      } else if (_selectedIndex == 3) {
        // _showBottomSheet(context, 0);
        ref
            .read(UserDashListProvider.notifier)
            .getUserDetails(widget.getMobile);

        txtReqAmount.text = "";
        _showBottomSheet(context, 1);
      }
    });
  }

  void shareApp(BuildContext context) async {
    final String appLink =
        "https://play.google.com/store/apps/details?id=com.maaakanmoney.mm";
    final String message =
        "Check out One Solution for Saving your Money! Maaka app is there to help you out.";

    try {
      await FlutterShare.share(
        title: "Share My App",
        text: message,
        linkUrl: appLink,
        chooserTitle: "Share My App with",
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Could not share the app link."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _showBottomSheet(BuildContext context, int getIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context, getIndex);
      },
    ).whenComplete(() {
      // Reset focus when the bottom sheet is closed
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  Widget _buildBottomSheetContent(BuildContext context, int getIndex) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: getIndex == 0
          ? Container(
              // Add your desired height to the container
              height: 200,
              child: Consumer(builder: (context, ref, child) {
                bool? getPaidStatus = ref.watch(txtPaidStatus);
                bool? getCashbckPaidStatus = ref.watch(txtCashbckPaidStatus);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 10.h,
                          width: 20.w,
                          child: Card(
                            elevation: 5,
                            child: ClipOval(
                              child: Material(
                                color: Colors.white, // Button color
                                child: InkWell(
                                  splashColor: Colors.red, // Splash color
                                  onTap: () async {
                                    //venkatjai.j@oksbi
                                    //ganeshmani1294@okaxis
                                    // String upiurl =
                                    //     'upi://pay?pa=venkatjai.j@oksbi&pn=babu&tn=TestingGpay&am=10&cu=INR';
                                    // var uri = Uri.parse(upiurl);

                                    // if (await canLaunch(uri)) {
                                    //   await launch(uri);
                                    // } else {
                                    //   print(
                                    //       'Could not launch the app with URI: $uri');
                                    // }

                                    // if (!await launchUrl(uri)) {
                                    //   throw Exception('Could not launch $uri');
                                    // }

                                    //todo:- uncomment below line

                                    var openAppResult = await LaunchApp.openApp(
                                      openStore: true,
                                      androidPackageName:
                                          'com.google.android.apps.nbu.paisa.user',
                                      // iosUrlScheme: 'pulsesecure://',
                                      // appStoreLink:
                                      //     'itms-apps://itunes.apple.com/us/app/pulse-secure/id945832041',
                                      iosUrlScheme: 'hjfg',
                                      appStoreLink:
                                          'https://apps.apple.com/in/app/google-pay-save-pay-manage/id1193357041',
                                    );
                                  },
                                  child: Image.asset(
                                    'images/gpay2.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "GPay",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.transparent,
                          height: 10.h,
                          width: 20.w,
                          child: Card(
                            elevation: 5,
                            child: ClipOval(
                              child: Material(
                                color: Colors.white, // Button color
                                child: InkWell(
                                  splashColor: Colors.red, // Splash color
                                  onTap: () async {
                                    // var uri = Uri.parse(
                                    //     'upi://pay?pa=ganeshmani1294@okaxis');
                                    //
                                    // if (!await launchUrl(uri)) {
                                    //   throw Exception('Could not launch $uri');
                                    // }

                                    var openAppResult = await LaunchApp.openApp(
                                      openStore: true,
                                      androidPackageName: 'com.phonepe.app',
                                      iosUrlScheme: 'sf',
                                      appStoreLink:
                                          'https://apps.apple.com/in/app/phonepe-secure-payments-app/id1170055821',
                                    );
                                  },
                                  child: Image.asset(
                                    'images/phonepe1.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "PhonePe",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ],
                );
              }),
            )
          : getIndex == 1
              ? isSavAmntReq == true
                  ? Container(
                      // Add your desired height to the container
                      height: 250,
                      child: Consumer(builder: (context, ref, child) {
                        bool? getPaidStatus = ref.watch(txtPaidStatus);
                        bool? getCashbckPaidStatus =
                            ref.watch(txtCashbckPaidStatus);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Savings Amount Request",
                              style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  letterSpacing: 1),
                            ),
                            Visibility(
                              visible: ref
                                          .read(UserDashListProvider.notifier)
                                          .getLastReqAmount! !=
                                      0
                                  ? true
                                  : false,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Your last Request ₹${ref.read(UserDashListProvider.notifier).getLastReqAmount!.toStringAsFixed(2)} is",
                                    style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        letterSpacing: 1),
                                  ),
                                  Text(
                                      // ref.read(UserDashListProvider.notifier).getIsMoneyReq!
                                      getPaidStatus! ? "UnPaid" : "Paid",
                                      style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .secondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22.0,
                                          letterSpacing: 1)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: txtReqAmount,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Enter amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    double amount = txtReqAmount.text.isEmpty
                                        ? 0
                                        : double.parse(txtReqAmount.text);
                                    if (amount != 0) {
                                      if (amount >
                                          ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .getNetbalance) {
                                        Constants.showToast(
                                            "Requested amount greater than Netbalance",
                                            ToastGravity.CENTER);
                                        return;
                                      } else {
                                        if (getPaidStatus) {
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert!",
                                                  descriptions:
                                                      "Your last Request ₹${ref.read(UserDashListProvider.notifier).getLastReqAmount!.toStringAsFixed(2)} is Not Paid, Do you want add More Request",
                                                  text: "Ok",
                                                  isNo: true,
                                                  isCancel: true,
                                                  onTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                                txtReqAmount
                                                                    .text) +
                                                            ref
                                                                .read(UserDashListProvider
                                                                    .notifier)
                                                                .getLastReqAmount!;
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                                txtReqAmount
                                                                    .text) +
                                                            ref
                                                                .read(UserDashListProvider
                                                                    .notifier)
                                                                .getLastReqAmount!;

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                true,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  onNoTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                            txtReqAmount.text);
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                            txtReqAmount.text);

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                true,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        } else {
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert!",
                                                  descriptions:
                                                      "Are you sure, Do you want to Request Money",
                                                  text: "Ok",
                                                  isCancel: true,
                                                  onTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                            txtReqAmount.text);
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                            txtReqAmount.text);

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                true,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        }
                                      }
                                    } else {
                                      Constants.showToast(
                                          txtReqAmount.text.isEmpty
                                              ? "Please Enter Amount"
                                              : "Please Enter Valid Amount",
                                          ToastGravity.CENTER);
                                      return;
                                    }
                                  },
                                  child: Text('Request'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    )
                  : Container(
                      // Add your desired height to the container
                      height: 250,
                      child: Consumer(builder: (context, ref, child) {
                        bool? getPaidStatus = ref.watch(txtPaidStatus);
                        bool? getCashbckPaidStatus =
                            ref.watch(txtCashbckPaidStatus);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Cashback Amount Request",
                              style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  letterSpacing: 1),
                            ),
                            Visibility(
                              visible: ref
                                          .read(UserDashListProvider.notifier)
                                          .getLastCashbckReqAmount! !=
                                      0
                                  ? true
                                  : false,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Your last Request ₹${ref.read(UserDashListProvider.notifier).getLastCashbckReqAmount!.toStringAsFixed(2)} is",
                                    style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                        letterSpacing: 1),
                                  ),
                                  Text(
                                      // ref.read(UserDashListProvider.notifier).getIsMoneyReq!
                                      getCashbckPaidStatus! ? "UnPaid" : "Paid",
                                      style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .secondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22.0,
                                          letterSpacing: 1)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: txtReqAmount,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Enter amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    double amount = txtReqAmount.text.isEmpty
                                        ? 0
                                        : double.parse(txtReqAmount.text);
                                    if (amount != 0) {
                                      if (amount >
                                          ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .getNetIntbalance) {
                                        Constants.showToast(
                                            "Requested amount greater than Cashback Netbalance",
                                            ToastGravity.CENTER);
                                        return;
                                      } else {
                                        if (getCashbckPaidStatus) {
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert!",
                                                  descriptions:
                                                      "Your last Request ₹${ref.read(UserDashListProvider.notifier).getLastCashbckReqAmount!.toStringAsFixed(2)} is Not Paid, Do you want add More Request",
                                                  text: "Ok",
                                                  isNo: true,
                                                  isCancel: true,
                                                  onTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                                txtReqAmount
                                                                    .text) +
                                                            ref
                                                                .read(UserDashListProvider
                                                                    .notifier)
                                                                .getLastCashbckReqAmount!;
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetIntbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Cashback Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                                txtReqAmount
                                                                    .text) +
                                                            ref
                                                                .read(UserDashListProvider
                                                                    .notifier)
                                                                .getLastCashbckReqAmount!;

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                false,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  onNoTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                            txtReqAmount.text);
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                            txtReqAmount.text);

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                false,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        } else {
                                          showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialogBox(
                                                  title: "Alert!",
                                                  descriptions:
                                                      "Are you sure, Do you want to Request Money",
                                                  text: "Ok",
                                                  isCancel: true,
                                                  onTap: () async {
                                                    double amount = txtReqAmount
                                                            .text.isEmpty
                                                        ? 0
                                                        : double.parse(
                                                            txtReqAmount.text);
                                                    if (amount != 0) {
                                                      if (amount >
                                                          ref
                                                              .read(
                                                                  UserDashListProvider
                                                                      .notifier)
                                                              .getNetbalance) {
                                                        Constants.showToast(
                                                            "Requested amount greater than Netbalance",
                                                            ToastGravity
                                                                .CENTER);
                                                      } else {
                                                        amount = double.parse(
                                                            txtReqAmount.text);

                                                        await ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .updateData(
                                                                false,
                                                                amount,
                                                                ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getDocId,
                                                                widget
                                                                    .getMobile);
                                                        Navigator.pop(context);
                                                      }
                                                    } else {
                                                      Constants.showToast(
                                                          txtReqAmount
                                                                  .text.isEmpty
                                                              ? "Please Enter Amount"
                                                              : "Please Enter Valid Amount",
                                                          ToastGravity.CENTER);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                );
                                              });
                                        }
                                      }
                                    } else {
                                      Constants.showToast(
                                          txtReqAmount.text.isEmpty
                                              ? "Please Enter Amount"
                                              : "Please Enter Valid Amount",
                                          ToastGravity.CENTER);
                                      return;
                                    }
                                  },
                                  child: Text('Request'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    )
              : Container(),
    );
  }

  Future<void> _handleRefresh() async {
    ref.read(isUserRefreshIndicator.notifier).state = true;
    return ref
        .read(UserDashListProvider.notifier)
        .getUserDetails(widget.getMobile);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % 3;

        _scrollToIndex(_currentIndex);
      });
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
                child: Visibility(
                  visible: isShowFilter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          final selectedRange = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              fieldEndHintText: '');

                          if (selectedRange != null) {
                            setState(() {
                              ref
                                  .read(UserDashListProvider.notifier)
                                  .startDate = selectedRange.start;
                              ref.read(UserDashListProvider.notifier).endDate =
                                  selectedRange.end;
                            });
                            ref
                                .read(UserDashListProvider.notifier)
                                .getUserDetails(widget.getMobile);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 3.2,
                          height: MediaQuery.of(context).size.height / 22,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Text.rich(
                              TextSpan(
                                text: ref
                                            .read(UserDashListProvider.notifier)
                                            .startDate ==
                                        null
                                    ? 'Start from:'
                                    : '',
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${ref.read(UserDashListProvider.notifier).startDate?.toString().substring(0, 10) ?? ''}',
                                    style: TextStyle(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final selectedRange = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2100),
                          );

                          if (selectedRange != null) {
                            setState(() {
                              ref
                                  .read(UserDashListProvider.notifier)
                                  .startDate = selectedRange.start;
                              ref.read(UserDashListProvider.notifier).endDate =
                                  selectedRange.end;
                            });
                            ref
                                .read(UserDashListProvider.notifier)
                                .getUserDetails(widget.getMobile);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 3.2,
                          height: MediaQuery.of(context).size.height / 22,
                          // margin: const EdgeInsets.all(10.0),
                          // padding: const EdgeInsets.all(3.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, right: 8),
                            child: Text.rich(
                              TextSpan(
                                text: ref
                                            .read(UserDashListProvider.notifier)
                                            .endDate ==
                                        null
                                    ? 'End to:'
                                    : '',
                                children: [
                                  TextSpan(
                                    text:
                                        ' ${ref.read(UserDashListProvider.notifier).endDate?.toString().substring(0, 10) ?? ''}',
                                    style: TextStyle(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ],
                              ),
                              style: const TextStyle(
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w500),
                            ),
                          )),
                        ),
                      ),
                      ref.read(UserDashListProvider.notifier).startDate !=
                                  null ||
                              ref.read(UserDashListProvider.notifier).endDate !=
                                  null
                          ? Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Center(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          50), // Adjust the radius as needed
                                      child: Material(
                                        color: FlutterFlowTheme.of(context)
                                            .primary, // Replace with your desired icon background color
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              ref
                                                  .read(UserDashListProvider
                                                      .notifier)
                                                  .startDate = null;
                                              ref
                                                  .read(UserDashListProvider
                                                      .notifier)
                                                  .endDate = null;

                                              ref
                                                  .read(UserDashListProvider
                                                      .notifier)
                                                  .getUserDetails(
                                                      widget.getMobile);
                                            });
                                          },
                                          child: const SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: Icon(
                                              Icons.clear,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ))))
                          : Container(),
                    ],
                  ),
                ),
              ))),
    );
  }
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
