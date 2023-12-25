import 'package:aws/dashboard.dart';
import 'package:aws/login.dart';
import 'package:aws/menulist.dart';
import 'package:aws/today.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'completed.dart';
import 'dummy.dart';
import 'mmcdash.dart';

void main() {
  runApp(Splash());
}

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({Key? key}) : super(key: key);

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  double progress = 0.0;
  final duration = Duration(seconds: 2);
  late Timer timer;
  void initState() {
    super.initState();
    // nextScreen();
    startTimer();
  }

  void startTimer() {
    // Calculate the interval based on the duration
    final interval = Duration(milliseconds: duration.inMilliseconds ~/ 100);

    timer = Timer.periodic(interval, (timer) {
      setState(() {
        progress += 0.01; // Incrementing by 1% (0.01)
        if (progress >= 1.0) {
          timer.cancel();
          nextScreen();
          // Stop the timer when it reaches 100%
        }
      });
    });
  }

  Future<void> nextScreen() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MyHomePage1(user: "MMC", pass:"12345",main:"MMC",logo:"mmc.png", mcc:"Vellakkal", type: "cat",),
      ),
    );

  }

  @override
  void dispose() {
    timer.cancel(); // Cancel timer to prevent memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: 500,
        width: 500,
        color: Colors.white38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              // color: Colors.lightBlue,
              child: Card(
                  elevation: 10,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: Colors.lightBlue,

                  // margin: EdgeInsets.all(10),
                  shape: CircleBorder(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/aws icon.png",
                      )
                    ],
                  )),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              "AUTOMATIC WEIGHING SYSTEM",
              style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              // height: MediaQuery.of(context).size.height*0.02,
              child: LinearProgressIndicator(
                value: progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Color _colorFromHex(String hexColor) {
//   final hexCode = hexColor.replaceAll('#', '');
//   return Color(int.parse('FF$hexCode', radix: 16));
// }
