import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class MetricDownload extends StatefulWidget {
  _MetricDownload createState() => _MetricDownload();
}

class _MetricDownload extends State<MetricDownload> {
  String _batch = "";
  String _branch = "";

  User currentMentor;

  getUser() async {
    String uid = await auth.currentUser().then((value) => value.uid);
    DocumentSnapshot doc = await userRef.document(uid).get();
    return User.fromDocument(doc);
  }

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
              borderRadius: BorderRadius.circular(15.0),
            ),
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
              borderRadius: BorderRadius.circular(15.0),
            ),
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

  downloadMetric() async {
    String metric = "${currentMentor.name}" + "_${_batch}" + "_${_branch}";
    print(metric);
    final storageRef = FirebaseStorage.instance.ref().child(metric + ".pdf");
    String url = await storageRef.getDownloadURL();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not Launch';
    }
  }

  @override
  void initState() {
    super.initState();
    getUser().then((val) {
      setState(() {
        currentMentor = val;
      });
    });
  }

  Widget build(context) {
    return Scaffold(
      body: Center(
        child: currentMentor == null
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
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (_batch == "" || _branch == "") {
                        showError(context);
                      } else {
                        downloadMetric();
                      }
                    },
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      "Download",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
