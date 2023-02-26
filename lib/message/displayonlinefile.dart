import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:smatch/message/optionmessage.dart';
import 'package:smatch/message/viewimage.dart';

class Displayonlinefile extends StatefulWidget {
  Displayonlinefile({
    Key? key,
    required this.idmessage,
    required this.idsend,
    required this.message,
    required this.typemessage,
    required this.namesend,
    required this.avatarsend,
    required this.reponsefilename,
  }) : super(key: key);
  late String idmessage;
  String avatarsend;

  String message;

  String typemessage;

  String namesend;

  String idsend;
  String reponsefilename;
  @override
  _DisplayonlinefileState createState() => _DisplayonlinefileState();
}

class _DisplayonlinefileState extends State<Displayonlinefile> {
  String typecontent = "";
  final instance = FirebaseFirestore.instance.collection("message");
  late Stream<QuerySnapshot> mediastream = FirebaseFirestore.instance
      .collection('fileUploads')
      .where("idmessage", isEqualTo: widget.idmessage)
      .snapshots();
  final mscontrol = Get.put(Messagecontroller());
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: mediastream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        int length = snapshot.data!.docs.length;
        List media = snapshot.data!.docs;
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (media[index]
                                  ["extension"]
                              .toString()
                              .toLowerCase() ==
                          "png" ||
                      media[index]["extension"].toString().toLowerCase() ==
                          "jpg" ||
                      media[index]["extension"].toString().toLowerCase() ==
                          "jpeg")
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Viewimage(
                                    url: media[index]["urlfile"],
                                  )),
                        );
                      },
                      onLongPress: () {
                        mscontrol.urlreponse.value = media[index]["urlfile"];
                        mscontrol.namefilereponse.value =
                            media[index]["namefile"];
                        Get.bottomSheet(SingleChildScrollView(
                          child: Optionmessage(
                            idmessage: widget.idmessage,
                            idsend: widget.idsend,
                            typemessage: "image",
                            message: widget.message,
                            namereponse: widget.namesend,
                            avataruser: widget.avatarsend,
                          ),
                        ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            maxHeight: 200,
                            minHeight: 50),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: (media[index]["urlfile"].toString().isNotEmpty)
                            ? ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Image.network(
                                  // fit: BoxFit.cover,
                                  media[index]["urlfile"],
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    // Si une erreur se produit lors du chargement de l'image, on affiche l'image de secours
                                    return const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "Erreur de chargement de l'image, cette image n'est plus disponible",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                    );
                                  },
                                ))
                            : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: Image.file(
                                      File(media[index]["localpath"]),
                                      fit: BoxFit.cover,
                                      height: 200,
                                      width: 500,
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100))),
                                      child: const CircularProgressIndicator(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5,
                                    right: 10,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.black.withBlue(30),
                                      radius: 20,
                                      child: CircularPercentIndicator(
                                        radius: 20.0,
                                        lineWidth: 3.0,
                                        percent: media[index]["percente"] / 100,
                                        center: const Icon(
                                          Icons.upload,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.grey,
                                        progressColor: Colors.redAccent,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                  if (media[index]["extension"].toString().toLowerCase() ==
                      "mp4")
                    GestureDetector(
                      onLongPress: () {
                        mscontrol.urlreponse.value = media[index]["urlfile"];
                        mscontrol.namefilereponse.value =
                            media[index]["namefile"];
                        Get.bottomSheet(SingleChildScrollView(
                          child: Optionmessage(
                            idmessage: widget.idmessage,
                            idsend: widget.idsend,
                            typemessage: "video",
                            message: widget.message,
                            namereponse: widget.namesend,
                            avataruser: widget.avatarsend,
                          ),
                        ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(5),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.1)),
                        height: 300,
                        width: 400,
                        child: (media[index]["finish"] == true)
                            ? ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: displayvideonly(
                                  videourl: media[index]["urlfile"],
                                  type: 'online',
                                ),
                              )
                            : Container(
                                height: 300,
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.grey.withOpacity(0.2)),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      child: displayvideonly(
                                        videourl: media[index]["pathlocal"],
                                        type: 'local',
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100))),
                                        child: const CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      right: 10,
                                      child: CircularPercentIndicator(
                                        radius: 20.0,
                                        lineWidth: 3.0,
                                        percent: media[index]["percente"] / 100,
                                        center: const Icon(
                                          Icons.upload_rounded,
                                          color: Colors.white,
                                        ),
                                        backgroundColor: Colors.grey,
                                        progressColor: Colors.redAccent,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                  if (media[index]["extension"] == 'm4a')
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blueAccent),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: <Widget>[
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 20,
                                child: IconButton(
                                  color: Colors.black,
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    if (isPlaying) {
                                      player.pause();
                                    } else {
                                      player.play(
                                          UrlSource(media[index]["urlfile"]));
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white.withOpacity(0.5),
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  value: position.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    final position =
                                        Duration(seconds: value.toInt());
                                    player.seek(position);
                                    player.resume();
                                  },
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTime(duration.inSeconds),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Text(
                                  formatTime((duration - position).inSeconds),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (media[index]["extension"] == 'pdf')
                    GestureDetector(
                      onLongPress: () {
                        mscontrol.urlreponse.value = media[index]["urlfile"];
                        mscontrol.namefilereponse.value =
                            media[index]["namefile"];
                        Get.bottomSheet(SingleChildScrollView(
                          child: Optionmessage(
                            idmessage: widget.idmessage,
                            idsend: widget.idsend,
                            typemessage: "file",
                            message: widget.message,
                            namereponse: widget.namesend,
                            avataruser: widget.avatarsend,
                          ),
                        ));
                      },
                      child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
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
                                      widget.reponsefilename,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Chip(
                                      backgroundColor: Colors.blue,
                                      avatar: (media[index]["finish"] == true)
                                          ? const Icon(
                                              Iconsax.document,
                                              color: Colors.white,
                                            )
                                          : const CircularProgressIndicator(
                                              color: Colors.redAccent,
                                              strokeWidth: 2,
                                            ),
                                      label: const Text(
                                        'Document',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Spacer(),
                              (media[index]["finish"] == true)
                                  ? Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      margin: const EdgeInsets.only(
                                        right: 10,
                                      ),
                                      child: const Icon(
                                        Icons.file_download,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )
                                  : CircularPercentIndicator(
                                      radius: 20.0,
                                      lineWidth: 3.0,
                                      percent: media[index]["percente"] / 100,
                                      center: const Icon(
                                        Icons.upload_rounded,
                                        color: Colors.white,
                                      ),
                                      backgroundColor: Colors.grey,
                                      progressColor: Colors.redAccent,
                                    ),
                            ],
                          )),
                    ),
                ],
              );
            });
      },
    );
  }
}

class displayvideonly extends StatefulWidget {
  displayvideonly({Key? key, required this.videourl, required this.type})
      : super(key: key);
  String videourl;
  String type;
  @override
  _displayvideonlyState createState() => _displayvideonlyState();
}

class _displayvideonlyState extends State<displayvideonly> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    super.initState();
    if (widget.type == "online") {
      videoPlayerController = VideoPlayerController.network(widget.videourl)
        ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: videoPlayerController,
          customVideoPlayerSettings:
              const CustomVideoPlayerSettings(settingsButtonAvailable: false));
    }
    if (widget.type == "local") {
      videoPlayerController = VideoPlayerController.file(File(widget.videourl))
        ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: videoPlayerController,
          customVideoPlayerSettings:
              const CustomVideoPlayerSettings(settingsButtonAvailable: false));
    }
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
