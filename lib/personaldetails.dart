import 'package:flutter/material.dart';
import 'technicaldetails.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'professionaldetails.dart';
import 'educationdetails.dart';
import 'editpersonal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'updatepersonal.dart';
import 'main.dart';

class PersonalDetails extends StatefulWidget {
  AuthService authService = new AuthService();

  @override
  _PersonalDetailsState createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  String userId = '';
  String Name = '';
  String Email = '';
  String Birthday = '';
  String Gender = '';
  String Address = '';

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.person,
                    color: Color(0xFF26D2DC),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PersonalDetails()));
                  })),
          Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.school,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EducationalDetails()));
                  })),
          Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.work,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ProfessionalDetails()));
                  })),
          Expanded(
              child: IconButton(
                  icon: Icon(
                    Icons.build,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                TechnicalDetails()));
                  })),
        ],
      ),
    );
  }

  Widget name(BuildContext context, String userid) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('personal')
            .document(userid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          setuserValues(userDocument);

          return ListTile(
            leading: Icon(
              Icons.person,
              size: 30.0,
            ),
            title: Text('Name', style: TextStyle(fontSize: 20.0)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child:
                  Text(userDocument['name'], style: TextStyle(fontSize: 15.0)),
            ),
          );
        });
  }

  Widget dob(BuildContext context, String userid) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('personal')
            .document(userid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return ListTile(
            leading: Icon(
              Icons.today,
              size: 30.0,
            ),
            title: Text('Birthday', style: TextStyle(fontSize: 20.0)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(userDocument['birthday'],
                  style: TextStyle(fontSize: 15.0)),
            ),
          );
        });
  }

  Widget email(BuildContext context, String userId) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('personal')
            .document(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return ListTile(
            leading: Icon(
              Icons.email,
              size: 30.0,
            ),
            title: Text('Email', style: TextStyle(fontSize: 20.0)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child:
                  Text(userDocument['email'], style: TextStyle(fontSize: 15.0)),
            ),
          );
        });
  }

  Widget gender(BuildContext context, String userId) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('personal')
            .document(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return ListTile(
            leading: Icon(
              Icons.wc,
              size: 30.0,
            ),
            title: Text('Gender', style: TextStyle(fontSize: 20.0)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(userDocument['gender'],
                  style: TextStyle(fontSize: 15.0)),
            ),
          );
        });
  }

  Widget address(BuildContext context, String userId) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('personal')
            .document(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ");
          }
          var userDocument = snapshot.data;

          return ListTile(
            leading: Icon(
              Icons.home,
              size: 30.0,
            ),
            title: Text('Address', style: TextStyle(fontSize: 20.0)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(userDocument['address'],
                  style: TextStyle(fontSize: 15.0)),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.authService.getCurrentuser().then((userId) {
      setState(() {
        this.userId = userId;
        print(" userid " + userId);
      });
    });
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
        ),
        visible: visibility);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) => loginUser()));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Personal"),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              UpdatePersonalDetails(
                                address: Address,
                                birthday: Birthday,
                                name: Name,
                                gender: Gender,
                                email: Email,
                              )));
                })
          ],
          backgroundColor: Color(0xff26D2DC),
        ),
        bottomNavigationBar: BottomAppBar(
          child: _buildButtons(),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: progress(true));
                      }
                      return ListView(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  name(context, userId),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  dob(context, userId),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  email(context, userId),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  gender(context, userId),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  address(context, userId),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future setuserValues(userDocument) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', userDocument['gender']);
    await prefs.setString('name', userDocument['name']);
    await prefs.setString('email', userDocument['email']);
    await prefs.setString('birthday', userDocument['birthday']);
    await prefs.setString('address', userDocument['address']);
    setState(() {
      Gender = prefs.get('gender');
      Address = prefs.get('address');
      Name = prefs.get('name');
      Email = prefs.get('email');
      Birthday = prefs.get('birthday');
    });
  }
}
