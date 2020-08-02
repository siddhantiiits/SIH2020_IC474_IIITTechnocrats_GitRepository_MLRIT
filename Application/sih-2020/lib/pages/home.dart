import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_attendance_manager/pages/intro.dart';
import 'package:flip_card/flip_card.dart';
import 'package:smart_attendance_manager/models/users.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final userRef = Firestore.instance.collection('users');
final storageRef = FirebaseStorage.instance.ref();
final attendanceRef = Firestore.instance.collection('Attendance');

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User currentUser;
  FlutterToast toastMsg;
  void initState() {
    super.initState();
    toastMsg = FlutterToast(context);
  }

  Widget buildAuthPage() {
    return IntroPage();
  }

//LoginCard

  Widget buildUnAuthPage() {
    GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
    GlobalKey<FormState> _pwdChange = GlobalKey<FormState>();
    GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
    GlobalKey<FormState> _registerKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _pwdController = TextEditingController();
    TextEditingController _name = TextEditingController();
    TextEditingController _batch = TextEditingController();
    TextEditingController _roll = TextEditingController();
    TextEditingController _branchController = TextEditingController();
    TextEditingController _emailPwdchange = TextEditingController();
    TextEditingController _hostel = TextEditingController();

    void _showAlert(String err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "Wrong Credentials",
              ),
              content: Text(
                err,
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
            );
          });
    }

    login() async {
      try {
        await auth.signInWithEmailAndPassword(
            email: _emailController.text, password: _pwdController.text);
      } catch (e) {
        _showAlert(e.message);
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

    String pwdValidator(String value) {
      if (value.length < 8) {
        return 'Password must be longer than 8 characters';
      } else {
        return null;
      }
    }

    handleRegister() async {
      String uid;
      await auth
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _pwdController.text)
          .then((value) => uid = value.user.uid);
      await userRef.document(uid).setData({
        'name': _name.text,
        'branch': _branchController.text,
        'batch': _batch.text,
        'email': _emailController.text,
        'pwd': _pwdController.text,
        'isAdmin': false,
        'roll': _roll.text,
        'uid': uid,
        'photoUrl': "",
        'hostel':_hostel.text,
      });
    }

    handlePwdTap() async {
      try {
        if (_pwdChange.currentState.validate()) {
          await auth.sendPasswordResetEmail(email: _emailPwdchange.text);
          toastMsg.showToast(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Text("Password change E-mail sent"),
            ),
            gravity: ToastGravity.BOTTOM,
            toastDuration: Duration(seconds: 2),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        _showAlert(e.message);
      }
    }

    handlePasswordChange() {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                height: 200.0,
                child: Form(
                  key: _pwdChange,
                  child: ListView(
                    children: <Widget>[
                      Text(
                        "Password Change",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                        child: TextFormField(
                          controller: _emailPwdchange,
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
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: RaisedButton(
                          onPressed: () async {
                            await handlePwdTap();
                          },
                          child: Text(
                            "Send E-Mail",
                            style: TextStyle(color: Colors.white),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          color: Color(0xFFa8dbe0),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
    }

    void showInfo() {
      showDialog(
          context: context,
          builder: (context) {
            return AboutDialog(
              title: "IIIT Technocrats",
              desc:
                  "Team Lead by Siddhant\nTeam Members:\n Pulkit,Nikhil,Vaibhav,Ansh,Pranati\n\n Acknowledgement:\nDr. MN Doja, Mr. Gaurav Gautam,  Dr. Mukesh Mann, Dr. Rajiv Verma, Dr. Diddy Swamy and other staff of IIIT Sonepat",
              btnText: "Close",
            );
          });
    }

    return Scaffold(
      floatingActionButton: IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            showInfo();
          }),
      body: Center(
          child: FlipCard(
        key: cardKey,
        flipOnTouch: false,
        front: Center(
          child: Container(
            height: 350.0,
            width: 300.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  width: 225.0,
                  child: Text("Login",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'FiraSans')),
                ),
                Form(
                  key: _loginKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
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
                            fillColor: Theme.of(context).primaryColor,
                            filled: true,
                          ),
                          style: TextStyle(
                            backgroundColor:
                                Theme.of(context).primaryColor.withAlpha(2),
                            decorationColor:
                                Theme.of(context).primaryColor.withAlpha(2),
                            color: Color(0xFF4a4a4a),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                        child: TextFormField(
                            controller: _pwdController,
                            obscureText: true,
                            validator: (value) => pwdValidator(value),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Color(0xFFa1a1a1),
                              ),
                              hintText: "********",
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
                              fillColor: Theme.of(context).primaryColor,
                              filled: true,
                            ),
                            style: TextStyle(
                              backgroundColor: Theme.of(context).primaryColor,
                              decorationColor: Theme.of(context).primaryColor,
                              color: Color(0xFF4a4a4a),
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 270.0,
                  child: InkWell(
                    onTap: () {
                      handlePasswordChange();
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(75, 20, 75, 0),
                  child: RaisedButton(
                    onPressed: () {
                      if (_loginKey.currentState.validate()) {
                        login();
                      }
                    },
                    child: Text("Login",
                        style: TextStyle(
                          fontFamily: "FiraSans",
                          color: Colors.white,
                        )),
                    color: Color(0xFFa8dbe0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: InkWell(
                      onTap: () => cardKey.currentState.toggleCard(),
                      child: Text(
                        "Register",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        back: Center(
          child: Container(
            height: 500.0,
            width: 300.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).accentColor),
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 225.0,
                    child: Text("Register",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'FiraSans')),
                  ),
                  Form(
                    key: _registerKey,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.characters,
                            controller: _branchController,
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            controller: _pwdController,
                            obscureText: true,
                            validator: (value) => pwdValidator(value),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Color(0xFFa1a1a1),
                              ),
                              hintText: "********",
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor: Theme.of(context).accentColor,
                                decorationColor: Theme.of(context).accentColor,
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            controller: _batch,
                            validator: (value) {
                              if (value.length > 4 || value.length < 4) {
                                return "Please enter a valid Year";
                              }
                            },
                            keyboardType: TextInputType.number,
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                    Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0),
                          child: TextFormField(
                            controller: _hostel,
                            validator: (value) {
                              if (value.length > 5 || value.length < 5) {
                                return "Please enter a valid Hostel Number";
                              }
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Hostel ID",
                              labelStyle: TextStyle(color: Color(0xFFa1a1a1)),
                              hintText: "A-123",
                              prefixIcon: Icon(
                                Icons.home,
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
                              fillColor: Theme.of(context).accentColor,
                              filled: true,
                            ),
                            style: TextStyle(
                                backgroundColor:
                                Theme.of(context).accentColor.withAlpha(2),
                                decorationColor:
                                Theme.of(context).accentColor.withAlpha(2),
                                color: Color.fromRGBO(74, 74, 74, 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(75, 20, 75, 0),
                    child: RaisedButton(
                      onPressed: () {
                        if (_registerKey.currentState.validate()) {
                          print("success");
                          handleRegister();
                        }
                      },
                      child: Text("Register",
                          style: TextStyle(
                            fontFamily: "FiraSans",
                            color: Colors.white,
                          )),
                      color: Color(0xFFebd3cc),
                      // color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                      child: InkWell(
                        onTap: () => cardKey.currentState.toggleCard(),
                        child: Text(
                          "Login",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      )),
    );
  }

  Widget build(context){
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context,snap){
        if(snap.hasData){
          if(snap.data.providerData.length == 1){
            return buildAuthPage();
          }else{
            return buildAuthPage();
          }
        }else{
          return buildUnAuthPage();
        }
      },
    );
  }
}

class AboutDialog extends StatelessWidget {
  final String title, desc, btnText;
  final Image image;

  AboutDialog({
    this.title,
    this.desc,
    this.btnText,
    this.image,
  });

  Widget build(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: Consts.avatarRadius + Consts.padding,
            bottom: Consts.padding,
            left: Consts.padding,
            right: Consts.padding,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title,
                  style:
                      TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700)),
              SizedBox(
                height: 16.0,
              ),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(btnText),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/logo.png'),
            backgroundColor: Theme.of(context).primaryColor,
            radius: 60.0,
          ),
          top: 10.0,
          // left: 84.0,
          // right: 77.0,
        )
      ],
    );
  }
}

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
