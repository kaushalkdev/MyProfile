import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'technicaldetails.dart';
import 'professionaldetails.dart';
import 'editeducation.dart';
import 'updateeducational.dart';
import 'main.dart';
import 'auth.dart';

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
                    color: Color(0xFF26D2DC),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.service.getCurrentuser().then((userid) {
      setState(() {
        this.userid = userid;
      });
    });
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot document) {
    return Dismissible(
      key: Key(document.documentID),
      onDismissed: (DismissDirection direction) {
        direction = DismissDirection.endToStart;

        Firestore.instance
            .collection('users')
            .document('education')
            .collection(userid)
            .document(document.documentID)
            .delete();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                    Text(document['degree'],
                        style:
                            TextStyle(fontSize: 16.0, color: Colors.blueGrey)),
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
                          document['startyear'] + ' - ' + document['endyear'],
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
                        builder: (BuildContext context) => UpdateEducationDetails(
                          institute:document['institute'],
                          description:document['degree'] ,
                          degree: document['field'],
                          startyear:document['startyear'] ,
                          endyear: document['endyear'],
                          field:document['field'],

                        )));
              }),
        ),
      ),
    );
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
                        .document('education')
                        .collection(userid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('Loading....');
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
