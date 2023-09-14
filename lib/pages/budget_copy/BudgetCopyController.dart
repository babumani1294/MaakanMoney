// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:tuple/tuple.dart';

enum ResStatus { init, loading, success, failure }

final adminDashListProvider =
    StateNotifierProvider<DashListNotifier, AdminDashState2>(
        (ref) => DashListNotifier(ref));

class DashListNotifier extends StateNotifier<AdminDashState2> {
  Ref ref;

  double getNetbalance = 0;
  double getTotalCredit = 0;
  double getTotalDebit = 0;

  double getNetIntbalance = 0;
  double getTotalIntCredit = 0;
  double getTotalIntDebit = 0;

  List<User>? userList = [];
  List<User2>? userList2 = [];
  List<Transaction>? transList = [];
  List<EnquiryList>? enquiryList = [];
  List<Transaction2>? transList2 = [];
  List<User>? moneyRequestUsers = [];
  List<User2>? moneyRequestUsers2 = [];
  List<User2>? cashBckRequestUsers2 = [];
  List<User2>? notifications = [];
  bool isPendingRequest = false;

  double? admnTtlCredit = 0.0;
  double? admnTtlDebit = 0.0;
  double? totalNet = 0.0;
  double? admnTtlIntCredit = 0.0;
  double? admnTtlIntDebit = 0.0;
  double? totalNetInt = 0.0;

  final txtSearch = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ConnectivityResult? data;

  DashListNotifier(this.ref)
      : super(AdminDashState2(
            status: ResStatus.init, success1: [], success2: [], failure: ""));

  Future<void> getDashboardDetails() async {
    //getHeaderDetails();
    // getNetbalance = 0;
    getTotalCredit = 0.0;
    getTotalDebit = 0.0;
    //
    // getNetIntbalance = 0;
    getTotalIntCredit = 0.0;
    getTotalIntDebit = 0.0;

    ref.read(isPendingReq.notifier).state = 0;
    ref.read(isPendingCashbckReq.notifier).state = 0;
    ref.read(isPendingMessages.notifier).state = 0;
    if (ref.read(adminDashListProvider.notifier).data ==
        ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }

    ref.read(getListItemProvider.notifier).state = [];
    state = getLoadingState();
    userList2 = await fetchUsersList2();
    enquiryList = await fetchEnquiryList();
    ref.read(getListItemProvider.notifier).state = userList2;
    state = getSuccessState(userList2, transList);
  }

  // Future<void> getHeaderDetails() async {
  //   // Map<String, dynamic> newAdminData = {};
  //   // CollectionReference? _collectionReference;
  //   // _collectionReference =
  //   //     FirebaseFirestore.instance.collection('adminDetails');
  //   // QuerySnapshot snapshot = await _collectionReference!.limit(1).get();
  //   //
  //   // newAdminData = {
  //   //   'totalCredit': 43366.0,
  //   //   'totalDebit': 28924.0,
  //   // };
  //   //
  //   // if (snapshot.docs.isNotEmpty) {
  //   //   String documentId = snapshot.docs.first.id;
  //   //   await _collectionReference!.doc(documentId).update(newAdminData);
  //   // }
  //
  //   QuerySnapshot adminSnapshot =
  //       await FirebaseFirestore.instance.collection('adminDetails').get();
  //
  //   await Future.forEach(adminSnapshot.docs, (doc) async {
  //     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //
  //     admnTtlCredit = data['totalCredit'];
  //     admnTtlDebit = data['totalDebit'];
  //     admnTtlIntCredit = data['totalIntCredit'];
  //     admnTtlIntDebit = data['totalIntDebit'];
  //     ref.read(getCredit.notifier).state = Tuple6(admnTtlCredit, admnTtlDebit,
  //         0.0, admnTtlIntCredit, admnTtlIntDebit, 0.0);
  //   });
  //
  //   if (adminSnapshot.docs.isNotEmpty) {
  //     Map<String, dynamic> data =
  //         adminSnapshot.docs[0].data() as Map<String, dynamic>;
  //
  //     admnTtlCredit = data['totalCredit'];
  //     admnTtlDebit = data['totalDebit'];
  //     admnTtlIntCredit = data['totalIntCredit'];
  //     admnTtlIntDebit = data['totalIntDebit'];
  //
  //     totalNet = admnTtlCredit! - admnTtlDebit!;
  //
  //     totalNetInt = admnTtlIntCredit! - admnTtlIntDebit!;
  //   }
  // }

