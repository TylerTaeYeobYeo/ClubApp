import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:path_provider/path_provider.dart';

class PersonalPage extends StatefulWidget {
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {

  ScrollController _scrollController = ScrollController();
  TextEditingController _phone =TextEditingController();
  
  void initState() { 
    super.initState();
    if(cu.currentUser.getPhoneNumber()!=null){
      _phone.text = cu.currentUser.getPhoneNumber();
    }
  }
  @override
  void dispose() { 
    _phone.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  Widget colorButton(Color color, String clr){
    return FlatButton(
      child: Container(
        padding: EdgeInsets.all(0.0),
        width: 30.0,
        height: 30.0,
        // color: color,
        decoration: BoxDecoration(
          border: (cu.currentUser.userColor == color&&clr!="")?Border.all(width: 4.0,color:Colors.black):Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(50.0),
          color: color,
        ),
      ),
      onPressed: ()async{
        // dynamic position = _scrollController.position;
        setState(() {
          cu.currentUser.userColor = color;
          // _scrollController.jumpTo(position);
        });
        final dir = await getApplicationDocumentsDirectory();
        File file = File(dir.path + "/color.json");
        Map<String,String> input = {"selected": clr};
        file.writeAsStringSync(json.encode(input));
        // Map<String, dynamic> jsonResult = json.decode(file.readAsStringSync());
        // print(jsonResult);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();
    return Scaffold(
      key: key,
      appBar: AppBar(
        centerTitle: true,
        title: Text("설정"),
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
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
                      initiallyExpanded: true,
                      title: Text("테마 색상 변경"),
                      children: <Widget>[
                        ListTile(
                          leading: Text("선택된 색상: "),
                          title: colorButton(cu.currentUser.userColor, ""),
                        ),
                        Divider(),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20.0),
                          height: 30.0,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              colorButton(Colors.red, "red"),
                              colorButton(Colors.deepOrange, "deepOrange"),
                              colorButton(Colors.orange, "orange"),
                              colorButton(Colors.amber, "amber"),
                              colorButton(Colors.yellow, "yellow"),
                              colorButton(Colors.lime, "lime"),
                              colorButton(Colors.lightGreen, "lightGreen"),
                              colorButton(Colors.green, "green"),
                              colorButton(Colors.teal, "teal"),
                              colorButton(Colors.blueGrey, "blueGrey"),
                              colorButton(Colors.grey, "grey"),
                              colorButton(Colors.cyan, "cyan"),
                              colorButton(Colors.lightBlue, "lightBlue"),
                              colorButton(Colors.blue, "blue"),
                              colorButton(Colors.indigo, "indigo"),
                              colorButton(Colors.deepPurple, "deepPurple"),
                              colorButton(Colors.purple, "purple"),
                              colorButton(Colors.pink, "pink"),
                              
                            ],
                          ),
                        ),
                        Divider(),
                        ListTile(
                          leading: Icon(Icons.help,color:Theme.of(context).primaryColor),
                          title: Text("스크롤해서 원하는 색상을 선택해주세요", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                        ),
                        ListTile(
                          leading: Icon(Icons.warning,color:Theme.of(context).primaryColor),
                          title: Text("새로운 테마색상은 재시작시 적용됩니다.", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                        )
                      ],
                    ),
                    Divider(),
                    ListTile(
                      title: Text("푸쉬 알림허용"),
                      trailing: Switch(
                        onChanged: (s){},
                        value: true,
                      ),
                    ),
                  ],
                )
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    ExpansionTile(
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
                                  // trailing: Text(data.data['type']),
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
                    ExpansionTile(
                      // initiallyExpanded: true,
                      title: Text("로그인정보"),
                      children: <Widget>[
                        // ListTile(
                        //   trailing: Text("프로필 이미지 변경은 정보제공처에서 부탁드립니다",style: TextStyle(color: Theme.of(context).primaryColorDark),),
                        // ),
                        ListTile(
                          leading: Icon(Icons.image, color:Theme.of(context).primaryColorDark),
                          title: Text("프로필 이미지"),
                          trailing: CircleAvatar(
                            backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                          ),
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (context){
                                return SimpleDialog(
                                  title: Text("프로필 이미지"),
                                  children: <Widget>[
                                    ListTile(
                                      leading: Text("url:"),
                                      title: Text(cu.currentUser.getphotoUrl()),
                                    ),
                                    ListTile(
                                      leading: Text("안내:"),
                                      title: Text("프로필이미지 변경은 정보 제공처에서 부탁드립니다."),
                                    )
                                  ],
                                );
                              }
                            );
                          },
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
                          onTap: (){
                            showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Text("전화번호 변경"),
                                  content: TextField(
                                    controller: _phone,
                                    maxLength: 13,
                                    decoration: InputDecoration(
                                      hintText: "ex) 010-1234-5678",
                                      helperText: "-를 포함해서 전화번호를 입력해주세요"
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text("취소"),
                                      onPressed: (){
                                        Navigator.pop(context);
                                        if(cu.currentUser.getPhoneNumber != null)_phone.text = cu.currentUser.getPhoneNumber();
                                        else _phone.clear();
                                      }
                                    ),
                                    RaisedButton(
                                      child: Text("확인",style: TextStyle(color: Colors.white),),
                                      onPressed: (){
                                        Navigator.pop(context);
                                        String number = _phone.text;
                                        Firestore.instance.collection('users').document(cu.currentUser.getUid()).updateData({
                                          "phoneNumber": number,
                                        });
                                        cu.currentUser.setPhoneNumber(_phone.text);
                                      },
                                    )
                                  ],
                                );
                              }
                            );
                          },
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
                    ),
                    ExpansionTile(
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
                  ],
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}