import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'technicaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'package:connectivity/connectivity.dart';

class UpdateTechnicalForm extends StatefulWidget {
  String institute = '';
  String projectname = '';
  String startdate = '';
  String enddate = '';
  String descriptiom = '';
  String documentref = '';

  UpdateTechnicalForm(
      {this.institute,
      this.projectname,
      this.startdate,
      this.enddate,
      this.descriptiom,
      this.documentref});

  AuthService authService = AuthService();

  @override
  _UpdateTechnicalFormState createState() => _UpdateTechnicalFormState();
}

class _UpdateTechnicalFormState extends State<UpdateTechnicalForm> {
  String institute = '';
  String projectname = '';
  String startdate = '';
  String enddate = '';
  String descriptiom = '';
  String documentref = '';

  String userid = '';
  final Map<String, dynamic> _technicalMap = {
    'company': null,
    'projectname': null,
    'startdate': null,
    'enddate': null,
    'description': null,
  };

  String _dateStart = '', _dateEnd = '';
  DateTime _duedate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool onpress;

  Future<Null> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _duedate,
        firstDate: DateTime(2009),
        lastDate: DateTime(2020));

    if (picked != null) {
      setState(() {
        _duedate = picked;
        _dateStart = "${picked.day}/${picked.month}/${picked.year}";
        _technicalMap['startdate'] = _dateStart;
      });
    } else {
      _dateStart = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
      _technicalMap['startdate'] = _dateStart;
    }
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _duedate,
        firstDate: DateTime(2009),
        lastDate: DateTime(2020));

    if (picked != null) {
      setState(() {
        _duedate = picked;
        _dateEnd = "${picked.day}/${picked.month}/${picked.year}";
        _technicalMap['enddate'] = _dateEnd;
      });
    } else {
      _dateEnd = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
      _technicalMap['enddate'] = _dateEnd;
    }
  }

  @override
  void initState() {
    super.initState();
    onpress = false;
    this.institute = widget.institute;
    this.projectname = widget.projectname;
    this.startdate = widget.startdate;
    this.enddate = widget.enddate;
    this.descriptiom = widget.descriptiom;
    this.documentref = widget.documentref;

    _dateStart = startdate;
    _dateEnd = enddate;
    _technicalMap['startdate'] = _dateStart;
    _technicalMap['enddate'] = _dateEnd;
    checkConnectivity();
    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        this.userid = userid;
      });
    });
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
  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('users')
        .document('technical')
        .collection(userId)
        .document(documentref)
        .setData(personalMap)
        .whenComplete(() {
      progress(false);
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => TechnicalDetails()));
    });
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects & Skills'),
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
                updateDatabase(userid, _technicalMap);
                setState(() {
                  onpress = true;
                });
              }
            },
          ),
        ],
        backgroundColor: Color(0xFF26D2DC),
      ),
      body: (onpress == true)
          ? progress(true)
          : Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 5.0,
                      ),
                      new ListTile(
                        leading: const Icon(Icons.account_balance),
                        title: new TextFormField(
                          initialValue: institute,
                          decoration: new InputDecoration(
                            hintText: "Institute/Company",
                          ),
                          validator: (String value) {
                            if (value.isEmpty ||
                                RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                    .hasMatch(value)) {
                              return 'Please fill the valid Institute/Company Name';
                            }
                          },
                          onSaved: (String value) {
                            _technicalMap['company'] = value;
                          },
                        ),
                      ),
                      Divider(),
                      new ListTile(
                        leading: const Icon(Icons.face),
                        title: new TextFormField(
                          initialValue: projectname,
                          decoration: new InputDecoration(
                            hintText: "Project Name",
                          ),
                          validator: (String value) {
                            if (value.isEmpty ||
                                RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                    .hasMatch(value)) {
                              return 'Please fill the valid Project Name';
                            }
                          },
                          onSaved: (String value) {
                            _technicalMap['projectname'] = value;
                          },
                        ),
                      ),
                      Divider(),
                      new ListTile(
                        leading: const Icon(Icons.today),
                        title: const Text('Start Date'),
                        subtitle: Text(_dateStart),
                        trailing: GestureDetector(
                          onTap: () {
                            _selectStartDate(context);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Divider(),
                      new ListTile(
                        leading: const Icon(Icons.today),
                        title: const Text('End Date'),
                        subtitle: Text(_dateEnd),
                        trailing: GestureDetector(
                          onTap: () {
                            _selectEndDate(context);
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
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
                            hintText: "Describe your Project and Skills",
                          ),
                          initialValue: descriptiom,
                          validator: (String value) {
                            if (value.isEmpty ||
                                RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$')
                                    .hasMatch(value)) {
                              return 'Please fill the valid Description';
                            }
                          },
                          onSaved: (String value) {
                            _technicalMap['description'] = value;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
