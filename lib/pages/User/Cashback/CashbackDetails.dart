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
import '../../../components/custom_dialog_box.dart';
import '../../../phoneController.dart';
import '../../budget_copy/BudgetCopyController.dart';
import '../../chatScreen.dart';
import '../Profile/Profile.dart';
import '../Request Money/RequestMoney.dart';
import '../SaveMoney/SaveMoney.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//todo:- 20.11.23 - new dashboard implementation
class CashbackDetails extends ConsumerStatefulWidget {
  CashbackDetails({
    Key? key,
    @required this.getMobile,
    @required this.getDocId,
    @required this.isSavingReq,
  }) : super(key: key);
  String? getMobile;
  String? getDocId;
  bool? isSavingReq;

  @override
  CashbackDetailsState createState() => CashbackDetailsState();
}

class CashbackDetailsState extends ConsumerState<CashbackDetails>
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


  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (alertcontext) => AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to Exit'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(alertcontext);
                },
                child: new Text('No'),
              ),
              TextButton(
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

    return Consumer(builder: (context, ref, child) {
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
                title: Text(
                  "",
                ),
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                toolbarHeight: 8.h,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                ),
                centerTitle: true,
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
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
                                                          left: 10.0,
                                                          right: 0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Container(

                                                      height: 8.h,
                                                      width: 100.w,
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
                                                                    .getNetIntbalance
                                                                    .toStringAsFixed(
                                                                        2),
                                                            textAlign:
                                                                TextAlign
                                                                    .start,
                                                            style: GlobalTextStyles
                                                                .primaryText1(
                                                                textColor:
                                                                FlutterFlowTheme.of(context).secondary)
                                                          ),
                                                          Text(
                                                            "Is your Saved Cashback ",
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
                                                                        txtSize: 12)
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Text(
                                                                        "Debited",
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style: GlobalTextStyles.secondaryText2(textColor: FlutterFlowTheme.of(context).primary, txtSize: 12)
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
                                                                  Container(
                                                                    child:
                                                                        Text(
                                                                      '₹ ' +
                                                                          ref.read(UserDashListProvider.notifier).getTotalIntCredit.toStringAsFixed(2),
                                                                      textAlign:
                                                                          TextAlign.start,
                                                                      style: GlobalTextStyles.secondaryText1(
                                                                          textColor: FlutterFlowTheme.of(context).primary,
                                                                          txtWeight: FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child:
                                                                        Text(
                                                                      '₹ ' +
                                                                          ref.read(UserDashListProvider.notifier).getTotalIntDebit.toStringAsFixed(2),
                                                                      textAlign:
                                                                          TextAlign.end,
                                                                      style: GlobalTextStyles.secondaryText1(
                                                                          textColor: FlutterFlowTheme.of(context).primary,
                                                                          txtWeight: FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow.ellipsis,
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
                        makeTitleHeader('Cashbacks', true,1),
                        ref
                            .read(UserDashListProvider.notifier)
                            .transList
                            ?.length ==
                            0
                            ?  SliverToBoxAdapter(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                        transitionDuration: Duration(milliseconds: 400),
                                        pageBuilder: (_, __, ___) => SaveMoney(
                                          getMobile: widget.getMobile,
                                          getUserName: ref
                                              .read(UserDashListProvider
                                              .notifier)
                                              .getUser,
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
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Tap to Start Saving Money!",
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
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
                              // final startingIndex = ref
                              //         .read(UserDashListProvider
                              //             .notifier)
                              //         .transList
                              //         ?.length ??
                              //     0 - 3;
                              //
                              // // Ensure the current index is within bounds
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


                              if(transType == false){
                                return SizedBox
                                    .shrink();
                              }

                              if(getFinInt == "0.00"){
                                return SizedBox
                                    .shrink();
                              }

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
                                         "Cashback",
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
                                                    FontWeight.bold


                                                ),
                                              ),
                                            ),
                                            Text(
                                              transType == true
                                                  ? "+" +
                                                  '$amount' +
                                                  ' ₹'
                                                  : "" +
                                                  '$amount' +
                                                  ' ₹',
                                              style: GlobalTextStyles.secondaryText1(
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
                        makeTitleHeader('Recent Withdrawals', true,2),
                        ref
                                    .read(UserDashListProvider.notifier)
                                    .cashBackList
                                    ?.length ==
                                0
                            ?  SliverToBoxAdapter(
              child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          transitionDuration: Duration(milliseconds: 400),
                          pageBuilder: (_, __, ___) => SaveMoney(
                            getMobile: widget.getMobile,
                            getUserName: ref
                                .read(UserDashListProvider
                                .notifier)
                                .getUser,
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
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tap to Start Saving Money!",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                                        .cashBackList?[index];
                                    final amount = document?.amount;
                                    final date = document?.date;
                                    final mobile = document?.mobile;
                                    final docId = document?.docId;

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
                                              color:
                                                  FlutterFlowTheme.of(context)
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
                                                  Icons.arrow_back,
                                                  color: Colors.white,
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              "Cashback",
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
                                                style:  GlobalTextStyles
                                                    .secondaryText2(
                                                    txtSize: 12,
                                                    txtWeight:
                                                    FontWeight.bold),),
                                            trailing: Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "+" + '$amount' + ' ₹',
                                                    style: GlobalTextStyles.secondaryText1(
                                                        txtSize: 16,
                                                        textColor: Colors.red,
                                                        txtWeight:
                                                        FontWeight.bold),
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
                                          .cashBackList
                                          ?.length ??
                                      0,
                                ),
                              ),
                        makeTitleHeader('News and Promo', false,3),
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
                                                      "Save More",
                                                      style: GlobalTextStyles
                                                          .secondaryText1(
                                                          txtSize: 24,
                                                          textColor:
                                                          FlutterFlowTheme.of(
                                                              context)
                                                              .secondary,
                                                          txtWeight:
                                                          FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "Earn More",
                                                      style: GlobalTextStyles
                                                          .secondaryText1(
                                                          txtSize: 24,
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
                                                "Save your Money",
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
                                              child: RichText(
                                                text: TextSpan(
                                                  text:
                                                      "Earn as you save, because your financial well-being deserves a reward.",
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
                                                      text: "",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "",
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
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      transitionDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  400),
                                                      pageBuilder:
                                                          (_, __, ___) =>
                                                              RequestMoney(
                                                        getMobile:
                                                            widget.getMobile,
                                                        isSavingReq: widget
                                                            .isSavingReq!,
                                                                getUserName:  ref
                                                                    .read(UserDashListProvider
                                                                    .notifier)
                                                                    .getUser,
                                                      ),
                                                      transitionsBuilder: (_,
                                                          animation,
                                                          __,
                                                          child) {
                                                        return SlideTransition(
                                                          position:
                                                              Tween<Offset>(
                                                            begin: Offset(0,
                                                                1), // You can adjust the start position
                                                            end: Offset
                                                                .zero, // You can adjust the end position
                                                          ).animate(
                                                                  animation),
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  height: 5.h,
                                                  width: 50.w,
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
                                                      "Request Cashback",
                                                      style: GlobalTextStyles.secondaryText2(
                                                          txtWeight: FontWeight.bold,
                                                          txtSize: 16,
                                                          textColor: FlutterFlowTheme.of(context).secondary),
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
      );
    });
  }

  Future<void> _handleRefresh() async {
    ref.read(isUserRefreshIndicator.notifier).state = true;
    return ref
        .read(UserDashListProvider.notifier)
        .getUserDetails(widget.getMobile);
  }

  SliverPersistentHeader makeTitleHeader(String headerText, bool isViewAll,int section) {
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
                              getMobile: widget.getMobile,
                              isSavingHis: section == 2 ? false : true,
                            ),
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
