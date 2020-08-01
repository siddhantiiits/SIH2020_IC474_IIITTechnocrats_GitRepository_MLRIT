import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/pages/checkattendance.dart';

class DateEntry extends StatefulWidget {
  _DateEntryState createState() => _DateEntryState();
}

class _DateEntryState extends State<DateEntry> {
  DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
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

  Widget build(context) {
    return Scaffold(
      body: Center(
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttendanceCheck(
                        dateSelected: dateTime,
                        mentor: _selectedMentor,
                      ),
                    ),
                  );
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
