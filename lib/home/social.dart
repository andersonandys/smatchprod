import 'dart:convert';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/settingsvideo.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:timeago/timeago.dart' as timeago;

class Social extends StatefulWidget {
  const Social({Key? key}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  String idbranche = Get.arguments[0]["idbranche"];
  String nombranche = Get.arguments[1]["nombranche"];
  String idcreat = Get.arguments[2]["idcreat"];
  int admin = Get.arguments[3]["admin"];
  String affiche = Get.arguments[4]["affiche"];
  bool publi = Get.arguments[5]["publi"];
  final Stream<QuerySnapshot> streampub = FirebaseFirestore.instance
      .collection("publication")
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .orderBy("range", descending: true)
      .snapshots();
  final userid = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withBlue(30),
        appBar: AppBar(
          backgroundColor: Colors.black.withBlue(30),
          elevation: 0,
          title: Text(
            nombranche,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            if (publi || idcreat == userid)
              IconButton(
                  onPressed: () {
                    Get.toNamed("mypubsocial", arguments: [
                      {"idbranche": idbranche}
                    ]);
                  },
                  icon: const Icon(
                    Iconsax.edit,
                    size: 30,
                    color: Colors.white,
                  ))
          ],
        ),
        body: StreamBuilder(
          stream: streampub,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            int length = snapshot.data!.docs.length;
            List publi = snapshot.data!.docs;
            return (publi.isEmpty)
                ? EmptyWidget(
                    hideBackgroundAnimation: true,
                    image: "assets/inbox.png",
                    packageImage: null,
                    title: 'Aucune publication',
                    subTitle: 'Aucune publication disponible',
                    titleTextStyle: const TextStyle(
                      fontSize: 22,
                      color: Color(0xff9da9c7),
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: const TextStyle(
                      fontSize: 18,
                      color: Color(0xffabb8d6),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: length,
                        itemBuilder: (BuildContext, index) {
                          return GestureDetector(
                            onTap: () {
                              if (publi[index]["typecontenu"] == "image") {
                                Get.toNamed("viewsocial", arguments: [
                                  {"idpub": publi[index]["id"]},
                                  {"textpub": publi[index]["text"]},
                                  {"type": "image"},
                                  {"date": publi[index]["date"]},
                                  {"typecompte": publi[index]["typepub"]},
                                  {"idcomptepub": publi[index]["idpub"]}
                                ]);
                              } else {
                                Get.toNamed("viewsocial", arguments: [
                                  {"idpub": publi[index]["id"]},
                                  {"textpub": publi[index]["text"]},
                                  {"type": "video"},
                                  {"date": publi[index]["date"].toString()},
                                  {"typecompte": publi[index]["typepub"]},
                                  {"idcomptepub": publi[index]["idpub"]}
                                ]);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15))),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 60,
                                    constraints: BoxConstraints(
                                        maxHeight: 150,
                                        maxWidth:
                                            MediaQuery.of(context).size.width),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: (publi[index]["typepub"] ==
                                                  "compte")
                                              ? Displaylogo(
                                                  idnoeud: publi[index]
                                                      ["idpub"],
                                                  date: publi[index]["date"],
                                                )
                                              : Displayavatar(
                                                  iduser: publi[index]["idpub"],
                                                  date: publi[index]["date"],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  DetectableText(
                                    trimExpandedText: "Montrer moins",
                                    trimCollapsedText: "Montrer plus",
                                    moreStyle: const TextStyle(
                                        color: Colors.blueAccent, fontSize: 16),
                                    lessStyle: const TextStyle(
                                        color: Colors.blueAccent, fontSize: 18),
                                    trimLength: 150,
                                    text: publi[index]["text"],
                                    detectionRegExp: RegExp(
                                      "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
                                      multiLine: true,
                                    ),
                                    detectedStyle: const TextStyle(
                                        color: Colors.orange, fontSize: 18),
                                    basicStyle: const TextStyle(
                                        color: Colors.white, fontSize: 18),
                                    onTap: (tappedText) {
                                      Get.toNamed("/checklien", arguments: [
                                        {"url": tappedText}
                                      ]);
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (publi[index]["typecontenu"] == "image")
                                    Displayimage(
                                      idpub: snapshot.data!.docs[index].id,
                                      type: '',
                                      textpub: snapshot.data!.docs[index]
                                          ["text"],
                                    ),
                                  if (publi[index]["typecontenu"] == "video")
                                    Displayvideopub(
                                      idpub: snapshot.data!.docs[index]["id"],
                                      type: '',
                                      textpub: snapshot.data!.docs[index]
                                          ["text"],
                                      video: snapshot.data!.docs[index]
                                          ["video"],
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Displaylike(
                                    idpub: snapshot.data!.docs[index].id,
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: (publi || idcreat == userid)
            ? FloatingActionButton(
                onPressed: () {
                  Get.toNamed("/socialpub", arguments: [
                    {"nombranche": nombranche},
                    {"affiche": affiche},
                    {"idbranche": idbranche}
                  ]);
                },
                child: Icon(Icons.publish),
              )
            : null);
  }
}

class Displayavatar extends StatefulWidget {
  Displayavatar({Key? key, required this.iduser, required this.date})
      : super(key: key);
  String iduser;
  var date;
  @override
  _DisplayavatarState createState() => _DisplayavatarState();
}

class _DisplayavatarState extends State<Displayavatar> {
  late Stream<QuerySnapshot> streamuser = FirebaseFirestore.instance
      .collection("users")
      .where("iduser", isEqualTo: widget.iduser)
      .snapshots();
  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamuser,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userinfo = snapshot.data!.docs;
        return ListView.builder(
            shrinkWrap: true,
            itemCount: userinfo.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      CachedNetworkImageProvider(userinfo[index]["avatar"]),
                ),
                title: Text(
                  "${userinfo[index]["nom"]}",
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: (widget.date == 1)
                    ? null
                    : Text(
                        timeago.format(widget.date.toDate(), locale: "fr"),
                        style: const TextStyle(color: Colors.white38),
                      ),
              );
            });
      },
    );
  }
}

class Displaylogo extends StatefulWidget {
  Displaylogo({Key? key, required this.idnoeud, required this.date})
      : super(key: key);
  String idnoeud;
  var date;
  @override
  _DisplaylogoState createState() => _DisplaylogoState();
}

class _DisplaylogoState extends State<Displaylogo> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("branche")
      .where("idbranche", isEqualTo: widget.idnoeud)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        var userinfo = snapshot.data!.docs;
        return ListView.builder(
            shrinkWrap: true,
            itemCount: userinfo.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: (userinfo[index]["affiche"] != "")
                      ? CachedNetworkImageProvider(userinfo[index]["affiche"])
                      : null,
                ),
                title: Text(
                  "${userinfo[index]["nom"]}",
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: (widget.date == 1)
                    ? null
                    : Text(
                        timeago.format(widget.date.toDate(), locale: "fr"),
                        style: TextStyle(color: Colors.white38),
                      ),
              );
            });
      },
    );
  }
}

