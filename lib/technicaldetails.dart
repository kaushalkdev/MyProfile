import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'professionaldetails.dart';
import 'educationdetails.dart';
import 'edittechnical.dart';
import 'main.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'welcomescreen.dart';
import 'updatetechnical.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class TechnicalDetails extends StatefulWidget {
  AuthService authService = AuthService();

  @override
  _TechnicalDetailsState createState() => _TechnicalDetailsState();
}

class _TechnicalDetailsState extends State<TechnicalDetails> {
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
                    color: Color(0xFF26D2DC),
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
                              .document('technical')
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.account_balance,
                size: 30.0,
              ),
              title: Text(document['company'],
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
                          child: Text(document['projectname'],
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
                            document['startdate'] + ' - ' + document['enddate'],
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
                                UpdateTechnicalForm(
                                  institute: document['company'],
                                  projectname: document['projectname'],
                                  startdate: document['startdate'],
                                  enddate: document['enddate'],
                                  descriptiom: document['description'],
                                  documentref: document.documentID,
                                )));
                  }),
            ),
          ),
        ));
  }


  checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.none) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: ()async=> false,
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
                     // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WelcomeScreen()));

                    },
                  )
                ],


              ),
            );
          });
    } else if (result == ConnectivityResult.mobile) {

    } else if (result == ConnectivityResult.wifi) {

    }
  }


  Widget progress(bool visibility) {
    return Visibility(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF26D2DC)),
        ),
        visible: visibility);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeDilation = 2.0;
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
          title: Text("Projects & Skills"),
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
                          builder: (BuildContext context) => TechnicalForm()));
                }),
          ],
          backgroundColor: Color(0xff26D2DC),
        ),
        bottomNavigationBar: BottomAppBar(
          child: _buildButtons(),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document('technical')
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
