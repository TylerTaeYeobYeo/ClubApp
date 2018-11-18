import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyzeUserPage extends StatefulWidget {
  final DocumentSnapshot data;
  AnalyzeUserPage({Key key, @required this.data})
    : assert(data != null);
  @override
  State<StatefulWidget> createState() => AnalyzeUserState(club: data);
}

class AnalyzeUserState extends State<AnalyzeUserPage> {
  final DocumentSnapshot club;
  AnalyzeUserState({Key key, @required this.club})
    : assert(club != null);
  List list =List();
  List<charts.Series<Item, String>> finalList;
  List<charts.Series<Item, String>> secondList;

  List<charts.Series<Item, String>> _initList(){
    int a=0, b=0, c=0, d=0;
    list.forEach((f){
      switch(f){
        case 0: a++;
          break;
        case 1: b++;
          break;
        case 2: c++;
          break;
        default: d++;
          break;
      }
    });
    final data = [
      new Item('활동', a),
      new Item('비활동', b),
      new Item('졸업생', c),
      new Item('미설정', d),
    ];

    return [
      new charts.Series<Item, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Item sales, _) => sales.name,
        measureFn: (Item sales, _) => sales.value,
        data: data,
      )
    ];
  }
  List<charts.Series<Item, String>> _secondList(){
    int a=0, b=0;
    list.forEach((f){
      switch(f){
        case 0: a++;
          break;
        case 1: b++;
          break;
      }
    });
    final data = [
      new Item('활동', a),
      new Item('비활동', b),
      // new Item('졸업생', c),
      // new Item('미설정', d),
    ];

    return [
      new charts.Series<Item, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Item sales, _) => sales.name,
        measureFn: (Item sales, _) => sales.value,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원 통계"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('clubs').document(club.documentID).collection('users').snapshots(),
        builder: (context, snapshots){
          if(!snapshots.hasData) return LinearProgressIndicator();
          list = snapshots.data.documents.map((data){
            return data.data['state'];
          }).toList();
          finalList = _initList();
          secondList = _secondList();
          return Stack(
            children: <Widget>[
              Center(
                child: Image.asset('assets/logo/logo1.png',fit: BoxFit.contain,color:Theme.of(context).primaryColor,)
              ),
              ListView(
                children: <Widget>[
                  Card(
                    child: Column(
                      children: <Widget>[
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: Text("전체 동아리 회원 분포"),
                          children: <Widget>[
                            ListTile(
                              title: Container(
                                height: MediaQuery.of(context).size.width*2/3,
                                // width: MediaQuery.of(context).size.width*2/3,
                                child: charts.PieChart(finalList,animate: true,
                                  defaultRenderer: charts.ArcRendererConfig(
                                    arcWidth: 60,
                                    arcRendererDecorators: [
                                      charts.ArcLabelDecorator(
                                        labelPosition: charts.ArcLabelPosition.inside
                                      )
                                    ]
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    child: Column(
                      children: <Widget>[
                        ExpansionTile(
                          initiallyExpanded: false,
                          title: Text("비졸업생 동아리 회원 분포"),
                          children: <Widget>[
                            ListTile(
                              title: Container(
                                height: MediaQuery.of(context).size.width*2/3,
                                // width: MediaQuery.of(context).size.width*2/3,
                                child: charts.BarChart(
                                  secondList,
                                  animate: true,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      )
    );
  }
}

class Item {
  final String name;  //label
  final int value;
  Item(this.name, this.value);
}
// Column(
        //   children: <Widget>[
        //     charts.PieChart(finalList,animate: true,
        //       defaultRenderer: charts.ArcRendererConfig(
        //         arcWidth: 40,
        //         startAngle: 2/5 * 3.141592, arcLength: 6 / 4 * 3.141592,
        //         arcRendererDecorators: [
        //           charts.ArcLabelDecorator(
        //             labelPosition: charts.ArcLabelPosition.inside
        //           )
        //         ]
        //       ),
        //     ),
        //     charts.PieChart(finalList,animate: true,
        //       defaultRenderer: charts.ArcRendererConfig(
        //         arcWidth: 60,
        //         arcRendererDecorators: [
        //           charts.ArcLabelDecorator(
        //             labelPosition: charts.ArcLabelPosition.inside
        //           )
        //         ]
        //       ),
        //     ),
        //   ],
        // ),