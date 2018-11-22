import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project_club2/global/currentUser.dart' as cu;
import 'package:project_club2/home.dart';
import 'package:project_club2/new.dart';
import 'package:project_club2/personal.dart';
import 'package:project_club2/settings.dart';

void main() => runApp(RouteApp());

class RouteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main',
      home: LoginPage(),
      theme: ThemeData(
        primarySwatch: Colors.orange,
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

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    Firestore.instance.collection('users').document(user.uid).get().then((doc){
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
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
              // cu.currentUser.googleLogOut();
              // FirebaseAuth.instance.signOut();
            }));},
          ),
          // RaisedButton(
          //   child: Text(
          //     "Google 로그인",
          //     style: TextStyle(
          //       color: Colors.red,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          //   onPressed: ()async{_updateUserData(context, await _signIn());},
          //   color: Colors.white,
          // )
        ],
      )
    );
  }
}