import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_club2/club/contact.dart';
import 'package:project_club2/club/setting.dart';
import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/club/image.dart';
import 'package:project_club2/club/imageN.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class ClubPage extends StatefulWidget {
  final DocumentSnapshot data;
  ClubPage({Key key, @required this.data})
    : assert(data != null),
    super(key: key);
  _ClubPageState createState() => _ClubPageState(data: data);
}

class _ClubPageState extends State<ClubPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Key open = ValueKey(false);
  int level;
  TextEditingController _request = new TextEditingController();
  DocumentSnapshot data;
  TextEditingController _new = new TextEditingController();
  File _image;
  List<File> _images = List();
  List<String> _types = ["공개","동아리"].toList();
  String type = "공개";
  int load = 20;
  Stream<QuerySnapshot> term;

  String text = "새로운 글쓰기";

  _ClubPageState({Key key, @required this.data})
    : assert(data != null);
  @override
  void initState() {
    super.initState();
    level = cu.currentUser.club.getLevel();
    setState(() {
      if(level > 1) term = Firestore.instance.collection('clubs').document(data.documentID).collection('Board').orderBy("head.date", descending: true).limit(load).snapshots();
      else term = Firestore.instance.collection('clubs').document(data.documentID).collection('Board').where("head.type", isLessThanOrEqualTo: level).snapshots();
    });
  }
  @override
  void dispose() { 
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
    bool a = data.data['adv'];
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
              backgroundImage: NetworkImage(data.data["image"]),
            ),
            title: Text(data.data['name']),
            trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey,fontSize: 12.0),),
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
                await Firestore.instance.collection('clubs').document(data.documentID).collection('request').document(cu.currentUser.getUid()).setData({
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
              leading: Icon(Icons.school),
              title: Text("수업자료"),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text("동아리자료"),
            ),
            ListTile(
              leading: Icon(Icons.call),
              title: Text("연락처"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ContactPage(data: data),
                  )
                );
              },
            ),
            cu.currentUser.club.getLevel()==3?ListTile(
              leading: Icon(Icons.settings),
              title: Text("임원단 메뉴"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ClubSettingPage(data: data),
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
      case 3: typed="임원단";
      break;
      default: typed = "공개";
      break;
    }
    return Card(
      key: ValueKey(data.data['id']),
      child: Column(
        children: <Widget>[
          // Image.network(data.data['body']['image'][0]),
          imageController(data),
          ListTile(   
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data.data['head']['photoUrl']),
            ),
            title: Text(data.data['head']['writer']),
            subtitle: Text(data.data['head']['date'].toString()),
            trailing: Text(typed),
          ),
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(data.data['body']['content']),
          ),
        ],
      ),
    );
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
                    title: Text(data.data['name'],
                      style: TextStyle(
                        fontSize: 18.0,
                      )
                    ),
                    background: Hero(
                      tag: data.data['id'],
                      child:Container(
                          decoration: new BoxDecoration(
                          image: new DecorationImage(image: new NetworkImage(data.data['image']), fit:BoxFit.cover,),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: cu.currentUser.club.getLevel()<2?ListView(
              children: <Widget>[
                Card(
                  child: ExpansionTile(
                    title: Text("동아리소개"),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(data.data['description']),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ExpansionTile(
                    initiallyExpanded: data.data['adv'],
                    title: Text("가입하기"),
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(data.data['advertisement']),
                      ),
                      _requestButton()
                    ],
                  ),
                )
              ] 
            )
            :ListView(
              children: <Widget>[
                Card(
                  // color: Theme.of(context).primaryColorLight,
                  child: ExpansionTile(
                    onExpansionChanged: (bool v){
                      if(v){
                        setState(() {
                          text = DateTime.now().toLocal().toString();
                        });
                      }
                      else                      
                        setState(() {
                          text = "새로운 글쓰기";
                        });
                    },                    
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                      ),
                    title: ListTile(
                      title: Text(cu.currentUser.getDisplayName()),
                      subtitle: Text(text),
                    ),
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
                                width: 100.0,
                                height: 100.0,
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: FlatButton(
                                  padding: EdgeInsets.all(0.0),
                                  child: Image.file(_images[index], fit: BoxFit.cover),
                                  onPressed: ()=>Navigator.push(context, 
                                    MaterialPageRoute(
                                      builder: (context) => ImagePage(image: _images[index],),
                                    )
                                  ),
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
                                  if(_new.text =="") showDialog(
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
                                    List<String> im = List();
                                    for(int i =0;i<_images.length;i++){
                                      String name = Uuid().v4();
                                      StorageUploadTask uploadTask = FirebaseStorage.instance.ref().child('club/${data.documentID}/${name}$i').putFile(_images[i]);
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
                                      case "임원단":
                                        level = 3;
                                      break;
                                    }
                                    String name = Uuid().v4();
                                    await Firestore.instance.collection('clubs').document(data.documentID).collection('Board').document(name).setData({
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
                                    });
                                    setState(() {
                                      type="공개";
                                      _new.clear();
                                      _images.clear();
                                      open = ValueKey(false);
                                    });
                                  }
                                },
                            ),
                          ],
                        )
                      ),
                    ],
                  )
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: term,
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
                        term = term;
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