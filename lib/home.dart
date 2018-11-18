import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/club/club.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Future<Null> _clicked(DocumentSnapshot data) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data.data['image']),
            ),
            title: Text(data.data['name']),
            trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey,fontSize: 12.0),),
          ),
          contentPadding: EdgeInsets.all(30.0),
          content: Container(
            child: Text(data.data['advertisement'],maxLines: 5,softWrap: true,),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: ()=>Navigator.pop(context),
            ),
            RaisedButton(
              child: Text("방문",style: TextStyle(color: Colors.white),),
              disabledColor: Colors.grey,
              color: Theme.of(context).primaryColor,
              onPressed: ()async {
                await cu.currentUser.club.enterClub(data);
                Navigator.pop(context);
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ClubPage(data: data),
                  )
                );
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data, int mode) {
    return Padding(
      key: ValueKey(data.data['id']),
      padding: const EdgeInsets.all(0.0),
      child: ListTile(
        leading: Hero(
          tag: data.data['id'],
          child:CircleAvatar(
            backgroundImage: NetworkImage(data.data['image']),
          ),
        ),
        title: Text(data.data['name']),
        trailing: Text(data.data['type'],style: TextStyle(color: Colors.grey),),
        onTap: mode==0?()=>_clicked(data):()async{
          DocumentSnapshot doc = await cu.currentUser.club.enterLikedClub(data.data['id']);
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => ClubPage(data: doc),
            )
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(cu.currentUser.getphotoUrl()),
                ),
                accountName: Text(cu.currentUser.getDisplayName()),
                accountEmail: Text(cu.currentUser.getEmail()),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("설정"),
                onTap: (){
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text("개인정보"),
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/personal');
                },
              ),
              ListTile(
                leading: Icon(Icons.people_outline),
                title: Text("다른 아이디로 로그인"),
                onTap: (){
                  FirebaseAuth.instance.signOut();
                  cu.currentUser.googleLogOut();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: IconButton(
            icon:Icon(Icons.menu),
            onPressed: ()=>_scaffoldKey.currentState.openDrawer(),
          ),
          centerTitle: true,
          title: Text("동아리"),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.fiber_new)),
              Tab(icon: Icon(Icons.favorite)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.pushNamed(context, '/new');
          },
        ),
        body: TabBarView(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('clubs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();

                return ListView(
                  padding: const EdgeInsets.only(top: 16.0),
                  children: snapshot.data.documents.map((data) => _buildListItem(context, data,0)).toList(),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('users').document(cu.currentUser.getUid()).collection('clubs').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LinearProgressIndicator();
                return ListView(
                  padding: const EdgeInsets.only(top: 16.0),
                  children: snapshot.data.documents.map((data) => _buildListItem(context, data,1)).toList(),
                );
              },
            ),
          ],
        )
      ),
    );
  }
}