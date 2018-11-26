 /* 
  * 운영자료
  */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_club2/club/newRDB.dart';
import 'package:http/http.dart' as http;

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
  static var httpClient = new HttpClient();

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
  
  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
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
                    key: ValueKey(doc.documentID),
                    child: ExpansionTile(
                      title: Text(doc.data['title']),
                      // leading: Text(doc.data['writer']),
                      children: <Widget>[
                        // ListTile(
                        //   leading: Text("작성자"),
                        //   title: Text(doc.data['writer']),
                        // ),
                        ListTile(
                          leading: Text("설명"),
                          title: Text(doc.data['description']),
                        ),
                        ListTile(
                          leading: Text("파일"),
                          title: Text(doc.data['fileName']),
                          trailing: IconButton(
                            icon: Icon(Icons.file_download),
                            onPressed: ()async{
                              // _downloadFile(doc.data['file'],doc.data['fileName']);
                              
                            },
                          ),
                        ),
                      ],
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
                    key: ValueKey(doc.data['title']),
                    child: ListTile(
                      title: Text(doc.data['writer']),
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
                    key: ValueKey(doc.data['title']),
                    child: ListTile(
                      title: Text(doc.data['writer']),
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