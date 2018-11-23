import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class CreateDataPage extends StatefulWidget {
  final DocumentSnapshot data;
  int index;
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
  List<String> _types = ["인수인계","활동일지","회계"].toList();
  String selected = "";
  String _file;
  @override
    void initState() {
      selected = _types.elementAt(index);
      super.initState();
    }
  @override
  void dispose() { 
    _name.dispose();
    super.dispose();
  }

  void _openPDFfile()async{
    _file = await FilePicker.getFilePath(type: FileType.PDF);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("새 파일 업로드"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Text("제목:"),
              title: TextField(
                controller: _name,
                keyboardType: TextInputType.multiline,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText: "ex) 회장 인수인계",
                  helperText: "20자 이내로 작성해 주세요"
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
                  controller: _name,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "ex) 1번째 파일은 학부제출 서류\n       2번째 파일은 동아리제출 서류",
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
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text("업로드"),
                      onPressed: (){},
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}