  Future<List<User2>> fetchUsersList2() async {
    QuerySnapshot userSnapshot =
        await firestore.collection('users').orderBy('name').get();

    List<User2> users2 = [];
    moneyRequestUsers2 = [];
    cashBckRequestUsers2 = [];
    notifications = [];

    await Future.forEach(userSnapshot.docs, (doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //todo:- below code, will check for empty message for user
      // bool? isMessages = await isCollectionEmpty(doc.id);

      //todo:- 1.9.23 - if field updated with wrong data type, below code is to resolve error
      // var name = data['name'];
      // if (name == "Babu") {
      //   //todo:- 1.9.23  adding specific field value to collection
      //   DocumentSnapshot snapshot = await FirebaseFirestore.instance
      //       .collection('users')
      //       .doc(doc.id)
      //       .get();
      //
      //   Map<String, dynamic> newUserData = {};
      //   newUserData = {
      //     // 'totalDebit': getFinalUsrDebit?.toDouble(),
      //     'totalIntDebit': 0.10,
      //     // 'netTotal': getFinalNetTotal,
      //     // 'netIntTotal': getFinalNetIntTotal,
      //   };
      //
      //   await updateUserDetails(newUserData, snapshot);
      //
      //   return;
      // }

      bool? isMoneyRequest = data['isMoneyRequest'];
      bool? isNotificationByAdmin = data['notificationByAdmin'];
      bool? isCashbckRequest = data['isCashbackRequest'];

      if (isMoneyRequest!) {
        ref.read(isPendingReq.notifier).state =
            (ref.read(isPendingReq.notifier).state! + 1)!;

        User2 user = User2(
          name: data['name'],
          total: data['total'],
          interest: data['totalIntCredit'],
          mobile: data['mobile'],
          docId: doc.id,
          isMoneyRequest: data['isMoneyRequest'],
          requestAmount: data['requestAmnt'],
          isNotificationByAdmin: data['notificationByAdmin'],
          transactions: transList2 ?? [],
          totalCredit: data['totalCredit'],
          totalDebit: data['totalDebit'],
          totalIntCredit: data['totalIntCredit'],
          totalIntDebit: data['totalIntDebit'],
          getSecurityCode: data['securityCode'],
          isCashBackRequest: data['isCashbackRequest'],
          requestCashbckAmount: data['requestCashbckAmnt'],
        );
        moneyRequestUsers2?.add(user);
      }

      if (isCashbckRequest!) {
        ref.read(isPendingCashbckReq.notifier).state =
            (ref.read(isPendingCashbckReq.notifier).state! + 1)!;

        User2 user = User2(
          name: data['name'],
          total: data['total'],
          interest: data['totalIntCredit'],
          mobile: data['mobile'],
          docId: doc.id,
          isMoneyRequest: data['isMoneyRequest'],
          requestAmount: data['requestAmnt'],
          isNotificationByAdmin: data['notificationByAdmin'],
          transactions: transList2 ?? [],
          totalCredit: data['totalCredit'],
          totalDebit: data['totalDebit'],
          totalIntCredit: data['totalIntCredit'],
          totalIntDebit: data['totalIntDebit'],
          getSecurityCode: data['securityCode'],
          isCashBackRequest: data['isCashbackRequest'],
          requestCashbckAmount: data['requestCashbckAmnt'],
        );
        cashBckRequestUsers2?.add(user);
      }

      // if (isMessages == true) {
      //   isNotificationByAdmin = true;
      // }

      if (isNotificationByAdmin! == false) {
        ref.read(isPendingMessages.notifier).state =
            (ref.read(isPendingMessages.notifier).state! + 1)!;
        // ref.read(isPendingReq.notifier).state =
        //     (ref.read(isPendingReq.notifier).state! + 1)!;

        User2 user = User2(
          name: data['name'],
          total: data['total'],
          interest: data['totalIntCredit'],
          mobile: data['mobile'],
          docId: doc.id,
          isMoneyRequest: data['isMoneyRequest'],
          requestAmount: data['requestAmnt'],
          isNotificationByAdmin: data['notificationByAdmin'],
          transactions: transList2 ?? [],
          totalCredit: data['totalCredit'],
          totalDebit: data['totalDebit'],
          totalIntCredit: data['totalIntCredit'],
          totalIntDebit: data['totalIntDebit'],
          getSecurityCode: data['securityCode'],
          isCashBackRequest: data['isCashbackRequest'],
          requestCashbckAmount: data['requestCashbckAmnt'],
        );
        notifications?.add(user);
      }

      User2 user = User2(
        name: data['name'],
        total: data['total'],
        interest: data['totalIntCredit'],
        mobile: data['mobile'],
        docId: doc.id,
        isMoneyRequest: data['isMoneyRequest'],
        requestAmount: data['requestAmnt'],
        isNotificationByAdmin: data['notificationByAdmin'],
        transactions: transList2 ?? [],
        totalCredit: data['totalCredit'],
        totalDebit: data['totalDebit'],
        totalIntCredit: data['totalIntCredit'],
        totalIntDebit: data['totalIntDebit'],
        getSecurityCode: data['securityCode'],
        isCashBackRequest: data['isCashbackRequest'],
        requestCashbckAmount: data['requestCashbckAmnt'],
      );
      users2.add(user);
    });

    return users2;
  }
//todo:- 1.9.23 dont delete
  // Future<void> updateUserDetails(
  //     Map<String, dynamic> newData, DocumentSnapshot snapshot) async {
  //   // QuerySnapshot snapshot = await _collectionReference!.limit(1).get();
  //   // FirebaseFirestore.instance.collection('adminDetails');
  //   CollectionReference? _collectionUsers;
  //   _collectionUsers = FirebaseFirestore.instance.collection('users');
  //   if (snapshot.id.isNotEmpty) {
  //     String documentId = snapshot.id;
  //     await _collectionUsers!
  //         .doc(documentId)
  //         .update(newData)
  //         .then((value) => null);
  //   }
  // }

