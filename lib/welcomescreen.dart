import 'package:flutter/material.dart';
import 'main.dart';
import 'dart:async';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _visibility = false;

  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
        ),
        visible: visibility);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => loginUser()));
    });

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _visibility = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment(0, 0.5),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 60.0),
                  child: Image.asset(
                    'assets/profileApp.png',
                    width: 350,
                    height: 350,
                  ),
                ),
              ],
            ),
            progress(_visibility)
          ],
        ),
      ),
    );
  }
}
