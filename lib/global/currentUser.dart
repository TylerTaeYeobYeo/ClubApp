library my_prj.globals;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser {
  String _displayName;
  String _email;
  String _photoUrl;
  String _uid;
  String _phoneNumber;
  bool _admin;
  DocumentSnapshot db;
  CurrentClub club = CurrentClub();
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  String getDisplayName(){return _displayName;}
  String getEmail(){return _email;}
  String getphotoUrl(){return _photoUrl;}
  String getUid(){return _uid;}
  String getPhoneNumber(){
    return _phoneNumber;
  }
  bool getAdmin(){return _admin;}
  setUser(DocumentSnapshot db){
    this.db = db;
  }
  setAdmin(dynamic value){ 
    if(value!=null)
      _admin = value;
    else _admin = false;
  }

  void setCurrentUser(
    displayName,
    email,
    photoUrl,
    uid,
    phoneNumber
  ){
    this._displayName = displayName;
    this._email = email;
    this._photoUrl = photoUrl;
    this._uid = uid;
    this._phoneNumber = phoneNumber;
  }

  void clear(){
    _displayName = null;
    _email = null;
    _photoUrl = null;
    _uid = null;
    _phoneNumber = null;
    db = null;
    _admin = false;
  }

  googleLogIn(){
    _googleSignIn.signIn();
  }
  googleLogOut(){
    _googleSignIn.signOut();
    clear();
  }
  GoogleSignIn getGoogleLogIn(){
    return _googleSignIn;
  }
}
class CurrentClub{
  String _id;
  String _name;
  String _type;
  String _advertisement;
  String _image;
  String _description;
  bool _adv;
  int _level;
  int _title;

  String getId(){return _id;}
  String getName(){return _name;}
  String getType(){return _type;}
  String getAdvT(){return _advertisement;}
  String getImage(){return _image;}
  String getDsc(){return _description;}
  bool getAdv(){return _adv;}
  int getLevel(){return _level;}
  int getTitle(){return _title;}

  Future<DocumentSnapshot> enterLikedClub(String id)async{
    DocumentSnapshot club = await Firestore.instance.collection('clubs').document(id).get();
    _id = club.data['id'];
    _name = club.data['name'];
    _type = club.data['type'];
    _advertisement = club.data['advertisement'];
    _image = club.data['image'];
    _description = club.data['description'];
    _adv = club.data['adv'];
    await setLevel();
    return club;
  }
  enterClub(DocumentSnapshot club)async{
    _id = club.data['id'];
    _name = club.data['name'];
    _type = club.data['type'];
    _advertisement = club.data['advertisement'];
    _image = club.data['image'];
    _description = club.data['description'];
    _adv = club.data['adv'];
    await setLevel();
  }
  setLevel()async{
    DocumentSnapshot doc = await Firestore.instance.collection('clubs').document(_id).collection('users').document(currentUser.getUid()).get();
    if(doc.exists) {
      _level = doc.data['level'];
      Firestore.instance.runTransaction((Transaction transaction)async{
        Firestore.instance.collection('users').document(currentUser.getUid()).collection('clubs').document(_id).updateData({
        "name": _name,
        "image": _image,
        "type": _type,
        "level": doc.data['level'],
        });
        Firestore.instance.collection('clubs').document(_id).collection('users').document(currentUser.getUid()).updateData({
          "name": currentUser.getDisplayName(),
          "phoneNumber": currentUser.getPhoneNumber(),
          "photoUrl":currentUser.getphotoUrl(),
          "email": currentUser.getEmail(),
        });
      });
    }
    else _level = 0;
  }
  exit(){
    _id = null;
    _name = null;
    _type = null;
    _advertisement = null;
    _image = null;
    _description = null;
    _adv = false;
    _level = 0;
  }
}

CurrentUser currentUser = CurrentUser();

