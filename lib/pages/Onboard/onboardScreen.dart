// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:maaakanmoney/flutter_flow/flutter_flow_theme.dart';
import 'package:maaakanmoney/pages/Auth/phone_auth_widget.dart';
import 'package:maaakanmoney/pages/Onboard/onboard_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Auth/mpin.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({Key? key}) : super(key: key);

  @override
  _OnBoardState createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int currentIndex = 0;
  late PageController _pageController;
  Color kblue = const Color(0xFF4756DF);
  Color kwhite = const Color(0xFFFFFFFF);
  Color kblack = const Color(0xFF000000);
  Color kbrown300 = const Color(0xFF8D6E63);
  Color kbrown = const Color(0xFF795548);
  Color kgrey = const Color(0xFFC0C0C0);
  List<OnboardModel> screens = <OnboardModel>[
    OnboardModel(
      img: 'assets/images/anim1.json',
      text: "Emergency Money Saving",
      desc:
          "Simplify Money management effortlessly through our convenient expenditure app experience",
      bg: Colors.white,
      button: const Color(0xFF4756DF),
    ),
    OnboardModel(
      img: 'assets/images/anim4.json',
      text: "Quick Withdrawal Processing",
      desc:
          "File and track savings seamlessly with our app's quick and efficient withdrawal processing.",
      bg: const Color(0xFF4756DF),
      button: Colors.white,
    ),
    OnboardModel(
      img: 'assets/images/anim10.json',
      text: "Getting Interest on Each Transactions",
      desc:
          "Watch your savings grow, effortlessly along with instant Cashback.",
      bg: Colors.white,
      button: const Color(0xFF4756DF),
    ),
    OnboardModel(
      img: 'assets/images/anim7.json',
      text: "Smart Savings Tracking",
      desc:
          "Stay on top of your savings with Maaka's intelligent tracking. Monitor your progress, set goals, and visualize your financial growth effortlessly.",
      bg: Colors.white,
      button: const Color(0xFF4756DF),
    ),
    OnboardModel(
      img: 'assets/images/anim8.json',
      text: "Rapid Savings Growth",
      desc:
          "Maaka collects random money, rapidly growing your savings over time.",
      bg: Colors.white,
      button: const Color(0xFF4756DF),
    ),
    OnboardModel(
      img: 'assets/images/anim9.json',
      text: "Flexible Savings Options",
      desc:
          "Maaka doesn't require mandatory savings, giving you the flexibility to save when it suits you.",
      bg: Colors.white,
      button: const Color(0xFF4756DF),
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _storeOnboardInfo() async {
    int isViewed = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 360;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: PageView.builder(
            itemCount: screens.length,
            controller: _pageController,

            ///physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0, top: 0),
                      child: Lottie.asset(
                        screens[index].img,
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 270,
                        repeat: true,
                        fit: BoxFit.scaleDown,
                        //controller: _lottieController,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Text(
                      screens[index].text,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Outfit',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff12100a),
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      screens[index].desc,
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                          fontFamily: 'Outfit',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff12100a),
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    SizedBox(
                      height: 10.0,
                      child: ListView.builder(
                        itemCount: screens.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
                                  width: currentIndex == index ? 25 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryColor,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ]);
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 180,
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  if (currentIndex == screens.length - 1) {
                    await _storeOnboardInfo();
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    var loginKey = prefs.getString("LoginSuccessuser1");
                    var mPin = prefs.getString("Mpin");
                    if (loginKey == null ||
                        loginKey == "" ||
                        loginKey!.isEmpty) {
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
                      String lastFourDigits = (myString ?? "")
                          .substring((myString ?? "").length - 4);


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

                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  child: Container(
                    width: double.infinity,
                    height: 52 * fem,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primary1,
                      borderRadius: BorderRadius.circular(56 * fem),
                    ),
                    child: Center(
                      child: Text(
                        currentIndex == screens.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: FlutterFlowTheme.of(context).labelLarge.override(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              currentIndex == screens.length - 1
                  ? Container()
                  : TextButton(
                      onPressed: () {
                        _storeOnboardInfo();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyPhone()));
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
