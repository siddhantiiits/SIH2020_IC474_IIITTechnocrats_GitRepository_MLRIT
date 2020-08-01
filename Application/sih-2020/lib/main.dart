import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:smart_attendance_manager/pages/home.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', "US"),
      ],
      title: 'Smart Attendance Manager',
      theme: ThemeData(
        primaryColor: Color(0xFFdee6e7),
        accentColor: Color(0xFFefe8e6),
      ),
      // accentColor: Color(0xFF8ab2bb)),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  _WelcomeScreen createState() => _WelcomeScreen();
}

class _WelcomeScreen extends State<WelcomeScreen> {
  Widget build(context) {
    String asset = "assets/images/animation.flr";
    return SplashScreen.callback(
      name: asset,
      
      onSuccess: (_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      },
      onError: (e, s) {},
      startAnimation: '0',
      endAnimation: '3',
      loopAnimation: 'Untitled',
      backgroundColor: Colors.white,
      until: () => Future.delayed(Duration(milliseconds: 3)),
    );
  }
}
