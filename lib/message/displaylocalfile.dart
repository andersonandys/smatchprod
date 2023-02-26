import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/message/displayonlinefile.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:smatch/message/responseonline.dart';
import 'package:smatch/message/selectlocalfile.dart';

class Displaylocalfile extends StatefulWidget {
  Displaylocalfile({
    Key? key,
    required this.idmessage,
  }) : super(key: key);
  String idmessage;

  @override
  _DisplaylocalfileState createState() => _DisplaylocalfileState();
}

class _DisplaylocalfileState extends State<Displaylocalfile> {
  final smscontroller = Get.put(Messagecontroller());
  late Stream<QuerySnapshot> streammedia = FirebaseFirestore.instance
      .collection("message")
      .doc(widget.idmessage)
      .collection("media")
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            Column(
              children: <Widget>[
                if (smscontroller.typereponse.value == 'sms')
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          smscontroller.nomreponse.value,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          smscontroller.messagereponse.value,
                          maxLines: 3,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        )
                      ],
                    ),
                  ),
                if (smscontroller.typereponse.value == "image" ||
                    smscontroller.typereponse.value == "video")
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    margin: const EdgeInsets.only(left: 10),
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
                                smscontroller.nomreponse.value,
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold),
                              ),
                              media(idmessage: widget.idmessage),
                              // Chip(
                              //   backgroundColor: Colors.blue,
                              //   avatar:
                              //       (smscontroller.typereponse.value == "image")
                              //           ? const Icon(
                              //               Icons.image,
                              //               color: Colors.white,
                              //             )
                              //           : const Icon(
                              //               Icons.video_library,
                              //               color: Colors.white,
                              //             ),
                              //   label: (smscontroller.typereponse.value ==
                              //           "image")
                              //       ? const Text(
                              //           'vimage',
                              //           style: TextStyle(color: Colors.white),
                              //         )
                              //       : const Text(
                              //           'Video',
                              //           style: TextStyle(color: Colors.white),
                              //         ),
                              // )
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                if (smscontroller.typereponse.value == "audio" ||
                    smscontroller.typereponse.value == "file")
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    margin: const EdgeInsets.only(left: 10),
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
                                smscontroller.nomreponse.value,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              Chip(
                                backgroundColor: Colors.blue,
                                avatar:
                                    (smscontroller.typereponse.value == "file")
                                        ? const Icon(
                                            Iconsax.document,
                                            color: Colors.white,
                                          )
                                        : const Icon(
                                            Iconsax.microphone_2,
                                            color: Colors.white,
                                          ),
                                label: (smscontroller.typereponse.value ==
                                        "file")
                                    ? Text(
                                        smscontroller.namefilereponse.value,
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
            ),
            Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    smscontroller.typereponse.value = "";
                  },
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close),
                  ),
                ))
          ],
        ));
  }
}

class media extends StatefulWidget {
  const media({Key? key, required this.idmessage}) : super(key: key);
  final idmessage;
  @override
  _mediaState createState() => _mediaState();
}

class _mediaState extends State<media> {
  late Stream<QuerySnapshot> media = FirebaseFirestore.instance
      .collection('message')
      .doc(widget.idmessage)
      .collection("media")
      .snapshots();
  List data = [];
  final smscontroller = Get.put(Messagecontroller());
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: media,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        data = snapshot.data!.docs;
        return Column(
          children: <Widget>[
            if (smscontroller.typereponse.value == "video")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Responseonlinevideo(
                          videourl: smscontroller.urlreponse.value),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Video',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            if (smscontroller.typereponse.value == "image")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: smscontroller.urlreponse.value,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Reponse image',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
          ],
        );
      },
    );
  }
}
