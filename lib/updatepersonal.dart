import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class UpdatePersonalDetails extends StatefulWidget {
  AuthService authService = new AuthService();
  String name = '';
  String email = '';
  String birthday = '';
  String gender = '';
  String address = '';

  UpdatePersonalDetails(
      {this.name, this.email, this.birthday, this.gender, this.address});

  @override
  _UpdatePersonalDetailsState createState() => _UpdatePersonalDetailsState();
}

class _UpdatePersonalDetailsState extends State<UpdatePersonalDetails> {
  String userId = '';

  String name = '';
  String email = '';
  String birthday = '';
  String gender = '';
  String address = '';

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
        lastDate: DateTime(2022));


    if (picked != null) {
      setState(() {
        _duedate = picked;
        _dateText = "${picked.day}/${picked.month}/${picked.year}";
        _personalMap['birthday'] = _dateText;
      });
    } else {
      _dateText = "${_duedate.day}/${_duedate.month}/${_duedate.year}";
      _personalMap['birthday'] = _dateText;
    }
  }

  @override
  void initState() {
    super.initState();

    this.name = widget.name;
    this.email = widget.email;
    this.gender = widget.gender;
    this.birthday = widget.birthday;
    this.address = widget.address;
    if (gender == 'Male') {
      groupValue = 1;
    } else {
      groupValue = 2;
    }

    _dateText = birthday;
    _personalMap['birthday'] = _dateText;
    _personalMap['gender'] = 'Male';
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
                      initialValue: name,
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
                      initialValue: email,
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
                      initialValue: address,
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

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('personal')
        .document(userId)
        .setData(personalMap)
        .whenComplete(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => PersonalDetails()));
    });
  }
}
