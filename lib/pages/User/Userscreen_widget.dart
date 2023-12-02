// ignore_for_file: must_be_immutable, avoid_print, unused_label, prefer_interpolation_to_compose_strings, library_private_types_in_public_api, unused_local_variable

import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:maaakanmoney/components/ReusableWidget/ReusableCard.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/pages/Auth/mpin.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/User/TransactionHist/TransactionHistory.dart';
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
import 'Cashback/CashbackDetails.dart';
import 'Profile/Profile.dart';
import 'Request Money/RequestMoney.dart';
import 'SaveMoney/SaveMoney.dart';
import 'budget_model.dart';
export 'budget_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

//todo:- 16.11.23 - new dashboard implementation
class BudgetWidget1 extends ConsumerStatefulWidget {
  BudgetWidget1({
    Key? key,
    @required this.getMobile,
    @required this.getDocId,
  }) : super(key: key);
  String? getMobile;
  String? getDocId;

  @override
  _BudgetWidget1State createState() => _BudgetWidget1State();
}

class _BudgetWidget1State extends ConsumerState<BudgetWidget1>
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
  int _selectedIndex = 0;
  bool _isNavigationBarVisible = false;
  bool? isSavAmntReq = false;

  // List<String> imagePaths = [
  //   'images/background1.png',
  //   'images/background3.png',
  // ];

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
                onPressed: () async {
                  // Navigator.of(context).pop(true);
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  loginKey = prefs.getString("LoginSuccessuser1");

                  if (loginKey == null || loginKey == "" || loginKey!.isEmpty) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyPhone()),
                      (route) => false, // Remove all routes from the stack
                    );
                  } else {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? mPin = prefs.getString("Mpin");
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MpinPageWidget(
                              getMobileNo: loginKey ?? "", getMpin: mPin)),
                      (route) => false, // Remove all routes from the stack
                    );
                  }
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

    //todo:- 25.9.23 stoped advertice banner in dashboard header
    // _startTimer();

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

    getDocumentIDsAndData();
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
    // int randomIndex = math.Random().nextInt(imagePaths.length);
    // String randomImagePath = imagePaths[randomIndex];
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
                  toolbarHeight: 8.h,
                  leading: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors
                            .transparent, // You can set your desired color here
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors
                            .transparent, // You can set your desired color here
                      ),
                    ),
                  ),
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
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            expandedHeight: 32.h,
                            flexibleSpace: FlexibleSpaceBar(
                              background: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                controller: _scrollController,
                                child: Container(
                                  color: FlutterFlowTheme.of(context).secondary,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Material(
                                          elevation: 8.0,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(50),
                                            bottomRight: Radius.circular(50),
                                          ),
                                          child: Container(
                                            width: 100.w,
                                            decoration: BoxDecoration(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(50),
                                                bottomRight:
                                                    Radius.circular(50),
                                              ),
                                            ),
                                            child: Container(
                                              color: Colors.transparent,
                                              child: Stack(children: [
                                                Positioned.fill(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 20.0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              transitionDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          200),
                                                              pageBuilder: (_,
                                                                      __,
                                                                      ___) =>
                                                                  ProfileScreen(
                                                                userName: ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getUser,
                                                                cashBack: ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getNetIntbalance
                                                                    .toStringAsFixed(
                                                                        2),
                                                                netBalance: ref
                                                                    .read(UserDashListProvider
                                                                        .notifier)
                                                                    .getNetbalance
                                                                    .toStringAsFixed(
                                                                        2),
                                                              ),
                                                              transitionsBuilder:
                                                                  (_,
                                                                      animation,
                                                                      __,
                                                                      child) {
                                                                return FadeTransition(
                                                                  opacity:
                                                                      animation,
                                                                  child: child,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          width: 60,
                                                          height: 60,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .secondary, // You can set your desired color here
                                                          ),
                                                          child: Icon(
                                                            Icons.person,
                                                            color: FlutterFlowTheme
                                                                    .of(context)
                                                                .primary, // You can set your desired color here
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Add more Positioned widgets for additional images
                                                ),
                                                Positioned.fill(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Container(
                                                        height: 8.h,
                                                        width: 60.w,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                '₹' +
                                                                    ref
                                                                        .read(UserDashListProvider
                                                                            .notifier)
                                                                        .getNetbalance
                                                                        .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: GlobalTextStyles
                                                                    .primaryText1(
                                                                        textColor:
                                                                            FlutterFlowTheme.of(context).secondary)),
                                                            Text(
                                                              "Is your Saved Earning ",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: GlobalTextStyles
                                                                  .secondaryText1(
                                                                      textColor:
                                                                          FlutterFlowTheme.of(context)
                                                                              .secondary1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Add more Positioned widgets for additional images
                                                ),
                                                Positioned.fill(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      bottom: 10.0,
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: SizedBox(
                                                        height: 18.h,
                                                        width: 90.w,
                                                        child: Card(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
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
                                                                        "Credited",
                                                                        style: GlobalTextStyles.secondaryText2(
                                                                            textColor:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            txtSize: 12)),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Text(
                                                                            "Debited",
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            style: GlobalTextStyles.secondaryText2(textColor: FlutterFlowTheme.of(context).primary, txtSize: 12)),
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
                                                                          .spaceAround,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Text(
                                                                          '₹ ' +
                                                                              ref.read(UserDashListProvider.notifier).getTotalCredit.toString(),
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style: GlobalTextStyles.secondaryText1(
                                                                              textColor: FlutterFlowTheme.of(context).primary,
                                                                              txtWeight: FontWeight.bold),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Text(
                                                                          '₹ ' +
                                                                              ref.read(UserDashListProvider.notifier).getTotalDebit.toString(),
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style: GlobalTextStyles.secondaryText1(
                                                                              textColor: FlutterFlowTheme.of(context).primary,
                                                                              txtWeight: FontWeight.bold),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            10.0),
                                                                child: Container(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary1,
                                                                    height: 1,
                                                                    width:
                                                                        80.w),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Add more Positioned widgets for additional images
                                                ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          //todo:- future implementation(adding new sections)
                          makeTitleHeader('Quick Access', false),
                          SliverToBoxAdapter(
                            child: Container(
                              height: 15.h,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: BorderSide(
                                        color: Colors.transparent, width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ReusableCertificateSection(
                                        getText: "Send",
                                        getImage: "saveMoney",
                                        getTextColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        getIconColor: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  SaveMoney(
                                                getMobile: widget.getMobile,
                                                getUserName: ref
                                                    .read(UserDashListProvider
                                                        .notifier)
                                                    .getUser,
                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(0, 1),
                                                    // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      ReusableCertificateSection(
                                        getText: "Request",
                                        getImage: "moneyReq",
                                        getTextColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        getIconColor: Colors.black,
                                        onTap: () {
                                          isSavAmntReq = true;
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  RequestMoney(
                                                getMobile: widget.getMobile,
                                                isSavingReq: isSavAmntReq,
                                                getUserName: ref
                                                    .read(UserDashListProvider
                                                        .notifier)
                                                    .getUser,
                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(0, 1),
                                                    // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      ReusableCertificateSection(
                                        getText: "History",
                                        getImage: "transHis",
                                        getTextColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        getIconColor: Colors.black,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  TransactionHistory(
                                                getMobile: widget.getMobile,
                                                isSavingHis: true,
                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(0, 1),
                                                    // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      ReusableCertificateSection(
                                        getText: "Cashback",
                                        getImage: "cashback",
                                        getTextColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        getIconColor: Colors.black,
                                        onTap: () {
                                          isSavAmntReq = false;
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  CashbackDetails(
                                                getMobile: widget.getMobile,
                                                isSavingReq: isSavAmntReq,
                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(0, 1),
                                                    // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      // Add more ReusableCertificateSection widgets as needed
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          makeTitleHeader('Recent Transactions', true),
                          ref.read(UserDashListProvider.notifier).transList?.length == 0
                              ? SliverToBoxAdapter(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Image.asset(
                                            'images/final/SecurityCode/MPin.png',
                                            width: 150,
                                            height: 150,
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration:
                                                    Duration(milliseconds: 400),
                                                pageBuilder: (_, __, ___) =>
                                                    SaveMoney(
                                                  getMobile: widget.getMobile,
                                                  getUserName: ref
                                                      .read(UserDashListProvider
                                                          .notifier)
                                                      .getUser,
                                                ),
                                                transitionsBuilder:
                                                    (_, animation, __, child) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: Offset(0, 1),
                                                      // You can adjust the start position
                                                      end: Offset
                                                          .zero, // You can adjust the end position
                                                    ).animate(animation),
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "Tap to Start Saving Money!",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "Cheers to Smart financial moves and Savings Plans.",
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      if (index > 2) {
                                        return SizedBox
                                            .shrink(); // Return an empty widget for transactions beyond the last three
                                      }

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
                                                        .secondary1,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                elevation: 5.0,
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
                                                style: GlobalTextStyles
                                                    .secondaryText1(
                                                        txtSize: 16,
                                                        textColor:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        txtWeight:
                                                            FontWeight.bold),
                                              ),
                                              subtitle: Text(
                                                date.toString().toUpperCase(),
                                                style: GlobalTextStyles
                                                    .secondaryText2(
                                                        txtSize: 12,
                                                        txtWeight:
                                                            FontWeight.bold),
                                              ),
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
                                                          : "" +
                                                              '$amount' +
                                                              ' ₹',
                                                      style: GlobalTextStyles.secondaryText1(
                                                          txtSize: 16,
                                                          textColor: transType ==
                                                                  true
                                                              ? FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .deposite
                                                              : FlutterFlowTheme
                                                                      .of(
                                                                          context)
                                                                  .withdrawal,
                                                          txtWeight:
                                                              FontWeight.bold),
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
                                                        style: GlobalTextStyles
                                                            .secondaryText1(
                                                                txtSize: 14,
                                                                textColor:
                                                                    transType ==
                                                                            true
                                                                        ? Colors
                                                                            .grey
                                                                        : Colors
                                                                            .red,
                                                                txtWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                ),
                          makeTitleHeader('News and Promo', false),
                          SliverToBoxAdapter(
                            child: Container(
                              height: 45.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondary,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                ),
                              ),
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 20.h,
                                        width: 90.w,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondary1
                                              .withOpacity(0.6),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                        ),
                                        child: Stack(children: [
                                          Positioned.fill(
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Image.asset(
                                                'images/final/Dashboard/addvertisement1.png',
                                              ),
                                            ),

                                            // Add more Positioned widgets for additional images
                                          ),
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0.0, right: 10),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Container(
                                                  height: 10.h,
                                                  width: 50.w,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                        "Get Instant",
                                                        style: GlobalTextStyles
                                                            .secondaryText1(
                                                                txtSize: 24,
                                                                textColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                txtWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      Text(
                                                        "Cashback!",
                                                        style: GlobalTextStyles
                                                            .secondaryText1(
                                                                txtSize: 24,
                                                                textColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary,
                                                                txtWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Add more Positioned widgets for additional images
                                          ),
                                        ]),
                                      ),
                                      Container(
                                        height: 20.h,
                                        width: 90.w,
                                        child: Stack(children: [
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  "Invite Friends & Earn",
                                                  style: GlobalTextStyles
                                                      .secondaryText1(
                                                          textColor:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .primary1,
                                                          txtWeight:
                                                              FontWeight.bold),
                                                ),
                                              ),
                                            ),

                                            // Add more Positioned widgets for additional images
                                          ),
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10.0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        "For every user you invite and signs up, you can Earn Upto ",
                                                    style: GlobalTextStyles
                                                        .secondaryText2(
                                                            txtSize: 16,
                                                            textColor:
                                                                FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary1,
                                                            txtWeight:
                                                                FontWeight
                                                                    .bold),
                                                    children: [
                                                      TextSpan(
                                                        text: "₹100",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ".",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Add more Positioned widgets for additional images
                                          ),
                                          Positioned.fill(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10.0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: InkWell(
                                                  splashColor:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .secondary,
                                                  onTap: () {
                                                    shareApp(context);
                                                  },
                                                  child: Container(
                                                    height: 5.h,
                                                    width: 40.w,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .primary,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "Share",
                                                        style: GlobalTextStyles
                                                            .secondaryText2(
                                                                txtWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                txtSize: 16,
                                                                textColor: FlutterFlowTheme.of(
                                                                        context)
                                                                    .secondary),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Add more Positioned widgets for additional images
                                          ),
                                        ]),
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
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(milliseconds: 400),
                    pageBuilder: (_, __, ___) => SaveMoney(
                      getMobile: widget.getMobile,
                      getUserName:
                          ref.read(UserDashListProvider.notifier).getUser,
                    ),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin:
                              Offset(0, 1), // You can adjust the start position
                          end: Offset.zero, // You can adjust the end position
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
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
                        icon: Icon(
                          Icons.home,
                          color: FlutterFlowTheme.of(context)
                              .secondary, // You can set your desired color here
                          size: 25,
                        ),
                        label: "Home",
                        backgroundColor: FlutterFlowTheme.of(context).primary,
                      ),
                      BottomNavigationBarItem(
                        icon: Stack(alignment: Alignment.topRight, children: [
                          Icon(
                            Icons.message,
                            color: FlutterFlowTheme.of(context).secondary,
                            // You can set your desired color here
                            size: 25,
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
                          Icon(
                            Icons.person,
                            color: FlutterFlowTheme.of(context).secondary,
                            // You can set your desired color here
                            size: 25,
                          ),
                        ]),
                        label: "Profile",
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
      // if (_selectedIndex == 0) {
      //   isSavAmntReq = true;
      // } else if (_selectedIndex == 1) {
      //   isSavAmntReq = false;
      // }

      if (_selectedIndex == 1) {
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
      } else if (_selectedIndex == 2) {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (_, __, ___) => ProfileScreen(
              userName: ref.read(UserDashListProvider.notifier).getUser,
              cashBack: ref
                  .read(UserDashListProvider.notifier)
                  .getNetIntbalance
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

  //todo:- 30.11.23 get current token value in collection
  Future<void> getDocumentIDsAndData() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('AdminToken');

    // Get the documents in the collection
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Iterate through the documents in the snapshot
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Access the document ID
      String documentID = documentSnapshot.id;

      // Access the document data as a Map
      Map<String, dynamic> documentData =
          documentSnapshot.data() as Map<String, dynamic>;

      // Access the value of the field (assuming there's only one field)
      dynamic fieldValue = documentData['token'];

      // Print the document ID and field value
      print('Document ID: $documentID, Token Value: $fieldValue');

      //todo:- saving admin token from firestore, so that, user trigger notification to that token
      Constants.adminDeviceToken = fieldValue ?? "";
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
                                    //todo:- 29.9.23 allowing user to get account details to search in gpay

                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Do Paste in Search Bar!",
                                            descriptions:
                                                "We've securely copied account details for you. To make a payment and save more money, simply open Google Pay and paste the details there.",
                                            text: "Ok",
                                            isNo: false,
                                            isCancel: true,
                                            onTap: () async {
                                              final String defaultValue = ref
                                                          .read(
                                                              UserDashListProvider
                                                                  .notifier)
                                                          .getAdminType ==
                                                      "1"
                                                  ? Constants.admin1Gpay
                                                  : Constants.admin2Gpay;
                                              Clipboard.setData(ClipboardData(
                                                  text: defaultValue));

                                              var openAppResult =
                                                  await LaunchApp.openApp(
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

                                              Navigator.pop(context);
                                            },
                                          );
                                        });
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
                                    //todo:-  showing message to user

                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Do Paste in Search Bar!",
                                            descriptions:
                                                "We've securely copied account details for you. To make a payment and save more money, simply open PhonePe and paste the details there.",
                                            text: "Ok",
                                            isNo: false,
                                            isCancel: true,
                                            onTap: () async {
                                              final String defaultValue = ref
                                                          .read(
                                                              UserDashListProvider
                                                                  .notifier)
                                                          .getAdminType ==
                                                      "1"
                                                  ? Constants.admin1Gpay
                                                  : Constants.admin2Gpay;
                                              Clipboard.setData(ClipboardData(
                                                  text: defaultValue));

                                              var openAppResult =
                                                  await LaunchApp.openApp(
                                                openStore: true,
                                                androidPackageName:
                                                    'com.phonepe.app',
                                                iosUrlScheme: 'sf',
                                                appStoreLink:
                                                    'https://apps.apple.com/in/app/phonepe-secure-payments-app/id1170055821',
                                              );

                                              Navigator.pop(context);
                                            },
                                          );
                                        });
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
                                      ref
                                                  .read(txtMoneyReqCanStatus
                                                      .notifier)
                                                  .state ==
                                              true
                                          ? "Cancelled"
                                          : getPaidStatus!
                                              ? "UnPaid"
                                              : "Paid",
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
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Enter amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {},
                                  child: Text('Request'),
                                ),
                                Visibility(
                                  visible: ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .getLastReqAmount! !=
                                          0
                                      ? true
                                      : false,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: "Alert!",
                                              descriptions:
                                                  "Are you sure, Do you want to Cancel Money Request",
                                              text: "Ok",
                                              isNo: false,
                                              isCancel: true,
                                              onTap: () async {
                                                await ref
                                                    .read(UserDashListProvider
                                                        .notifier)
                                                    .canclRequest(
                                                        ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .getDocId,
                                                        true,
                                                        widget.getMobile);

                                                Navigator.pop(context);

                                                //todo:- pops bottom sheet
                                                Navigator.pop(context);
                                              },
                                            );
                                          });
                                    },
                                    child: Text('Cancel Request'),
                                  ),
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
                                      ref
                                                  .read(txtCashbckReqCanStatus
                                                      .notifier)
                                                  .state ==
                                              true
                                          ? "Cancelled"
                                          : getCashbckPaidStatus!
                                              ? "UnPaid"
                                              : "Paid",
                                      style:
                                          TextStyle(
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Enter amount',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                        if (getCashbckPaidStatus ?? false) {
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
                                                  onTap: () async {},
                                                  onNoTap: () async {},
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
                                                  onTap: () async {},
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
                                Visibility(
                                  visible: ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .getLastReqAmount! !=
                                          0
                                      ? true
                                      : false,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialogBox(
                                              title: "Alert!",
                                              descriptions:
                                                  "Are you sure, Do you want to Cancel Cashback Request",
                                              text: "Ok",
                                              isNo: false,
                                              isCancel: true,
                                              onTap: () async {
                                                await ref
                                                    .read(UserDashListProvider
                                                        .notifier)
                                                    .canclRequest(
                                                        ref
                                                            .read(
                                                                UserDashListProvider
                                                                    .notifier)
                                                            .getDocId,
                                                        false,
                                                        widget.getMobile);

                                                Navigator.pop(context);

                                                //todo:- pops bottom sheet
                                                Navigator.pop(context);
                                              },
                                            );
                                          });
                                    },
                                    child: Text('Cancel Request'),
                                  ),
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

  SliverPersistentHeader makeTitleHeader(String headerText, bool isViewAll) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: 50.0,
        maxHeight: 70.0,
        child: Container(
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    headerText,
                    style: GlobalTextStyles.secondaryText1(
                        textColor: FlutterFlowTheme.of(context).primary,
                        txtWeight: FontWeight.w700),
                  ),
                  Visibility(
                    visible: isViewAll,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 400),
                            pageBuilder: (_, __, ___) => TransactionHistory(
                                getMobile: widget.getMobile, isSavingHis: true),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0,
                                      1), // You can adjust the start position
                                  end: Offset
                                      .zero, // You can adjust the end position
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        "View All",
                        style: GlobalTextStyles.secondaryText1(
                            txtSize: 16,
                            textColor: FlutterFlowTheme.of(context).secondary2,
                            txtWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
