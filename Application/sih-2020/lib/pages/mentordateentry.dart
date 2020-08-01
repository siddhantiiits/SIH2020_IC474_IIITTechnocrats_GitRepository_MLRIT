import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/pages/mentorAttendaceCheck.dart';

class DateEntryMentor extends StatefulWidget {
  _DateMentorState createState() => _DateMentorState();
}

class _DateMentorState extends State<DateEntryMentor> {
  DateTime dateTime;
  String _batch = "";
  String _branch = "";

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

  openDatePicker(context) async {
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

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
  }

  Widget build(context) {
    return Scaffold(
      body: Center(
        child: Column(
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
                      "Date Selected:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
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
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                await openDatePicker(context);
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AttendanceCheckMentor(
                                batch: _batch,
                                branch: _branch,
                                dateSelected: dateTime,
                              )));
                }
              },
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
            ),
          ],
        ),
      ),
    );
  }
}
