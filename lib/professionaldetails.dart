import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'educationdetails.dart';
import 'technicaldetails.dart';
import 'editprofessional.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'welcomescreen.dart';
import 'package:connectivity/connectivity.dart';
import 'main.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'updateprofessional.dart';

class ProfessionalDetails extends StatefulWidget {
  AuthService authService = new AuthService();

  @override
  _ProfessionalDetailsState createState() => _ProfessionalDetailsState();
}

class _ProfessionalDetailsState extends State<ProfessionalDetails> {
  String userid = '';

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
                    color: Colors.grey,
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
                    color: Color(0xFF4074c4),
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
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WelcomeScreen()));
                    },
                  )
                ],
              ),
            );
          });
    } else if (result == ConnectivityResult.mobile) {
    } else if (result == ConnectivityResult.wifi) {}
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    progress(false);
    return Dismissible(
      key: Key(document.documentID),
      confirmDismiss: (direction) async {
        final bool res = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm"),
                content: const Text("Do you want to delete this item?"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);

                        Firestore.instance
                            .collection('users')
                            .document('professional')
                            .collection(userid)
                            .document(document.documentID)
                            .delete();
                      },
                      child: const Text("DELETE")),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  )
                ],
              );
            });
      },
      background: Container(
        alignment: Alignment(0.8, 0),
        color: Color(0xffe8eaed),
        child: Icon(
          Icons.delete,
          color: Colors.grey,
          size: 35.0,
        ),
      ),
      direction: DismissDirection.endToStart,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: ListTile(
              leading: Icon(
                Icons.account_balance,
                size: 30.0,
              ),
              title: Text(document['designation'],
                  style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(document['company'],
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                            document['startmonth'] +
                                ' ' +
                                document['startyear'] +
                                ' - ' +
                                document['endmonth'] +
                                ' ' +
                                document['endyear'],
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(document['description'],
                              style: TextStyle(
                                fontSize: 16.0,
                              )),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    checkConnectivity();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                UpdateProfessionalDetails(
                                  company: document['company'],
                                  descriptiom: document['description'],
                                  designation: document['designation'],
                                  documentref: document.documentID,
                                  endyear: document['endyear'],
                                  endmonth: document['endmonth'],
                                  startyear: document['startyear'],
                                  startmonth: document['startmonth'],
                                  location: document['location'],
                                )));
                  }),
            ),
          ),
          Divider(
            height: 0,
          )
        ],
      ),
    );
  }

  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF4074c4)),
        ),
        visible: visibility);
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
          title: Text("Professional"),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  checkConnectivity();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ProfessionalForm()));
                }),
          ],
          backgroundColor: Color(0xFF4074c4),
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
                        .document('professional')
                        .collection(userid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: progress(true));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => buildListItem(
                            context, snapshot.data.documents[index]),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
