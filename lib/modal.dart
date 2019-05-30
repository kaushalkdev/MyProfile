import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:io';
import 'main.dart';

class Modal {
  AuthService authService = new AuthService();

  File _image;

  String userId;

  void openSettings(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.share,
                        color: Colors.blue,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Share Profile",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  authService.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => loginUser()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app, color: Colors.deepOrange),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Sign Out",
                          style:
                              TextStyle(fontSize: 18, color: Colors.deepOrange),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
          );
        });
  }

  Widget updateStatus(BuildContext context,String userId) {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String status = '';
          return AlertDialog(
            title: Text('Update Status'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Status', hintText: 'eg. Sowtware Developer.'),
                  onChanged: (value) {
                    status = value;
                  },
                ))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                onPressed: () {
                  updateStatusdata(userId, status);
                  Navigator.of(context).pop(status);
                },
              ),
            ],
          );
        });
  }

  Widget updateBio(BuildContext context, String userId) {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String bio = '';
          return AlertDialog(
            title: Text('Update Bio'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Bio', hintText: ' Describle your self.'),
                  onChanged: (value) {
                    bio = value;
                  },
                ))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                onPressed: () {
                  updateBiodata(userId, bio);
                  Navigator.of(context).pop(bio);
                },
              ),
            ],
          );
        });
  }

  void openProfile(BuildContext context, String userId) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  getImage(userId);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.camera,
                        color: Colors.black54,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Update Image",
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  updateStatus(context,userId);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        color: Colors.green,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Update Status",
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              GestureDetector(
                onTap: () {
                  updateBio(context, userId);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.format_indent_decrease,
                        color: Colors.deepOrange,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Update Bio",
                          style:
                              TextStyle(fontSize: 18, color: Colors.deepOrange),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]),
          );
        });
  }

  //method to get, crop, upload and update image
  Future getImage(String userId) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    _image = image;

    File croppedFile = await ImageCropper.cropImage(
      sourcePath: _image.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );

    String fileName = userId;
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

  //update bio function
  Future updateBiodata(String userId, String value) async {
    Firestore.instance
        .collection('users')
        .document(userId)
        .setData({"bio": value}, merge: true);
  }

  //update bio function
  Future updateStatusdata(String userId, String value) async {
    Firestore.instance
        .collection('users')
        .document(userId)
        .setData({"status": value}, merge: true);
  }
}
