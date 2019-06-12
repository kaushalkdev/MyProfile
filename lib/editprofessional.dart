import 'package:flutter/material.dart';
import 'professionaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'Tabs.dart';
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
  int newYearStart, newYearEnd;
  String newMonthStart, newMonthEnd;
  String saalstart = "2019";
  String saalend = "2019";
  String mStart = "2019";
  String mEnd = "2019";

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
          child: DropdownButton(
            hint: Text('End Year'),
            onChanged: (newValue) {
              setState(() {
                newYearEnd = newValue;
                saalend = "${newYearEnd}";
              });
              if (newYearEnd < newYearStart) {
                showDialog(
                    context: context,
                    builder: (BuildContext contect) {
                      return AlertDialog(
                        title: Text('Oops!'),
                        content: Text('End Year is less than Start Year'),
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
              }
              _professionalMap['endyear'] = saalend;
            },
            value: newYearEnd,
            items: getList().map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
        ),
        SizedBox(
          width: 40.0,
        ),
        Container(
          child: DropdownButton(
            hint: Text('End Month'),
            onChanged: (newValue) {
              setState(() {
                newMonthEnd = newValue;
                mEnd = "${newMonthEnd}";
              });
              _professionalMap['endmonth'] = mEnd;
            },
            value: newMonthEnd,
            items: months.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
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
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff4074c4)),
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
              builder: (BuildContext context) => TabScreen(value: 2,)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Professional'),
          backgroundColor: Color(0xff4074c4),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              color: Colors.white,
              onPressed: () {
                if (!_formKey.currentState.validate() ||
                    int.parse(_professionalMap['startyear']) >
                        int.parse(_professionalMap['endyear'])) {
                  showDialog(
                      context: context,
                      builder: (BuildContext contect) {
                        return AlertDialog(
                          title: Text('Oops!'),
                          content: Text('End Year is less than Start Year'),
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
                                        activeColor: Color(0xff4074c4),
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
                              child: DropdownButton(
                                hint: Text('Start Year'),
                                onChanged: (newValue) {
                                  setState(() {
                                    newYearStart = newValue;
                                    saalstart = "${newYearStart}";
                                  });
                                  _professionalMap['startyear'] = saalstart;
                                },
                                value: newYearStart,
                                items: getList()
                                    .map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(
                              width: 40.0,
                            ),
                            Container(
                              child: DropdownButton(
                                hint: Text('Start Month'),
                                onChanged: (newValue) {
                                  setState(() {
                                    newMonthStart = newValue;
                                    mStart = "${newMonthStart}";
                                  });
                                  _professionalMap['startmonth'] = mStart;
                                },
                                value: newMonthStart,
                                items: months.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
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

  List<int> getList() {
    List<int> year = new List<int>();
    int y = 1980;
    for (var i = y; i <= 2019; i++) {
      year.add(y);
      y = y + 1;
    }
    return year;
  }

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];
}
