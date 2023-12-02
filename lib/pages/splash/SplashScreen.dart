// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maaakanmoney/components/constants.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/Onboard/onboardScreen.dart';
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      loginKey = prefs.getString("LoginSuccessuser1");
      mPin = prefs.getString("Mpin");
      var isviewed = prefs.getInt('onBoard');

      if ((isviewed == 0) || (isviewed == null)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnBoard()),
          (Route<dynamic> route) => false,
        );
      } else {
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

          return Stack(alignment: Alignment.center, children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: FlutterFlowTheme.of(context).primary1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: Stack(children: [
                              Positioned.fill(
                              child: Align(
                              alignment: Alignment.centerRight,
                                child: Stack(children: [
                                  CustomPaint(
                                    painter: CombinedCustomPainter3(
                                        fillColor1: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context)
                                                .secondary1,
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.bottomLeft,
                                        ),
                                        fillColor2:
                                        FlutterFlowTheme.of(context)
                                            .secondary2,
                                        fillColor3: Colors.green),
                                  ),
                                ]),
                              ),
                            ),
                          Positioned.fill(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                          "MAAKA",
                          style: GlobalTextStyles.primaryText1(
                          txtWeight: FontWeight.bold,
                          textColor: FlutterFlowTheme.of(context)
                          .primary1,
                ),
              ),
          ),
          ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Savings",
                                            style:
                                                GlobalTextStyles.primaryText2(
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary,
                                                    txtWeight: FontWeight.bold),
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            "Made Simple!",
                                            style:
                                                GlobalTextStyles.primaryText2(
                                                    textColor:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .secondary1,
                                                    txtWeight:
                                                        FontWeight.normal,
                                                    txtSize: 22),
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: Image.asset(
                                      'images/final/splash/splashIcon.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}


class CombinedCustomPainter3 extends CustomPainter {
  final Gradient fillColor1;
  final Color fillColor2;
  final Color fillColor3;

  CombinedCustomPainter3({
    required this.fillColor1,
    required this.fillColor2,
    required this.fillColor3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Path path1 = _createCustomShapePath(
      size,
      rotationAngle: -45 * (3.141592653589793 / 250.0),
      offsetX: 20.0,
      offsetY: -300.0,
    );

    Path path2 = _createCustomShapePath(
      size,
      rotationAngle: -45 * (3.141592653589793 / 150.0),
      offsetX: 20.0,
      offsetY: -300.0,
    );

    // Create a mask for the intersection
    Path intersectionPath = Path.combine(PathOperation.intersect, path1, path2);

    final Paint fillPaint1 = Paint()
      ..shader = fillColor1.createShader(path1.getBounds())
      ..style = PaintingStyle.fill;

    final Paint fillPaint2 = Paint()
      ..color = fillColor2
      ..style = PaintingStyle.fill;

    final Paint intersectionPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(path1, fillPaint1);
    canvas.drawPath(path2, fillPaint2);

    // Use the mask to draw only in the intersection area
    canvas.drawPath(intersectionPath, intersectionPaint);
  }

  Path _createCustomShapePath(Size size,
      {required double rotationAngle,
        double offsetX = 0.0,
        double offsetY = 0.0}) {
    final double rectWidth = 450.0;
    final double rectHeight = 600.0;
    final double cornerRadius = 100.0;
    final double screenWidth = size.width;

    final Rect rect = Rect.fromPoints(
      Offset(screenWidth - rectWidth + 200 + offsetX, 0 + offsetY),
      Offset(screenWidth + 200 + offsetX, rectHeight + offsetY),
    );

    final double centerX = rect.left + (rect.width / 2);
    final double centerY = rect.top + (rect.height / 2);

    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)));

    path = path.shift(Offset(centerX, centerY));
    path = path.transform(Matrix4.rotationZ(rotationAngle).storage);
    path = path.shift(Offset(-centerX, -centerY));

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

