import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailClubPage extends StatefulWidget {
  final DocumentSnapshot data;
  DetailClubPage({Key key, @required this.data})
    : assert(data != null),
    super(key: key);
  _DetailClubPageState createState() => _DetailClubPageState(data: data);
}

class _DetailClubPageState extends State<DetailClubPage> {
  final DocumentSnapshot data;
  _DetailClubPageState({Key key, @required this.data})
    : assert(data != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height /4,
              floating: true,
              snap: true,
              title: Text(data.data['id']),
              centerTitle: true,
            )
          ];
        },
        body: ListView(),
      ),
    );
  }
}