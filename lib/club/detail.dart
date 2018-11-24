import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_club2/club/imageN.dart';
import 'package:project_club2/global/currentUser.dart' as cu;

class DetailClubPage extends StatefulWidget {
  final DocumentSnapshot club;
  final DocumentSnapshot data;
  DetailClubPage({Key key, @required this.club, @required this.data})
    : assert(data != null),
    super(key: key);
  _DetailClubPageState createState() => _DetailClubPageState(club: club, data: data);
}

class _DetailClubPageState extends State<DetailClubPage> {
  TextEditingController _comment = TextEditingController();
  TextEditingController controller = TextEditingController(); //for comments fixing
  final DocumentSnapshot club;
  final DocumentSnapshot data;
  _DetailClubPageState({Key key, @required this.club, @required this.data})
    : assert(data != null);

  String typed= "";
  @override
  void initState() {
    int type = data.data['head']['type'];
    switch(type){
      case 2: typed="동아리";
      break;
      default: typed = "공개";
      break;
    }
    super.initState();
  }
  @override
  void dispose() { 
    _comment.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              actions: <Widget>[
                cu.currentUser.getUid() == data.data['head']['uid']
                  ?IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: (){},
                  )
                  :SizedBox(),
                cu.currentUser.getUid() == data.data['head']['uid']
                  ?IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: (){
                      Navigator.pop(context);
                      Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).delete();
                    },
                  )
                  :SizedBox(),
              ],
            )
          ];
        },
        body: ListView(
          children: <Widget>[
            ListTile(
              leading: Container(
                height: 40.0,
                width: 40.0,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(data.data['head']['photoUrl']),
                ),
              ),
              title: Text(data.data['head']['writer'],
                style: TextStyle(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.bold),),
              subtitle: Text(DateFormat.yMd().add_jm().format(data.data['head']['date'])),
              trailing: Text(typed,style: TextStyle(fontSize: 14.0),),
            ),
            data.data['body']['image'].length!=0?Container(
              height: MediaQuery.of(context).size.height/2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: data.data['body']['image'].length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Container(
                      // width: MediaQuery.of(context).size.width-20,
                      child: FlatButton(
                        padding: EdgeInsets.all(0.0),
                        child: Hero(
                          tag: data.data['body']['image'][index],
                          child: Image.network(data.data['body']['image'][index], fit: BoxFit.fitHeight),
                        ),
                        onPressed: ()=>Navigator.push(context, MaterialPageRoute(
                          builder: (context) => NetworkImagePage(images: data.data['body']['image'],index: index,),
                        )),
                      ),
                    )
                  );
                },
              ),
            )
            :SizedBox(),
            Container(
              padding: EdgeInsets.all(30.0),
              child: Text(data.data['body']['content']),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                StreamBuilder<DocumentSnapshot>(
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
              ],
            ),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                    ),
                    title: Container(
                      padding: EdgeInsets.all(10.0),
                      child: TextField(
                        controller: _comment,
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: (){
                        String body = _comment.text;
                        _comment.clear();
                        Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).collection('comments').add({
                          "date": DateTime.now(),
                          "writer": cu.currentUser.getDisplayName(),
                          "photoUrl":cu.currentUser.getphotoUrl(),
                          "uid":cu.currentUser.getUid(),
                          "body": body,
                          "like": [],
                        });
                      },
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).collection('comments').orderBy("date",descending: true).snapshots(),
                    builder: (context,snapshots){
                      if(!snapshots.hasData) return LinearProgressIndicator();
                      return Column(
                        children: snapshots.data.documents.map((doc){
                          List<dynamic> like = List();
                          return ListTile(
                            // isThreeLine: true,
                            contentPadding: EdgeInsets.all(0.0),
                            dense: true,
                            leading: Container(
                              height: 30.0,
                              width: 30.0,
                              margin: EdgeInsets.all(6.0),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(doc.data['photoUrl'].toString()),
                              ),
                            ),
                            title: Container(
                              width: MediaQuery.of(context).size.width*2/3,
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text:doc.data['writer'] + "\n", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                                    TextSpan(text:doc.data['body'], style: TextStyle(color: Colors.black),)
                                  ]
                                ),
                              ),
                            ),
                            subtitle: Text(DateFormat.yMd().add_jm().format(doc.data['date'].toLocal())),
                            trailing: Container(
                              width: MediaQuery.of(context).size.width/6,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    icon: doc.data['like'].contains(cu.currentUser.getUid())
                                      ?Icon(Icons.favorite, size:20.0, color: Theme.of(context).primaryColor,)
                                      :Icon(Icons.favorite_border, size:20.0, color: Theme.of(context).primaryColor,),
                                    onPressed: (){
                                      doc.data['like'].forEach((item){
                                        like.add(item);
                                      });
                                      if(doc.data['like'].contains(cu.currentUser.getUid())){
                                        like.remove(cu.currentUser.getUid());
                                      }
                                      else like.add(cu.currentUser.getUid());
                                      Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).collection('comments').document(doc.documentID).updateData({
                                        "like":like
                                      });
                                    },
                                  ),
                                  Text(doc.data['like'].length.toString())
                                ],
                              ),
                            ),
                            onLongPress: cu.currentUser.getUid()==doc.data['uid']?(){
                              controller.text = doc.data['body'];
                              showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    titlePadding: EdgeInsets.all(8.0),
                                    title: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(doc.data['photoUrl'].toString()),
                                      ),
                                      title: Text(doc.data['writer']),
                                      subtitle: Text(DateFormat.yMd().add_jm().format(doc.data['date'].toLocal())),
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete,color: Colors.black,),
                                        tooltip: "삭제",
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).collection('comments').document(doc.documentID).delete();
                                        },
                                      ),
                                    ),
                                    content: TextField(
                                      controller: controller,
                                      maxLines: 5,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        hintText: "댓글을 입력해주세요",
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("취소"),
                                        onPressed: ()=>Navigator.pop(context),
                                      ),
                                      RaisedButton(
                                        child: Text("수정",style: TextStyle(color: Colors.white),),
                                        color: Theme.of(context).primaryColor,
                                        onPressed: (){
                                          Navigator.pop(context);
                                          Firestore.instance.collection('clubs').document(club.documentID).collection('Board').document(data.documentID).collection('comments').document(doc.documentID).updateData({
                                            "body": controller.text,
                                          });
                                        },
                                      )
                                    ],
                                  );
                                }
                              );
                            }:null,
                          );
                          // Container(
                          //   padding: EdgeInsets.all(4.0),
                          //   child: Row(children: <Widget>[
                          //     Container(
                          //       height: 30.0,
                          //       width: 30.0,
                          //       margin: EdgeInsets.all(8.0),
                          //       child: CircleAvatar(
                          //         backgroundImage: NetworkImage(doc.data['photoUrl'].toString()),
                          //       ),
                          //     ),
                          //     Column(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       crossAxisAlignment: CrossAxisAlignment.end,
                          //       children: <Widget>[
                          //         Container(
                          //           width: MediaQuery.of(context).size.width*2/3,
                          //           padding: EdgeInsets.symmetric(horizontal: 4.0),
                          //           child: RichText(
                          //             text: TextSpan(
                          //               children: [
                          //                 TextSpan(text:doc.data['writer'] + "\n", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                          //                 TextSpan(text:doc.data['body'], style: TextStyle(color: Colors.black),)
                          //               ]
                          //             ),
                          //           ),
                          //         ),
                          //         Text(DateFormat.yMd().add_jm().format(doc.data['date'].toLocal()), style: TextStyle(color: Colors.grey),)

                          //       ],
                          //     ),
                          //     IconButton(
                          //       padding: EdgeInsets.all(0.0),
                          //       icon: Icon(Icons.favorite, size: 20.0,color: Colors.red,),
                          //       onPressed: (){},
                          //     ),
                          //     Text("32")
                          //   ],),
                          // );
                        }).toList()
                      );
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}