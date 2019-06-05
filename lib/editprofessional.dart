import 'package:flutter/material.dart';
import 'professionaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'package:connectivity/connectivity.dart';

class ProfessionalForm extends StatefulWidget {
  AuthService authService = new AuthService();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfessionalFormState();
  }
}

class _ProfessionalFormState extends State<ProfessionalForm> {
  String userid = '';
  final Map<String, dynamic> _professionalMap = {
    'company': null,
    'designation': null,
    'startmonth': null,
    'endmonth': null,
    'startyear': null,
    'endyear': null,
    'location': null,
    'description': null,
  };
  int groupValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool val = true;

  bool onpress;

  Widget box(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 18.0,
        ),
        Icon(
          Icons.date_range,
          color: Colors.grey,
        ),
        SizedBox(
          width: 25.0,
        ),
        Container(
          width: 100.0,
          child: TextFormField(
            decoration: InputDecoration(hintText: 'End Year'),
            keyboardType: TextInputType.number,
            maxLength: 4,
            validator: (String value) {
              if (value.isEmpty ||
                  value.length > 4 ||
                  value.length < 4 ||
                  !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value) ||
                  !(int.parse(value) >= 1980) ||
                  !(int.parse(value) <= 2022)) {
                return 'Invalid Year';
              }
            },
            onSaved: (String value) {
              _professionalMap['endyear'] = value;
            },
          ),
        ),
        SizedBox(
          width: 40.0,
        ),
        Container(
          width: 90.0,
          child: TextFormField(
            decoration: InputDecoration(hintText: 'End Month'),
            maxLength: 3,
            validator: (String value) {
              if (value.isEmpty ||
                  value.length > 3 ||
                  value.length < 3 ||
                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value) ||
                  !checkMonth(value.toUpperCase())) {
                return 'Not valid Month';
              }
            },
            onSaved: (String value) {
              _professionalMap['endmonth'] = value.toUpperCase();
            },
          ),
        ),
      ],
    );
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectivity();
    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        this.userid = userid;
      });
    });

    onpress = false;
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
          ),
        ),
        visible: visibility);
  }

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('users')
        .document('professional')
        .collection(userId)
        .add(personalMap)
        .whenComplete(() {
      progress(false);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => ProfessionalDetails()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Professional'),
          backgroundColor: Color(0xFF26D2DC),
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
                  updateDatabase(userid, _professionalMap);
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
                              hintText: "Company",
                            ),
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill the valid Company Name';
                              }
                            },
                            onSaved: (String value) {
                              _professionalMap['company'] = value;
                            },
                          ),
                        ),
                        new ListTile(
                          leading: const Icon(Icons.face),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              hintText: "Designation",
                            ),
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill valid Designation';
                              }
                            },
                            onSaved: (String value) {
                              _professionalMap['designation'] = value;
                            },
                          ),
                        ),
                        Divider(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: new ListTile(
                            leading: const Icon(Icons.timer),
                            title: const Text('Time Period'),
                            subtitle: Container(
                              child: Row(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text('I currently work here'),
                                      Checkbox(
                                        activeColor: Color(0xFF26D2DC),
                                        value: val,
                                        onChanged: (bool value) {
                                          setState(() {
                                            val = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 18.0,
                            ),
                            Icon(
                              Icons.date_range,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              width: 25.0,
                            ),
                            Container(
                              width: 100.0,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration: new InputDecoration(
                                  hintText: "Start Year",
                                ),
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
                                  _professionalMap['startyear'] = value;
                                },
                              ),
                            ),
                            SizedBox(
                              width: 40.0,
                            ),
                            Container(
                              width: 100.0,
                              child: TextFormField(
                                decoration: new InputDecoration(
                                  hintText: "Start Month",
                                ),
                                maxLength: 3,
                                validator: (String value) {
                                  if (value.isEmpty ||
                                      value.length > 3 ||
                                      value.length < 3 ||
                                      RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                          .hasMatch(value) ||
                                      !checkMonth(value.toUpperCase())) {
                                    return 'Invalid Month';
                                  }
                                },
                                onSaved: (String value) {
                                  _professionalMap['startmonth'] =
                                      value.toUpperCase();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        appear(context, val),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(),
                        new ListTile(
                          leading: const Icon(Icons.location_on),
                          title: new TextFormField(
                            decoration: new InputDecoration(
                              hintText: "Location",
                            ),
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please fill valid Location';
                              }
                            },
                            onSaved: (String value) {
                              _professionalMap['location'] = value;
                            },
                          ),
                        ),
                        Divider(),
                        new ListTile(
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
                            validator: (String value) {
                              if (value.isEmpty ||
                                  RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                      .hasMatch(value)) {
                                return 'Please enter valid Description';
                              }
                            },
                            onSaved: (String value) {
                              _professionalMap['description'] = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ));
  }

  Widget appear(BuildContext context, bool valu) {
    if (valu) {
      _professionalMap['endyear'] = 'present';

      _professionalMap['endmonth'] = '';

      return Container();
    } else {
      return box(context);
    }
  }

  bool checkMonth(String value) {
    if (value == 'JAN') {
      return true;
    } else if (value == 'FEB') {
      return true;
    } else if (value == 'MAR') {
      return true;
    } else if (value == 'APR') {
      return true;
    } else if (value == 'MAY') {
      return true;
    } else if (value == 'JUN') {
      return true;
    } else if (value == 'JUL') {
      return true;
    } else if (value == 'AUG') {
      return true;
    } else if (value == 'SEP') {
      return true;
    } else if (value == 'OCT') {
      return true;
    } else if (value == 'NOV') {
      return true;
    } else if (value == 'DEC') {
      return true;
    }
    return false;
  }
}
