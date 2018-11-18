import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:project_club2/club/request.dart';
import 'package:project_club2/club/members.dart';
import 'package:project_club2/club/leaders.dart';

class ClubSettingPage extends StatefulWidget {
  final DocumentSnapshot data;
  ClubSettingPage({Key key, @required this.data})
    : assert(data != null);
  _ClubSettingPageState createState() => _ClubSettingPageState(data: data);
}

class _ClubSettingPageState extends State<ClubSettingPage> {
  final DocumentSnapshot data;
  _ClubSettingPageState({Key key, @required this.data})
    : assert(data != null);
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("임원단 메뉴"),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
            ),
            ListView(
              children: <Widget>[
                Card(
                  child:ExpansionTile(
                    leading: Icon(Icons.menu, color: Theme.of(context).primaryColor),
                    title: Text("동아리 관리"),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.settings, color: Theme.of(context).primaryColorLight),
                        title: Text("정보 수정"),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.white70,
                  child:ExpansionTile(
                    initiallyExpanded: true,
                    leading: Icon(Icons.new_releases, color: Theme.of(context).primaryColor),
                    title: Text("리쿠르팅"),
                    trailing: Switch(
                      value: data.data['adv'],
                      onChanged: (bool value) {
                        setState(() {
                          data.data['adv'] = value;
                          Firestore.instance.collection('clubs').document(data.documentID).updateData({
                            "adv": value,
                          });
                        });
                      },
                    ),
                    children: <Widget>[
                      ListTile(
                        title: Text("활성화 시 동아리 가입신청을 받을 수 있습니다."),
                      )
                    ],
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: true,
                    leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
                    title: Text("동아리원 관리"),
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.new_releases, color: Theme.of(context).primaryColorLight),
                        title: Text("새로운 가입신청"),
                        onTap: ()=>Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context) => RequestPage(data: data),
                          )
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.face, color: Theme.of(context).primaryColorLight),
                        title: Text("임원단 관리"),
                        onTap: ()=>Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context) => LeadersPage(data: data),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.tag_faces, color: Theme.of(context).primaryColorLight),
                        title: Text("회원 관리"),
                        onTap: ()=>Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context) => MembersPage(data: data),
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  color: Colors.white70,
                  child: ExpansionTile(
                    leading: Icon(Icons.delete, color: Theme.of(context).primaryColor,),
                    title: Text("동아리 패쇄"),
                    children: <Widget>[
                      ListTile(
                        title: RichText(
                          text:TextSpan(
                            text: "동아리를 ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(text: "삭제",style: TextStyle(color: Colors.red)),
                              TextSpan(text: "하시면 "),
                              TextSpan(text: "복구",style: TextStyle(color: Colors.red)),
                              TextSpan(text: "가 되지 않습니다."),
                            ]
                          ),
                        ),
                      ),
                      FlatButton(
                        child: Text("패쇄",style: TextStyle(color: Colors.red),),
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (context){
                              return AlertDialog(
                                title: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(data.data['image']),
                                  ),
                                  title: Text(data.data['name']),
                                  subtitle: Text(data.data['created'].toString()),
                                  trailing: Text(data.data['type'],style: TextStyle(fontSize: 12.0),),
                                ),
                                content: Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: RichText(
                                    text:TextSpan(
                                      style: TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(text: data.data['name'],style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: "를 "),
                                        TextSpan(text: "패쇄",style: TextStyle(color: Colors.red)),
                                        TextSpan(text: "하시면 "),
                                        TextSpan(text: "복구",style: TextStyle(color: Colors.red)),
                                        TextSpan(text: "하실 수 없습니다."),
                                      ]
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  ButtonBar(
                                    children: <Widget>[
                                      RaisedButton(
                                        child: Text("삭제",style: TextStyle(color: Colors.white),),
                                        color: Theme.of(context).primaryColor,
                                        onPressed: ()async{
                                          Navigator.popUntil(context, ModalRoute.withName('/home'));
                                          FirebaseStorage.instance.ref().child('clubs/background/${data.documentID}').delete();
                                          QuerySnapshot doc = await Firestore.instance.collection('users').getDocuments();
                                          doc.documents.forEach((user){
                                            Firestore.instance.collection('users').document(user.documentID).collection('clubs').document(data.documentID).delete();
                                          });
                                          Firestore.instance.collection('clubs').document(data.documentID).delete();
                                        },
                                      ),
                                      FlatButton(
                                        child: Text("취소"),
                                        onPressed: ()=>Navigator.pop(context),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),  
          ],
        )
      ),
    );
  }
}