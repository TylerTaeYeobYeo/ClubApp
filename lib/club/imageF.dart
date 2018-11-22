import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImagePage extends StatelessWidget {
  final List<File> images;
  final int index;
  ImagePage({@required this.images, @required this.index})
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
                title: Text("업로드 이미지"),
                centerTitle: true,
                floating: true,
                snap: true,
              ),
            ];
          },
          body: TabBarView(
            children: images.map((item){
              return PhotoViewInline(
                imageProvider: FileImage(item),
                heroTag: item.toString(),
              );
            }).toList(),
          ),
        )
      ),
    );
  }
}