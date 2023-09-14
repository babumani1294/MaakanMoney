import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:maaakanmoney/components/constants.dart';

class ConnectivityStateNotifier extends StateNotifier<ConnectivityResult> {
  ConnectivityStateNotifier() : super(ConnectivityResult.none);

  Future<void> initialize() async {
    final result = await Connectivity().checkConnectivity();
    // state = result;

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      state = result;
      displayToast(result);
    });
  }

  void displayToast(ConnectivityResult result) {
    String message;
    switch (result) {
      case ConnectivityResult.wifi:
        message = 'Connected to WiFi';
        break;
      case ConnectivityResult.mobile:
        message = 'Connected to mobile network';
        break;
      case ConnectivityResult.none:
        message = 'No network connection';
        break;
      default:
        message = 'Unknown network status';
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityStateNotifier, ConnectivityResult>((ref) {
  final stateNotifier = ConnectivityStateNotifier();
  stateNotifier.initialize();
  return stateNotifier;
});

var isOtpSent = StateProvider<bool?>((ref) => false);
var isLastPage = StateProvider<bool?>((ref) => false);
