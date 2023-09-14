// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maaakanmoney/pages/splash/SplashScreen.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/internationalization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Upgrader.clearSavedSettings();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Firebase.initializeApp();

  await FlutterFlowTheme.initialize();
  await FFLocalizations.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale = FFLocalizations.getStoredLocale();
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  // String primaryColor = '#0B4D40';
  String primaryColor = '#101213';

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
    FFLocalizations.storeLocale(language);
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Maaka App',
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ta'),
        ],
        theme: ThemeData(
          primarySwatch: getColorFromHex(primaryColor),
        ),
        darkTheme: ThemeData(
          primarySwatch: getColorFromHex(primaryColor),
        ),
        themeMode: _themeMode,
        home: FillingAnimationScreen2(),
      );
    });
  }

  MaterialColor getColorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return MaterialColor(
      int.parse('FF$hexCode', radix: 16),
      <int, Color>{
        50: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.1),
        100: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.2),
        200: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.3),
        300: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.4),
        400: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.5),
        500: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.6),
        600: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.7),
        700: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.8),
        800: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(0.9),
        900: Color(int.parse('FF$hexCode', radix: 16)).withOpacity(1.0),
      },
    );
  }
}