  Future<List<EnquiryList>> fetchEnquiryList() async {
    QuerySnapshot userSnapshot = await firestore.collection('Enquiry').get();

    List<EnquiryList> enquiryList = [];

    await Future.forEach(userSnapshot.docs, (doc) async {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //todo:- below code, will check for empty message for user
      // bool? isMessages = await isCollectionEmpty(doc.id);
      String? enquiryNo = data['mobile'];

      EnquiryList enquiry = EnquiryList(
        mobile: data['mobile'],
      );
      enquiryList?.add(enquiry);

      // if (isMessages == true) {
      //   isNotificationByAdmin = true;
      // }
    });

    return enquiryList;
  }

  Future<bool?> isPendingMoneyReq() async {
    ref.read(adminDashListProvider.notifier).userList?.map((doc) {
      bool? isPendingAmount = doc?.isMoneyRequest;

      if (isPendingAmount!) {
        isPendingRequest = true;
        return;
      }
    });
  }

  Future<bool> isCollectionEmpty(String getDocId) async {
    QuerySnapshot messagesSnapshot = await firestore
        .collection('users')
        .doc(getDocId)
        .collection('messages')
        .limit(1)
        .get();

    return messagesSnapshot.docs.isEmpty;
  }

  Future<bool?> updateData(String? getDocId, bool? isSavingAmntReqPaid) async {
    String? documentId = getDocId;

    if (isSavingAmntReqPaid!) {
      try {
        await firestore.collection('users').doc(documentId).update({
          'isMoneyRequest': false,
        }).then((value) {
          Constants.showToast(
              "Money Request Status Updated", ToastGravity.CENTER);
          getDashboardDetails();
          return true;
        });
        return null; // Return null or a success message if desired
      } catch (error) {
        Constants.showToast("Request Failed, Try again!", ToastGravity.CENTER);
        return false; // Return the error message as a string
      }
    } else {
      try {
        await firestore.collection('users').doc(documentId).update({
          'isCashbackRequest': false,
        }).then((value) {
          Constants.showToast(
              "Money Request Status Updated", ToastGravity.CENTER);
          getDashboardDetails();
          return true;
        });
        return null; // Return null or a success message if desired
      } catch (error) {
        Constants.showToast("Request Failed, Try again!", ToastGravity.CENTER);
        return false; // Return the error message as a string
      }
    }
  }

  AdminDashState2 getLoadingState() {
    return AdminDashState2(
        status: ResStatus.loading, success1: null, success2: null, failure: "");
  }

  AdminDashState2 getSuccessState(userList, transList) {
    return AdminDashState2(
        status: ResStatus.success,
        success1: userList,
        success2: transList,
        failure: "");
  }

  AdminDashState2 getFailureState(err) {
    return AdminDashState2(
        status: ResStatus.failure, success1: [], success2: [], failure: err);
  }
}

