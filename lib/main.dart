import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'userprofile.dart';
import 'welcomescreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'FlutterBase', home: WelcomeScreen());
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
          alignment: Alignment(0, 0.55),
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
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
          'bio': 'Freelancer',
          'status': 'Student',
          'lastSeen': DateTime.now()
        }).whenComplete(() {
         _db.collection('personal').document(user.uid).setData({

           'name':user.displayName,
           'email':user.email,
           'gender':'Enter your Gender',
           'birthday':'Enter your Birthday',
           'address':'Enter your current Address',

         }).whenComplete((){
           progress(false);
         });
        });
      }
    });

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => userProfile()));
    return user;
  }

  void setVisibility(){
    setState(() {
      visibility = true;
    });

  }
   void setBtnVisibility(){
     setState(() {
       btnVisibility = false;
     });

   }

  @override
  void initState() {
    super.initState();

    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        authStatus =
            userid == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.signedIn:
        return new userProfile();

      case AuthStatus.notSignedIn:
        return Scaffold(
            appBar: null,
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
                          'assets/profileApp.png',
                          width: 350,
                          height: 350,
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
                        googleSignIn();

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
