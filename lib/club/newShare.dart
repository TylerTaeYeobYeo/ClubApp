import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_club2/global/currentUser.dart' as cu;

class NewSharePage extends StatefulWidget {
  final DocumentSnapshot club;
  NewSharePage({@required this.club}):assert(club != null);
  _NewSharePageState createState() => _NewSharePageState(club: club);
}

class _NewSharePageState extends State<NewSharePage> {
  File _upload;
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();

  final DocumentSnapshot club;
  _NewSharePageState({@required this.club}):assert(club != null);
  
  void _openFileExplorer() async {
    String  _path = await FilePicker.getFilePath(type: FileType.PDF);
    if (!mounted) return;
    setState(() {
      _upload = File(_path);
    });
  }

  @override
  void dispose() { 
    _name.dispose();
    _description.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("파일 공유하기"),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text("업로드"),
            onPressed: ()async{
              if(_upload != null){
                if(_name.text != ""){
                  Navigator.pop(context);
                  StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('club/${club.documentID}/share/${_name.text}').putFile(_upload);
                  String url = await (await uploadTask.onComplete).ref.getDownloadURL();
                  Firestore.instance.collection('clubs').document(club.documentID).collection('share').add({
                    "writer": cu.currentUser.getDisplayName(),
                    "uid": cu.currentUser.getUid(),
                    "photoUrl": cu.currentUser.getphotoUrl(),
                    "title": _name.text,
                    "created": DateTime.now(),
                    "description":_description.text,
                    "fileName": _name.text,
                    "file": url,
                  });
                }
              }
              else{
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: Text("파일 오류"),
                      content: Text("파일이 없거나 이름이 없습니다."),
                    );
                  }
                );
              }
            }
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                      ),
                      title: Text(cu.currentUser.getDisplayName()),
                      subtitle: Text(DateFormat.yMd().add_jm().format(DateTime.now().toLocal())),
                    ),
                    Divider(),
                    _upload==null?ListTile(
                      leading: Icon(Icons.folder),
                      title: Text("현재 PDF파일만 지원합니다."),
                      trailing: FlatButton(
                        child: Text("파일 선택"),
                        onPressed: ()=>_openFileExplorer(),
                      ),
                      onTap: ()=>_openFileExplorer(),
                    ):Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListTile(
                          leading: Text("파일명"),
                          title: Text(_name.text + ".pdf"),
                        ),
                        ListTile(
                          leading: Icon(Icons.folder),
                          title: TextField(
                            controller: _name,
                            decoration: InputDecoration(
                              hintText: "파일 이름을 입력해주세요",
                              helperText: "확장명없이 입력해주세요"
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.description),
                      title: Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: TextField(
                          controller: _description,
                          decoration: InputDecoration(
                            hintText: "ex) 로고 벡터 파일",
                            helperText: "파일에 대한 부연설명을 입력해주세요"
                          ),
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                        )
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      )
      
      
    );
  }
}