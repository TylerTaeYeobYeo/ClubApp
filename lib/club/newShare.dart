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

  final DocumentSnapshot club;
  _NewSharePageState({@required this.club}):assert(club != null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("파일 공유하기"),
      ),
      body: ListView(
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
                Container(
                  height: MediaQuery.of(context).size.width/2,
                  child: Center(
                    child: FlatButton(
                      child: Text("업로드"),
                      onPressed: (){},
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "ex) 로고 파일",
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
    );
  }
}