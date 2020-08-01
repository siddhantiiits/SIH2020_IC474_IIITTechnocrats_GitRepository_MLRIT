import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final String branch;
  final String email;
  final String pwd;
  final bool isAdmin;
  final String batch;
  final String roll;
  final String uid;
  final String photoUrl;

  User(
      {this.name,
      this.branch,
      this.email,
      this.pwd,
      this.isAdmin,
      this.batch,
      this.roll,
      this.uid,
      this.photoUrl});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      name: doc['name'],
      branch: doc['branch'],
      email: doc['email'],
      pwd: doc['pwd'],
      isAdmin: doc['isAdmin'],
      batch: doc['batch'],
      roll: doc['roll'],
      uid: doc.documentID,
      photoUrl: doc['photoUrl'],
    );
  }
}
