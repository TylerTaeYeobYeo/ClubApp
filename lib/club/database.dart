 /* 
  * 운영자료
  */

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_club2/club/new.dart';

class DatabasePage extends StatefulWidget {
  final DocumentSnapshot data;
  DatabasePage({Key key, @required this.data})
    : assert(data != null),
    super(key: key);
  _DatabasePageState createState() => _DatabasePageState(club: data);
}

class _DatabasePageState extends State<DatabasePage> with SingleTickerProviderStateMixin{
  DocumentSnapshot club;
  TabController _tabController;

  _DatabasePageState({Key key, @required this.club})
    : assert(club != null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() { 
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("운영 자료"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(child: Text("인수인계"),),
            Tab(child: Text("활동일지"),),
            Tab(child: Text("회계"),)
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.note_add),
            onPressed: (){
              Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context) => CreateDataPage(data: club, index: _tabController.index,),
                )
              );
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 0).snapshots(),
            builder: (context,snapshots){
              if(!snapshots.hasData)return LinearProgressIndicator();
              return ListView(
                children: snapshots.data.documents.map((doc){
                  return Card(
                    key: ValueKey(doc.data['id']),
                    child: ListTile(
                      title: Text(doc.data['name']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 1).snapshots(),
            builder: (context,snapshots){
              if(!snapshots.hasData)return LinearProgressIndicator();
              return ListView(
                children: snapshots.data.documents.map((doc){
                  return Card(
                    key: ValueKey(doc.data['id']),
                    child: ListTile(
                      title: Text(doc.data['name']),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 2).snapshots(),
            builder: (context,snapshots){
              if(!snapshots.hasData)return LinearProgressIndicator();
              return ListView(
                children: snapshots.data.documents.map((doc){
                  return Card(
                    key: ValueKey(doc.data['id']),
                    child: ListTile(
                      title: Text(doc.data['name']),
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