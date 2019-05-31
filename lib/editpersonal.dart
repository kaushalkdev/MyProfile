import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class EditPersonalDetails extends StatefulWidget {
  AuthService authService = new AuthService();

  @override
  _EditPersonalDetailsState createState() => _EditPersonalDetailsState();
}

class _EditPersonalDetailsState extends State<EditPersonalDetails> {
  String userId = '';
  final Map<String, dynamic> _personalMap = {
    'name': null,
    'birthday': null,
    'email': null,
    'gender': null,
    'address': null,
  };

  int groupValue;
  String _dateText;
  DateTime _duedate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void action(int e) {
    setState(() {
      if (e == 1) {
        groupValue = 1;
        _personalMap['gender'] = 'Male';
      } else if (e == 2) {
        groupValue = 2;
        _personalMap['gender'] = 'Female';
      }
    });
  }

  Future<Null> _selectdueDate(BuildContext context) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: _duedate,
        firstDate: DateTime(1980),
        lastDate: DateTime(2030));

    if (picked != null) {
      setState(() {
        _duedate = picked;
        _dateText = "${picked.day}/${picked.month}/${picked.year}";

        _personalMap['birthday'] = _dateText;
      });
    } else {
      _dateText = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
      _personalMap['enddate'] = _dateText;
    }
  }

  @override
  void initState() {
    super.initState();
    _dateText = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
    _personalMap['birthday'] = _dateText;

    groupValue = 1;
    widget.authService.getCurrentuser().then((userId) {
      setState(() {
        this.userId = userId;
        print(" userid " + userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Personal'),
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

                  updateDatabase(userId, _personalMap);
                  progress(true);
                }
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  SizedBox(
                    height: 5.0,
                  ),
                  new ListTile(
                    leading: const Icon(Icons.person),
                    title: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: "Name",
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please fill the name';
                        }
                      },
                      onSaved: (String value) {
                        _personalMap['name'] = value;
                      },
                    ),
                  ),
                  new ListTile(
                    leading: const Icon(Icons.email),
                    title: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: "Email",
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please fill EmailId';
                        }
                      },
                      onSaved: (String value) {
                        _personalMap['email'] = value;
                      },
                    ),
                  ),
                  Divider(
                    height: 30.0,
                  ),
                  new ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Birthday'),
                    subtitle: Text(_dateText),
                    trailing: GestureDetector(
                      onTap: () {
                        _selectdueDate(context);
                      },
                      child: const Icon(
                        Icons.edit,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new ListTile(
                      leading: const Icon(Icons.wc),
                      title: const Text('Gender'),
                      subtitle: Container(
                        child: Row(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text('Male'),
                                Radio(
                                  onChanged: (int e) {
                                    action(e);
                                  },
                                  activeColor: Colors.blue,
                                  value: 1,
                                  groupValue: groupValue,
                                ),
                                SizedBox(
                                  width: 8.0,
                                ),
                                Text('Female'),
                                Radio(
                                  onChanged: (int e) {
                                    action(e);
                                  },
                                  activeColor: Colors.blue,
                                  value: 2,
                                  groupValue: groupValue,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  new ListTile(
                    leading: const Icon(Icons.home),
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
                        hintText: "Address",
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter the address';
                        }
                      },
                      onSaved: (String value) {
                        _personalMap['address'] = value;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
        ),
        visible: visibility);
  }

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('personal')
        .document(userId)
        .setData(personalMap)
        .whenComplete(() {
      progress(false);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PersonalDetails()));
    });
  }
}
