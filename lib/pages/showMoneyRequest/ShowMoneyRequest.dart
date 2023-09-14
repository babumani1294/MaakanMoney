import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../components/constants.dart';
import '../../components/custom_dialog_box.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../budget_copy/BudgetCopyController.dart';

class ShowMoneyRequest extends ConsumerStatefulWidget {
  ShowMoneyRequest({
    Key? key,
  }) : super(key: key);

  @override
  ShowMoneyRequestState createState() => ShowMoneyRequestState();
}

class ShowMoneyRequestState extends ConsumerState<ShowMoneyRequest>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          ref.read(isUserRefreshIndicator.notifier).state = false;
        }));

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
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
                title: Text(
                  "Money Request",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // Set the desired text color here
                  ),
                ),
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
                elevation: 0.0,
              )
            : null,
        body: SafeArea(
            child: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ref
                  .read(adminDashListProvider.notifier)
                  .moneyRequestUsers
                  ?.length,
              itemBuilder: (context, index) {
                final document = ref
                    .read(adminDashListProvider.notifier)
                    .moneyRequestUsers?[index];

                final name = document?.name;
                final mobile = document?.mobile;
                final total = document?.total;
                final interest = document?.interest;
                String? getDocId = document?.docId;
                bool? isMoneyRequest = document?.isMoneyRequest;
                double? requestAmnt = document?.requestAmount;

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 5),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 3,
                    child: Slidable(
                      key: const ValueKey(0),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          Visibility(
                            visible: isMoneyRequest! ? true : false,
                            child: SlidableAction(
                              onPressed: (context) {
                                String? documentId = getDocId;

                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        title: "Alert!",
                                        descriptions:
                                            "Are you sure, Have you sent money",
                                        text: "Ok",
                                        isCancel: true,
                                        onTap: () {
                                          if (ref
                                                  .read(adminDashListProvider
                                                      .notifier)
                                                  .data ==
                                              ConnectivityResult.none) {
                                            Constants.showToast(
                                                "No Internet Connection",
                                                ToastGravity.BOTTOM);
                                            return;
                                          }
                                          ref
                                              .read(adminDashListProvider
                                                  .notifier)
                                              .updateData(getDocId, true);
                                          Navigator.pop(context);
                                        },
                                      );
                                    });
                              },
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              icon: Icons.currency_rupee,
                              label: isMoneyRequest! ? 'paid' : "UnPaid",
                            ),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: ListTile(
                          leading: Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            color: isMoneyRequest!
                                ? Colors.red
                                : const Color(0xFF004D40),
                            elevation: 6.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: const Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  8.0, 8.0, 8.0, 8.0),
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24.0,
                              ),
                            ),
                          ),
                          title: Text(
                            name.toString().toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xFF004D40),
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                letterSpacing: 0.5),
                          ),
                          subtitle: Text('$total' + ' ₹',
                              style: const TextStyle(
                                  color: Color(0xFF004D40),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  letterSpacing: 0.5)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(isMoneyRequest! ? 'Requested' : "",
                                  style: const TextStyle(
                                      color: Colors.lightGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      letterSpacing: 0.5)),
                              Text(isMoneyRequest! ? '$requestAmnt' + ' ₹' : "",
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0,
                                      letterSpacing: 0.5)),
                            ],
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ])),
      ),
    );
  }
}
