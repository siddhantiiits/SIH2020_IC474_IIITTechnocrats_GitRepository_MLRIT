import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'package:smart_attendance_manager/pages/home.dart';
import 'package:smart_attendance_manager/pages/modifyAttendance.dart';
import 'package:smart_attendance_manager/pages/runmain.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'package:animated_floatactionbuttons/animated_floatactionbuttons.dart';
import 'package:smart_attendance_manager/pages/userinfo.dart';
import 'package:smart_attendance_manager/pages/mentordateentry.dart';
import 'package:smart_attendance_manager/pages/dateentry.dart';
import 'package:smart_attendance_manager/pages/metricdownload.dart';
import 'package:smart_attendance_manager/pages/addrequest.dart';

class IntroPage extends StatefulWidget {
  _IntroPage createState() => _IntroPage();
}

class _IntroPage extends State<IntroPage> {
  User currentUser;

  getUser() async {
    String uid = await auth.currentUser().then((value) => value.uid);
    DocumentSnapshot doc = await userRef.document(uid).get();
    return User.fromDocument(doc);
  }

  void initState() {
    super.initState();
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }

  logout() async {
    await auth.signOut();
  }

  userFloat() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserInfo(currentUser)));
        },
        tooltip: "User Info",
        child: Icon(Icons.account_circle),
      ),
    );
  }

  logoutFloat() {
    return Container(
      child: FloatingActionButton(
        heroTag: null,
        onPressed: () async {
          logout();
        },
        tooltip: "Logout",
        child: Icon(Icons.exit_to_app),
      ),
    );
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
                stream: userRef.document(currentUser.uid).snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return ColorLoader2(
                      color1: Colors.redAccent,
                      color2: Colors.deepPurple,
                      color3: Colors.green,
                    );
                  }
                  User user = User.fromDocument(snap.data);
                  //admin check
                  if (user.isAdmin == true) {
                    return Scaffold(
//                      appBar: AppBar(
////                        backgroundColor: Color.fromRGBO(31, 6, 77, 1),
//                        backgroundColor: Color.fromRGBO(57, 90, 174, 1),
//                        title: Center(
//                          child: Text(
//                            'Dashboard',
//                            style: TextStyle(color: Colors.white, fontSize: 20),
//                          ),
//                        ),
//                      ),

                      body: ListView(children: [
                        SafeArea(
                          child: Center(
                            child: Column(
//                            mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 8.0),
                                CircleAvatar(
                                  radius: 100.0,
                                  backgroundColor: Colors.black12,
                                  child: CircleAvatar(
                                    radius: 90,
//                                  backgroundImage:
//                                      AssetImage('images/batman.jpg'),
                                    backgroundImage:
                                        NetworkImage(snap.data['photoUrl']),
                                  ),
                                  foregroundColor: Colors.black12,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Welcome ' + snap.data['name'] + '!',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Color.fromRGBO(57, 90, 174, 1),
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(57, 90, 174, 1),
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 80,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          ' Capture Attendance',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RunMain()));
                                  },
                                ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(57, 90, 174, 1),
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 80,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          ' Check Attendance',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DateEntryMentor(),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(57, 90, 174, 1),
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 80,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          ' Modify Attendance',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ModifyAttendance()));
                                  },
                                ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(57, 90, 174, 1),
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 80,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          'Manage Requests',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                                SizedBox(height: 20.0),
                                InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(57, 90, 174, 1),
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 80,
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          ' Download Metrics ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MetricDownload(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),

                      floatingActionButton: AnimatedFloatingActionButton(
                        colorStartAnimation: Color.fromRGBO(57, 90, 174, 1),
                        colorEndAnimation: Colors.red,
                        animatedIconData: AnimatedIcons.menu_close,
                        fabButtons: <Widget>[
                          userFloat(),
                          logoutFloat(),
                        ],
                      ),
                    );
                  }
                  return Scaffold(
                    body: ListView(children: [
                      SafeArea(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 8.0),
                              CircleAvatar(
                                radius: 100.0,
                                backgroundColor: Colors.black12,
                                child: CircleAvatar(
                                  radius: 90,
                                  backgroundImage:
                                      NetworkImage(snap.data['photoUrl']),
                                ),
                                foregroundColor: Colors.black12,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Welcome ' + snap.data['name'] + '!',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Color.fromRGBO(57, 90, 174, 1),
                                ),
                              ),
                              SizedBox(height: 20.0),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(57, 90, 174, 1),
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    height: 80,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        ' Check Attendance',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DateEntry(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20.0),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(57, 90, 174, 1),
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    height: 80,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        'Apply Leave',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {},
                              ),
                              SizedBox(height: 20.0),
                              InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(57, 90, 174, 1),
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    height: 80,
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        'Submit Appeal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AddRequest()));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    floatingActionButton: AnimatedFloatingActionButton(
                      colorStartAnimation: Color.fromRGBO(57, 90, 174, 1),
                      colorEndAnimation: Colors.red,
                      animatedIconData: AnimatedIcons.menu_close,
                      fabButtons: <Widget>[
                        userFloat(),
                        logoutFloat(),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
