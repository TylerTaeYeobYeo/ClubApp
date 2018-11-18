import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  final DocumentSnapshot data;
  ContactPage({Key key, @required this.data})
    : assert(data != null);
  @override
  State<StatefulWidget> createState() =>_ContactPageState(data:data);

}

class _ContactPageState extends State<ContactPage>{
  final DocumentSnapshot data;
  TextEditingController _search = TextEditingController();
  Stream<QuerySnapshot> term;
  String strSearch = "a";
  int strlength;
  var strFrontCode;
  String strEndCode;

  String startcode;
  String endcode;

  @override
  void initState() {
    term = Firestore.instance.collection('clubs').document(data.documentID).collection('users').snapshots();
    super.initState();
  }

  @override
  void dispose() { 
    _search.dispose();
    super.dispose();
  }  
  
  @override
  _ContactPageState({Key key, @required this.data})
    : assert(data != null);
  
  _call(url) async {
    String call = "tel://" + url;
    if (await canLaunch(call)) {
      await launch(call);
    } else {
      print("failed");
    }
  }

  _mail(url) async {
    if (url != ""){
      String call = "mailto:" + url;
      if (await canLaunch(call)) {
        await launch(call);
      } else {
        print("failed");
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("연락처"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
          ),
          Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Text("검색"),
                  title: TextField(
                    controller: _search,
                    maxLength: 30,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: (){
                      setState(() {
                        if(_search.text =="") term = Firestore.instance.collection('clubs').document(data.documentID).collection('users').orderBy("name").snapshots();
                        else {
                          term = Firestore.instance.collection('clubs').document(data.documentID).collection('users').where("name", isGreaterThanOrEqualTo: startcode).where("name", isLessThan: endcode).orderBy("name").snapshots();
                          strSearch = _search.text;
                          strlength = strSearch.length;
                          strFrontCode = strSearch.substring(0, strlength-1);
                          strEndCode = strSearch.substring(strlength-1, strSearch.length);
                          startcode = strSearch;
                          endcode= strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
                        }
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: term,
                  builder: (context, snapshots){
                    return ListView(
                      children: snapshots.data.documents.map((user){
                        int a = user.data['level'];
                        String state = "";
                        if(user.data['state']!= null){
                          switch(user.data['state']){
                            case 0:
                              state = "회장";
                              break;
                            case 1:
                              state = "부회장";
                              break;
                            case 2:
                              state = "총무";
                              break;
                            default:
                              state = "그 외";
                              break;
                          }
                        }
                        return Card(
                          // color: Colors.white70,
                          child: ExpansionTile(
                            trailing: a>2?Icon(Icons.star,color: Colors.yellow,):null,
                            title: Text(user.data['name']),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.data['photoUrl']),
                            ),
                            children: <Widget>[
                              a>2?ListTile(
                                leading: Icon(Icons.star,color: Colors.yellow,),
                                title: Text("임원"),
                                trailing: Text(state),
                              ):SizedBox(),
                              ListTile(
                                leading: Icon(Icons.email,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                                title: Text("email:"),
                                trailing: Text(user.data['email'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                onTap: ()=>_mail(user.data['email']),
                              ),
                              ListTile(
                                leading: Icon(Icons.call,
                                  color: Colors.green,
                                ),
                                title: Text("전화번호:"),
                                trailing: Text(user.data['phoneNumber'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                onTap: ()=>_call(user.data['phoneNumber']),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            ],
          )
        ],
      )
    );
  }
}