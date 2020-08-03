import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';

class AddRequest extends StatefulWidget {
  _AddRequest createState() => _AddRequest();
}

class _AddRequest extends State<AddRequest> {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  FlutterToast flutterToast;
  TextEditingController _reqMsg = TextEditingController();
  DateTime dateTime;
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
    dateTime = DateTime.now();
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }

  showError(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Select Mentor"),
          );
        });
  }

  showDuplicateError(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "Please wait for your mentor to review your previous appeal"),
          );
        });
  }

  openSelector(context) async {
    DateTime newDateTime = await showDatePicker(
            context: context,
            initialDate: dateTime,
            firstDate: DateTime(2014),
            lastDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      } else {
        setState(() {
          dateTime = value;
        });
      }
    });
  }

  List<String> _mentors = ["Mentor 1", "Mentor 2", "Mentor 3"];
  String _selectedMentor = "";

  openMentorSelector(context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Container(
              height: 500,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      child: ListTile(
                        leading: Icon(Icons.arrow_forward_ios),
                        title: Text(_mentors[index]),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMentor = _mentors[index];
                        });
                        Navigator.pop(context);
                      });
                },
              ),
            ),
          );
        });
  }

  addRequest() async {
    DocumentSnapshot doc = await reqRef
        .document(_selectedMentor)
        .collection('msgs')
        .document(currentUser.uid)
        .get();
    if (!doc.exists) {
      await reqRef
          .document(_selectedMentor)
          .collection('msgs')
          .document(currentUser.uid)
          .setData({
        "name": currentUser.name,
        "roll": currentUser.roll,
        "email": currentUser.email,
        "batch": currentUser.batch,
        "branch": currentUser.branch,
        "uid": currentUser.uid,
        "msg": _reqMsg.text,
        "photoUrl": currentUser.photoUrl,
        "date": formatter.format(dateTime),
      });
    } else {
      showDuplicateError(context);
    }
  }

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
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                                "Date Selected:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                              //Text("${dateTime.day} - ${dateTime.month} - ${dateTime.year}",textAlign: TextAlign.center,style: TextStyle(fontSize: 20.0,color: Colors.grey[600]),)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "${dateTime.day}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Container(
                                        width: 1.0,
                                        height: 10.0,
                                        color: Colors.grey[600],
                                      )),
                                  Text(
                                    "${dateTime.month}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5.0),
                                      child: Container(
                                        width: 1.0,
                                        height: 10.0,
                                        color: Colors.grey[600],
                                      )),
                                  Text(
                                    "${dateTime.year}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await openSelector(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      GestureDetector(
                        child: Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).accentColor),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Selected Mentor",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _selectedMentor,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          openMentorSelector(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).primaryColor),
                        width: 300,
                        height: 150,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: TextField(
                            controller: _reqMsg,
                            decoration: InputDecoration(
                              hintText: "Please enter any message...",
                              labelText: "Request Message",
                            ),
                            maxLines: 5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5.0),
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        child: Text(
                          "Submit",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        onPressed: () {
                          if (_selectedMentor != "") {
                            addRequest().then((val) {
                              _scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text("Request Sent."),
                              ));
                            });
                          } else {
                            showError(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
        ));
  }
}
