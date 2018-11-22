import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class NetworkImagePage extends StatelessWidget {
  final List<dynamic> images;
  final int index;
  NetworkImagePage({@required this.images, @required this.index})
  :assert(images!=null), 
  assert(index!=null);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: images.length,
      initialIndex: index,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
            return <Widget>[
              SliverAppBar(
                backgroundColor: Colors.white70,
                title: Text("이미지"),
                centerTitle: true,
                floating: true,
                snap: true,
              ),
            ];
          },
          body: TabBarView(
            children: images.map((item){
              return Hero(
                tag: item.toString(),
                child: PhotoViewInline(
                  imageProvider: NetworkImage(item.toString()),
                ),
              );
            }).toList(),
          ),
        )
      ),
    );
  }
}