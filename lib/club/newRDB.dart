import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

import 'package:project_club2/global/currentUser.dart' as cu;

class CustomFile{
  File file;
  String name = "";
}

class CreateDataPage extends StatefulWidget {
  final DocumentSnapshot data;
  final int index;
  CreateDataPage({Key key, @required this.data, @required this.index})
    : assert(data != null),
    super(key: key);
  _CreateDataPageState createState() => _CreateDataPageState(club: data, index: index);
}

class _CreateDataPageState extends State<CreateDataPage> {
  DocumentSnapshot club;
  int index;
  _CreateDataPageState({Key key, @required this.club, @required this.index})
    : assert(club != null);
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  // TextEditingController _fileNameController = TextEditingController();
  List<String> _types = ["인수인계","활동일지","회계"].toList();
  String selected = "";
  File upload;
  // List<CustomFile> _files = List();
  @override
  void initState() {
    selected = _types.elementAt(index);
    super.initState();
  }
  @override
  void dispose() {
    upload.delete();
    _name.dispose();
    _description.dispose();
    // _fileNameController.dispose();
    super.dispose();
  }

  void _openFileExplorer() async {
    // CustomFile upload = new CustomFile();
    String  _path = await FilePicker.getFilePath(type: FileType.PDF);
    if (!mounted) return;
    setState(() {
      upload = File(_path);
    });
    // upload.file = File(_path);
    // upload.name = "클릭해서 파일이름을 변경해주세요";
    // setState(() {
    //   _files.add(upload);
    // });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새 파일 업로드"),
        centerTitle: true, 
        actions: <Widget>[
          FlatButton(
            child: Text("업로드"),
            onPressed: ()async{
              if(upload != null){
                // if(_fileNameController.text != ""){
                  Navigator.pop(context);
                  StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('club/${club.documentID}/run/$index/${_name.text}').putFile(upload);
                  String url = await (await uploadTask.onComplete).ref.getDownloadURL();
                  Firestore.instance.collection('clubs').document(club.documentID).collection('run').add({
                    "writer": cu.currentUser.getDisplayName(),
                    "uid": cu.currentUser.getUid(),
                    "photoUrl": cu.currentUser.getphotoUrl(),
                    "title": _name.text,
                    "created": DateTime.now(),
                    "description":_description.text,
                    "type": index,
                    "fileName": _name.text,
                    "file": url,
                  });
                // }
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
            },
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Text("제목:"),
              title: TextField(
                controller: _name,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "ex) 회장 인수인계\n",
                  helperText: "업로드할 파일의 이름이 됩니다."
                ),
              ),
              trailing: DropdownButton(
                value: selected,
                items: <DropdownMenuItem>[
                  DropdownMenuItem(
                    value: "인수인계",
                    child: Text("인수인계"),),
                  DropdownMenuItem(
                    value: "활동일지",
                    child: Text("활동일지"),),
                  DropdownMenuItem(
                    value: "회계",
                    child: Text("회계"),),
                ], 
                onChanged: (value) {
                  setState(() {
                    selected = value;
                    switch(selected){
                      case "인수인계":
                        index = 0;
                        break;
                      case "활동일지":
                      index = 1;
                      break;
                      case "회계":
                      index=2;
                      break;
                    }
                  });
                },
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Text("설명"),
              title: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: TextField(
                  controller: _description,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "ex) 회장 인수인계에 대한 자세한 설명이 되어있다.",
                  ),
                ),
              )
            ),
          ),
          Card(
            child: ExpansionTile(
              leading: Text("파일:"),
              title: Text("PDF파일형식만 지원합니다"),
              children: <Widget>[
                // upload==null?SizedBox():Text(upload.path),
                upload==null?SizedBox():
                ListTile(
                  leading: Icon(Icons.file_upload),
                  title: Text(_name.text + ".pdf"),
                  // TextField(
                  //   controller: _fileNameController,
                  //   decoration: InputDecoration(
                  //     hintText: "ex) 2018-2 결산",
                  //     helperText: "파일이름을 입력해주세요"
                  //   ),
                  // ),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: (){
                      setState(() {
                        upload = null;
                      });
                    },
                  ),
                ),
                upload==null?ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text("파일추가"),
                      onPressed: ()=>_openFileExplorer(),
                    )
                  ],
                ):SizedBox(),
              ],
            ),
          ),
        ],
      )
    );
  }
}