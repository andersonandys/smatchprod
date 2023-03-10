import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/social.dart';

class Viewsocial extends StatefulWidget {
  const Viewsocial({Key? key}) : super(key: key);

  @override
  _ViewsocialState createState() => _ViewsocialState();
}

class _ViewsocialState extends State<Viewsocial> {
  String idpub = Get.arguments[0]["idpub"];
  String textpub = Get.arguments[1]["textpub"];
  String typepub = Get.arguments[2]["type"];
  String typecompte = Get.arguments[4]["typecompte"];
  String idcomptepub = Get.arguments[5]["idcomptepub"];

  String nomuser = "";
  String avataruser = "";

  late VideoPlayerController videoPlayerController;
  late CustomVideoPlayerController _customVideoPlayerController;
  String userid = FirebaseAuth.instance.currentUser!.uid;
  final instance = FirebaseFirestore.instance;
  final commentcontroller = TextEditingController();
  final Stream<QuerySnapshot> streamcomment = FirebaseFirestore.instance
      .collection("publication")
      .doc(Get.arguments[0]["idpub"])
      .collection("comment")
      .snapshots();
  List alluser = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (typepub == "video") {
      videoPlayerController =
          VideoPlayerController.network(Get.arguments[3]["video"])
            ..initialize().then((value) => setState(() {}));
      _customVideoPlayerController = CustomVideoPlayerController(
          context: context,
          videoPlayerController: videoPlayerController,
          customVideoPlayerSettings:
              CustomVideoPlayerSettings(settingsButtonAvailable: false));
    }

    getinfouser();
    getuser();
    print(typepub);
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      nomuser = querySnapshot.docs.first['nom'];
      avataruser = querySnapshot.docs.first['avatar'];
    });
  }

  getuser() {
    FirebaseFirestore.instance.collection('users').get().then((data) {
      setState(() {
        alluser = data.docs;
      });
    });
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(30),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Expanded(
              child: (typecompte == "compte")
                  ? Displaylogo(
                      idnoeud: idcomptepub,
                      date: 1,
                    )
                  : Displayavatar(
                      iduser: idcomptepub,
                      date: 1,
                    ),
            ),
          ),
          Expanded(
              child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    // color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      textpub,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    if (typepub == "image")
                      Displayimage(
                        idpub: idpub,
                        type: 'look',
                        textpub: '',
                      ),
                    if (typepub == "video")
                      Container(
                        padding: const EdgeInsets.all(5),
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomVideoPlayer(
                              customVideoPlayerController:
                                  _customVideoPlayerController),
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Displaylike(idpub: idpub),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Commentaire',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                      stream: streamcomment,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        int length = snapshot.data!.docs.length;
                        List comment = snapshot.data!.docs;
                        return (comment.isEmpty)
                            ? EmptyWidget(
                                hideBackgroundAnimation: true,
                                image: "assets/inbox.png",
                                packageImage: null,
                                title: 'Aucun commentaire',
                                subTitle: 'Soyez le premier a commenter',
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
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: length,
                                itemBuilder: (BuildContext, index) {
                                  return Column(
                                    children: <Widget>[
                                      for (var users in alluser)
                                        if (users["iduser"] ==
                                            comment[index]['iduser'])
                                          Row(
                                            // mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        users['avatar']),
                                              ),
                                              BubbleSpecialThree(
                                                text:
                                                    "${users["nom"]} \n ${comment[index]['message']} ",
                                                color: Color(0xFFE8E8EE),
                                                tail: true,
                                                isSender: false,
                                              )
                                            ],
                                          ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  );
                                });
                      },
                    )
                  ],
                ),
              )
            ],
          )),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(avataruser),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                    child: TextFormField(
                  style: const TextStyle(fontSize: 18),
                  controller: commentcontroller,
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    filled: false,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    labelStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                  ),
                )),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    sendcomment();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(50)),
                    height: 40,
                    width: 40,
                    child: const Icon(
                      Iconsax.send1,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sendcomment() {
    instance.collection('publication').doc(idpub).collection("comment").add({
      "message": commentcontroller.text,
      'range': DateTime.now().millisecondsSinceEpoch,
      "iduser": userid,
      "date": DateTime.now()
    });
    instance
        .collection('publication')
        .doc(idpub)
        .update({"nbrecomment": FieldValue.increment(1)});
    print('send');
    setState(() {
      commentcontroller.text = "";
    });
  }
}
