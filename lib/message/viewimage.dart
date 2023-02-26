import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';

class Viewimage extends StatefulWidget {
  Viewimage({Key? key, required this.url}) : super(key: key);
  String url;
  @override
  _ViewimageState createState() => _ViewimageState();
}

class _ViewimageState extends State<Viewimage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(20),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.url),
      ),
    );
  }
}
