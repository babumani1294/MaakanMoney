import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/pages/budget_copy/BudgetCopyController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import '../../components/constants.dart';
import '../update_money/update_money_widget.dart';

final UserDashListProvider =
    StateNotifierProvider<DashListNotifier, UserDashListState>(
        (ref) => DashListNotifier(ref));

class DashListNotifier extends StateNotifier<UserDashListState> {
  Ref ref;

  List<Transaction>? transList = [];
  List<Cashbacks>? cashBackList = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ConnectivityResult? data;

  //todo:- varialble for user screen
  double getNetbalance = 0;
  double getTotalCredit = 0;
  double getTotalDebit = 0;

  double getNetIntbalance = 0;
  double getTotalIntCredit = 0;
  double getTotalIntDebit = 0;

  String? getUser = "";
  double? getLastReqAmount;
  double? getLastCashbckReqAmount;
  bool? getIsMoneyReq;
  bool? getIsCashbckReq;
  bool? getIsCanMoneyReq;
  bool? getIsCanCashbckReq;
  String? getDocId;
  bool isNotificationByAdmin = false;
  String? getAdminType = "";

  DateTime? startDate;
  DateTime? endDate;

  DashListNotifier(this.ref)
      : super(UserDashListState(
            status: ResStatus.init, success: [], failure: ""));

  Future<void> getUserDetails(String? getMobile) async {
    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    state = getLoadingState();
    transList = await getUserTransactions(getMobile);
    cashBackList = await getUserCashbckTransactions(getMobile);
    state = getSuccessState(transList);
  }

