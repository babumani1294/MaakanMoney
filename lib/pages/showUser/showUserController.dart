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



final showUserListProvider =
    StateNotifierProvider<DashListNotifier, ShowUserListState>(
        (ref) => DashListNotifier(ref));

class DashListNotifier extends StateNotifier<ShowUserListState> {
  Ref ref;

  String getDocId = "";
  List<Transaction2>? transList = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ConnectivityResult? data;

  double getNetbalance = 0;
  double getTotalCredit = 0;
  double getTotalDebit = 0;

  double getNetIntbalance = 0;
  double getTotalIntCredit = 0;
  double getTotalIntDebit = 0;

  DashListNotifier(this.ref)
      : super(ShowUserListState(
            status: ResStatus.init, success: [], failure: ""));

  Future<void> getUserListDetails(
      String? getMobile, String? getDocId, int? getUserIndex) async {
    if (ref.read(adminDashListProvider.notifier).data ==
        ConnectivityResult.none) {
      Constants.showToast("No Internet Connection", ToastGravity.BOTTOM);
      return;
    }
    state = getLoadingState();
    // transList = await getUserListTransactions(getMobile, getDocId);
    ref
            .read(adminDashListProvider.notifier)
            .userList2?[getUserIndex ?? 0]
            .transactions =
        await getUserListTransactions(getMobile, getDocId, getUserIndex ?? 0);
    getUserNetBal(getUserIndex);
    state = getSuccessState(transList);
  }

  Future<List<Transaction2>> getUserListTransactions(
      String? getMobile, String? getDocId, int getUserIndex) async {
    QuerySnapshot transactionSnapshot = await firestore
        .collection('users')
        .doc(getDocId)
        .collection('transaction')
        .orderBy('date', descending: true)
        .get();

    final List<Transaction2> transactionList = transactionSnapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'];
          final isDeposit = data['isDeposit'];
          final mobile = data['mobile'];
          final date = data['date'];
          final interest = data['interest'];

          return Transaction2(
              amount: amount,
              date: date,
              isDeposit: isDeposit,
              mobile: mobile,
              interest: interest,
              transDocId: doc.id);
        })
        .whereType<Transaction2>()
        .toList();

    // var getUserDetails = await getUserNetBal(getUserIndex);

    return transactionList;
  }

  Future<void> getUserNetBal(int? getUserIndex) async {
    double totalCredit = 0;
    List<double>? creditList = [];

    double totalDebit = 0;
    List<double>? debitList = [];

    double totalIntCredit = 0;
    List<double>? creditIntList = [];

    creditList = ref
        .read(adminDashListProvider.notifier)
        .userList2?[getUserIndex ?? 0]
        .transactions
        .map((doc) {
          // final data = doc.data() as Map<String, dynamic>;

          final amount = doc.amount;
          final isDeposit = doc.isDeposit;
          final mobile = doc.mobile;

          if (isDeposit!) {
            return amount?.toDouble();
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in creditList!) {
      totalCredit += transaction;
    }

    debitList = ref
        .read(adminDashListProvider.notifier)
        .userList2?[getUserIndex ?? 0]
        .transactions
        .map((doc) {
          // final data = doc.data() as Map<String, dynamic>;

          final amount = doc.amount;
          final isDeposit = doc.isDeposit;
          final mobile = doc.mobile;

          if (isDeposit! == false) {
            return amount?.toDouble();
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in debitList!) {
      totalDebit += transaction;
    }

    getTotalCredit = totalCredit;

    getTotalDebit = totalDebit;

    double finalCredit = getTotalCredit;
    double finalDebit = getTotalDebit;
    getNetbalance = finalCredit - finalDebit;

    //todo:- 06.7.23 calculating Interest total debit and total credit

    creditIntList = ref
        .read(adminDashListProvider.notifier)
        .userList2?[getUserIndex ?? 0]
        .transactions
        .map((doc) {
          // final data = doc.data() as Map<String, dynamic>;

          final amount = doc.amount;
          final isDeposit = doc.isDeposit;
          final mobile = doc.mobile;
          final interest = doc.interest;

          if (isDeposit!) {
            if (interest == null) {
              return 0.00;
            }
            return interest.toDouble();
          }
        })
        .whereType<double>()
        .toList();

    for (var transaction in creditIntList!) {
      totalIntCredit += transaction;
    }

    getTotalIntCredit = totalIntCredit;

    double finalIntCredit = getTotalIntCredit;

    getNetIntbalance = finalIntCredit;

    ref.read(getUserNetTotal.notifier).state =
        Tuple4(getTotalCredit, getTotalDebit, getNetbalance, getTotalIntCredit);
  }

  ShowUserListState getLoadingState() {
    return ShowUserListState(
        status: ResStatus.loading, success: null, failure: "");
  }

  ShowUserListState getSuccessState(transList) {
    return ShowUserListState(
        status: ResStatus.success, success: transList, failure: "");
  }

  ShowUserListState getFailureState(err) {
    return ShowUserListState(
        status: ResStatus.failure, success: [], failure: err);
  }
}

class ShowUserListState {
  ResStatus? status;
  List<Transaction2>? success;
  String? failure;

  ShowUserListState({this.status, this.success, this.failure});
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

var isLoadingstate = StateProvider<bool?>((ref) => false);
var getUserNetTotal =
    StateProvider<Tuple4>((ref) => Tuple4(0.0, 0.0, 0.0, 0.0));
