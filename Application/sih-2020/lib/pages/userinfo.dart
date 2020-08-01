import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_attendance_manager/models/users.dart';

import 'home.dart';

class UserInfo extends StatefulWidget {
  final User user;
  UserInfo(this.user);
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  File _image;
  String _uploadedFileUrl;
  final picker = ImagePicker();
  GlobalKey<FormState> _updateInfo = GlobalKey<FormState>();
  String name, branch, batch, email, pass;
  bool showPwd = false;

  @override
  void initState() {
    super.initState();
  }

  handleUpdate() async {
    if (_updateInfo.currentState.validate()) {
      _updateInfo.currentState.save();
      await userRef.document(widget.user.uid).updateData({
        "name": name,
        "email": email,
        "branch": branch,
        "batch": batch,
        "pwd": pass,
      });
      await auth.currentUser().then((value) => value.updatePassword(pass));
    }
  }

  handleRemove() async {
    await userRef.document(widget.user.uid).updateData({'photoUrl': ""});
  }

  openCam() async {
    final pickedImg = await picker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(pickedImg.path);
    });
    StorageReference ref = storageRef.child("dp_${widget.user.name}");
    StorageUploadTask storageUploadTask = ref.putFile(_image);
    await storageUploadTask.onComplete;
    ref.getDownloadURL().then((value) {
      userRef.document(widget.user.uid).updateData({'photoUrl': value});
    });
  }

  chooseFile() async {
    final pickedImg = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImg.path);
    });
    StorageReference ref = storageRef.child("dp_${widget.user.name}");
    StorageUploadTask storageUploadTask = ref.putFile(_image);
    await storageUploadTask.onComplete;
    ref.getDownloadURL().then((value) {
      userRef.document(widget.user.uid).updateData({'photoUrl': value});
    });
  }

  updatePhoto() async {
    await userRef
        .document(widget.user.uid)
        .updateData({'photoUrl': _uploadedFileUrl});
  }

  handlePhoto() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Photo from:"),
        content: Container(
          height: 125.0,
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () {
                  openCam();
                },
              ),
              ListTile(
                leading: Icon(Icons.collections),
                title: Text("Gallery"),
                onTap: () {
                  chooseFile();
                },
              )
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Close",
            ),
          ),
        ],
      ),
    );
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userRef.document(widget.user.uid).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                strokeWidth: 5.0,
              ),
            ),
          );
        }
        User user = User.fromDocument(snap.data);
        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
          ),
          body: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Stack(
                      alignment: Alignment(0, 0.7),
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Color.fromRGBO(57, 90, 174, 1),
                          backgroundImage: snap.data['photoUrl'] == null
                              ? null
                              : NetworkImage(snap.data['photoUrl']),
                          radius: 90.0,
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.black45),
                          child: InkWell(
                              onTap: () {
                                handlePhoto();
                              },
                              child: Text(
                                "Update Photo",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _updateInfo,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 10.0, top: 10.0),
                          child: TextFormField(
                            onSaved: (val) => name = val,
                            initialValue: user.name,
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 10.0),
                          child: TextFormField(
                            enabled: false,
                            onSaved: (val) => email = val,
                            initialValue: user.email,
                            validator: (value) => emailValidator(value),
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                              hintText: "student@mail.com",
                              prefixIcon: Icon(
                                Icons.email,
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 10.0),
                          child: TextFormField(
                            initialValue: user.pwd,
                            onSaved: (val) => pass = val,
                            obscureText: showPwd ? false : true,
                            validator: (value) => pwdValidator(value),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Color(0xFFa1a1a1),
                              ),
                              hintText: "********",
                              suffix: GestureDetector(
                                child: Icon(Icons.remove_red_eye),
                                onTap: () => setState(() {
                                  showPwd = !showPwd;
                                }),
                              ),
                              prefixIcon: Icon(
                                Icons.arrow_forward_ios,
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
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: 30.0, right: 30.0, bottom: 10.0),
                            child: TextFormField(
                              onSaved: (val) => branch = val,
                              initialValue: user.branch,
                              validator: (value) {
                                if (value != "CSE" && value != "IT") {
                                  return "Please enter valid Branch CSE or IT";
                                }
                              },
                              decoration: InputDecoration(
                                labelText: "Branch",
                                labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                                hintText: "CSE",
                                prefixIcon: Icon(
                                  Icons.all_inclusive,
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
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 10.0),
                          child: TextFormField(
                            onSaved: (val) => batch = val,
                            initialValue: user.batch,
                            validator: (value) {
                              if (value.length > 4 || value.length < 4) {
                                return "Please enter a valid Year";
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Batch",
                              labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                              hintText: "2020",
                              prefixIcon: Icon(
                                Icons.calendar_today,
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
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 10.0),
                          child: TextFormField(
                            enabled: false,
                            initialValue: user.roll,
                            validator: (value) {
                              if (value.length > 8 || value.length < 8) {
                                return "Please enter a valid Roll number";
                              }
                            },
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
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () async {
                          await handleUpdate();
                        },
                        child: Text("Update Info"),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: RaisedButton(
                          onPressed: () async {
                            await handleRemove();
                          },
                          child: Text("Remove Profile Picture"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
