import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String displayName;
  final String email;
  final String uid;
  final String level;
  final String phoneNumber;
  final String classof;
  final String specific;
  final String state;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['displayName'] != null),
        assert(map['email'] != null),
        assert(map['uid'] != null),
        assert(map['level'] != null),
        //assert(map['phoneNumber] != null),
        displayName = map['displayName'],
        email = map['email'],
        uid = map['uid'],
        level = map['level'],
        phoneNumber = map['phoneNumber'] == null ? "미등록" 
        : map['phoneNumber'],
        classof = map['classof'] == null ? "미등록" : map['classof'],
        specific = map['specific'] ==null? "미등록": map['specific'],
        state = map['state'] ==null? "미등록": map['state'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$displayName:$email>";
}


class RecordS {
  final String displayName;
  final String uid;
  final String level;
  final String specific;
  final String state;
  final DocumentReference reference;

  RecordS.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['displayName'] != null),
        assert(map['uid'] != null),
        assert(map['level']!=null),
        level = map['level'],
        uid = map['uid'],
        displayName = map['displayName'],
        specific = map['specific'] ==null? "": map['specific'],
        state = map['state'] ==null? "": map['state'];

  RecordS.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "RecordS<$displayName>";
}