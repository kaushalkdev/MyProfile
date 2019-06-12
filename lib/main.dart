import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'userprofile.dart';
import 'welcomescreen.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        title: 'FlutterBase',debugShowCheckedModeBanner: false, home: WelcomeScreen());
  }
}

class loginUser extends StatefulWidget {
  final AuthService authService = new AuthService();
  final VoidCallback onSingnedIn;

  loginUser({this.onSingnedIn});

  @override
  _loginUserState createState() => _loginUserState();
}

enum AuthStatus {
  signedIn,
  notSignedIn,
}

class _loginUserState extends State<loginUser> {
  bool visibility = false;
  bool btnVisibility = true;

  AuthStatus authStatus = AuthStatus.notSignedIn;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Widget progress(bool visibility) {
    return Visibility(
        child: Container(
          alignment: Alignment(0, 0.7),
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF4074c4)),
          ),
        ),
        visible: visibility);
  }

  Future<FirebaseUser> googleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    setVisibility();
    setBtnVisibility();
    final FirebaseUser user = await _auth.signInWithCredential(credential);

    _db.collection("users").document(user.uid).snapshots().listen((snapshots) {
      if (!snapshots.exists) {
        _db.collection("users").document(user.uid).setData({
          'uid': user.uid,
          'email': user.email,
          'photoURL': user.photoUrl,
          'displayName': user.displayName,
          'bio': 'Update Bio. eg. I am a software developer and has experience in android and flutter application designing',
          'status': 'Update Status eg. Software developer',
          'lastSeen': DateTime.now()
        }).whenComplete(() {
          _db.collection('personal').document(user.uid).setData({
            'name': user.displayName,
            'email': user.email,
            'gender': 'Enter your Gender',
            'birthday': 'Enter your Birthday',
            'address': 'Enter your current Address',
          }).whenComplete(() {
            progress(false);
          });
        });
      }
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => userProfile()));
    return user;
  }

  void setVisibility() {
    setState(() {
      visibility = true;
    });
  }

  void setBtnVisibility() {
    setState(() {
      btnVisibility = false;
    });
  }

  @override
  void initState() {
    super.initState();


    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white12, // status bar color
        statusBarIconBrightness: Brightness.dark
    ));

    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        authStatus =
            userid == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Oops! Internet lost'),
              content: Text(
                  'Sorry, Please ckeck your internet connection and then try again'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else if (result == ConnectivityResult.mobile) {
      googleSignIn();
    } else if (result == ConnectivityResult.wifi) {
      googleSignIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.signedIn:
        return new userProfile();

      case AuthStatus.notSignedIn:
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
            progress(visibility),
            Container(
              alignment: Alignment(0.0, 0.8),
              child: Visibility(
                child: GoogleSignInButton(
                  onPressed: () {
                    checkConnectivity();
                  },
                  darkMode: true, // default: false
                ),
                visible: btnVisibility,
              ),
            ),
          ],
        ));
    }
  }
}
