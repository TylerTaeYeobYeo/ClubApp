 /* 
  * 운영자료
  */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_club2/club/newRDB.dart';
import 'package:dio/dio.dart';

class DatabasePage extends StatefulWidget {
  final DocumentSnapshot data;
  DatabasePage({Key key, @required this.data})
    : assert(data != null),
    super(key: key);
  _DatabasePageState createState() => _DatabasePageState(club: data);
}

class _DatabasePageState extends State<DatabasePage> with SingleTickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  DocumentSnapshot club;
  TabController _tabController;
  // static var httpClient = new HttpClient();
  bool downloading = false;
  bool loadingScreen = false;
  var progressString = "";

  _DatabasePageState({Key key, @required this.club})
    : assert(club != null);

  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();
  int _load =20;
  int _load2 =20;
  int _load3 =20;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        setState(() {
          if(_load<10000)
          _load += 20;
        });
      }
    });
    _scrollController2.addListener((){
      if(_scrollController2.position.pixels == _scrollController2.position.maxScrollExtent){
        setState(() {
          if(_load2<10000)
          _load2 += 20;
        });
      }
    });
    _scrollController3.addListener((){
      if(_scrollController3.position.pixels == _scrollController3.position.maxScrollExtent){
        setState(() {
          if(_load3<10000)
          _load3 += 20;
        });
      }
    });

    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.minScrollExtent){
        setState(() {
          _load = 20;
        });
      }
    });
    _scrollController2.addListener((){
      if(_scrollController2.position.pixels == _scrollController2.position.minScrollExtent){
        setState(() {
          _load2 = 20;
        });
      }
    });
    _scrollController3.addListener((){
      if(_scrollController3.position.pixels == _scrollController3.position.minScrollExtent){
        setState(() {
          _load3 = 20;
        });
      }
    });
  }

  @override
  void dispose() { 
    _tabController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }
  
  void _downloadFile(String url, String filename) async {
    Dio dio = Dio();
    var dir = await getExternalStorageDirectory();
    try {
      await dio.download(url, "${dir.path}/Download/$filename.pdf",
        onProgress: (rec, total) {
          // print("Rec: $rec , Total: $total");

          setState(() {
            downloading = true;
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
        }
      );
    } catch (e) {
      // print(e + "failed");
    }
    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    // print("${dir.path}/Download/$filename.pdf Download completed");
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("$filename.pdf"+" 다운로드 완료"),
      duration: Duration(seconds: 1),));
  }

  Card returnCard(DocumentSnapshot doc){
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
              onPressed: ()=>
                _downloadFile(doc.data['file'],doc.data['fileName'])
              ,
            ),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text("삭제", style:TextStyle(
                  color: Colors.red
                )),
                onPressed: ()=>showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text("게시물 삭제"),
                      content: Text("삭제된 게시물은 복구 할 수 없습니다."),
                      actions: <Widget>[
                        RaisedButton(
                          child: Text("삭제", style: TextStyle(color: Colors.white),),
                          color: Colors.red,
                          onPressed: (){
                            Navigator.pop(context);
                            FirebaseStorage.instance.ref().child('club/${club.documentID}/run/${_tabController.index}/${doc.data['fileName']}').delete();
                            Firestore.instance.collection('clubs').document(club.documentID).collection('run').document(doc.documentID).delete();
                          },
                        ),
                        FlatButton(
                          child: Text("취소", style:TextStyle(color: Colors.red)),
                          onPressed: (){
                            Navigator.pop(context);
                          },
                        )
                      ],
                    );
                  }
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: Stack(
        children: <Widget>[
          TabBarView(
            controller: _tabController,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 0).limit(_load).snapshots(),
                builder: (context,snapshots){
                  if(!snapshots.hasData)return LinearProgressIndicator();
                  return ListView(
                    controller: _scrollController,
                    children: snapshots.data.documents.map((doc){
                      return returnCard(doc);
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 1).limit(_load2).snapshots(),
                builder: (context,snapshots){
                  if(!snapshots.hasData)return LinearProgressIndicator();
                  return ListView(
                    controller: _scrollController2,
                    children: snapshots.data.documents.map((doc){
                      return returnCard(doc);
                    }).toList(),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 2).limit(_load3).snapshots(),
                builder: (context,snapshots){
                  if(!snapshots.hasData)return LinearProgressIndicator();
                  return ListView(
                    controller: _scrollController3,
                    children: snapshots.data.documents.map((doc){
                      return returnCard(doc);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          downloading?Center(
            child: Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Downloading File: $progressString",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ):SizedBox(),
        ],
      )
    );
  }
}