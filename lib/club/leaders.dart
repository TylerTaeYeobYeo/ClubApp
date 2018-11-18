import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeadersPage extends StatefulWidget {
  final DocumentSnapshot data;
  LeadersPage({Key key, @required this.data})
    : assert(data != null);
  _LeadersPageState createState() => _LeadersPageState(club: data);
}

class _LeadersPageState extends State<LeadersPage> {
    final DocumentSnapshot club;
  _LeadersPageState({Key key, @required this.club})
    : assert(club != null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("임원단 관리"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.data['id']).collection('users').where("level",isEqualTo: 3).snapshots(),
            builder: (context,snapshots){
              return ListView(
                children: snapshots.data.documents.map((data){
                  return Card(
                    child:ExpansionTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data.data['photoUrl']),
                      ),
                      title: Text(data.data['name']),
                      children: <Widget>[
                        RadioListTile(
                          title: Text("회장"),
                          groupValue: data.data['title'], 
                          onChanged: (value) {
                            Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                              "title": value
                            });
                          },
                          value: 0,
                        ),
                        RadioListTile(
                          title: Text("부회장"),
                          groupValue: data.data['title'], 
                          onChanged: (value) {
                            Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                              "title": value
                            });
                          },
                          value: 1,
                        ),
                        RadioListTile(
                          title: Text("총무"),
                          groupValue: data.data['title'], 
                          onChanged: (value) {
                            Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                              "title": value
                            });
                          },
                          value: 2,
                        ),
                        RadioListTile(
                          title: Text("그 외"),
                          groupValue: data.data['title'], 
                          onChanged: (value) {
                            Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                              "title": value
                            });
                          },
                          value: 3,
                        )
                      ],
                    )
                  );
                }).toList(),
              );
            },
          ),
        ],
      )   
    );
  }
}