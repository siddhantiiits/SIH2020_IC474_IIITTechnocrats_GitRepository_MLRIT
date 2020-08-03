import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'package:smart_attendance_manager/pages/home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRangePicker;

class ApplyLeave extends StatefulWidget{
  _ApplyLeave createState() => _ApplyLeave();
}

class _ApplyLeave extends State<ApplyLeave>{
  User currentUser;
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  var formatter = new DateFormat("yyyy-MM-dd");
  TextEditingController _leaveMsg = TextEditingController();


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
            content: Text("Enter some dates"),
          );
        });
  }

  void initState(){
    super.initState();
    getUser().then((val) {
      setState(() {
        currentUser = val;
      });
    });
  }
  List<String> formatDate = [];
  List<DateTime> listDate = [];

  addLeave() async {
    await leaveRef.document(currentUser.uid).setData({
      "name":currentUser.name,
      "roll":currentUser.roll,
      "hostel":currentUser.hostel,
      "batch":currentUser.batch,
      "branch":currentUser.branch,
      "msg":_leaveMsg.text,
      "email":currentUser.email,
      "photoUrl":currentUser.photoUrl,
      "dateFrom":"${listDate[0].day}/${listDate[0].month}/${listDate[0].year}",
      "dateTo":"${listDate[1].day}/${listDate[1].month}/${listDate[1].year}",
    });
  }


  Widget build(context){
    return Scaffold(
      key: _scaffoldState,
      body: Center(
        child: currentUser == null ? ColorLoader2(
          color1: Colors.redAccent,
          color2: Colors.deepPurple,
          color3: Colors.green,
        ) : Column(
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
                      listDate.length == 0 ? Text("") : listDate[0] == listDate[1] ? Text("${listDate[0].day}/${listDate[0].month}/${listDate[0].year}") : Text("${listDate[0].day}/${listDate[0].month}/${listDate[0].year} to ${listDate[1].day}/${listDate[1].month}/${listDate[0].year}"),
                    ],
                  ),
                ),
                onTap: () async {
                  final List<DateTime> picked = await DateRangePicker.showDatePicker(context: context, initialFirstDate: DateTime.now(), initialLastDate: DateTime.now(), firstDate: DateTime(2014), lastDate: DateTime(2025)).then((value) {
                    if(value == null){
                      formatDate.removeRange(0, 1);
                    }
                    else{setState(() {
                    value.forEach((element) {formatDate.add(formatter.format(element));});
                    listDate = value;
                  });}});
                }),
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
                  controller: _leaveMsg,
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
              onPressed: ()async {
                if (listDate.length != 0)  {
                  await addLeave().then((val){_scaffoldState.currentState.showSnackBar(SnackBar(content: Text("Applied"),));});
                } else {
                  showError(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}