import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_club2/club/statistic.dart';

class MembersPage extends StatefulWidget {
  final DocumentSnapshot data;
  MembersPage({Key key, @required this.data})
    : assert(data != null);
  _MembersPageState createState() => _MembersPageState(club:data);
}

class _MembersPageState extends State<MembersPage> {
  final DocumentSnapshot club;
  _MembersPageState({Key key, @required this.club})
    : assert(club != null);

  Future<Null> _clicked(data) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data.data["photoUrl"]),
            ),
            title: RichText(
              text: TextSpan(
                text: data.data['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                children: [
                  TextSpan(text: "님을 동아리에서 제외하시겠습니까?",
                    style: TextStyle(
                      fontWeight: FontWeight.normal
                    )
                  ),
                ]
              ),
            )
            // Text(data.data['name']+"님을 동아리에서 제외하시겠습니까?"),
            // trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey,fontSize: 12.0),),
          ),
          contentPadding: EdgeInsets.all(30.0),
          content: Text("*주의: 퇴출은 번복할 수 없습니다.*", style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold
          ),),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: ()=>Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("퇴출",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              disabledColor: Colors.grey,
              color: Colors.red,
              onPressed: ()async {
                Navigator.pop(context);
                Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.data['id']).delete();
              },
            ),
          ],
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원관리"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.insert_chart),
            onPressed: ()=>Navigator.push(context, 
              MaterialPageRoute(
                builder: (context) => AnalyzeUserPage(data: club,),
              )
            ),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('clubs').document(club.data['id']).collection('users').snapshots(),
            builder: (context, snapshots){
              return ListView(
                children: snapshots.data.documents.map((data){
                  bool value = data.data['level'] > 2;
                  return Card(
                    child:ExpansionTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(data.data['photoUrl']),
                      ),
                      title: Text(data.data['name']),
                      children: <Widget>[
                        SwitchListTile(
                          title: Text("임원단"), onChanged: (bool s) {
                            setState(() {
                              value = s;
                            });
                            if(s){
                              Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                                "level": 3,
                              });
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(data['name'] + "님이 임원단이 되었습니다."),
                                duration: Duration(milliseconds: 500),));
                            }
                            else {
                              Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                                "level": 2,
                              });
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(data['name'] + "님이 일반회원이 되었습니다."),
                                duration: Duration(milliseconds: 500),));
                            }
                          }, value: value,
                        ),
                        ExpansionTile(
                          title: Text("회원활동상태"),
                          children: <Widget>[
                            RadioListTile(
                              title: Text("활동"),
                              onChanged: (value){
                                Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                                  "state": value
                                });
                              },
                              value: 0,
                              groupValue: data.data['state'],
                            ),
                            RadioListTile(
                              title: Text("비활동/OB"),
                              onChanged: (value){
                                Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                                  "state": value
                                });
                              },
                              value: 1,
                              groupValue: data.data['state'],
                            ),
                            RadioListTile(
                              title: Text("졸업생"),
                              onChanged: (value){
                                Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(data.documentID).updateData({
                                  "state": value
                                });
                              },
                              value: 2,
                              groupValue: data.data['state'],
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Text("연락처"),
                          children: <Widget>[
                            ListTile(
                              title: Text("email:"),
                              trailing: Text(data.data['email']),
                            ),
                            ListTile(
                              title: Text("phoneNumber:"),
                              trailing: Text(data.data['phoneNumber'].toString()),
                            ),
                          ],
                        ),
                        ListTile(
                          title: Text("퇴출", style: TextStyle(color: Colors.red),),
                          onTap: ()=>_clicked(data),
                        ),
                      ],
                    )
                  );
                }).toList(),
              );
            },
          ),
        ],
      )      
    );
  }
}