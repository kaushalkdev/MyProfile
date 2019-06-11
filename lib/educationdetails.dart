import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'personaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'technicaldetails.dart';
import 'professionaldetails.dart';
import 'editeducation.dart';
import 'updateeducational.dart';
import 'main.dart';
import 'welcomescreen.dart';
import 'auth.dart';
import 'package:connectivity/connectivity.dart';

class EducationalDetails extends StatefulWidget {
  AuthService service = new AuthService();

  @override
  _EducationalDetailsState createState() => _EducationalDetailsState();
}

class _EducationalDetailsState extends State<EducationalDetails> {
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
                    color: Color(0xFF4074c4),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.service.getCurrentuser().then((userid) {
      setState(() {
        this.userid = userid;
      });
    });
    checkConnectivity();
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
                            .document('education')
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
              title: Text(document['institute'],
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(document['degree'],
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.blueGrey)),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(document['field'],
                              style: TextStyle(
                                  fontSize: 16.0, color: Colors.blueGrey)),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              document['startyear'] +
                                  ' - ' +
                                  document['endyear'],
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                UpdateEducationDetails(
                                  institute: document['institute'],
                                  description: document['description'],
                                  degree: document['degree'],
                                  startyear: document['startyear'],
                                  endyear: document['endyear'],
                                  field: document['field'],
                                  documentRef: document.documentID,
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
        child: SizedBox(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF4074c4)),
          ),
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
          title: Text("Education"),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => EducationForm()));
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
                        .document('education')
                        .collection(userid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container(child: Center(child: progress(true)));
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
