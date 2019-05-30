import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'educationdetails.dart';

class EducationForm extends StatefulWidget {
  AuthService authService = new AuthService();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EducationFormState();
  }
}

class _EducationFormState extends State<EducationForm> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId = '';
  final Map<String, dynamic> _educationallMap = {
    'institute': null,
    'degree': null,
    'field': null,
    'startyear': null,
    'endyear': null,
    'description': null,
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.authService.getCurrentuser().then((userid) {
      setState(() {
        this.userId = userid;
      });
    });
  }

  Future updateDatabase(String userId, Map<String, dynamic> personalMap) async {
    Firestore.instance
        .collection('users')
        .document('education')
        .collection(userId)
        .add(personalMap)
        .whenComplete(() {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => EducationalDetails()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Education'),
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

                  updateDatabase(userId, _educationallMap);
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
                    leading: const Icon(Icons.account_balance),
                    title: new TextFormField(
                      decoration: new InputDecoration(
                        hintText: "Institute/University",
                      ),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please fill the Institute/University';
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
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please fill Degree';
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
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please fill Field of Study';
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
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please fill Start Year';
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
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please fill End Year';
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
                        validator: (String value) {
                          if(value.isEmpty){return 'Please enter your Description';}

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