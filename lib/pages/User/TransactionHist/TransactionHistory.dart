import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;
import '../../../components/ReusableWidget/ReusableCard.dart';
import '../../../components/constants.dart';
import '../../../components/custom_dialog_box.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import '../../../flutter_flow/flutter_flow_widgets.dart';
import '../../../phoneController.dart';
import '../../Auth/mpin.dart';
import '../../Auth/phone_auth_widget.dart';
import '../../budget_copy/BudgetCopyController.dart';
import '../../chatScreen.dart';
import '../Profile/Profile.dart';
import '../SaveMoney/SaveMoney.dart';
import '../UserScreen_Notifer.dart';

//todo:- 17.11.23 - new transaction list implementation
class TransactionHistory extends ConsumerStatefulWidget {
  TransactionHistory({
    Key? key,
    @required this.getMobile,
    @required this.getDocId,
    @required this.isSavingHis,
  }) : super(key: key);
  String? getMobile;
  String? getDocId;
  bool? isSavingHis;

  @override
  TransactionHistoryState createState() => TransactionHistoryState();
}

class TransactionHistoryState extends ConsumerState<TransactionHistory>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final txtReqAmount = TextEditingController();
  String? loginKey;

//todo:- 3.5.23
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(isUserRefreshIndicator.notifier).state = false;
      ref.read(txtPaidStatus.notifier).state = false;
      ref.read(txtCashbckPaidStatus.notifier).state = false;
      ref.read(UserDashListProvider.notifier).getUserDetails(widget.getMobile);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: true,
                toolbarHeight: 8.h,
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
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
          child: Container(
            color: Colors.white,
            height: 100.h,
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: CustomScrollView(
                    slivers: [
                      makeTitleHeader('Recent Transactions', false),
                      widget.isSavingHis!
                          ? ref
                                      .read(UserDashListProvider.notifier)
                                      .transList
                                      ?.length ==
                                  0
                          ? SliverToBoxAdapter(
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
                                  delegate:

                                      //todo:- 4.10.23 grouping up transaction by date.par
                                      SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    // Now, use the groupedTransactions map to access transactions for each date
                                    final groupedTransactions = ref
                                        .read(UserDashListProvider.notifier)
                                        .groupTransactionsByDate(ref
                                                .read(UserDashListProvider
                                                    .notifier)
                                                .transList ??
                                            []);
                                    final dateKeys =
                                        groupedTransactions.keys.toList();
                                    final date = dateKeys[
                                        index]; // Get the date for this index

                                    // Create a list of transaction widgets for the current date
                                    final transactionsForDate =
                                        groupedTransactions[date] ?? [];

                                    final transactionWidgets =
                                        transactionsForDate.map((transaction) {
                                      //todo:- 4.10.23 Customize how you want to display each transaction item
                                      final amount = transaction?.amount;
                                      final transType = transaction?.isDeposit;
                                      final datee = transaction?.date;
                                      final mobile = transaction?.mobile;
                                      final docId = transaction?.docId;
                                      final interest = transaction?.interest;

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
                                                datee.toString().toUpperCase(),
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
                                    }).toList();

                                    //todo:- Calculate the total sum for the current date
                                    double totalSum = transactionsForDate.fold(
                                      0.0, // Initial value as a double
                                      (double sum, transaction) =>
                                          sum +
                                          ((transaction!.isDeposit)!
                                              ? (transaction.amount ?? 0)
                                              : -(transaction.amount ?? 0)),
                                    );

                                    return Container(
                                      color: Colors.grey.shade50,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                top: 15,
                                                bottom: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  date,
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
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Saved:",
                                                      style: GlobalTextStyles
                                                          .secondaryText1(
                                                              txtSize: 16,
                                                              textColor:
                                                                  Colors.grey,
                                                              txtWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Text(
                                                      " $totalSum ₹",
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Display transaction widgets for the date
                                          ...transactionWidgets,
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: ref
                                      .read(UserDashListProvider.notifier)
                                      .groupTransactionsByDate(ref
                                              .read(
                                                  UserDashListProvider.notifier)
                                              .transList ??
                                          [])
                                      .length,
                                ))
                          : ref
                                      .read(UserDashListProvider.notifier)
                                      .cashBackList
                                      ?.length ==
                                  0
                          ? SliverToBoxAdapter(
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
                                  delegate:

                                      //todo:- 4.10.23 grouping up transaction by date.par
                                      SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    // Now, use the groupedTransactions map to access transactions for each date
                                    final groupedTransactions = ref
                                        .read(UserDashListProvider.notifier)
                                        .groupTransactionsByDate1(ref
                                                .read(UserDashListProvider
                                                    .notifier)
                                                .cashBackList ??
                                            []);
                                    final dateKeys =
                                        groupedTransactions.keys.toList();
                                    final date = dateKeys[
                                        index]; // Get the date for this index

                                    // Create a list of transaction widgets for the current date
                                    final transactionsForDate =
                                        groupedTransactions[date] ?? [];

                                    final transactionWidgets =
                                        transactionsForDate.map((transaction) {
                                      //todo:- 4.10.23 Customize how you want to display each transaction item
                                      final amount = transaction?.amount;
                                      // final transType = transaction?.isDeposit;
                                      final datee = transaction?.date;
                                      final mobile = transaction?.mobile;
                                      final docId = transaction?.docId;

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
                                                  datee
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: GlobalTextStyles
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
                                                          textColor: FlutterFlowTheme
                                                              .of(
                                                              context)
                                                              .deposite
                                                          ,
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
                                    }).toList();

                                    //todo:- Calculate the total sum for the current date
                                    double totalSum = transactionsForDate.fold(
                                      0.0, // Initial value as a double
                                      (double sum, transaction) =>
                                          sum + (transaction.amount ?? 0),
                                    );

                                    return Container(
                                      color: Colors.grey.shade50,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0,
                                                right: 16.0,
                                                top: 15,
                                                bottom: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  date,
                                                  style: TextStyle(
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Saved:",
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary2,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      " $totalSum ₹",
                                                      style: TextStyle(
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18.0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Display transaction widgets for the date
                                          ...transactionWidgets,
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: widget.isSavingHis!
                                      ? ref
                                          .read(UserDashListProvider.notifier)
                                          .groupTransactionsByDate(ref
                                                  .read(UserDashListProvider
                                                      .notifier)
                                                  .transList ??
                                              [])
                                          .length
                                      : ref
                                          .read(UserDashListProvider.notifier)
                                          .groupTransactionsByDate1(ref
                                                  .read(UserDashListProvider
                                                      .notifier)
                                                  .cashBackList ??
                                              [])
                                          .length,
                                ))
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
      );
    });
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
                        print("View all tapped!");
                      },
                      child: Text(
                        "View All",
                        style: FlutterFlowTheme.of(context).bodyLarge.override(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              color: FlutterFlowTheme.of(context).secondary2,
                              letterSpacing: 0.5,
                              fontSize: 16,
                            ),
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
