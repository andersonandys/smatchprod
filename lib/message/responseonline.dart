import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:video_player/video_player.dart';

class Responsonline extends StatefulWidget {
  Responsonline(
      {Key? key,
      required this.typereponse,
      required this.nameuser,
      required this.urlfile,
      required this.message,
      required this.idsend,
      required this.namefile})
      : super(key: key);
  String typereponse;
  String nameuser;
  String urlfile;
  String namefile;
  String message;
  String idsend;
  @override
  _ResponsonlineState createState() => _ResponsonlineState();
}

class _ResponsonlineState extends State<Responsonline> {
  String typemessage = "";
  String iduser = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.typereponse == "sms")
          Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: (widget.idsend == iduser)
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withBlue(30)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.nameuser,
                  style: const TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.message,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        if (widget.typereponse == "image" || widget.typereponse == "video")
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withBlue(20),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.nameuser,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Chip(
                        backgroundColor: Colors.blue,
                        avatar: (widget.typereponse == "image")
                            ? const Icon(
                                Icons.image,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.video_library,
                                color: Colors.white,
                              ),
                        label: (widget.typereponse == "image")
                            ? const Text(
                                'Image',
                                style: TextStyle(color: Colors.white),
                              )
                            : const Text(
                                'Video',
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  height: 80,
                  width: 80,
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  margin: const EdgeInsets.only(left: 10),
                  child: (widget.typereponse == "image")
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(
                            imageUrl: widget.urlfile,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Responseonlinevideo(
                            videourl: widget.urlfile,
                          ),
                        ),
                ),
              ],
            ),
          ),
        if (widget.typereponse == "audio" || widget.typereponse == "file")
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withBlue(20),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            width: MediaQuery.of(context).size.width / 1.3,
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(3),
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.nameuser,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      Chip(
                        backgroundColor: Colors.blue,
                        avatar: (widget.typereponse == "file")
                            ? const Icon(
                                Iconsax.document,
                                color: Colors.white,
                              )
                            : const Icon(
                                Iconsax.microphone_2,
                                color: Colors.white,
                              ),
                        label: (widget.typereponse == "file")
                            ? Text(
                                widget.namefile,
                                style: TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : const Text(
                                'Audio',
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}

class Responseonlinevideo extends StatefulWidget {
  Responseonlinevideo({Key? key, required this.videourl}) : super(key: key);
  String videourl;
  @override
  _ResponseonlinevideoState createState() => _ResponseonlinevideoState();
}

class _ResponseonlinevideoState extends State<Responseonlinevideo> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videourl)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings: const CustomVideoPlayerSettings(
          settingsButtonAvailable: false,
          showPlayButton: false,
          showDurationPlayed: false,
          showDurationRemaining: false,
          showFullscreenButton: false,
        ));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomVideoPlayer(
        customVideoPlayerController: _customVideoPlayerController);
  }
}
