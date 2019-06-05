import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
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
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF4074c4)),
        ),
        visible: visibility);
  }

  checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                title: Text('Oops! Internet lost'),
                content: Text(
                    'Sorry, Please ckeck your internet connection and then try again'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      checkConnectivity();
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            );
          });
    } else if (result == ConnectivityResult.mobile) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => loginUser()));
    } else if (result == ConnectivityResult.wifi) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => loginUser()));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      checkConnectivity();
    });
    timeDilation = 2.0;
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _visibility = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment(0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Image.asset(
                      'assets/appIcon.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                alignment: Alignment(0, 0.7),
                child: progress(_visibility)),

          ],
        ));



  }
}
