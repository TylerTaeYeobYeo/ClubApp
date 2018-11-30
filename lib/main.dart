import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/home.dart';
import 'package:project_club2/new.dart';
import 'package:project_club2/personal.dart';
import 'package:project_club2/settings.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(RouteApp());

class RouteApp extends StatefulWidget {
  @override
  RouteAppPage createState() =>RouteAppPage();
}

class RouteAppPage extends State<RouteApp>{
  void loadJson()async{
    final dir = await getApplicationDocumentsDirectory();
    File data = File("${dir.path}/color.json");
 
    if(await data.exists()){
      Map<String, dynamic> jsonResult = json.decode(data.readAsStringSync());
      print(jsonResult['selected']);
      setState(() {
        switch(jsonResult['selected']){
          case "red":
            cu.currentUser.userColor = Colors.red;
            break;
          case "deepOrange":
            cu.currentUser.userColor = Colors.deepOrange;
            break;
          case "orange":
            cu.currentUser.userColor = Colors.orange;
            break;
          case "amber":
            cu.currentUser.userColor = Colors.amber;
            break;
          case "yellow":
            cu.currentUser.userColor = Colors.yellow;
            break;
          case "lime":
            cu.currentUser.userColor = Colors.lime;
            break;
          case "lightGreen":
            cu.currentUser.userColor = Colors.lightGreen;
            break;
          case "green":
            cu.currentUser.userColor = Colors.green;
            break;
          case "teal":
            cu.currentUser.userColor = Colors.teal;
            break;
          case "cyan":
            cu.currentUser.userColor = Colors.cyan;
            break;
          case "lightBlue":
            cu.currentUser.userColor = Colors.lightBlue;
            break;
          case "blue":
            cu.currentUser.userColor = Colors.blue;
            break;
          case "indigo":
            cu.currentUser.userColor = Colors.indigo;
            break;
          case "deepPurple":
            cu.currentUser.userColor = Colors.deepPurple;
            break;
          case "purple":
            cu.currentUser.userColor = Colors.purple;
            break;
          case "pink":
            cu.currentUser.userColor = Colors.pink;
            break;
          default:
            break;
        }
      });
    }
    else {
      print('none');
      Map<String,String> input = {"selected": "orange"};
      File file = File(dir.path + "/color.json");
      file.createSync();
      file.writeAsStringSync(json.encode(input));
    }
  }
  @override
  void initState() {
    loadJson();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main',
      home: LoginPage(),
      theme: ThemeData(
        primarySwatch: cu.currentUser.userColor,
        // primaryColorBrightness: Brightness.dark
      ),
      initialRoute: '/login',
      routes: {
        '/login':(context)=>LoginPage(),
        '/home':(context)=>HomePage(),
        '/new':(context)=>NewClubPage(),
        '/personal':(context)=>PersonalPage(),
        '/appSetting':(context)=>AppSettingPage(),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() =>LoginPageState();
}

class LoginPageState extends State<LoginPage>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  void initState() {
    
    super.initState();
  }

  Future<FirebaseUser> _signIn()  async {
    GoogleSignInAccount googleSignInAccount = await cu.currentUser.getGoogleLogIn().signIn().catchError((e)=>print(e));
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    
    FirebaseUser user = await _auth.signInWithGoogle(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken
    );
    return user;
  }
  void setCurrentUser(FirebaseUser user){
    cu.currentUser.setCurrentUser(
      user.displayName,
      user.email,
      user.photoUrl,
      user.uid,
      user.phoneNumber
    );
  }
  void _updateUserData(BuildContext context, FirebaseUser user)async {
    setCurrentUser(user);
    setState(() {
      loading = true;
    });
    await Firestore.instance.collection('users').document(user.uid).get().then((doc){
      if (doc.exists){
        cu.currentUser.setAdmin(doc.data['admin']);
        Firestore.instance.collection('users').document(user.uid).updateData({
          "uid": user.uid,
          "photoUrl":user.photoUrl,
          "displayName":user.displayName,
          "email":user.email,
          "phoneNumber":user.phoneNumber,
        });
      }
      else {
        //new user
        Firestore.instance.collection('users').document(user.uid).setData({
          "uid": user.uid,
          "photoUrl":user.photoUrl,
          "displayName":user.displayName,
          "email":user.email,
          "phoneNumber":user.phoneNumber,
        });
      }
      Navigator.pushNamed(context, '/home');
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image.asset('assets/logo/logo2.png',fit: BoxFit.fitWidth,),
              FlatButton(
                child: Container(
                  width: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/logo/google.png',height: 30.0,),
                    title: Text("Google 로그인",style: TextStyle(),),
                  ),
                ),
                onPressed: ()async{_updateUserData(context, await _signIn().catchError((onError){
                }));},
              ),
            ],
          ),
          loading?Center(
            child: Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.black54,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Loading",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
          ):SizedBox(),
        ],
      )
    );
  }
}