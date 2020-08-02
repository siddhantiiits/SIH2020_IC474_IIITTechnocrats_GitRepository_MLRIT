import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';

class AttendanceCheckMentor extends StatefulWidget {
  final String batch;
  final String branch;
  final DateTime dateSelected;
  AttendanceCheckMentor({this.branch, this.batch, this.dateSelected});
  _AttendanceMentorState createState() => _AttendanceMentorState();
}

class _AttendanceMentorState extends State<AttendanceCheckMentor> {
  User currentUser;

  var formatter = new DateFormat("yyyy-MM-dd");
  String formattedDate;
  DateTime date;

  getUser() async {
    String uid = await auth.currentUser().then((value) => value.uid);
    DocumentSnapshot doc = await userRef.document(uid).get();
    return User.fromDocument(doc);
  }

  @override
  void initState() {
    super.initState();
    formattedDate = formatter.format(widget.dateSelected);
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }

  Widget build(context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: currentUser == null
            ? ColorLoader2(
                color1: Colors.redAccent,
                color2: Colors.deepPurple,
                color3: Colors.green,
              )
            : StreamBuilder(
                stream: attendanceRef
                    .document(widget.batch)
                    .collection(widget.branch)
                    .document(currentUser.name)
                    .collection(formattedDate)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return ColorLoader2(
                      color1: Colors.redAccent,
                      color2: Colors.deepPurple,
                      color3: Colors.green,
                    );
                  }
                  List _attendance = snap.data.documents;
                  if (_attendance.length == 0) {
                    return Scaffold(
                      backgroundColor: Theme.of(context).accentColor,
                      body: Center(
                        child: Text(
                          "No Record Found!",
                          style: TextStyle(
                              fontSize: 20.0, color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }
                  return Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                      child: Container(
                        child: ListView.builder(
                            itemCount: _attendance.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: ListTile(
                                        leading: Icon(Icons.account_circle),
                                        title: Text(_attendance[index]['name']),
                                        subtitle:
                                            Text(_attendance[index]['roll']),
                                        trailing: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                ],
                              );
                            }),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
