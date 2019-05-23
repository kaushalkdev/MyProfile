import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
 
 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'FlutterBase', home: loginUser());
  }
}

class loginUser extends StatefulWidget {

  final AuthService authService = new AuthService() ;
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



  AuthStatus authStatus = AuthStatus.notSignedIn;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Future<FirebaseUser> googleSignIn() async {
// Start

    // Step 1
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    // Step 2
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _auth.signInWithCredential(credential);
    // Step 3

     _db.collection("users").document(user.uid).snapshots().listen((snapshots){

       if(!snapshots.exists){


          _db.collection("users").document(user.uid).setData(
            {'uid': user.uid,
              'email': user.email,
              'photoURL': user.photoUrl,
              'displayName': user.displayName,
              'lastSeen': DateTime.now()

            }



          );



       }



     });


    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => userProfile(

                )));
    return user;
  }

  void signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  void initState() {

    super.initState();

    widget.authService.getCurrentuser().then((userid){

      setState(() {
        authStatus = userid == null ? AuthStatus.notSignedIn: AuthStatus.signedIn;

      });


    });

//    _auth.onAuthStateChanged.listen((firebaseUser) {
////
//      if (firebaseUser != null) {
//        authStatus = AuthStatus.signedIn;
//      } else {
//        authStatus = AuthStatus.notSignedIn;
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.signedIn:
        return new userProfile();

      case AuthStatus.notSignedIn:
        return Scaffold(
          appBar: AppBar(
            title: Text("login"),
          ),
          body:Container(
            alignment: Alignment(0.0, 0.8),
            child: GoogleSignInButton(
              onPressed:googleSignIn,
              darkMode: true, // default: false
            ),
          )
        );
    }
  }
}

class userProfile extends StatefulWidget {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService authService = new AuthService() ;


  void signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }


  @override
  _userProfileState createState() => _userProfileState();
}

class _userProfileState extends State<userProfile> {
  File _image;
  String userid;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;






  //method to get, crop, upload and update image
  Future getImage(String userId) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );




    String fileName =  userId;
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedFile);

    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();

    Firestore.instance
        .collection('users')
        .document(userId)
        .setData({"photoURL": url}, merge: true);

  }


   @override
  void initState() {

    super.initState();

  widget.authService.getCurrentuser().then((userId){

    setState(() {
      this.userid = userId;
      print(" userid "+ userid);
    });
  });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User profile'),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("signout"),
            onPressed: () {
              widget.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => loginUser()));
            },
          ),
          IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                getImage(userid);
              }),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(userid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return new Text("Loading");
                }
                var userDocument = snapshot.data;
                return ClipOval(
                    child: SizedBox(
                        height: 180.0,
                        width: 180.0,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/userimage.png',
                          image:userDocument['photoURL'],
                        )));
              }),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(userid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return new Text("Loading");
                }
                var userDocument = snapshot.data;
                return Text(userDocument['displayName']);
              }),
        ],
      ),
    );
  }
}
