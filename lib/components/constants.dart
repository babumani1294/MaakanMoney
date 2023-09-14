// ignore_for_file: dead_code

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;

  static bool isAdmin = false;
  static String adminId = "0805080508";
  static String adminNo1 = "+919360840071";
  static String adminNo2 = "+919941445471";
  static String appVersion = "1.0.10";

  static bool? displayToast(ConnectivityResult result) {
    String message;
    switch (result) {
      case ConnectivityResult.wifi:
        message = 'Connected to WiFi';
        break;
        return true;
      case ConnectivityResult.mobile:
        message = 'Connected to mobile network';
        break;
        return true;
      case ConnectivityResult.none:
        message = 'No network connection';
        break;
        return false;
      default:
        message = 'Unknown network status';
        return false;
    }

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
    return null;
  }

  static void showToast(String toastMessage, ToastGravity? getToastGravity) {
    Fluttertoast.showToast(
      msg: toastMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: getToastGravity,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}

enum NetworkConnection {
  wifi,
  mobile,
  none,
}

var getNetworkConnection =
    StateProvider<NetworkConnection>((ref) => NetworkConnection.mobile);
