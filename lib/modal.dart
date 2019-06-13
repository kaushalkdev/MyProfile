import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'pdfconversion.dart';
import 'package:pdf/widgets.dart' as Pdf;
import 'package:printing/printing.dart';
import 'package:connectivity/connectivity.dart';
import 'auth.dart';
import 'dart:io';
import 'main.dart';

class Modal {
  AuthService authService = new AuthService();
  CollectionReference db = Firestore.instance.collection('users');

  File _image;
  String userid, name, email, address;

  checkConnectivity(BuildContext context) async {
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
                      checkConnectivity(context);
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

  List<int> buildPdf(PdfPageFormat format) {
    email = 'kaushal.deligence@gmail.com';
    address =
        ' 106 & 107, 1st Floor, Jyoti Shikhar Tower,District Center, Janakpuri';
    final PdfDoc pdf = PdfDoc()
      ..addPage(Pdf.MultiPage(
          pageFormat: PdfPageFormat.letter
              .copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
          crossAxisAlignment: Pdf.CrossAxisAlignment.start,
          footer: (Pdf.Context context) {
            return Pdf.Container(
                alignment: Pdf.Alignment.centerRight,
                margin: const Pdf.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: Pdf.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: Pdf.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(color: PdfColors.grey)));
          },
          build: (Pdf.Context context) => <Pdf.Widget>[
                Pdf.Header(
                    level: 0,
                    child: Pdf.Row(
                        mainAxisAlignment: Pdf.MainAxisAlignment.center,
                        children: <Pdf.Widget>[
                          Pdf.Text('Resume', textScaleFactor: 2),
                        ])),

                Pdf.Paragraph(text: ''),
                Pdf.Column(children: <Pdf.Widget>[
                  //bio start
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Text('Name: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Text(name),
                  ]),
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Text('Email: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Text(email),
                  ]),
                  Pdf.Row(children: <Pdf.Widget>[
                    Pdf.Paragraph(
                        text: 'Address: ',
                        style: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                    Pdf.Paragraph(text: address),
                  ]),
                  //bio end
                ]),

                // Educational details
                Pdf.Header(level: 1, text: 'Profile'),
                Pdf.Paragraph(
                    text:
                        'I am a full stack Software Developer and develops Mobile applications. Have experience in app designing with Fultter and Android Studio.'),

                Pdf.Header(level: 1, text: 'Education Details'),

                Pdf.Header(
                    level: 3,
                    text: 'Higher Secondary',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Institution: Kv.No.1 Delhi Cantt'),
                Pdf.Bullet(text: 'Field of Study: Science'),
                Pdf.Bullet(text: 'Year: 2011 - 2012'),

                Pdf.Header(
                    level: 3,
                    text: 'Senior Secondary',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Institution: Kv.No.1 Delhi Cantt'),
                Pdf.Bullet(text: 'Field of Study: PCM'),
                Pdf.Bullet(text: 'Year: 2013 - 2014'),

                Pdf.Header(
                    level: 3,
                    text: 'B.Tech',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(
                    text:
                        'Institution: Maharaja Surajmal Institute of Technology'),
                Pdf.Bullet(text: 'Field of Study: ECE'),
                Pdf.Bullet(text: 'Year: 2014 - 2018'),
                Pdf.Paragraph(text: ''),

                //project details
                Pdf.Header(level: 1, text: 'Project Details'),

                Pdf.Header(
                    level: 3,
                    text: 'MYProfile App',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: '19/05/2019 - 10/06/2019'),
                Pdf.Bullet(
                    text:
                        'Description: The App helps in creating profile for users which they can share in form of Pdf. '),
                Pdf.Header(
                    level: 3,
                    text: 'TextToSpeech Chat App',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: '15/03/2019 - 26/03/2019'),
                Pdf.Bullet(
                    text:
                        'Description: The App is simple chat app with speech out. User can send message to each other and can read as well as hear the messge. '),

                //professional detials
                Pdf.Header(level: 1, text: 'Professional Experience'),

                Pdf.Header(
                    level: 3,
                    text: 'Software Developer',
                    textStyle: Pdf.TextStyle(fontWeight: Pdf.FontWeight.bold)),
                Pdf.Bullet(text: 'Deligence Technologies'),
                Pdf.Bullet(text: 'Mar 2019 - present'),
                Pdf.Bullet(
                    text:
                        'Description: The comapny mainly deals with developement of web aps and android and ios developement.'),
              ]));

    return pdf.save();
  }

  void openSettings(
      BuildContext context, String userid, DocumentSnapshot docref) {
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Conversion(
                                  pdfPersonalDetails: 'email',
                                )));
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.cached,
                        color: Colors.blue,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          "Convert to pdf",
                          style: TextStyle(fontSize: 18, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    authService.signOut();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => loginUser()));
                  },
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

  Widget updateStatus(BuildContext context, String userId) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String status;
          return AlertDialog(
            title: Text('Update Status'),
            content: Form(
              key:_formKey,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new TextFormField(
                        autofocus: true,
                        decoration: new InputDecoration(
                            labelText: 'Status',
                            hintText: 'eg. Sowtware Developer.'),
                        validator: (String value) {
                          if (value.isEmpty ||
                              RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                  .hasMatch(value)) {
                            return 'Please fill valid Status';
                          }
                        },
                        onSaved: (value) {
                          status = value;
                        },
                      ))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                onPressed: () {
                  if(!_formKey.currentState.validate()){

                    return;
                  }
                  _formKey.currentState.save();
                  updateStatusdata(userId, status);
                  Navigator.of(context).pop(status);
                },
              ),
            ],
          );
        });
  }

  Widget updateBio(BuildContext context, String userId) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          String bio;
          return AlertDialog(
            title: Text('Update Bio'),
            content: Form(
              key: _formKey,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new TextFormField(
                        autofocus: true,
                        decoration: new InputDecoration(
                            labelText: 'Bio', hintText: ' Describle your self.'),
                        validator: (String value) {
                          if (value.isEmpty ||
                              RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                  .hasMatch(value)) {
                            return 'Please fill valid Bio';
                          }
                        },
                        onSaved: (value) {
                          bio = value;
                        },
                      ))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Update'),
                onPressed: () {


                  if(!_formKey.currentState.validate()){

                    return;
                  }
                  _formKey.currentState.save();
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    getImage(userId);
                    checkConnectivity(context);
                    Navigator.pop(context);
                  },
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    updateStatus(context, userId);
                  },
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    updateBio(context, userId);
                  },
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
