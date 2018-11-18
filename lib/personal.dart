import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:project_club2/global/currentUser.dart' as cu;

class PersonalPage extends StatefulWidget {
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  Text _level(int level){
    switch(level){
      case 3:
        return Text("동아리 임원");
        break;
      case 2: 
        return Text("동아리 회원");
        break;
      default: return Text("오류");
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        title: Text("개인정보"),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          ListView(
            children: <Widget>[
              Card(
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text("가입 동아리"),
                  children: <Widget>[
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').snapshots(),
                      builder: (context, snapshots){
                        if(!snapshots.hasData) return LinearProgressIndicator();
                        return Column(
                          children: snapshots.data.documents.map((data){
                            return ExpansionTile(
                              leading: CircleAvatar(backgroundImage: NetworkImage(data.data['image'])), 
                              title: Text(data.data['name']),
                              trailing: Text(data.data['type']),
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.face,color: Theme.of(context).primaryColor),
                                  title: Text("직위"),
                                  trailing: _level(data.data['level']),
                                ),
                                ListTile(
                                  leading: Icon(Icons.date_range,color: Theme.of(context).primaryColor,),
                                  title: Text("가입일"),
                                  trailing: Text(data.data['date'].toString()),
                                ),
                                FlatButton(
                                  child: Text("탈퇴하기", style: TextStyle(color: Colors.red),),
                                  onPressed: (){
                                    showDialog(
                                      context: context,
                                      builder: (context){
                                        return AlertDialog(
                                          title: ListTile(
                                            leading: CircleAvatar(backgroundImage: NetworkImage(data.data['image'])), 
                                            title: Text(data.data['name']),
                                            trailing: Text(data.data['type'],style: TextStyle(fontSize: 12.0),),
                                          ),
                                          content: Container(
                                            padding: EdgeInsets.all(20.0),
                                            child: RichText(
                                              text: TextSpan(
                                                text: data.data['name'],
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                    text: "를 탈퇴하시겠습니까?",
                                                    style: TextStyle(fontWeight: FontWeight.normal),
                                                  ),
                                                ]
                                              ),
                                            ),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("취소"),
                                              onPressed: ()=>Navigator.pop(context),
                                            ),
                                            RaisedButton(
                                              child: Text("탈퇴",style: TextStyle(color:Colors.white),),
                                              color: Theme.of(context).primaryColor,
                                              onPressed: (){
                                                Navigator.pop(context);
                                                Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').document(data.documentID).delete();
                                                Firestore.instance.collection('clubs').document(data.documentID).collection('users').document(cu.currentUser.getUid()).delete();
                                              }
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    )
                  ],
                ),
              ),
              Card(
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text("로그인정보"),
                  children: <Widget>[
                    ListTile(
                      trailing: Text("개인정보 변경은 정보제공처에서 부탁드립니다",style: TextStyle(color: Theme.of(context).primaryColorDark),),
                    ),
                    ListTile(
                      leading: Icon(Icons.image, color:Theme.of(context).primaryColorDark),
                      title: Text("프로필 이미지"),
                      trailing: CircleAvatar(
                        backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                      ),
                      onLongPress: (){
                        Clipboard.setData(ClipboardData(text: cu.currentUser.getphotoUrl()));
                        key.currentState.showSnackBar(
                          new SnackBar(content: new Text("이미지 주소가 복사되었습니다."),));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.tag_faces,color:Theme.of(context).primaryColorDark),
                      title: Text("이름"),
                      trailing: Text(cu.currentUser.getDisplayName()),
                      onLongPress: (){
                        Clipboard.setData(ClipboardData(text: cu.currentUser.getDisplayName()));
                        key.currentState.showSnackBar(
                          new SnackBar(content: new Text("이름이 복사되었습니다."),));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.call,color:Theme.of(context).primaryColorDark),
                      title: Text("전화번호"),
                      trailing: Text(cu.currentUser.getPhoneNumber().toString()),
                      onLongPress: (){
                        Clipboard.setData(ClipboardData(text: cu.currentUser.getPhoneNumber().toString()));
                        key.currentState.showSnackBar(
                          new SnackBar(content: new Text("전화번호가 복사되었습니다."),));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.mail,color:Theme.of(context).primaryColorDark),
                      title: Text("email"),
                      trailing: Text(cu.currentUser.getEmail()),
                      onLongPress: (){
                        Clipboard.setData(ClipboardData(text: cu.currentUser.getEmail()));
                        key.currentState.showSnackBar(
                          new SnackBar(content: new Text("이메일이 복사되었습니다."),));
                      }
                    ),
                  ],
                )
              ),
              Card(
                child: ExpansionTile(
                  title: Text("회원 탈퇴"),
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.delete_forever,color: Colors.red,),
                      title: Text("회원 탈퇴를 하시게 되시면 가입한 모든 동아리에서도 탈퇴하게 되며 복구 되지 않습니다."),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text("탈퇴하기", style: TextStyle(color: Colors.red),),
                          onPressed: ()async{
                            showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                                    ),
                                    title: Text(cu.currentUser.getDisplayName()),
                                  ),
                                  content: Container(
                                    padding: EdgeInsets.all(20.0),
                                    child: RichText(
                                      text:TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        children: [
                                          TextSpan(text: cu.currentUser.getDisplayName(),style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "님의 모든 정보를 "),
                                          TextSpan(text: "삭제",style: TextStyle(color: Colors.red)),
                                          TextSpan(text: "하며 가입된 모든 동아리에서도 "),
                                          TextSpan(text: "탈퇴",style: TextStyle(color: Colors.red)),
                                          TextSpan(text: "합니다. 또한 탈퇴 후 모든 정보는 "),
                                          TextSpan(text: "복구",style: TextStyle(color: Colors.red)),
                                          TextSpan(text: "가 불가능 합니다."),
                                        ]
                                      ),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ButtonBar(
                                      children: <Widget>[
                                        RaisedButton(
                                          child: Text("탈퇴",style: TextStyle(color: Colors.white),),
                                          color: Theme.of(context).primaryColor,
                                          onPressed: ()async{
                                            String id = cu.currentUser.getUid();
                                            Navigator.popUntil(context, ModalRoute.withName('/login'));

                                            QuerySnapshot doc = await Firestore.instance.collection('clubs').getDocuments();
                                            doc.documents.forEach((club){
                                              Firestore.instance.collection('clubs').document(club.documentID).collection('users').document(id).delete();
                                            });
                                            QuerySnapshot doc2 = await Firestore.instance.collection('users').document(id).collection('clubs').getDocuments();
                                            doc2.documents.forEach((club){
                                              Firestore.instance.collection('users').document(id).collection('clubs').document(club.documentID).delete();
                                            });
                                            Firestore.instance.collection('users').document(id).delete();
                                            cu.currentUser.googleLogOut();
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
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}