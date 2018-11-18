import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:project_club2/global/currentUser.dart'as cu;

class NewClubPage extends StatefulWidget {
  _NewClubPageState createState() => _NewClubPageState();
}

class _NewClubPageState extends State<NewClubPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController _description = TextEditingController();
  TextEditingController _advertisement = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _type = TextEditingController();
  String text = "샘플 동아리 이름";
  bool adv = false;
  @override
  void dispose() { 
    _description.dispose();
    _advertisement.dispose();
    _name.dispose();
    _type.dispose();
    super.dispose();
  }
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: "입력한 정보를 토대로 추가합니다.",
        onPressed: (){
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                title: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: _image!=null?FileImage(_image):NetworkImage("http://image.sportsseoul.com/2018/01/02/news/2018010201000018800000491.jpg"),
                  ),
                  title: Text(text),
                ),
                content: Container(
                  height: MediaQuery.of(context).size.height*5/6,
                  width: MediaQuery.of(context).size.width*5/6,
                  child: ListView(
                    children: <Widget>[
                      ExpansionTile(
                        title: Text("배경이미지"),
                        children: <Widget>[
                          _image!=null?Image.file(_image):Image.network("http://image.sportsseoul.com/2018/01/02/news/2018010201000018800000491.jpg"),
                        ],
                      ),
                      ExpansionTile(
                        title: Text("동아리 소개글"),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: TextField(
                              controller: _description,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "동아리 소개글을 여기에 써주세요\nex) 1995년에 기계공학과 학생과 전산전자과 학생들이모여 설립한 친목 동아리입니다.",
                              ),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        title: Text("동아리 홍보글"),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: TextField(
                              controller: _advertisement,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "동아리 소개글을 여기에 써주세요\nex) 1995년에 기계공학과 학생과 전산전자과 학생들이모여 설립한 친목 동아리입니다.",
                              ),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text("리쿠르팅"),
                        trailing: Switch(
                          onChanged: (bool value) {
                            setState(() {
                              adv = value;
                            });
                          },
                          value: adv,
                        ),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: Text("이 기능을 키면 동아리를 생성하는 즉시 리쿠르팅이 시작합니다."),
                          )
                        ],
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text("어떤 동아리인가요?"),
                        children: <Widget>[
                          ListTile(
                            title: TextField(
                              maxLength: 10,
                              maxLines: 1,
                              controller: _type,
                              decoration: InputDecoration(
                                hintText: "ex) 음악/밴드",
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text("취소"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    child: Text("생성", style: TextStyle(color: Colors.black),),
                    color: Theme.of(context).primaryColor,
                    onPressed: ()async{
                      //check
                      if(_name.text ==""){
                        return ;
                      }
                      //do
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                      String id = Uuid().v1();
                      String image;
                      if(_image != null){
                        StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('clubs/background/$id').putFile(_image);
                        image = await (await uploadTask.onComplete).ref.getDownloadURL();
                      }
                      else image = "http://image.sportsseoul.com/2018/01/02/news/2018010201000018800000491.jpg";
                      Firestore.instance.runTransaction((Transaction transaction){
                        Firestore.instance.collection('clubs').document(id).setData({
                          "id": id,
                          "name": _name.text,
                          "description": _description.text,
                          "image": image,
                          "advertisement": _advertisement.text,
                          "adv": adv,
                          "type": _type.text,
                        });
                        Firestore.instance.collection('clubs').document(id).collection('users').document(cu.currentUser.getUid()).setData({
                          "id": cu.currentUser.getUid(),
                          "email": cu.currentUser.getEmail(),
                          "level": 3,
                          "name": cu.currentUser.getDisplayName(),
                          "phoneNumber":cu.currentUser.getPhoneNumber(),
                          "photoUrl":cu.currentUser.getphotoUrl(),
                        });
                        Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').document(id).setData({
                          "id": id,
                          "image": image,
                          "level":3,
                          "name": _name.text,
                          "type": _type.text
                        });
                      });
                    },
                  ),
                ],
              );
            }
          );
        },
      ),
      // drawer: _drawer(),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height /4,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: FlatButton(
                      child: Text(text,
                        style: TextStyle(
                          fontSize: 18.0,
                        )
                      ),
                      onPressed: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              title: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: _image!=null?FileImage(_image):NetworkImage("http://image.sportsseoul.com/2018/01/02/news/2018010201000018800000491.jpg"),
                                ),
                                title: Text(text),
                              ),
                              content: Container(
                                child: TextField(
                                  controller: _name,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: text,
                                    helperText: "동아리 이름을 입력해주세요!"
                                  ),
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("취소"),
                                  onPressed: ()=>Navigator.pop(context),
                                ),
                                RaisedButton(
                                  child: Text("변경",style: TextStyle(color: Colors.black),),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: (){
                                    Navigator.pop(context);
                                    setState(() {
                                      text = _name.text;
                                    });
                                  },
                                )
                              ],
                            );
                          }
                        );
                      },
                    ),
                    background: Container(
                      decoration: new BoxDecoration(
                        image: new DecorationImage(
                          image: _image!=null?FileImage(_image):NetworkImage("http://image.sportsseoul.com/2018/01/02/news/2018010201000018800000491.jpg"), 
                          fit:BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: ()=>getImage(),
                    )
                  ],
                ),
              ];
            },
            body: ListView(
              children: <Widget>[
                Card(
                  child: Column(
                    children: <Widget>[
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text("동아리소개"),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(30.0),
                            child: TextField(
                              controller: _description,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "동아리 소개글을 여기에 써주세요\nex) 1995년에 기계공학과 학생과 전산전자과 학생들이모여 설립한 친목 동아리입니다.",
                              ),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text("가입하기"),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20.0),
                            child: TextField(
                              controller: _advertisement,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "동아리 모집내용을 여기에 써주세요\nex) 12/15일까지 모집합니다\nex) 죄송합니다. 모집이 종료되었습니다.",
                              ),
                            ),
                          ),
                          ButtonBar(
                            children: <Widget>[
                              Text("리쿠르팅 ON/OFF"),
                              Switch(
                                onChanged: (bool value) {
                                  setState(() {
                                    adv = value;
                                  });
                                },
                                value: adv,
                              ),
                              RaisedButton(
                                child: Text("가입하기"),
                                color: Theme.of(context).primaryColor,
                                onPressed: adv?(){}:null,
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 300.0,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Image(
                          image: NetworkImage("https://pbs.twimg.com/profile_images/882259118131523585/jckOG2cP_400x400.jpg"),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      ListTile(   
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage("https://cdn4.vectorstock.com/i/1000x1000/12/78/businessman-flat-icon-business-and-person-vector-16051278.jpg"),
                        ),
                        title: Text("작성자"),
                        subtitle: Text(DateTime.now().toString()),
                        trailing: Text("공개"),
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -"),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: <Widget>[
                            FlatButton(
                              child: SizedBox(
                                height: 300.0,
                                width: MediaQuery.of(context).size.width/2-4,
                                child: Image(
                                  image: NetworkImage("https://mblogthumb-phinf.pstatic.net/MjAxODA2MjJfMTYy/MDAxNTI5NjQzNzM0ODIx.Ra-EGOhq4KwWy9zB3R2rvr1bYlxixyxjJ34_Utkj2FQg.dFRtyS7ThwnIlFkaBV5SOnP0XC6DhorWyOdaTM2f-4cg.PNG.loveyourstyle/78180_65744_464.png?type=w800"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(0.0),
                              onPressed: (){
                                // print("page1");
                              },
                            ),
                            FlatButton(
                              child: SizedBox(
                                height: 300.0,
                                width: MediaQuery.of(context).size.width/2-4,
                                child: Image(
                                  image: NetworkImage("http://image.chosun.com/sitedata/image/201803/24/2018032401273_0.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(0.0),
                              onPressed: (){},
                            ),
                          ],
                        ),
                      ),
                      ListTile(   
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage("https://cdn4.vectorstock.com/i/1000x1000/12/78/businessman-flat-icon-business-and-person-vector-16051278.jpg"),
                        ),
                        title: Text("작성자"),
                        subtitle: Text(DateTime.now().toString()),
                        trailing: Text("비공개"),
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -"),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: <Widget>[
                            FlatButton(
                              child: SizedBox(
                                height: 300.0,
                                width: MediaQuery.of(context).size.width*2/3-4,
                                child: Image(
                                  image: NetworkImage("http://thestar.chosun.com/site/data/img_dir/2017/04/10/2017041001453_0.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(0.0),
                              onPressed: (){
                              },
                            ),
                            Column(
                              children: <Widget>[
                                FlatButton(
                                  child: SizedBox(
                                    height: 150.0,
                                    width: MediaQuery.of(context).size.width/3-4,
                                    child: Image(
                                      image: NetworkImage("http://cphoto.asiae.co.kr/listimglink/1/2018021616064428389_1518764804.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                  onPressed: (){},
                                ),
                                FlatButton(
                                  child: Stack(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 150.0,
                                        width: MediaQuery.of(context).size.width/3-4,
                                        child: Image(
                                          image: NetworkImage("https://i.pinimg.com/originals/25/2d/7d/252d7dcd1b10286ffd181b0625de5a1f.jpg"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(0.0),
                                  onPressed: (){
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListTile(   
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage("https://cdn4.vectorstock.com/i/1000x1000/12/78/businessman-flat-icon-business-and-person-vector-16051278.jpg"),
                        ),
                        title: Text("작성자"),
                        subtitle: Text(DateTime.now().toString()),
                        trailing: Text("임원단"),
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Sample - 샘플입니다 - Sample - 샘플입니다 - Sample - 샘플입니다 -Sample - 샘플입니다 -Sample - 샘플입니다 -"),
                      ),
                    ],
                  ),
                )
              ] 
            ),
          ),
        ],
      )
    );
  }
}