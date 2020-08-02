import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'addAttendance.dart';

class ModifyPage extends StatefulWidget {
  final String batch;
  final String branch;
  final DateTime dateSelected;
  ModifyPage({this.branch, this.batch, this.dateSelected});
  _ModifyPage createState() => _ModifyPage();
}

class _ModifyPage extends State<ModifyPage> {
  FlutterToast ftoast;
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

  showDelete(context, String uid) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Attendance?"),
              content: Text(
                  "Are you sure you want to delete the particular attendance?"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Delete"),
                  onPressed: () async {
                    await attendanceRef
                        .document(widget.batch)
                        .collection(widget.branch)
                        .document(currentUser.name)
                        .collection(formattedDate)
                        .document(uid)
                        .delete()
                        .then((value) {
                      Navigator.pop(context);
                      ftoast.showToast(
                          child: Text("Deleted"),
                          gravity: ToastGravity.BOTTOM,
                          toastDuration: Duration(seconds: 2));
                    });
                  },
                ),
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Route _animatedRoute() {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddAttendance(
              date: formattedDate,
              branch: widget.branch,
              batch: widget.batch,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.fastLinearToSlowEaseIn;
          var tween = Tween(begin: begin, end: end);
          var curvedAnimation =
              CurvedAnimation(parent: animation, curve: curve);
          return SlideTransition(
            child: child,
            position: tween.animate(curvedAnimation),
          );
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
                        floatingActionButton: FloatingActionButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            Navigator.push(context, _animatedRoute());
                          },
                        ),
                        body: Center(
                          child: Text(
                            "No Record Found!",
                            style: TextStyle(
                                fontSize: 20.0, color: Colors.grey[600]),
                          ),
                        ));
                  }
                  return Scaffold(
                    floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () {
                        Navigator.push(context, _animatedRoute());
                      },
                    ),
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
                                        child: ListTile(
                                          leading: Icon(Icons.account_circle),
                                          title:
                                              Text(_attendance[index]['name']),
                                          subtitle:
                                              Text(_attendance[index]['roll']),
                                          trailing: Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
//                                          onTap: () {
//                                            showDelete(context,
//                                                _attendance[index]['uid']);
//                                          },
                                        ),
                                      )),
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
