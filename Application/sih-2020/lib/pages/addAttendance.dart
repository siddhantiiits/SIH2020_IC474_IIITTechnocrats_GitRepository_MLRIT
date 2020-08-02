import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';

class AddAttendance extends StatefulWidget {
  final String date;
  final String branch;
  final String batch;
  AddAttendance({this.date, this.branch, this.batch});
  _AddAttendance createState() => _AddAttendance();
}

class _AddAttendance extends State<AddAttendance> {
  FocusNode _focus = new FocusNode();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _roll = TextEditingController();
  bool isSearching = false;
  DocumentSnapshot i;
  User _userSelected;
  User currentUser;

  getUser() async {
    String uid = await auth.currentUser().then((value) => value.uid);
    DocumentSnapshot doc = await userRef.document(uid).get();
    return User.fromDocument(doc);
  }

  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() {
        isSearching = focusChange();
      });
    });
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }

  bool focusChange() {
    return _focus.hasFocus;
  }

  addAttendance() async {
    await attendanceRef
        .document(widget.batch)
        .collection(widget.branch)
        .document(currentUser.name)
        .collection(widget.date)
        .document(_userSelected.uid)
        .setData({
      "email": _userSelected.email,
      "name": _userSelected.name,
      "roll": _userSelected.roll,
      "uid": _userSelected.uid,
    });
  }

  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Attendance"),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: currentUser == null
            ? ColorLoader2(
                color1: Colors.redAccent,
                color2: Colors.deepPurple,
                color3: Colors.green,
              )
            : Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          focusNode: _focus,
                          textCapitalization: TextCapitalization.words,
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                            hintText: "John Appleseed",
                            prefixIcon: Icon(
                              Icons.account_circle,
                              color: Color(0xFFa1a1a1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Color(0xFFa1a1a1))),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red)),
                            fillColor: Theme.of(context).primaryColor,
                            filled: true,
                          ),
                          style: TextStyle(
                              backgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(2),
                              decorationColor:
                                  Theme.of(context).primaryColor.withAlpha(2),
                              color: Color.fromRGBO(74, 74, 74, 1)),
                        ),
                      ),
                      isSearching
                          ? Container(
                              child: StreamBuilder(
                                stream: userRef
                                    .where("batch",
                                        isEqualTo: "${widget.batch}")
                                    .snapshots(),
                                builder: (context, snap) {
                                  if (!snap.hasData) {
                                    return CircularProgressIndicator(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      strokeWidth: 5.0,
                                    );
                                  }
                                  List _docList = snap.data.documents;
                                  _docList.removeWhere(
                                      (element) => element['isAdmin']);
                                  _docList.removeWhere((element) =>
                                      element['branch'] != "${widget.branch}");
                                  return SingleChildScrollView(
                                      child: Column(
                                    children: <Widget>[
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: _docList.length,
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              title:
                                                  Text(_docList[index]['name']),
                                              onTap: () {
                                                setState(() {
                                                  _name.text =
                                                      _docList[index]['name'];
                                                  _roll.text =
                                                      _docList[index]['roll'];
                                                  _userSelected =
                                                      User.fromDocument(
                                                          _docList[index]);
                                                });
                                              },
                                            );
                                          }),
                                    ],
                                  ));
                                },
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.4)),
                            )
                          : Text(""),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          controller: _roll,
                          validator: (value) {
                            if (value.length > 8 || value.length < 8) {
                              return "Please enter a valid Roll number";
                            }
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Roll Number",
                            labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                            hintText: "12345678",
                            prefixIcon: Icon(
                              Icons.branding_watermark,
                              color: Color(0xFFa1a1a1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Color(0xFFa1a1a1))),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.red)),
                            fillColor: Theme.of(context).primaryColor,
                            filled: true,
                          ),
                          style: TextStyle(
                              backgroundColor:
                                  Theme.of(context).primaryColor.withAlpha(2),
                              decorationColor:
                                  Theme.of(context).primaryColor.withAlpha(2),
                              color: Color.fromRGBO(74, 74, 74, 1)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(75, 20, 75, 0),
                        child: RaisedButton(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              addAttendance()
                                  .then((val) => Navigator.of(context).pop());
                            }
                          },
                          child: Text("Add",
                              style: TextStyle(
                                fontFamily: "FiraSans",
                                color: Colors.white,
                              )),
                          color: Color(0xFFa8dbe0),
                          // color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
