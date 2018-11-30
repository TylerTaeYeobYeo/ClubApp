 /* 
  * 운영자료
  */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_club2/club/newRDB.dart';
import 'package:dio/dio.dart';

class Search{
  TextEditingController _search = TextEditingController();
  Stream<QuerySnapshot> term;
  String strSearch = "a";
  int strlength;
  var strFrontCode;
  String strEndCode;
  String startcode;
  String endcode;
}

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
  var progressString = "Loading";
  TextEditingController _description =TextEditingController();
  _DatabasePageState({Key key, @required this.club})
    : assert(club != null);

  Search first = Search();
  Search second = Search();
  Search third = Search();

  ScrollController _scrollController = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();
  int _load =20;
  int _load2 =20;
  int _load3 =20;
  @override
  void initState() {
    first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 0).limit(_load).snapshots();
    second.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 1).limit(_load2).snapshots();
    third.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 2).limit(_load3).snapshots();
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
    first._search.dispose();
    second._search.dispose();
    _description.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }
  
  void _downloadFile(String url, String filename) async {
    setState((){
      downloading = true;
    });
    Dio dio = Dio();
    var dir = await getExternalStorageDirectory();
    try {
      await dio.download(url, "${dir.path}/Download/$filename.pdf",
        onProgress: (rec, total) {
          // print("Rec: $rec , Total: $total");

          setState(() {
            // downloading = true;
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
        }
      );
    } catch (e) {
      // print(e + "failed");
    }
    setState(() {
      downloading = false;
      progressString = "Loading";
    });
    // print("${dir.path}/Download/$filename.pdf Download completed");
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("$filename.pdf"+" 다운로드 완료"),
      duration: Duration(seconds: 1),));
  }

  void fixFile(DocumentSnapshot doc){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("설명 수정"),
          content: TextField(
            controller: _description,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "",
              helperText: "파일에 대해 구체저으로 적어주세요"
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              child: Text("확인", style: TextStyle(color: Colors.white),),
              color: Theme.of(context).primaryColor,
              onPressed: (){
                Navigator.pop(context);
                Firestore.instance.collection('clubs').document(club.documentID).collection('run').document(doc.documentID).updateData({
                  "description": _description.text
                });
              },
            ),
            FlatButton(
              child: Text("취소", style:TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  void deleteFile(DocumentSnapshot doc){
    showDialog(
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
    );
  }

  Card returnCard(DocumentSnapshot doc){
    return Card(
      key: ValueKey(doc.documentID),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.description, color: Theme.of(context).primaryColor,),
            title: Text(doc.data['fileName']+".pdf",),
            subtitle: Text(DateFormat.yMd().add_jm().format(doc.data['created'])),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor,), 
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: "다운로드",
                    child: Text("다운로드"),
                  ),
                  PopupMenuItem(
                    value: "수정",
                    child: Text("수정"),
                  ),
                  PopupMenuItem(
                    value: "삭제",
                    child: Text("삭제"),
                  ),
                ];
              },
              onSelected: (s){
                _description.text = doc.data['description'];
                switch(s){
                  case "수정":
                    fixFile(doc);
                    break;
                  case "삭제":
                    deleteFile(doc);
                    break;
                  case "다운로드":
                    _downloadFile(doc.data['file'],doc.data['fileName']);
                  break;    
                }
              },
            ),
            onTap: ()=>_downloadFile(doc.data['file'],doc.data['fileName']),
          ),
          ListTile(
            title: Text(doc.data['description']),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(doc.data['photoUrl']),
            ),
            title: Text(doc.data['writer']),
            subtitle: Text("작성자",style: TextStyle(color: Theme.of(context).primaryColorLight),),
          ),
        ],
      )
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
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          TabBarView(
            controller: _tabController,
            children: <Widget>[
              ListView(
                controller: _scrollController,
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Text("검색"),
                      title: TextField(
                        controller: first._search,
                        maxLength: 30,
                        onChanged: (s){
                          setState(() {
                            if(first._search.text =="") first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 0).limit(_load).snapshots();
                            else {
                              _load = 20;
                              first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: first.startcode).where("title", isLessThan: first.endcode).where("type", isEqualTo: 0).orderBy("title").limit(_load).snapshots();
                              first.strSearch = first._search.text;
                              first.strlength = first.strSearch.length;
                              first.strFrontCode = first.strSearch.substring(0, first.strlength-1);
                              first.strEndCode = first.strSearch.substring(first.strlength-1, first.strSearch.length);
                              first.startcode = first.strSearch;
                              first.endcode= first.strFrontCode + String.fromCharCode(first.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                        onPressed: (){
                          setState(() {
                            if(first._search.text =="") first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 0).limit(_load).snapshots();
                            else {
                              _load = 20;
                              first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: first.startcode).where("title", isLessThan: first.endcode).where("type", isEqualTo: 0).orderBy("title").limit(_load).snapshots();
                              first.strSearch = first._search.text;
                              first.strlength = first.strSearch.length;
                              first.strFrontCode = first.strSearch.substring(0, first.strlength-1);
                              first.strEndCode = first.strSearch.substring(first.strlength-1, first.strSearch.length);
                              first.startcode = first.strSearch;
                              first.endcode= first.strFrontCode + String.fromCharCode(first.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: first.term,
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return LinearProgressIndicator();
                      return Column(
                        children: snapshots.data.documents.map((doc){
                          return returnCard(doc);
                        }).toList(),
                      );
                    },
                  )
                ],
              ),
              ListView(
                controller: _scrollController2,
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Text("검색"),
                      title: TextField(
                        controller: second._search,
                        maxLength: 30,
                        onChanged: (s){
                          setState(() {
                            if(second._search.text =="") second.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 1).limit(_load2).snapshots();
                            else {
                              _load2 = 20;
                              second.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: second.startcode).where("title", isLessThan: second.endcode).where("type", isEqualTo: 1).orderBy("title").limit(_load2).snapshots();
                              second.strSearch = second._search.text;
                              second.strlength = second.strSearch.length;
                              second.strFrontCode = second.strSearch.substring(0, second.strlength-1);
                              second.strEndCode = second.strSearch.substring(second.strlength-1, second.strSearch.length);
                              second.startcode = second.strSearch;
                              second.endcode= second.strFrontCode + String.fromCharCode(second.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                        onPressed: (){
                          setState(() {
                            if(second._search.text =="") second.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 1).limit(_load2).snapshots();
                            else {
                              _load2 = 20;
                              second.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: second.startcode).where("title", isLessThan: second.endcode).where("type", isEqualTo: 1).orderBy("title").limit(_load2).snapshots();
                              second.strSearch = second._search.text;
                              second.strlength = second.strSearch.length;
                              second.strFrontCode = second.strSearch.substring(0, second.strlength-1);
                              second.strEndCode = second.strSearch.substring(second.strlength-1, second.strSearch.length);
                              second.startcode = second.strSearch;
                              second.endcode= second.strFrontCode + String.fromCharCode(second.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: second.term,
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return LinearProgressIndicator();
                      return Column(
                        children: snapshots.data.documents.map((doc){
                          return returnCard(doc);
                        }).toList(),
                      );
                    },
                  )
                ],
              ),
              ListView(
                controller: _scrollController3,
                children: <Widget>[
                  Card(
                    child: ListTile(
                      leading: Text("검색"),
                      title: TextField(
                        controller: third._search,
                        maxLength: 30,
                        onChanged: (s){
                          setState(() {
                            if(third._search.text =="") third.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 2).limit(_load3).snapshots();
                            else {
                              _load3 = 20;
                              third.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: third.startcode).where("title", isLessThan: third.endcode).where("type", isEqualTo: 2).orderBy("title").limit(_load3).snapshots();
                              third.strSearch = third._search.text;
                              third.strlength = third.strSearch.length;
                              third.strFrontCode = third.strSearch.substring(0, third.strlength-1);
                              third.strEndCode = third.strSearch.substring(third.strlength-1, third.strSearch.length);
                              third.startcode = third.strSearch;
                              third.endcode= third.strFrontCode + String.fromCharCode(third.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                        onPressed: (){
                          setState(() {
                            if(third._search.text =="") third.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("type", isEqualTo: 2).limit(_load3).snapshots();
                            else {
                              _load3 = 20;
                              third.term = Firestore.instance.collection('clubs').document(club.documentID).collection('run').where("title", isGreaterThanOrEqualTo: third.startcode).where("title", isLessThan: third.endcode).where("type", isEqualTo: 2).orderBy("title").limit(_load3).snapshots();
                              third.strSearch = third._search.text;
                              third.strlength = third.strSearch.length;
                              third.strFrontCode = third.strSearch.substring(0, third.strlength-1);
                              third.strEndCode = third.strSearch.substring(third.strlength-1, third.strSearch.length);
                              third.startcode = third.strSearch;
                              third.endcode= third.strFrontCode + String.fromCharCode(third.strEndCode.codeUnitAt(0) + 1);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: third.term,
                    builder: (context,snapshots){
                      if(!snapshots.hasData)return LinearProgressIndicator();
                      return Column(
                        children: snapshots.data.documents.map((doc){
                          return returnCard(doc);
                        }).toList(),
                      );
                    },
                  )
                ],
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