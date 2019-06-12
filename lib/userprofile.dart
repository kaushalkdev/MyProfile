import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'professionaldetails.dart';
import 'educationdetails.dart';
import 'technicaldetails.dart';
import 'personaldetails.dart';
import 'modal.dart';
import 'package:connectivity/connectivity.dart';
import 'auth.dart';
import 'Tabs.dart';
import 'welcomescreen.dart';
import 'dart:io';

class userProfile extends StatefulWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService authService = new AuthService();

  void signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  @override
  _userProfileState createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  DocumentSnapshot documentSnapshot;

  Modal modal = new Modal();
  String userid;
  String image;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _visibility = true;

  bool _visibleProfile = false;

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
    } else if (result == ConnectivityResult.wifi) {}
  }

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 3.2,
      decoration: BoxDecoration(
        color: Color(0xFF4074c4),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return StreamBuilder(
        stream:
            Firestore.instance.collection('users').document(userid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return Text(
            userDocument['displayName'],
            style: _nameTextStyle,
          );
        });
  }

  Widget _buildStatus(BuildContext context) {
    return StreamBuilder(
        stream:
            Firestore.instance.collection('users').document(userid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return Container(
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              userDocument['status'],
              style: TextStyle(
                fontFamily: 'Spectral',
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          );
        });
  }

  Widget _buildProfileImage() {
    return Center(
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(userid)
              .snapshots(),
          builder: (context, snapshot) {
            var userDocument = snapshot.data;

            if (userDocument != null) {
              return Stack(
                children: <Widget>[
                  Container(
                    child: progress(_visibility),
                    alignment: Alignment(0, 0),
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: NetworkImage(userDocument['photoURL']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(80.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 5.0,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return new Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage('assets/defaultimage.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(80.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 5.0,
                  ),
                ),
              );
            }
          }),
    );
  }

  Widget _buildStatContainer(
      BuildContext context, String userid, DocumentSnapshot docref) {
    return Container(
      height: 30.0,
      margin: EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
              onTap: () {
                modal.openProfile(context, userid);
              },
              child: Icon(
                Icons.apps,
                color: Color(0xFF4074c4),
              )),
          VerticalDivider(
            color: Colors.blueGrey,
          ),
          GestureDetector(
              onTap: () {
                modal.openSettings(context, userid, docref);
              },
              child: Icon(Icons.settings, color: Color(0xFF4074c4)))
        ],
      ),
    );
  }

  Map<String, dynamic> pdfPersonal = new Map();

  Widget _buildBio(BuildContext context, String useId) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return StreamBuilder(
        stream:
            Firestore.instance.collection('users').document(userid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.all(8.0),
            child: Text(
              userDocument['bio'],
              textAlign: TextAlign.center,
              style: bioTextStyle,
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    widget.authService.getCurrentuser().then((userId) {
      setState(() {
        this.userid = userId;
        print(" userid " + userid);
      });
    });

    Future.delayed(Duration(seconds: 5), () {
      checkConnectivity();
      setState(() {
        _visibility = false;
        _visibleProfile = true;
      });
    });

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF4074c4), // status bar color
      statusBarIconBrightness: Brightness.light
    ));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: _visibleProfile,
        child: FloatingActionButton(
          elevation: 20,
          child: Icon(Icons.view_carousel),
          backgroundColor: Color(0xFF4074c4),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => TabScreen()));
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Visibility(
                visible: _visibleProfile,
                child: Stack(
                  children: <Widget>[
                    _buildCoverImage(screenSize),
                    Column(
                      children: <Widget>[
                        SizedBox(height: screenSize.height / 5.1),
                        _buildProfileImage(),
                        _buildFullName(),
                        _buildStatus(context),
                        SizedBox(
                          height: 15,
                        ),
                        Builder(
                          builder: (BuildContext context) {
                            return _buildStatContainer(
                                context, userid, documentSnapshot);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        _buildBio(context, userid),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 60.0, right: 60.0),
                          child: Divider(
                            color: Colors.blueGrey,
                          ),
                        ),
                        //_buildSeparator(screenSize),
                        SizedBox(height: 10.0),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(alignment: Alignment(0, 0), child: progress(_visibility)),
        ],
      ),
    );
  }
}
