import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'FlutterBase', home: Root());
  }
}

class Root extends StatefulWidget {
  FirebaseAuth firebaseAuth;

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  GoogleSignIn googleSignIn;

  Root({this.firebaseAuth, this.user, this.googleSignIn});

  @override
  _RootState createState() => _RootState();
}

//enum AuthStatus {
//  signedIn,
//  notSignedIn,
//}

class _RootState extends State<Root> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();

    widget.auth.onAuthStateChanged.listen((firebaseUser){
//
      if(firebaseUser != null){
        authStatus = AuthStatus.signedIn;

      }else{
        authStatus = AuthStatus.notSignedIn;
      }

    });

//    if (widget.auth != null) {
//      authStatus = AuthStatus.signedIn;
//    } else {
//      authStatus = AuthStatus.notSignedIn;
//    }
  }

//  void signedIn() {
//    setState(() {
//      authStatus = AuthStatus.signedIn;
//    });
//  }
//
//  void signedOut() {
//    setState(() {
//      authStatus = AuthStatus.notSignedIn;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.signedIn:
        return new userProfile(
          onSignedOut: signedOut,
        );

      case AuthStatus.notSignedIn:
        return new loginUser(
          onSingnedIn: signedIn,
        );
    }

    return null;
  }
}




class loginUser extends StatefulWidget {
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

    userProfile( firebaseUser: user, googleSignIn: _googleSignIn);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => userProfile(
                  firebaseUser: user,
                  googleSignIn: _googleSignIn,
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
    // TODO: implement initState
    super.initState();

    _auth.onAuthStateChanged.listen((firebaseUser){
//
      if(firebaseUser != null){
        authStatus = AuthStatus.signedIn;

      }else{
        authStatus = AuthStatus.notSignedIn;
      }

    });

  }



  @override
  Widget build(BuildContext context) {

    switch (authStatus) {
      case AuthStatus.signedIn:
        return new userProfile(

        );

      case AuthStatus.notSignedIn:
        return Scaffold(
          appBar: AppBar(
            title: Text("login"),
          ),
          body: RaisedButton(
            child: Text("sign in with google"),
            onPressed: googleSignIn,
          ),
        );
    }



  }
}

class userProfile extends StatefulWidget {
  final FirebaseUser firebaseUser;
  final GoogleSignIn googleSignIn;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;


  void signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  userProfile({this.firebaseUser, this.googleSignIn});

  @override
  _userProfileState createState() => _userProfileState();
}







class _userProfileState extends State<userProfile> {
  File _image;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;



  //method to get, crop, upload and update image
  Future getImage() async {
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

    String fileName = widget.firebaseUser.uid;
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(croppedFile);

    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();

    Firestore.instance
        .collection('users')
        .document(widget.firebaseUser.uid)
        .setData({"photoURL": url}, merge: true);
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Root()));
            },
          ),
          IconButton(
              icon: Icon(Icons.camera_alt),
              onPressed: () {
                getImage();
              }),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document("xy2dXCUupBgl3aotCF8BEFIIbVA3")
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
                        child: Image.network(userDocument['photoURL'])));
              }),
          StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document("xy2dXCUupBgl3aotCF8BEFIIbVA3")
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
