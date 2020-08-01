import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';

class AttendanceCheck extends StatefulWidget {
  final String mentor;
  final DateTime dateSelected;
  AttendanceCheck({this.dateSelected, this.mentor});
  _AttendanceCheckState createState() => _AttendanceCheckState();
}

class _AttendanceCheckState extends State<AttendanceCheck> {
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
//                stream: attendanceRef.document(currentUser.batch).collection(currentUser.branch).document(widget.mentor).collection("${widget.dateSelected.year}-${widget.dateSelected.month}-${widget.dateSelected.day}").snapshots(),
                stream: attendanceRef
                    .document(currentUser.batch)
                    .collection(currentUser.branch)
                    .document(widget.mentor)
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
                  List _list = snap.data.documents;
                  bool isPresent = _list.length > 0;
                  return Scaffold(
                    backgroundColor: isPresent
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).accentColor,
                    body: Center(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              isPresent ? "Present" : "Absent",
                              style: TextStyle(
                                  fontSize: 25.0, color: Colors.grey[600]),
                            ),
                            Text(
                              isPresent
                                  ? "Attendance Captured on : ${formattedDate} in ${widget.mentor} Lecture"
                                  : "",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
