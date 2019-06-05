import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'educationdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'package:connectivity/connectivity.dart';
import 'welcomescreen.dart';

class UpdateEducationDetails extends StatefulWidget {
  AuthService authService = AuthService();

  String institute = '';
  String degree = '';
  String field = '';
  String startyear = '';
  String endyear = '';
  String description = '';
  String documentRef = '';

  UpdateEducationDetails(
      {this.institute,
      this.degree,
      this.field,
      this.startyear,
      this.endyear,
      this.description,
      this.documentRef});

  @override
  _UpdateEducationDetailsState createState() => _UpdateEducationDetailsState();
}

class _UpdateEducationDetailsState extends State<UpdateEducationDetails> {
  String userId = '';
  String institute = '';
  String degree = '';
  String field = '';
  String startyear = '';
  String endyear = '';
  String description = '';
  String documentRef = '';

  var onpress;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _educationallMap = {
    'institute': null,
    'degree': null,
    'field': null,
    'startyear': null,
    'endyear': null,
    'description': null,
  };

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        this.userId = userid;
      });
    });

    onpress = false;

    this.institute = widget.institute;
    this.degree = widget.degree;
    this.field = widget.field;
    this.startyear = widget.startyear;
    this.endyear = widget.endyear;
    this.description = widget.description;
    this.documentRef = widget.documentRef;

    checkConnectivity();
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff4074c4)),
          ),
        ),
        visible: visibility);
  }

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('users')
        .document('education')
        .collection(userId)
        .document(documentRef)
        .setData(personalMap)
        .whenComplete(() {
      progress(false);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => EducationalDetails()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Education'),
          backgroundColor: Color(0xff4074c4),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              color: Colors.white,
              onPressed: () {
                if (!_formKey.currentState.validate()) {
                  return;
                } else {
                  _formKey.currentState.save();
                  checkConnectivity();
                  updateDatabase(userId, _educationallMap);
                  setState(() {
                    onpress = true;
                  });
                }
              },
            ),
          ],
        ),
        body: (onpress == true)
            ? progress(true)
            : Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        SizedBox(
                          height: 5.0,
                        ),
                        new ListTile(
                          leading: const Icon(Icons.account_balance),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              hintText: "Institute/University",
                            ),
                            initialValue: institute,
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill valid Institute/University';
                              }
                            },
                            onSaved: (String value) {
                              _educationallMap['institute'] = value;
                            },
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.school),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              hintText: "Degree",
                            ),
                            initialValue: degree,
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill valid Degree';
                              }
                            },
                            onSaved: (String value) {
                              _educationallMap['degree'] = value;
                            },
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.local_library),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              hintText: "Field of Study",
                            ),
                            initialValue: field,
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill valid Field of Study';
                              }
                            },
                            onSaved: (String value) {
                              _educationallMap['field'] = value;
                            },
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 18.0,
                              ),
                              Icon(
                                Icons.today,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 25.0,
                              ),
                              Container(
                                width: 90.0,
                                child: TextFormField(
                                  decoration: new InputDecoration(
                                    hintText: "Start Year",
                                  ),
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                  initialValue: startyear,
                                  validator: (String value) {
                                    if (value.isEmpty ||
                                        value.length > 4 ||
                                        value.length < 4 ||
                                        !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                            .hasMatch(value) ||
                                        !(int.parse(value) >= 1980) ||
                                        !(int.parse(value) <= 2022)) {
                                      return 'Invalid Year';
                                    }
                                  },
                                  onSaved: (String value) {
                                    _educationallMap['startyear'] = value;
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 40.0,
                              ),
                              Container(
                                width: 90.0,
                                child: TextFormField(
                                  decoration: new InputDecoration(
                                    hintText: "End Year",
                                  ),
                                  initialValue: endyear,
                                  maxLength: 4,
                                  keyboardType: TextInputType.number,
                                  validator: (String value) {
                                    if (value.isEmpty ||
                                        value.length > 4 ||
                                        !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                            .hasMatch(value) ||
                                        value.length < 4 ||
                                        !(int.parse(value) >= 1980) ||
                                        !(int.parse(value) <= 2022)) {
                                      return 'Invalid Year';
                                    }
                                  },
                                  onSaved: (String value) {
                                    _educationallMap['endyear'] = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: new ListTile(
                            leading: const Icon(Icons.library_books),
                            title: new TextFormField(
                              maxLines: 3,
                              decoration: new InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0))),
                                hintText: "Description",
                              ),
                              initialValue: description,
                              validator: (String value) {
                                if (value.isEmpty ||
                                    RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                        .hasMatch(value)) {
                                  return 'Please enter valid Description';
                                }
                              },
                              onSaved: (String value) {
                                _educationallMap['description'] = value;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }
}
