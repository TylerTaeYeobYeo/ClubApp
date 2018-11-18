import 'package:cloud_firestore/cloud_firestore.dart';

class Article {
  final String id;
  final List<dynamic> image;
  final String body;
  final String uid;
  final String name;
  final String photoUrl;
  final DateTime date;
  final int like;
  final DocumentReference reference;

  Article.fromMap(Map<String, dynamic> map, {this.reference}):
    assert(map['id']!=null),
    assert(map['body']!=null),
    assert(map['writer']['id']!=null),
    assert(map['writer']['name']!=null),
    assert(map['writer']['photoUrl']!=null),
    assert(map['date'] != null),
    assert(map['like']!=null),
    image = map['image'],
    date = map['date'],
    id = map['id'],
    body = map['body'],
    uid = map['writer']['id'],
    name = map['writer']['name'],
    photoUrl = map['writer']['photoUrl'],
    like = map['like'];

  Article.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  // @override
  // String toString() => "Article<>";
}