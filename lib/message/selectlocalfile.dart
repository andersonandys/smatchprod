import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/messagecontroller.dart';

class Selectlocalfile extends StatefulWidget {
  const Selectlocalfile({Key? key}) : super(key: key);

  @override
  _SelectlocalfileState createState() => _SelectlocalfileState();
}

class _SelectlocalfileState extends State<Selectlocalfile> {
  final smscontroller = Get.put(Messagecontroller());
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  Widget build(BuildContext context) {
    return Obx((() => Column(
          children: <Widget>[
            if (smscontroller.filedisplay.isNotEmpty)
              Container(
                width: MediaQuery.of(context).size.width / 1.3,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                height: 180,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: smscontroller.filedisplay.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: <Widget>[
                          Stack(
                            children: [
                              Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      // color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  constraints:
                                      const BoxConstraints(maxHeight: 150),
                                  width: 190,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: (smscontroller.filedisplay[index]
                                                    ["extension"] ==
                                                "jpg" ||
                                            smscontroller.filedisplay[index]
                                                    ["extension"] ==
                                                "png" ||
                                            smscontroller.filedisplay[index]
                                                    ["extension"] ==
                                                "jpeg")
                                        ? Container(
                                            height: 180,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: FileImage(File(
                                                        smscontroller
                                                                    .filedisplay[
                                                                index]
                                                            ["localpath"])),
                                                    fit: BoxFit.cover)),
                                          )
                                        : (smscontroller.filedisplay[index]
                                                    ["extension"] ==
                                                "mp4")
                                            ? Container(
                                                height: 180,
                                                child: Videolocale(
                                                  urlvideo: smscontroller
                                                          .filedisplay[index]
                                                      ["localpath"],
                                                ),
                                              )
                                            : (smscontroller.filedisplay[index]
                                                            ["extension"] ==
                                                        "pdf" ||
                                                    smscontroller.filedisplay[
                                                                index]
                                                            ["extension"] ==
                                                        "docx")
                                                ? Container(
                                                    height: 100,
                                                    width: MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        1.3,
                                                    child: ListTile(
                                                      leading: const Icon(
                                                          Iconsax.document,
                                                          color: Colors.white,
                                                          size: 30),
                                                      title: Text(
                                                        smscontroller
                                                                .filedisplay[
                                                            index]["name"],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ))
                                                : SizedBox(),
                                  )),
                              Positioned(
                                right: 0,
                                child: GestureDetector(
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onTap: () {
                                    smscontroller.filedisplay.removeAt(index);
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      );
                    }),
              )
          ],
        )));
  }
}

class Videolocale extends StatefulWidget {
  Videolocale({Key? key, required this.urlvideo}) : super(key: key);
  String urlvideo;
  @override
  _VideolocaleState createState() => _VideolocaleState();
}

class _VideolocaleState extends State<Videolocale> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(widget.urlvideo))
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
            settingsButtonAvailable: false, showFullscreenButton: false));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomVideoPlayer(
          customVideoPlayerController: _customVideoPlayerController),
    );
  }
}
