import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'personaldetails.dart';
import 'professionaldetails.dart';
import 'technicaldetails.dart';
import 'educationdetails.dart';

class TabScreen extends StatefulWidget {
  int value;

  TabScreen({this.value});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TabScreenState();
  }
}

class _TabScreenState extends State<TabScreen>
    with SingleTickerProviderStateMixin {
  TabController controller;

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 4);

    if (widget.value != null) {
      controller.index = widget.value;
    }
    controller.addListener(_handleTabSelection);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: null,
      bottomNavigationBar: Material(
        child: TabBar(
          indicatorColor: Colors.white,
          controller: controller,
          tabs: <Widget>[
            Tab(
              icon: Icon(
                Icons.person,
                color:
                    (controller.index == 0) ? Color(0xff4074c4) : Colors.grey,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.school,
                color:
                    (controller.index == 1) ? Color(0xff4074c4) : Colors.grey,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.work,
                color:
                    (controller.index == 2) ? Color(0xff4074c4) : Colors.grey,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.build,
                color:
                    (controller.index == 3) ? Color(0xff4074c4) : Colors.grey,
              ),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          PersonalDetails(),
          EducationalDetails(),
          ProfessionalDetails(),
          TechnicalDetails()
        ],
      ),
    );
  }
}
