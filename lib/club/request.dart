import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestPage extends StatefulWidget {
  final DocumentSnapshot data;
  RequestPage({Key key, @required this.data})
    : assert(data != null);
  _RequestPageState createState() => _RequestPageState(club: data);
}

class _RequestPageState extends State<RequestPage> {
  final DocumentSnapshot club;
  _RequestPageState({Key key, @required this.club})
    : assert(club != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("request처리"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          Column(
            children: <Widget>[
              Card(
                // color: Colors.white70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ExpansionTile(
                      title: Text("설명서"),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("<<왼쪽으로 밀어서 거절"),
                              Text("오른쪽으로 밀어서 승인>>"),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('clubs').document(club.documentID).collection('request').snapshots(),
                  builder: (context, snapshot){
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return ListView(
                      children: snapshot.data.documents.map((data){
                        return Dismissible(
                          key: ValueKey(data.data['uid']),
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(data.data['photoUrl']),
                                  ),
                                  title: Text(data.data['name']),
                                  children: <Widget>[
                                    ListTile(
                                      leading: Text("신청사유:"),
                                      trailing: Container(
                                        padding: EdgeInsets.symmetric(vertical: 20.0),
                                        child: Text(data.data['content']),
                                      ),
                                    ),
                                    ListTile(
                                      leading: Text("email:"),
                                      trailing: Text(data.data['email']),
                                    ),
                                    ListTile(
                                      leading: Text("phone:"),
                                      trailing: Text(data.data['phoneNumber'].toString()),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          onDismissed: (direction){
                            if(direction == DismissDirection.endToStart){
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(data['name'] + " 삭제됨"),
                                duration: Duration(milliseconds: 500),));
                            }
                            else{
                              Firestore.instance.runTransaction((Transaction transaction)async{
                                Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data['uid']).setData({
                                  "email": data['email'],
                                  "id": data['uid'],
                                  "level": 2,
                                  "name": data['name'],
                                  "phoneNumber": data['phoneNumber'],
                                  "photoUrl": data['photoUrl'],
                                });
                                Firestore.instance.collection('users').document(data['uid']).collection('clubs').document(club.documentID).setData({
                                  "id":club.documentID,
                                  "image":club.data['image'],
                                  "level":2,
                                  "name":club.data['name'],
                                  "type":club.data['type'],
                                  "date": DateTime.now(),
                                });
                              });
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(data['name']+" 추가됨"),
                                  duration: Duration(milliseconds: 500),
                                )
                              );
                            }
                            Firestore.instance.collection('clubs').document(club.documentID).collection('request').document(data['uid']).delete();
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          ),
        ],
      )
    );
  }
}