import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wechat/helper/apis.dart';
import 'package:wechat/screens/home_screen.dart';
import 'package:wechat/screens/login_screen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (Apis.auth.currentUser != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    blue = const Color.fromARGB(250, 9, 12, 156);
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .35,
              width: mq.width * .6,
              right: mq.width * .2,
              child: Image.asset("assets/images/ii.png")),
          Positioned(
              bottom: mq.height * .1,
              width: mq.width,
              child: Text(
                "We Chat",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.bold, color: blue),
              )),
        ],
      ),
    );
  }
}
