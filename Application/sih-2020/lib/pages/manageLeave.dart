import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/pages/home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';

class ManageLeave extends StatefulWidget{
  _ManageLeave createState() =>  _ManageLeave();
}

class _ManageLeave extends State<ManageLeave>{
  Widget build(context){
    return StreamBuilder(
      stream: leaveRef.snapshots(),
      builder: (context,snap){
        if(!snap.hasData){
          return ColorLoader2(
            color1: Colors.redAccent,
            color2: Colors.deepPurple,
            color3: Colors.green,
          );
        }
        List _leave = snap.data.documents;
        return Scaffold(
          body:Center(
            child: ListView.builder(itemCount: _leave.length,itemBuilder: (context,index){
              return Card(
                elevation: 15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(_leave[index]['photoUrl']),
                        radius: 50,
                      ),
                      Text(_leave[index]['name'],style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                      Text("${_leave[index]['batch']}, ${_leave[index]['branch']}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                      Text("${_leave[index]['dateFrom']} to ${_leave[index]['dateTo']}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
                      Text(_leave[index]['msg'],style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}