var isPendingReq = StateProvider<int?>((ref) => 0);
var isPendingCashbckReq = StateProvider<int?>((ref) => 0);
var isPendingMessages = StateProvider<int?>((ref) => 0);
var isRefreshIndicator = StateProvider<bool?>((ref) => false);
var isUserRefreshIndicator = StateProvider<bool?>((ref) => false);
var getCredit =
    StateProvider<Tuple6>((ref) => Tuple6(0.0, 0.0, 0.0, 0.0, 0.0, 0.0));

var aaa = StateProvider<double?>((ref) => 0.0);

class AdminDashState {
  ResStatus? status;
  List<User>? success1;
  List<Transaction>? success2;
  String? failure;

  AdminDashState({this.status, this.success1, this.success2, this.failure});
}

class AdminDashState2 {
  ResStatus? status;
  List<User2>? success1;
  List<Transaction>? success2;
  String? failure;

  AdminDashState2({this.status, this.success1, this.success2, this.failure});
}

class User {
  String? name;
  String? mobile;
  String? total;
  double? interest;
  String? docId;
  bool? isNotificationByAdmin;
  bool? isMoneyRequest;
  double? requestAmount;
  // List<Transaction> transactions;

  User({
    required this.name,
    required this.mobile,
    required this.total,
    required this.interest,
    required this.docId,
    required this.isMoneyRequest,
    required this.requestAmount,
    required this.isNotificationByAdmin,
    // required this.transactions
  });
}

class User2 {
  String? name;
  String? mobile;
  double? total;
  double? interest;
  String? docId;
  bool? isNotificationByAdmin;
  bool? isMoneyRequest;
  bool? isCashBackRequest;
  double? requestAmount;
  double? requestCashbckAmount;
  List<Transaction2> transactions;
  double? totalCredit;
  double? totalDebit;
  double? totalIntCredit;
  double? totalIntDebit;
  int? getSecurityCode;
  double? getNetBal() {
    var getTotalCredit = totalCredit;
    var getTotalDebit = totalDebit;

    double getFinalBal = getTotalCredit! - getTotalDebit!;
    // print(getFinalBal);

    return getFinalBal;
  }

  double? getNetIntBal() {
    var getTotalCredit = totalIntCredit;
    var getTotalDebit = totalIntDebit;

    double getFinalBal = getTotalCredit! - getTotalDebit!;
    // print(getFinalBal);

    return getFinalBal;
  }

  User2(
      {required this.name,
      required this.mobile,
      required this.total,
      required this.interest,
      required this.docId,
      required this.isMoneyRequest,
      required this.isCashBackRequest,
      required this.requestAmount,
      required this.requestCashbckAmount,
      required this.isNotificationByAdmin,
      required this.transactions,
      required this.totalCredit,
      required this.totalDebit,
      required this.totalIntCredit,
      required this.totalIntDebit,
      required this.getSecurityCode});
}

class EnquiryList {
  String? mobile;

  EnquiryList({
    required this.mobile,
  });
}

class Transaction {
  int? amount;
  double? interest;
  String? date;
  bool? isDeposit;
  String? mobile;

  Transaction({
    required this.amount,
    required this.date,
    required this.isDeposit,
    required this.mobile,
    required this.interest,
  });
}

class Transaction2 {
  int? amount;
  double? interest;
  String? date;
  bool? isDeposit;
  String? mobile;
  String? transDocId;

  Transaction2({
    required this.amount,
    required this.date,
    required this.isDeposit,
    required this.mobile,
    required this.interest,
    required this.transDocId,
  });
}

class AdminDetails {
  double? totalCredit;
  double? totalDebit;
  double? totalIntCredit;
  double? totalIntDebit;

  double? getNetBal() {
    var getTotalCredit = totalCredit;
    var getTotalDebit = totalDebit;

    double getFinalBal = getTotalCredit! - getTotalDebit!;
    print(getFinalBal);

    return getFinalBal;
  }

  double? getNetIntBal() {
    var getTotalCredit = totalIntCredit;
    var getTotalDebit = totalIntDebit;

    double getFinalBal = getTotalCredit! - getTotalDebit!;
    print(getFinalBal);

    return getFinalBal;
  }

  AdminDetails(
      {required this.totalCredit,
      required this.totalDebit,
      required this.totalIntCredit,
      required this.totalIntDebit});
}

var getListItemProvider = StateProvider<List<User2>?>((ref) => []);
