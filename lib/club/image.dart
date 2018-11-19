import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  final File image;
  ImagePage({@required this.image}):assert(image!=null);
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 20.0),
      height: MediaQuery.of(context).size.height,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled){
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white70,
              title: Text("업로드 할 이미지"),
              centerTitle: true,
              floating: true,
              snap: true,
            ),
          ];
        },
        body: PhotoViewInline(
          imageProvider: FileImage(image),
        ),
      )
    );
  }
}