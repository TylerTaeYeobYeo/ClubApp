import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_club2/club/newShare.dart';
class ShareFilePage extends StatefulWidget {
  final DocumentSnapshot club;
  ShareFilePage({@required this.club}):assert(club != null);
  _ShareFilePageState createState() => _ShareFilePageState(club: club);
}

class _ShareFilePageState extends State<ShareFilePage> {
  
  final DocumentSnapshot club;
  _ShareFilePageState({@required this.club}):assert(club != null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("공유자료"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: (){
              Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context)=>NewSharePage(club: club,),
                )
              );
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.documentID).collection('share').snapshots(),
            builder: (context, snapshots){
              if(!snapshots.hasData)return LinearProgressIndicator(); 
              return Column(
                children: snapshots.data.documents.map((data){
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Text(data.data['name']),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}