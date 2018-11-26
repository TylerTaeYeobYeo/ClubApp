import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_club2/club/contact.dart';
import 'package:project_club2/club/setting.dart';
import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/club/imageF.dart';
import 'package:project_club2/club/imageN.dart';
import 'package:project_club2/club/database.dart';
import 'package:project_club2/club/detail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ClubPage extends StatefulWidget {
  final DocumentSnapshot data;
  ClubPage({Key key, @required this.data})
    : assert(data != null),
    super(key: key);
  _ClubPageState createState() => _ClubPageState(club: data);
}

class _ClubPageState extends State<ClubPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  // Key open = ValueKey(false);
  int level;
  TextEditingController _request = new TextEditingController();
  TextEditingController _new = new TextEditingController();
  File _image;
  List<File> _images = List();
  List<String> _types = ["공개","동아리"].toList();
  String type = "공개";
  int load = 20;
  String text = "새로운 글쓰기";
  bool open = false;
  DocumentSnapshot club;
  _ClubPageState({Key key, @required this.club})
    : assert(club != null);
  @override
  void initState() {
    super.initState();
    level = cu.currentUser.club.getLevel();
  }
  @override
  void dispose() { 
    _images.clear();
    _request.dispose();
    _new.dispose();
    cu.currentUser.club.exit();
    super.dispose();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image ==null) return;
    setState(() {
      _image = image;
      _images.add(_image);
    });
  }

  Widget imageController (DocumentSnapshot data){
    if(data.data['body']['image'].length == 0) return SizedBox();
    else {
      int len = data.data['body']['image'].length;
      switch(len){
        case 1:
          return Container(
            height: 300.0,
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: FlatButton(
                  child: SizedBox(
                    height: 300.0,
                    width: MediaQuery.of(context).size.width -8,
                    child: Hero(
                      tag: data.data['body']['image'][0],
                      child: Image(
                        image: NetworkImage(data.data['body']['image'][0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(0.0),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NetworkImagePage(images: data.data['body']['image'],index: 0,),
                  )),
                ),
          );
          break;
        case 2: 
        return 
        Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: <Widget>[
                FlatButton(
                  child: SizedBox(
                    height: 300.0,
                    width: MediaQuery.of(context).size.width/2-4,
                    child: Hero(
                      tag: data.data['body']['image'][0],
                      child: Image(
                        image: NetworkImage(data.data['body']['image'][0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(0.0),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NetworkImagePage(images: data.data['body']['image'],index: 0,),
                  )),
                ),
                FlatButton(
                  child: SizedBox(
                    height: 300.0,
                    width: MediaQuery.of(context).size.width/2-4,
                    child: Hero(
                      tag: data.data['body']['image'][1],
                      child: Image(
                        image: NetworkImage(data.data['body']['image'][1]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(0.0),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NetworkImagePage(images: data.data['body']['image'], index: 1,),
                  )),
                ),
              ],
            ),
          );
          break;
        default:
          return Container(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: <Widget>[
                FlatButton(
                  child: SizedBox(
                    height: 300.0,
                    width: MediaQuery.of(context).size.width*2/3-4,
                    child: Hero(
                      tag: data.data['body']['image'][0],
                      child: Image(
                        image: NetworkImage(data.data['body']['image'][0]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.all(0.0),
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NetworkImagePage(images: data.data['body']['image'], index: 0),
                  )),
                ),
                Column(
                  children: <Widget>[
                    FlatButton(
                      child: SizedBox(
                        height: 150.0,
                        width: MediaQuery.of(context).size.width/3-4,
                        child: Hero(
                          tag: data.data['body']['image'][1],
                          child: Image(
                            image: NetworkImage(data.data['body']['image'][1]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(0.0),
                      onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                        builder: (context) => NetworkImagePage(images: data.data['body']['image'], index: 1,),
                      )),
                    ),
                    FlatButton(
                      child: Stack(
                        children: <Widget>[
                          SizedBox(
                            height: 150.0,
                            width: MediaQuery.of(context).size.width/3-4,
                            child: Hero(
                              tag: data.data['body']['image'][2],
                              child: Image(
                                image: NetworkImage(data.data['body']['image'][2]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          len-3>0?Container(
                            height: 150.0,
                            width: MediaQuery.of(context).size.width/3 - 4,
                            decoration:BoxDecoration(
                              color: Colors.black26
                            ),
                            child: Center(
                              child:Text("+${len - 3}",
                                style: TextStyle(
                                  fontSize: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ):SizedBox(),
                        ],
                      ),
                      padding: EdgeInsets.all(0.0),
                      onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                        builder: (context) => NetworkImagePage(images: data.data['body']['image'], index: 2,),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          );
          break;
      }
    }
  }

  Widget _requestButton(){
    bool a = club.data['adv'];
    if(a && cu.currentUser.club.getLevel() < 2)
      return ButtonBar(
        children: <Widget>[
          FlatButton(
            child: Text("가입신청", 
              style: TextStyle(color: a?Theme.of(context).primaryColor:Colors.grey),
            ),
            onPressed: ()=>_clicked(),
          ),
        ],
      );
    else return SizedBox();
  }
  Future<Null> _clicked() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(club.data["image"]),
            ),
            title: Text(club.data['name']),
            trailing: Text(club.data['type'],style: TextStyle(color: Colors.grey,fontSize: 12.0),),
          ),
          contentPadding: EdgeInsets.all(30.0),
          content: Container(
            child: TextField(
              controller: _request,
              decoration: InputDecoration(
                hintText: "각오를 적어주세요\n*모집기간이 아니거나*\n*기존회원이 아닐경우*\n*거부될 수도 있습니다*",
              ),
              maxLines: 5,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: ()=>Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("신청",style: TextStyle(color: Colors.white),),
              disabledColor: Colors.grey,
              color: Theme.of(context).primaryColor,
              onPressed: ()async {
                Navigator.pop(context);
                await Firestore.instance.collection('clubs').document(club.documentID).collection('request').document(cu.currentUser.getUid()).setData({
                    "uid": cu.currentUser.getUid(),
                    "name": cu.currentUser.getDisplayName(),
                    "email": cu.currentUser.getEmail(),
                    "phoneNumber": cu.currentUser.getPhoneNumber(),
                    "photoUrl": cu.currentUser.getphotoUrl(),
                    "content": _request.text,
                  }
                );
                _request.clear();
              },
            ),
          ],
        );
      }
    );
  }

  Drawer _drawer(){
    if(cu.currentUser.club.getLevel()>1)
      return Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                ),
              accountName: Text(cu.currentUser.getDisplayName()),
              accountEmail: Text(cu.currentUser.getEmail()),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("메인"),
              onTap: (){Navigator.popUntil(context, ModalRoute.withName('/home'));},
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("공유자료"),
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text("연락처"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ContactPage(data: club),
                  )
                );
              },
            ),
            cu.currentUser.club.getLevel()==3?ListTile(
              leading: Icon(Icons.folder_special),
              title: Text("운영자료"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => DatabasePage(data: club),
                  )
                );
              },
            ):SizedBox(),
            cu.currentUser.club.getLevel()==3?ListTile(
              leading: Icon(Icons.settings),
              title: Text("임원단 메뉴"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ClubSettingPage(data: club),
                  )
                );
              },
            ):SizedBox(),
            
          ],
        ),
      );
    else return null;
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    int type = data.data['head']['type'];
    String typed;
    switch(type){
      case 2: typed="동아리";
      break;
      default: typed = "공개";
      break;
    }
    List<String> setting = ["공개범위","삭제"].toList();
    return Card(
      key: ValueKey(data.data['id']),
      child: Column(
        children: <Widget>[
          // Image.network(data.data['body']['image'][0]),
          ListTile(   
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data.data['head']['photoUrl']),
            ),
            title: Text(data.data['head']['writer'],
              style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold),),
            subtitle: Text(typed +" "+ DateFormat.yMd().add_jm().format((data.data['head']['date'].toLocal()))),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              itemBuilder: (BuildContext context) {
                return setting.map((item){
                  return PopupMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              },
              onSelected: (s)=>choiceAction(s, data),
            )
          ),
          imageController(data),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(data.data['body']['content'],
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                // stream: Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').document(club.documentID).snapshots(),
                stream: Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).snapshots(),
                builder: (context, snapshots){
                  if(!snapshots.hasData) return CircularProgressIndicator();
                  List<dynamic> list = snapshots.data.data['like'];
                  return Row(
                    children: <Widget>[
                      IconButton(
                        icon: list.contains(cu.currentUser.getUid())?Icon(Icons.favorite, color: Colors.red,):Icon(Icons.favorite_border, color: Colors.red,),
                        onPressed: (){
                          List<dynamic> like = List();
                          list.forEach((item){
                            like.add(item);
                          });
                          if(list.contains(cu.currentUser.getUid())) {
                            like.remove(cu.currentUser.getUid());
                            Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).updateData({
                              "liked": like.length,
                              "like": like,
                            });
                          }
                          else{
                            like.add(cu.currentUser.getUid());
                            Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).updateData({
                              "liked": like.length,
                              "like": like,
                            });
                          }
                          setState(() {
                            cu.currentUser.club.setLike(like);
                          });
                        },
                      ),
                      Text(list.length.toString()),
                    ],
                  );
                },
              ),
              FlatButton(
                child: Text("더보기", style: TextStyle(color: Theme.of(context).primaryColorDark),),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context)=>DetailClubPage(club: club, data: data),
                  ));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  void choiceAction(String choice, DocumentSnapshot data){
    if(choice == "공개범위"){
      if(cu.currentUser.getUid() == data.data['head']['uid'] || cu.currentUser.club.getLevel() == 3){
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: ListTile(
                title: Text("게시물의 공개범위를 재설정합니다"),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    child: Text("공개",style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),),
                    onPressed: (){
                      Navigator.pop(context);
                      Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).updateData({
                        "head.type": 0 
                      });
                    },
                  ),
                  FlatButton(
                    child: Text("동아리",style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),),
                    onPressed: (){
                      Navigator.pop(context);
                      Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).updateData({
                        "head.type": 2 
                      });
                    },
                  ),
                ],
              )
            );
          }
        );
      }
      else{
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: ListTile(
                leading: Icon(Icons.warning),
                title: Text("권한이 없습니다."),
              ),
            );
          }
        );
      }
    }else {
      if(cu.currentUser.getUid() == data.data['head']['uid'] || cu.currentUser.club.getLevel() == 3){
        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text("게시물을 삭제하시겠습니까?"),
              content: Container(
                padding: EdgeInsets.all(10.0),
                child: Text("삭제된 게시물은 복구가 불가능합니다."),
              ),
              actions: <Widget>[
                ButtonBar(
                  children: <Widget>[
                    RaisedButton(
                      child: Text("삭제",style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        Navigator.pop(context);
                        Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).delete();
                      },
                    ),
                    FlatButton(
                      child: Text("취소",style: TextStyle(color: Theme.of(context).primaryColor),),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    )
                  ],
                )
              ],
            );
          }
        );
      }
      else showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: ListTile(
              leading: Icon(Icons.warning),
              title: Text("권한이 없습니다."),
            ),
          );
        }
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final dropdownMenuOptions = _types

      .map((String item) =>
        new DropdownMenuItem<String>(value: item, child: new Text(item))
      )
      .toList();

    return Scaffold(
      key: _scaffoldKey,
      // floatingActionButton: _floating(),
      drawer: _drawer(),
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
                  // floating: true,
                  // snap: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(club.data['name'],
                      style: TextStyle(
                        fontSize: 18.0,
                      )
                    ),
                    background: Hero(
                      tag: club.data['id'],
                      child:Container(
                          decoration: new BoxDecoration(
                          image: new DecorationImage(image: new NetworkImage(club.data['image']), fit:BoxFit.cover,),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: cu.currentUser.club.getLevel()<2
            ?ListView(
              children: <Widget>[
                Card(
                  child: ExpansionTile(
                    title: Text("동아리소개"),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(club.data['description']),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: club.data['adv'],
                    title: Text("가입하기"),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(club.data['advertisement']),
                      ),
                      _requestButton()
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('clubs').document(club.documentID).collection('Board').where("head.type", isLessThanOrEqualTo: level).limit(50).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return Column(
                      children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
                    );
                  },
                ),
              ] 
            )
            :ListView(
              children: <Widget>[
                Card(
                  // color: Theme.of(context).primaryColorLight,
                  child: ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      if(!open){
                        setState(() {
                          text = DateFormat.yMd().add_jm().format((DateTime.now().toLocal()));
                          open = !open;
                        });
                      }
                      else                      
                        setState(() {
                          open = !open;
                          text = "새로운 글쓰기";
                        });
                    },
                    children: <ExpansionPanel>[
                      ExpansionPanel(
                        isExpanded: open,
                        headerBuilder: (context, isExpanded){
                          return ListTile(
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                              ),
                            title: ListTile(
                              title: Text(cu.currentUser.getDisplayName()),
                              subtitle: Text(text),
                            ),
                          );
                        },
                        body: Column(
                          children: <Widget>[
                            _images.length>0?ListTile(
                              title: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/logo/image2.png'),
                                    fit: BoxFit.fitWidth,
                                    // colorFilter: ColorFilter.mode(Colors.orange, BlendMode.dst)
                                  )
                                ),
                                height: 50.0,
                                width: 300.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _images.length,
                                  itemBuilder: (context, int index){
                                    return Container(
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            width: 100.0,
                                            height: 100.0,
                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                            child: FlatButton(
                                              padding: EdgeInsets.all(0.0),
                                              child: Hero(
                                                tag: _images[index].toString(),
                                                child: Image.file(_images[index], fit: BoxFit.cover),
                                              ),
                                              onPressed: ()=>Navigator.push(context, 
                                                MaterialPageRoute(
                                                  builder: (context) => ImagePage(images: _images, index: index,),
                                                )
                                              ),
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(width: 80.0,),
                                              Container(
                                                child: IconButton(
                                                  padding: EdgeInsets.all(0.0),
                                                  icon: Icon(Icons.close),
                                                  onPressed: (){
                                                    setState(() {
                                                      _images.remove(_images[index]);
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ):SizedBox(),
                            Divider(color: Colors.grey,),
                            ListTile(
                              title: Container(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Column(
                                  children: <Widget>[
                                    TextField(
                                      controller: _new,
                                      maxLines: 7,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintText: "오늘의 동아리는 어떤가요?",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  DropdownButton(
                                    value: type,
                                    items: dropdownMenuOptions,
                                    onChanged: (String value) {
                                      setState(() {
                                        type = value;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.camera_alt),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: ()=>getImage(),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.send),
                                    color: Theme.of(context).primaryColor,
                                    onPressed: ()async{
                                      if(_new.text =="" && _images.length==0 ) showDialog(
                                        context: context,
                                        builder: (context){
                                          return AlertDialog(
                                            title: Text("내용이 없습니다!"),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("확인"),
                                                onPressed: ()=>Navigator.pop(context),
                                              )
                                            ],
                                          );
                                        }
                                      );
                                      else{
                                        setState(() {
                                          open = false;
                                        });
                                        List<String> im = List();
                                        for(int i =0;i<_images.length;i++){
                                          String name = Uuid().v4();
                                          StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('club/${club.documentID}/$name$i').putFile(_images[i]);
                                          im.add(await (await uploadTask.onComplete).ref.getDownloadURL());
                                        }
                                        int level = 0;
                                        switch(type){
                                          case "공개":
                                            level = 0;
                                          break;
                                          case "동아리":
                                            level = 2;
                                          break;
                                        }
                                        String name = Uuid().v4();
                                        await Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(name).setData({
                                          "body": {
                                            "content": _new.text,
                                            "image": im,
                                          },
                                          "head":{
                                            "date": DateTime.now(),
                                            "photoUrl": cu.currentUser.getphotoUrl(),
                                            "writer": cu.currentUser.getDisplayName(),
                                            "uid":cu.currentUser.getUid(),
                                            "type": level,
                                          },
                                          "id": name,
                                          "like": [],
                                        });
                                        setState(() {
                                          type="공개";
                                          _new.clear();
                                          _images.clear();
                                        });
                                      }
                                    },
                                  ),
                                ],
                              )
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('clubs').document(club.documentID).collection('Board').orderBy("head.date", descending: true).limit(load).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();
                    return Column(
                      children: snapshot.data.documents.map((data) => _buildListItem(context, data)).toList(),
                    );
                  },
                ),
                Card(
                  child: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: (){
                      setState(() {
                        load +=10;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
