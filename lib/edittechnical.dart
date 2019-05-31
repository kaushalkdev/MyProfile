import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'technicaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class TechnicalForm extends StatefulWidget {
  String institute = '';
  String projectname = '';
  String startdate = '';
  String enddate = '';
  String descriptiom = '';

  AuthService authService = AuthService();

  @override
  State<StatefulWidget> createState() {
    return _TechnicalFormState();
  }
}

class _TechnicalFormState extends State<TechnicalForm> {
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

  Future<Null> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _duedate,
        firstDate: DateTime(2018),
        lastDate: DateTime(2080));

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
        firstDate: DateTime(2018),
        lastDate: DateTime(2080));

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

    _dateEnd = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
    _dateStart = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
    _technicalMap['startdate'] = _dateStart;
    _technicalMap['enddate'] = _dateEnd;
    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        this.userid = userid;
      });
    });
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
          backgroundColor: Colors.green,
        ),
        visible: visibility);
  }

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('users')
        .document('technical')
        .collection(userId)
        .add(personalMap)
        .whenComplete(() {

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => TechnicalDetails()));
    });
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

                updateDatabase(userid, _technicalMap);
                progress(true);
              }
            },
          ),
        ],
        backgroundColor: Color(0xFF26D2DC),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Project Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5.0,
                ),
                new ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: new TextFormField(
                    decoration: new InputDecoration(
                      hintText: "Institute/Company",
                    ),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please fill the Institute/Company Name';
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
                    decoration: new InputDecoration(
                      hintText: "Project Name",
                    ),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please fill Project Name';
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
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      hintText: "Description",
                    ),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter Description';
                      }
                    },
                    onSaved: (String value) {
                      _technicalMap['description'] = value;
                    },
                  ),
                ),
                Divider(
                  color: Color(0xFF26D2DC),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  'Add your Skills',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5.0,
                ),
                new ListTile(
                  title: Container(
                    width: 90.0,
                    child: new TextFormField(
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
                        hintText: "Skills",
                      ),
                    ),
                  ),
                  trailing: FlatButton(
                    child: Text(
                      'Add +',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Color(0xFF26D2DC),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Skills'),
                              content: TextField(
                                  decoration: InputDecoration(
                                hintText: 'Add Skills',
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF26D2DC))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF26D2DC))),
                              )),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Add',
                                    style: TextStyle(color: Color(0xFF26D2DC)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
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
