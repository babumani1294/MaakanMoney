//todo:- 17.11.23 - new transaction list implementation
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
import 'package:maaakanmoney/pages/User/SaveMoney/PaymentDemo.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../components/NotificationService.dart';
import '../../../components/constants.dart';
import '../../../components/custom_dialog_box.dart';
import '../../../flutter_flow/flutter_flow_theme.dart';
import '../../../flutter_flow/flutter_flow_util.dart';
import '../../../flutter_flow/flutter_flow_widgets.dart';
import '../../../phoneController.dart';
import '../../budget_copy/BudgetCopyController.dart';
import '../../budget_copy/budget_copy_widget.dart';
import '../../chatScreen.dart';
import '../UserScreen_Notifer.dart';

class SaveMoney extends ConsumerStatefulWidget {
  SaveMoney({
    Key? key,
    @required this.getMobile,
    @required this.getDocId,
    @required this.getUserName,
  }) : super(key: key);
  String? getMobile;
  String? getDocId;
  String? getUserName;

  @override
  SaveMoneyState createState() => SaveMoneyState();
}

class SaveMoneyState extends ConsumerState<SaveMoney>
    with TickerProviderStateMixin {
  bool? isGooglePaySelected = false;
  bool? isPhonePeSelected = false;
  String? getPayment = "Select";
  String? getUserName = "";

  @override
  void initState() {
    super.initState();
getUserName = widget.getUserName ?? "";
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
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

      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        appBar: responsiveVisibility(
          context: context,
          tabletLandscape: false,
          desktop: false,
        )
            ? AppBar(
                title: Text(
                  "Save Money",
                  style: GlobalTextStyles.secondaryText1(
                      textColor: FlutterFlowTheme.of(context).secondary2,
                      txtWeight: FontWeight.w700),
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
            child: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(
                                    0), // Bottom-left corner is rounded
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Preferred Mode",
                                        style: GlobalTextStyles.secondaryText1(
                                            textColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            txtWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),

                                  // Add more Positioned widgets for additional images
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondary,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(0), // Bottom-left corner is rounded
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildPaymentRow(
                              getImage: "gpay",
                              title: 'Google Pay',
                              isSelected: isGooglePaySelected ?? false,
                              onChanged: (value) async {

                                isGooglePaySelected = true;


                                //todo:- 2.12.23 adding notification to let admin know payment initiated
                                String? token =
                                await NotificationService
                                    .getDocumentIDsAndData();
                                if (token != null) {
                                  Response? response =
                                  await NotificationService
                                      .postNotificationRequest(
                                      token,
                                      "Hi Admin,\n$getUserName is Trying to Save Money",
                                      "Hurry up, let's Check with GPay App.");
                                  // Handle the response as needed
                                } else {
                                  print(
                                      "Problem in getting Token");
                                }


                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context1) {
                                      return CustomDialogBox(
                                        title: "Need Payment Demo?",
                                        descriptions: "We created an animation to illustrate the payment process.",
                                        text: "Ok",
                                        isNo: true,
                                        isCancel: false,
                                        onNoTap: () async {
                                          final String defaultValue = ref
                                                      .read(UserDashListProvider
                                                          .notifier)
                                                      .getAdminType ==
                                                  "1"
                                              ? Constants.admin1Gpay
                                              : Constants.admin2Gpay;
                                          Clipboard.setData(
                                              ClipboardData(text: defaultValue));

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
                                          Navigator.pop(context1);
                                        },
                                        onTap: () async {
                                          Navigator.pop(context1);
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  PaymentDemo(
                                                isGpaySelected:
                                                    isGooglePaySelected,

                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(1,
                                                        0), // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                            ),
                            SizedBox(height: 20),
                            Container(
                                color: FlutterFlowTheme.of(context).secondary1,
                                height: 1,
                                width: 100.w),
                            SizedBox(height: 20),
                            buildPaymentRow(
                              getImage: "phonePe",
                              title: 'PhonePe',
                              isSelected: isPhonePeSelected ?? false,
                              onChanged: (value) async {

                                isGooglePaySelected = false;

                                //todo:- 2.12.23 adding notification to let admin know payment initiated
                                String? token =
                                await NotificationService
                                    .getDocumentIDsAndData();
                                if (token != null) {
                                  Response? response =
                                  await NotificationService
                                      .postNotificationRequest(
                                      token,
                                      "Hi Admin,\n$getUserName is Trying to Save Money",
                                      "Hurry up, let's Check with PhonePe App.");
                                  // Handle the response as needed
                                } else {
                                  print(
                                      "Problem in getting Token");
                                }

                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context1) {
                                      return CustomDialogBox(
                                        title: "Need Payment Demo?",
                                        descriptions:
                                            "We created an animation to illustrate the payment process.",
                                        text: "Ok",
                                        isNo: true,
                                        isCancel: false,
                                        onNoTap: () async {
                                          final String defaultValue = ref
                                                      .read(UserDashListProvider
                                                          .notifier)
                                                      .getAdminType ==
                                                  "1"
                                              ? Constants.admin1Gpay
                                              : Constants.admin2Gpay;
                                          Clipboard.setData(
                                              ClipboardData(text: defaultValue));

                                          var openAppResult =
                                              await LaunchApp.openApp(
                                            openStore: true,
                                            androidPackageName: 'com.phonepe.app',
                                            iosUrlScheme: 'sf',
                                            appStoreLink:
                                                'https://apps.apple.com/in/app/phonepe-secure-payments-app/id1170055821',
                                          );

                                          Navigator.pop(context1);
                                        },
                                        onTap: () async {
                                          Navigator.pop(context1);
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration:
                                                  Duration(milliseconds: 400),
                                              pageBuilder: (_, __, ___) =>
                                                  PaymentDemo(
                                                isGpaySelected:
                                                    isGooglePaySelected,

                                              ),
                                              transitionsBuilder:
                                                  (_, animation, __, child) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(1,
                                                        0), // You can adjust the start position
                                                    end: Offset
                                                        .zero, // You can adjust the end position
                                                  ).animate(animation),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    });
                              },
                            ),
                            SizedBox(height: 20),
                            Container(
                                color: FlutterFlowTheme.of(context).secondary1,
                                height: 1,
                                width: 100.w),
                            SizedBox(height: 20),
                            buildPaymentRow(
                              getImage: "Paytm",
                              title: 'Paytm',
                              isSelected: isPhonePeSelected ?? false,
                              onChanged: (value) async {

                                //todo:- 2.12.23 , coping mapped admin mobile no

                                final String defaultValue = ref
                                    .read(UserDashListProvider
                                    .notifier)
                                    .getAdminType ==
                                    "1"
                                    ? Constants.admin1Gpay
                                    : Constants.admin2Gpay;

                                Clipboard.setData(
                                    ClipboardData(text: defaultValue));

                                //todo:- 2.12.23 adding notification to let admin know payment initiated
                                String? token =
                                await NotificationService
                                    .getDocumentIDsAndData();
                                if (token != null) {
                                  Response? response =
                                  await NotificationService
                                      .postNotificationRequest(
                                      token,
                                      "Hi Admin,\n$getUserName is Trying to Save Money",
                                      "Hurry up, let's Check with Paytm App.");
                                  // Handle the response as needed
                                } else {
                                  print(
                                      "Problem in getting Token");
                                }

                                var openAppResult = await LaunchApp.openApp(
                                  openStore: true,
                                  androidPackageName: 'net.one97.paytm',
                                  iosUrlScheme: 'paytm',
                                  appStoreLink: 'https://apps.apple.com/in/app/paytm-kyc-wallet-recharge/id473941634',
                                );
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),


              ]
            ),
          ),
        )),
      );
    });
  }