  //todo:- 4.10.23 Helper function to group transactions by date
  Map<String, List<Transaction>> groupTransactionsByDate(
      List<Transaction> transactions) {
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final date =
          transaction.date.toString(); // Assuming date is stored as a string
      if (groupedTransactions[date] == null) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]?.add(transaction);
    }
    return groupedTransactions;
  }

  //todo:- 4.10.23 Helper function to group transactions by date for cashback
  Map<String, List<Cashbacks>> groupTransactionsByDate1(
      List<Cashbacks> transactions) {
    final groupedTransactions = <String, List<Cashbacks>>{};
    for (final transaction in transactions) {
      final date =
          transaction.date.toString(); // Assuming date is stored as a string
      if (groupedTransactions[date] == null) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]?.add(transaction);
    }
    return groupedTransactions;
  }

  Future<List<Transaction>> getUserTransactions(String? getMobile) async {
    double totalCredit = 0;
    List<double> creditList = [];

    double totalDebit = 0;
    List<double> debitList = [];

//todo:- for interest
    double totalIntCredit = 0;
    List<double> creditIntList = [];

    double totalIntDebit = 0;
    List<double> debitIntList = [];

    getUser = await isUserVerified(getMobile);

    final QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(getDocId)
        .collection('transaction')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp',
            isLessThanOrEqualTo: endDate == null
                ? endDate
                : DateTime(endDate!.year, endDate!.month, endDate!.day))
        .orderBy('timestamp', descending: true)
        .get();

    final List<Transaction> transactionList = transactionSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'];
          final isDeposit = data['isDeposit'];
          final mobile = data['mobile'];
          final date = data['date'];
          final interest = data['interest'];

          if (getMobile == (mobile)) {
            return Transaction(
              amount: amount,
              date: date,
              isDeposit: isDeposit,
              mobile: mobile,
              docId: doc.id,
              interest: interest,
            );
          } else {
            return null;
          }
        })
        .whereType<Transaction>()
        .toList();

    //todo:- calculating total debit and total credit
    creditList = transactionSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'] as int;
          final isDeposit = data['isDeposit'] as bool;
          final mobile = data['mobile'] as String;

          if (getMobile == (mobile)) {
            if (isDeposit) {
              return amount.toDouble();
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in creditList) {
      totalCredit += transaction;
    }

    debitList = transactionSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'] as int;
          final isDeposit = data['isDeposit'] as bool;
          final mobile = data['mobile'] as String;

          if (getMobile == (mobile)) {
            if (isDeposit == false) {
              return amount.toDouble();
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in debitList) {
      totalDebit += transaction;
    }

    getTotalCredit = totalCredit;

    getTotalDebit = totalDebit;

    double finalCredit = getTotalCredit;
    double finalDebit = getTotalDebit;
    getNetbalance = finalCredit - finalDebit;

    //todo:- calculating Interest of total debit and total credit
    creditIntList = transactionList
        .map((doc) {
          // final data = doc. as Map<String, dynamic>;
          final intAmount = doc.interest as double;
          final isDeposit = doc.isDeposit as bool;
          final mobile = doc.mobile as String;

          if (getMobile == (mobile)) {
            if (isDeposit) {
              return intAmount.toDouble();
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in creditIntList) {
      totalIntCredit += transaction;
    }

    getTotalIntCredit = totalIntCredit;

    double finalIntCredit = getTotalIntCredit;

    getNetIntbalance = finalIntCredit;

    return transactionList;
  }

  Future<List<Cashbacks>> getUserCashbckTransactions(String? getMobile) async {
    double totalIntDebit = 0;
    List<double> debitIntList = [];

    getUser = await isUserVerified(getMobile);

    final QuerySnapshot cashbackSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(getDocId)
        .collection('cashbacks')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp',
            isLessThanOrEqualTo: endDate == null
                ? endDate
                : DateTime(endDate!.year, endDate!.month, endDate!.day))
        .orderBy('timestamp', descending: true)
        .get();

    final List<Cashbacks> transactionList = cashbackSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'];
          final isCashbckDep = data['isCashbckDeposit'];
          final mobile = data['mobile'];
          final date = data['date'];

          if (getMobile == (mobile)) {
            return Cashbacks(
              amount: amount,
              date: date,
              isCashbackDeposit: isCashbckDep,
              mobile: mobile,
              docId: doc.id,
            );
          } else {
            return null;
          }
        })
        .whereType<Cashbacks>()
        .toList();

    //todo:- calculating Interest of total debit
    debitIntList = transactionList
        .map((doc) {
          // final data = doc. as Map<String, dynamic>;
          final intAmount = doc.amount as double;
          final isCashbckDeposit = doc.isCashbackDeposit as bool;
          final mobile = doc.mobile as String;

          if (getMobile == (mobile)) {
            if (isCashbckDeposit == false) {
              return intAmount.toDouble();
            } else {
              return null;
            }
          } else {
            return null;
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in debitIntList) {
      totalIntDebit += transaction;
    }

    getTotalIntDebit = totalIntDebit;

    double finalIntDebit = getTotalIntDebit;
    double finalIntCredit = getTotalIntCredit;

    getNetIntbalance = finalIntCredit - finalIntDebit;

    return transactionList;
  }

  Future<String?> isUserVerified(String? phoneNumber) async {
    QuerySnapshot querySnapshot = await firestore
        .collection('users')
        .where('mobile', isEqualTo: phoneNumber)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Phone number does not exist in the Firestore table
      return "";
    }

    var user = querySnapshot.docs.first.data() as Map<String, dynamic>?;
    getUser = user?['name'] ?? "";
    getLastReqAmount = user?['requestAmnt'] ?? "";
    getLastCashbckReqAmount = user?['requestCashbckAmnt'] ?? "";
    getIsMoneyReq = user?['isMoneyRequest'] ?? "";
    getIsCashbckReq = user?['isCashbackRequest'] ?? "";

    getIsCanMoneyReq = user?['isCanMoneyReq'] ?? "";
    getIsCanCashbckReq = user?['isCanCashbackReq'] ?? "";

    getDocId = querySnapshot.docs.first.id;
    isNotificationByAdmin = user?['notificationByAdmin'] ?? "";
    getAdminType = user?['mappedAdmin'] ?? "";
    ref.read(txtPaidStatus.notifier).state = getIsMoneyReq;
    ref.read(txtCashbckPaidStatus.notifier).state = getIsCashbckReq;

    ref.read(txtMoneyReqCanStatus.notifier).state = getIsCanMoneyReq;
    ref.read(txtCashbckReqCanStatus.notifier).state = getIsCanCashbckReq;

    return getUser;
  }

  Future<bool?> updateData(
      bool? isMoneyReq,
      double? getReqAmount,
      String? getDocId,
      String? getMobile,
      TextEditingController? getText) async {
    String? documentId = getDocId;

    if (data == ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return false;
    }

    if (isMoneyReq!) {
      try {
        await firestore.collection('users').doc(documentId).update({
          'isMoneyRequest': true,
          'requestAmnt': getReqAmount,
          'isCanMoneyReq': false,
        }).then((value) {
          getText?.text = "";
          Constants.showToast(
              "Money Requested Successfully", ToastGravity.CENTER);
          getUserDetails(getMobile);
          return true;
        });
        return null; // Return null or a success message if desired
      } catch (error) {
        getText?.text = "";
        Constants.showToast("Request Failed, Try again!", ToastGravity.CENTER);
        return false; // Return the error message as a string
      }
    } else {
      try {
        await firestore.collection('users').doc(documentId).update({
          'isCashbackRequest': true,
          'requestCashbckAmnt': getReqAmount,
          'isCanCashbackReq': false,
        }).then((value) {
          getText?.text = "";
          Constants.showToast(
              "Money Requested Successfully", ToastGravity.CENTER);
          getUserDetails(getMobile);
          return true;
        });
        return null; // Return null or a success message if desired
      } catch (error) {
        getText?.text = "";
        Constants.showToast("Request Failed, Try again!", ToastGravity.CENTER);
        return false; // Return the error message as a string
      }
    }
  }

  Future<bool?> canclRequest(
      String? getDocId, bool? isSavingAmntReqPaid, String? getMobile) async {
    String? documentId = getDocId;

    if (isSavingAmntReqPaid!) {
      try {
        await firestore.collection('users').doc(documentId).update({
          'isMoneyRequest': false,
          'isCanMoneyReq': true,
        }).then((value) {
          Constants.showToast(
              "Money Request Cancelled Successfully", ToastGravity.CENTER);
          getUserDetails(getMobile);
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
          'isCanCashbackReq': true,
        }).then((value) {
          Constants.showToast(
              "Cashback Request Cancelled Successfully", ToastGravity.CENTER);
          getUserDetails(getMobile);
          return true;
        });
        return null; // Return null or a success message if desired
      } catch (error) {
        Constants.showToast("Request Failed, Try again!", ToastGravity.CENTER);
        return false; // Return the error message as a string
      }
    }
  }

  UserDashListState getLoadingState() {
    return UserDashListState(
        status: ResStatus.loading, success: null, failure: "");
  }

  UserDashListState getSuccessState(transList) {
    return UserDashListState(
        status: ResStatus.success, success: transList, failure: "");
  }

  UserDashListState getFailureState(err) {
    return UserDashListState(
        status: ResStatus.failure, success: [], failure: err);
  }
}

class UserDashListState {
  ResStatus? status;
  List<Transaction>? success;
  String? failure;

  UserDashListState({this.status, this.success, this.failure});
}

class Transaction {
  int? amount;
  double? interest;
  String? date;
  bool? isDeposit;
  String? mobile;
  final String docId;

  Transaction(
      {required this.amount,
      required this.date,
      required this.isDeposit,
      required this.mobile,
      required this.docId,
      required this.interest});
}

//todo:- 31.8.23
class Cashbacks {
  double? amount;
  String? date;
  bool? isCashbackDeposit;
  String? mobile;
  final String docId;

  Cashbacks({
    required this.amount,
    required this.date,
    required this.isCashbackDeposit,
    required this.mobile,
    required this.docId,
  });
}

var txtPaidStatus = StateProvider<bool?>((ref) => false);
var txtCashbckPaidStatus = StateProvider<bool?>((ref) => false);

var txtMoneyReqCanStatus = StateProvider<bool?>((ref) => false);
var txtCashbckReqCanStatus = StateProvider<bool?>((ref) => false);

// final isMsgByAdmin =
//     StateProvider<Tuple2<bool?, String?>>((ref) => Tuple2(false, ""));
