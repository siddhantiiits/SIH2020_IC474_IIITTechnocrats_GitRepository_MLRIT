import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_attendance_manager/models/users.dart';
import 'home.dart';
import 'package:smart_attendance_manager/widget/loader.dart';
import 'package:swipe_stack/swipe_stack.dart';

class ReviewReqCard extends StatefulWidget {
  _ReviewReqCard createState() => _ReviewReqCard();
}

class _ReviewReqCard extends State<ReviewReqCard>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
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

  List<Widget> _getCards(List<DocumentSnapshot> list) {
    List<Widget> cardList = new List();

    for (int x = 0; x < list.length; x++) {
      cardList.add(Positioned(
        top: 50,
        child: Draggable(
            onDragEnd: (drag) {
              setState(() {
                cardList.removeAt(x);
              });
            },
            childWhenDragging: Container(),
            child: Card(
              elevation: 12,
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                child: Text(list[x]['name']),
                width: 240,
                height: 300,
              ),
            ),
            feedback: Card(
              elevation: 12,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                child: Text(list[x]['name']),
                width: 240,
                height: 300,
              ),
            )),
      ));
    }
    return cardList;
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
              : StreamBuilder(
                  stream: reqRef
                      .document(currentUser.name)
                      .collection("msgs")
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return ColorLoader2(
                        color1: Colors.redAccent,
                        color2: Colors.deepPurple,
                        color3: Colors.green,
                      );
                    }
                    List<DocumentSnapshot> _reqs = snap.data.documents;
                    return _reqs.length == 0
                        ? Scaffold(
                            backgroundColor: Theme.of(context).accentColor,
                            body: Center(
                              child: Text(
                                "No Pending Requests!",
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.grey[600]),
                              ),
                            ))
                        : Scaffold(
                            body: Center(
                                child: SwipeStack(
                              children: _reqs.map((index) {
                                return SwiperItem(builder:
                                    (SwiperPosition pos, double progress) {
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Material(
                                      elevation: 4,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6))),
                                        child: Stack(
                                          children: <Widget>[
                                            index['photoUrl'] == null
                                                ? Container(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  )
                                                : Positioned(
                                                    bottom: 25,
                                                    child: Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                        child: Image.network(
                                                            index[
                                                                'photoUrl']))),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Details(
                                                                  user:
                                                                      index)));
                                                },
                                                child: Hero(
                                                  tag: index['name'],
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                        "${index['name']}, ${index['batch']}, ${index['branch']}",
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                      Text(
                                                        index['date'],
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              }).toList(),
                              visibleCount: 3,
                              stackFrom: StackFrom.Top,
                              translationInterval: 6,
                              scaleInterval: 0.03,
                              onEnd: () {},
                              onSwipe: (index, SwiperPosition pos) async {
                                if (pos == SwiperPosition.Left) {
                                  await reqRef
                                      .document(currentUser.name)
                                      .collection("msgs")
                                      .document(_reqs[index]['uid'])
                                      .delete();
                                  _scaffoldState.currentState.showSnackBar(
                                      SnackBar(content: Text("Declined")));
                                  setState(() {
                                    _reqs.removeAt(index);
                                  });
                                } else if (pos == SwiperPosition.Right) {
                                  await attendanceRef
                                      .document(_reqs[index]["batch"])
                                      .collection(_reqs[index]["branch"])
                                      .document(currentUser.name)
                                      .collection(_reqs[index]['date'])
                                      .document(_reqs[index]['uid'])
                                      .setData({
                                    "email": _reqs[index]['email'],
                                    "name": _reqs[index]['name'],
                                    "roll": _reqs[index]['roll'],
                                    "uid": _reqs[index]['uid'],
                                  }).then((value) async {
                                    await reqRef
                                        .document(currentUser.name)
                                        .collection("msgs")
                                        .document(_reqs[index]['uid'])
                                        .delete();
                                    _scaffoldState.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text("Accepted"),
                                    ));
                                    setState(() {
                                      _reqs.removeAt(index);
                                    });
                                  });
                                }
                              },
                            )),
                          );
                  },
                )),
    );
  }
}

class Details extends StatelessWidget {
  final DocumentSnapshot user;
  Details({this.user});
  Widget build(context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: user['photoUrl'] == null
                  ? Container(
                      color: Theme.of(context).primaryColor,
                    )
                  : Image.network(user['photoUrl']),
            ),
          ),
          DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 1.0,
              builder: (context, controller) {
                return Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            Text(
                              user['name'],
                              style: TextStyle(fontSize: 25),
                            ),
                            Text(
                              user['branch'],
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              "Batch of ${user['batch']}",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: user['msg'].trim() == ""
                            ? Text(
                                "Requested you to mark his/her attendance on ${user['date']}")
                            : Text(
                                "Requested to mark the attendance on ${user['date']}, saying '${user['msg']}' "),
                      )
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