//todo:- 19.11.23 - creating column row for payment mode design

  Widget buildPaymentRow({
    required String getImage,
    required String title,
    required bool isSelected,
    required Function(bool?) onChanged,
    // Function()? onTap;
  }) {
    return InkWell(
      onTap: () {
        onChanged(!isSelected);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              height: 30,
              width: 30,
              child: Image.asset(
                "images/final/Dashboard/SaveMoney/$getImage.png",
                errorBuilder: (context, exception, stackTrace) {
                  return Image.asset(
                    "images/final/Common/Error.png",
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: GlobalTextStyles.secondaryText2(
                  textColor: FlutterFlowTheme.of(context).primary,
                  txtWeight: FontWeight.w600),
            ),
            Spacer(),
            RoundCheckbox(
              value: isSelected,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

class RoundCheckbox extends StatelessWidget {
  final bool? value;
  final Function(bool) onChanged;

  const RoundCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value!);
      },
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color:
              value! ? FlutterFlowTheme.of(context).secondary1 : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
              width: 2.0,
              color: value!
                  ? FlutterFlowTheme.of(context).secondary
                  : Colors.grey),
        ),
        child: Center(
          child: value!
              ? Icon(
                  Icons.check,
                  size: 18.0,
                  color: value!
                      ? FlutterFlowTheme.of(context).secondary
                      : Colors.black,
                )
              : null,
        ),
      ),
    );
  }
}
