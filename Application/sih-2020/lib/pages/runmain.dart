import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
class RunMain extends StatefulWidget {
  _RunMain createState() => _RunMain();
}

class _RunMain extends State<RunMain> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  User currentUser;
  String _batch="";
  String _branch="";

  showError(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Select the required fields"),
          );
        });
  }

  List<String> _year = ["2019", "2020", "2021", "2022"];
  List<String> _stream = ["CSE", "IT"];

  openYearSelector(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              height: 300,
              child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text(_year[index]),
                      ),
                      onTap: () {
                        setState(() {
                          _batch = _year[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
            ),
          );
        });
  }

  openBranchSelector(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              height: 150,
              child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: ListTile(
                        leading: Icon(Icons.all_inclusive),
                        title: Text(_stream[index]),
                      ),
                      onTap: () {
                        setState(() {
                          _branch = _stream[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  }),
            ),
          );
        });
  }

  getUser() async {
    String uid = await auth.currentUser().then((value) => value.uid);
    DocumentSnapshot doc = await userRef.document(uid).get();
    return User.fromDocument(doc);
  }

  runMain(User mentor,String _batch,String _branch) async {
    var client = new http.Client();
    try {
      var res = await client.post('http://10.0.2.2:5000/${mentor.name}/${_batch}/${_branch}');
      print(res.body);
    } finally {
      client.close();
    }
  }

  void initState() {
    super.initState();
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }
  Duration _duration = Duration(hours: 0,minutes: 0);
  Widget build(context) {
    return Scaffold(
      key: _scaffoldState,
        body: Center(
      child: currentUser == null
          ? ColorLoader2(
              color1: Colors.redAccent,
              color2: Colors.deepPurple,
              color3: Colors.green,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).accentColor,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Selected Batch:",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.grey[600]),
                            ),
                            Text(
                              _batch,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        openYearSelector(context);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                    GestureDetector(
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffd2cffe),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Selected Branch:",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.grey[600]),
                            ),
                            Text(
                              _branch,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        openBranchSelector(context);
                      },
                    ),
                  ],
                ),
                GestureDetector(
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Duration:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Text(
//                              "${dateTime.day}",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                fontSize: 20,
//                                color: Colors.grey[600],
//                              ),
//                            ),
//                            Padding(
//                                padding: EdgeInsets.symmetric(horizontal: 5.0),
//                                child: Container(
//                                  width: 1.0,
//                                  height: 10.0,
//                                  color: Colors.grey[600],
//                                )),
//                            Text(
//                              "${dateTime.month}",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                fontSize: 20,
//                                color: Colors.grey[600],
//                              ),
//                            ),
//                            Padding(
//                                padding: EdgeInsets.symmetric(horizontal: 5.0),
//                                child: Container(
//                                  width: 1.0,
//                                  height: 10.0,
//                                  color: Colors.grey[600],
//                                )),
//                            Text(
//                              "${dateTime.year}",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                fontSize: 20,
//                                color: Colors.grey[600],
//                              ),
//                            )
//                          ],
//                        ),
                      Text(
                        "${_duration.inMinutes}mins",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600]
                        ),
                      ),
                      ],
                    ),
                  ),
                  onTap: () async {
                     await showDurationPicker(context: context, initialTime: _duration).then((value) {
                       if(value==null){
                         setState(() {
                           _duration = Duration(minutes: 30);
                         });
                       }else{
                         setState(() {
                           _duration = value;
                         });
                       }
                       });
                  },
                ),

                Padding(
                  padding: EdgeInsets.only(top: 5.0),
                ),
                RaisedButton(
                  onPressed: () {
                    if (_batch == "" || _branch == "") {
                      showError(context);
                    } else {
                      runMain(currentUser,_batch,_branch).then((val) => _scaffoldState.currentState.showSnackBar(SnackBar(content: Text("Captured"))));
                    }
                  },
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Text(
                    "Capture",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
    ));
  }
}
