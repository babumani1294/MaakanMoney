// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../flutter_flow/flutter_flow_theme.dart';
import '../../phoneController.dart';
import '../Auth/mpin.dart';

class FillingAnimationScreen2 extends ConsumerStatefulWidget {
  @override
  _FillingAnimationScreen2State createState() =>
      _FillingAnimationScreen2State();
}

class _FillingAnimationScreen2State
    extends ConsumerState<FillingAnimationScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  String? loginKey;
  String? mPin;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fillAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();

    Timer(const Duration(seconds: 4), () async {
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => const MyPhone()));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      loginKey = prefs.getString("LoginSuccessuser1");
      mPin = prefs.getString("Mpin");

      if (loginKey == null || loginKey == "" || loginKey!.isEmpty) {
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => const MyPhone()));
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => MyPhone(),
            transitionsBuilder: (_, animation, __, child) {
              return ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0, // You can adjust the start scale
                  end: 1.0, // You can adjust the end scale
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      } else {
        String? myString = loginKey;
        String lastFourDigits =
            (myString ?? "").substring((myString ?? "").length - 4);

        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => MpinPageWidget(
        //               getMobileNo: loginKey ?? "",
        //               getMpin: mPin,
        //             )));

        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => MpinPageWidget(
              getMobileNo: loginKey ?? "",
              getMpin: mPin,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return ScaleTransition(
                scale: Tween<double>(
                  begin: 0.0, // You can adjust the start scale
                  end: 1.0, // You can adjust the end scale
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer(builder: (context, ref, child) {
          ConnectivityResult data = ref.watch(connectivityProvider);

          // if (data == ConnectivityResult.wifi ||
          //     data == ConnectivityResult.mobile) {
          //   Timer(const Duration(seconds: 4), () {
          //     Navigator.pushReplacement(context,
          //         MaterialPageRoute(builder: (context) => const MyPhone()));
          //   });
          // }

          return Stack(alignment: Alignment.center, children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              // color: FlutterFlowTheme.of(context).primary,
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //

                    Image.asset(
                      'images/mmLogo.png',
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 10),
                    const Text(
                      "We Rise Emergency Fund for You!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    return ClipPath(
                      clipper: FillingClipper(
                        fillPercentage: _fillAnimation.value,
                        constraints: constraints,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text(
                              //   "Maakan Money",
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 30,
                              //     fontStyle: FontStyle.italic,
                              //     fontWeight: FontWeight.w500,
                              //     letterSpacing: 2,
                              //   ),
                              // ),
                              Image.asset(
                                'images/mmLogo.png',
                                width: 50.w,
                                height: 50.h,
                                fit: BoxFit.contain,
                              ),

                              SizedBox(height: 10),
                              Text(
                                "We Rise Emergency Fund for You!",
                                style: TextStyle(
                                  // color: FlutterFlowTheme.of(context).primary,
                                  color: Colors.blueGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ]);
        }),
      ),
    );
  }
}

// class FillingClipper extends CustomClipper<Path> {
//   final double fillPercentage;
//   final BoxConstraints constraints;
//
//   FillingClipper({required this.fillPercentage, required this.constraints});
//
//   @override
//   Path getClip(Size size) {
//     double fillHeight = constraints.maxHeight * fillPercentage;
//     double fillWidth = constraints.maxWidth * fillPercentage;
//
//     // Path path = Path()
//     //   ..moveTo(constraints.maxWidth, 0)
//     //   ..lineTo(constraints.maxWidth, fillHeight)
//     //   ..lineTo(constraints.maxWidth - fillWidth, fillHeight)
//     //   ..lineTo(constraints.maxWidth - fillWidth, 0)
//     //   ..close();
//
//     Path path = Path()
//       ..moveTo(constraints.maxWidth, 0)
//       ..lineTo(constraints.maxWidth, fillHeight)
//       ..lineTo(constraints.maxWidth - fillWidth, fillHeight)
//       ..lineTo(constraints.maxWidth - fillWidth, 0)
//       ..lineTo(0, fillHeight) // Add this line to create a diagonal line
//       ..lineTo(0, 0) // Add this line to complete the shape
//       ..close();
//
//     return path;
//   }
//
//   @override
//   bool shouldReclip(FillingClipper oldClipper) {
//     return oldClipper.fillPercentage != fillPercentage ||
//         oldClipper.constraints != constraints;
//   }
// }

class FillingClipper extends CustomClipper<Path> {
  final double fillPercentage;
  final BoxConstraints constraints;

  FillingClipper({required this.fillPercentage, required this.constraints});

  @override
  Path getClip(Size size) {
    double fillHeight = constraints.maxHeight * fillPercentage;
    double fillWidth = constraints.maxWidth * fillPercentage;

    Path path = Path()
      ..moveTo(constraints.maxWidth, 0)
      ..lineTo(constraints.maxWidth, fillHeight)
      ..lineTo(constraints.maxWidth - fillWidth, fillHeight)
      ..lineTo(constraints.maxWidth - fillWidth, 0)
      ..close();

    Path bottomLeftPath = Path()
      ..moveTo(0, constraints.maxHeight)
      ..lineTo(0, constraints.maxHeight - fillHeight)
      ..lineTo(fillWidth, constraints.maxHeight - fillHeight)
      ..lineTo(fillWidth, constraints.maxHeight)
      ..close();

    path.addPath(bottomLeftPath, Offset(0, 0));

    return path;
  }

  @override
  bool shouldReclip(FillingClipper oldClipper) {
    return oldClipper.fillPercentage != fillPercentage ||
        oldClipper.constraints != constraints;
  }
}
