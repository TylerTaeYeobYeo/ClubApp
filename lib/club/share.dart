import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_club2/club/newShare.dart';
import 'package:project_club2/global/currentUser.dart' as cu;

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

class ShareFilePage extends StatefulWidget {
  final DocumentSnapshot club;
  ShareFilePage({@required this.club}):assert(club != null);
  _ShareFilePageState createState() => _ShareFilePageState(club: club);
}

class _ShareFilePageState extends State<ShareFilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Search first = Search();
  ScrollController _scrollController = ScrollController();
  int _load =20;
  bool downloading = false;
  TextEditingController _description = TextEditingController();
  String progressString = "Loading";
  final DocumentSnapshot club;
  _ShareFilePageState({@required this.club}):assert(club != null);

  @override
  void initState() {
    first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('share').limit(_load).snapshots();
    _scrollController.addListener((){
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        setState(() {
          if(_load<10000)
          _load += 20;
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
    super.initState();
  }

  @override
  void dispose() {
    _description.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Card returnCard(DocumentSnapshot doc){
    return Card(
      key: ValueKey(doc.documentID),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.description, color: Theme.of(context).primaryColor,),
            title: Text(doc.data['fileName']+".pdf"),
            subtitle: Text(DateFormat.yMd().add_jm().format(doc.data['created'])),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor), 
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
                ];
              },
              onSelected: (s){
                _description.text = doc.data['description'];
                switch(s){
                  case "수정":
                    fixFile(doc);
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
            subtitle: Text("작성자"),
            trailing: (doc.data['uid']==cu.currentUser.getUid()||cu.currentUser.club.getLevel()==3)?IconButton(
              icon: Icon(Icons.delete),
              color: Theme.of(context).primaryColor,
              onPressed: ()=>deleteFile(doc),
            ):SizedBox(),
          ),
        ],
      )
    );
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
                Firestore.instance.collection('clubs').document(club.documentID).collection('share').document(doc.documentID).updateData({
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
                FirebaseStorage.instance.ref().child('club/${club.documentID}/share/${doc.data['fileName']}').delete();
                Firestore.instance.collection('clubs').document(club.documentID).collection('share').document(doc.documentID).delete();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
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
                      if(first._search.text =="") first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('share').limit(_load).snapshots();
                      else {
                        _load = 20;
                        first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('share').where("title", isGreaterThanOrEqualTo: first.startcode).where("title", isLessThan: first.endcode).orderBy("title").limit(_load).snapshots();
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
                      if(first._search.text =="") first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('share').limit(_load).snapshots();
                      else {
                        _load = 20;
                        first.term = Firestore.instance.collection('clubs').document(club.documentID).collection('share').where("title", isGreaterThanOrEqualTo: first.startcode).where("title", isLessThan: first.endcode).orderBy("title").limit(_load).snapshots();
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
                builder: (context, snapshots){
                  if(!snapshots.hasData)return LinearProgressIndicator(); 
                  return Column(
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
      ),
    );
  }
}