class Displayimage extends StatefulWidget {
  Displayimage(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub})
      : super(key: key);
  String idpub;
  String type;
  String textpub;
  @override
  _DisplayimageState createState() => _DisplayimageState();
}

class _DisplayimageState extends State<Displayimage> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("image")
      .snapshots();
  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List imagepub = snapshot.data!.docs;
        int length = snapshot.data!.docs.length;
        return Column(
          children: <Widget>[
            CarouselSlider.builder(
              itemCount: length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      GestureDetector(
                          onTap: () {
                            if (widget.type == "look") {
                              Get.toNamed("viewimage", arguments: [
                                {"urlfile": imagepub[itemIndex]["image"]}
                              ]);
                            } else {
                              Get.toNamed("viewsocial", arguments: [
                                {"idpub": widget.idpub},
                                {"textpub": widget.textpub},
                                {"type": "image"}
                              ]);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            constraints: const BoxConstraints(
                                minHeight: 300, maxHeight: 300),
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              child: CachedNetworkImage(
                                imageUrl: imagepub[itemIndex]["image"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
              options: CarouselOptions(
                height: 320,
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1,
                aspectRatio: 2.0,
                initialPage: 0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imagepub.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.orange
                                  : Colors.blueAccent)
                              .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        );
      },
    );
  }
}

class Displayvideo extends StatefulWidget {
  Displayvideo(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub})
      : super(key: key);
  String idpub;
  String type;
  String textpub;
  @override
  _DisplayvideoState createState() => _DisplayvideoState();
}

class _DisplayvideoState extends State<Displayvideo> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("video")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List imagepub = snapshot.data!.docs;
        int length = snapshot.data!.docs.length;
        return Column(
          children: <Widget>[
            CarouselSlider.builder(
              itemCount: length,
              itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      GestureDetector(
                onTap: () {
                  if (widget.type == "look") {
                    Get.toNamed("viewvideo", arguments: [
                      {"urlfile": imagepub[itemIndex]["video"]}
                    ]);
                  } else {
                    Get.toNamed("viewsocial", arguments: [
                      {"idpub": widget.idpub},
                      {"textpub": widget.textpub},
                      {"type": "video"}
                    ]);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: imagepub[itemIndex]["image"],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              options: CarouselOptions(
                  height: 300,
                  enlargeStrategy: CenterPageEnlargeStrategy.height),
            ),
          ],
        );
      },
    );
  }
}

class Displaylike extends StatefulWidget {
  Displaylike({
    Key? key,
    required this.idpub,
  }) : super(key: key);
  String idpub;
  @override
  _DisplaylikeState createState() => _DisplaylikeState();
}

class _DisplaylikeState extends State<Displaylike> {
  late Stream<QuerySnapshot> streamnoeud = FirebaseFirestore.instance
      .collection("publication")
      .doc(widget.idpub)
      .collection("userlike")
      .where("iduserlike", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
  late Stream<QuerySnapshot> like = FirebaseFirestore.instance
      .collection("publication")
      .where("id", isEqualTo: widget.idpub)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamnoeud,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        int length = snapshot.data!.docs.length;
        return StreamBuilder(
          stream: like,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> likedata) {
            if (!likedata.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else if (likedata.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return (likedata.data!.docs.isEmpty)
                ? Row(
                    children: <Widget>[
                      ActionChip(
                        backgroundColor: Colors.black.withBlue(30),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection("publication")
                              .doc(widget.idpub)
                              .collection("userlike")
                              .add({
                            "iduserlike": FirebaseAuth.instance.currentUser!.uid
                          });
                          FirebaseFirestore.instance
                              .collection("publication")
                              .doc(widget.idpub)
                              .update({"nbrelike": FieldValue.increment(1)});
                        },
                        padding: const EdgeInsets.all(10),
                        label: const Text(
                          "0",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        avatar: const Icon(Iconsax.heart, color: Colors.white),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ActionChip(
                        backgroundColor: Colors.black.withBlue(30),
                        onPressed: () {},
                        padding: const EdgeInsets.all(10),
                        label: const Text(
                          "0",
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                        avatar:
                            const Icon(Iconsax.message, color: Colors.white),
                      )
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: likedata.data!.docs.length,
                    itemBuilder: (BuildContext, index) {
                      return (likedata.data!.docs.isEmpty)
                          ? CircularProgressIndicator()
                          : Row(
                              children: <Widget>[
                                ActionChip(
                                  backgroundColor: Colors.black.withBlue(30),
                                  onPressed: () {
                                    if (length == 0) {
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .collection("userlike")
                                          .add({
                                        "iduserlike": FirebaseAuth
                                            .instance.currentUser!.uid
                                      });
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .update({
                                        "nbrelike": FieldValue.increment(1)
                                      });
                                    } else {
                                      print(snapshot.data!.docs.first.id);
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .collection("userlike")
                                          .doc(snapshot.data!.docs.first.id)
                                          .delete();
                                      FirebaseFirestore.instance
                                          .collection("publication")
                                          .doc(widget.idpub)
                                          .update({
                                        "nbrelike": FieldValue.increment(-1)
                                      });
                                    }
                                  },
                                  padding: const EdgeInsets.all(10),
                                  label: Text(
                                    "${likedata.data!.docs[index]["nbrelike"]}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  avatar: Icon(Iconsax.heart5,
                                      color: (length == 1)
                                          ? Colors.red
                                          : Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ActionChip(
                                  backgroundColor: Colors.black.withBlue(30),
                                  onPressed: () {},
                                  padding: const EdgeInsets.all(10),
                                  label: Text(
                                    "${likedata.data!.docs[index]["nbrecomment"]}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 17),
                                  ),
                                  avatar: const Icon(Iconsax.message5,
                                      color: Colors.white),
                                )
                              ],
                            );
                    });
          },
        );
      },
    );
  }
}

class Displayvideopub extends StatefulWidget {
  Displayvideopub(
      {Key? key,
      required this.idpub,
      required this.type,
      required this.textpub,
      required this.video})
      : super(key: key);
  String idpub;

  String type;

  String textpub;
  String video;
  @override
  _DisplayvideopubState createState() => _DisplayvideopubState();
}

class _DisplayvideopubState extends State<Displayvideopub> {
  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String videoUrl =
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

    videoPlayerController = VideoPlayerController.network(widget.video)
      ..initialize().then((value) => setState(() {}));
    _customVideoPlayerController = CustomVideoPlayerController(
        context: context,
        videoPlayerController: videoPlayerController,
        customVideoPlayerSettings:
            CustomVideoPlayerSettings(settingsButtonAvailable: false));
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("ok");
        Get.toNamed("viewsocial", arguments: [
          {"idpub": widget.idpub},
          {"textpub": widget.textpub},
          {"type": "video"},
          {"video": widget.video}
        ]);
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CustomVideoPlayer(
              customVideoPlayerController: _customVideoPlayerController,
            ),
          )),
    );
  }
}

class Mypublicationsocial extends StatefulWidget {
  const Mypublicationsocial({Key? key}) : super(key: key);

  @override
  _MypublicationsocialState createState() => _MypublicationsocialState();
}

class _MypublicationsocialState extends State<Mypublicationsocial> {
  final instance = FirebaseFirestore.instance;
  final Stream<QuerySnapshot> streamepublication = FirebaseFirestore.instance
      .collection("publication")
      .where("idpub", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where("idbranche", isEqualTo: Get.arguments[0]["idbranche"])
      .snapshots();
  final req = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
        title: const Text('Mes publications'),
      ),
      body: StreamBuilder(
        stream: streamepublication,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          int length = snapshot.data!.docs.length;
          List datavideo = snapshot.data!.docs;
          return (datavideo.isEmpty)
              ? EmptyWidget(
                  hideBackgroundAnimation: true,
                  image: "assets/inbox.png",
                  packageImage: null,
                  title: 'Aucun contenu',
                  subTitle: "Aucun contenu publier pour l'intant",
                  titleTextStyle: const TextStyle(
                    fontSize: 22,
                    color: Color(0xff9da9c7),
                    fontWeight: FontWeight.w500,
                  ),
                  subtitleTextStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xffabb8d6),
                  ),
                )
              : ListView.builder(
                  itemCount: length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext, index) {
                    return Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (datavideo[index]["typecontenu"] == "image")
                            Displayimage(
                                idpub: datavideo[index]["id"],
                                type: datavideo[index]["typecontenu"],
                                textpub: datavideo[index]["text"]),
                          if (datavideo[index]["typecontenu"] == "video")
                            Container(
                              height: 300,
                              child: DisplaySettingsvideo(
                                  url: datavideo[index]["video"]),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            datavideo[index]["text"],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Chip(
                                      backgroundColor:
                                          Colors.black.withBlue(20),
                                      padding: const EdgeInsets.all(10),
                                      avatar: const Icon(
                                        Iconsax.heart,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "${datavideo[index]["nbrelike"]} ",
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Chip(
                                      backgroundColor:
                                          Colors.black.withBlue(20),
                                      padding: const EdgeInsets.all(10),
                                      avatar: const Icon(
                                        Iconsax.message,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        "${datavideo[index]["nbrecomment"]} ",
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ))
                                ],
                              ),
                              ActionChip(
                                  onPressed: () {
                                    Get.defaultDialog(
                                        onConfirm: () {
                                          instance
                                              .collection("publication")
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .delete();
                                          Navigator.of(context).pop();
                                          req.message("success",
                                              "Publication supprime avec succes");
                                        },
                                        textCancel: "Annuler",
                                        textConfirm: "Supprimer",
                                        title: "Confirmation",
                                        content: const Text(
                                            "Voulez vous vraiment supprimer cette publication ?"),
                                        confirmTextColor: Colors.white);
                                  },
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.all(10),
                                  avatar: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Supprimer',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ))
                            ],
                          )
                        ],
                      ),
                    );
                  });
        },
      ),
    );
  }
}
