import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:iconsax/iconsax.dart';
import 'package:isolate_flutter/isolate_flutter.dart';
import 'package:record/record.dart';
import 'package:smatch/home/empty.dart';
import 'package:smatch/message/displaylocalfile.dart';
import 'package:smatch/message/displayonlinefile.dart';
import 'package:smatch/message/messagecontroller.dart';
import 'package:smatch/message/optionmessage.dart';
import 'package:smatch/message/responseonline.dart';
import 'package:smatch/message/selectlocalfile.dart';
import 'package:smatch/message/suggestion.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:http/http.dart' as http;

class Message extends StatefulWidget {
  const Message({Key? key}) : super(key: key);

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  IsolateFlutter? _isolateFlutter;
  String idbranche = Get.arguments[0]['idbranche'];
  String nombranche = Get.arguments[1]['nombranche'];
  String idcreat = Get.arguments[2]['idcreat'];
  int admin = Get.arguments[3]['admin'];
  String token = Get.arguments[4]['token'];
  String logobranche = Get.arguments[5]['affiche'];
  String path = "";
  final instance = FirebaseFirestore.instance;
  double progress = 0.0;
  String filename = "";
  String data = "";
  final smscontrol = Get.put(Messagecontroller());
  String iduser = FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot> messagestream = FirebaseFirestore.instance
      .collection('message')
      .where("idbranche", isEqualTo: Get.arguments[0]['idbranche'])
      .snapshots();
  String nomusers = "";
  String avataruser = "";

  int _recordDuration = 0;
  Timer? _timer;
  final _audioRecorder = Record();
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  final listViewController = FlutterListViewController();
  @override
  void initState() {
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() => _recordState = recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) => setState(() => _amplitude = amp));
    getinfouser();
    super.initState();
  }

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // We don't do anything with this but printing
        final isSupported = await _audioRecorder.isEncoderSupported(
          AudioEncoder.aacLc,
        );
        if (kDebugMode) {
          print('${AudioEncoder.aacLc.name} supported: $isSupported');
        }

        // final devs = await _audioRecorder.listInputDevices();
        // final isRecording = await _audioRecorder.isRecording();

        await _audioRecorder.start();
        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    _recordDuration = 0;

    final path = await _audioRecorder.stop();
    if (path != null) {
      smscontrol.typemessage.value = "nv";
      smscontrol.filelist.add(path);

      smscontrol.extension.value = "m4a";
      print(path);
      smscontrol.sendmessage(idbranche, nomusers, avataruser);
    }
  }

  Future<void> _pause() async {
    _timer?.cancel();
    await _audioRecorder.pause();
  }

  Future<void> _resume() async {
    _startTimer();
    await _audioRecorder.resume();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      for (var elememt in value.docs) {
        nomusers = elememt['nom'];
        avataruser = elememt['avatar'];
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(20),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: SafeArea(
              child: ListTile(
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                )),
            title: Text(
              nombranche,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            // subtitle: Text(
            //   "En ligne",
            //   style: const TextStyle(color: Colors.white),
            // ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.call,
                        color: Colors.white,
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed("/settingsbranche/", arguments: [
                      {"idbranche": idbranche},
                      {"admin": admin},
                      {"nombranche": nombranche},
                      {"idcreat": idcreat},
                    ]);
                  },
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(logobranche),
                  ),
                ),
              ],
            ),
          ))),
      body: Obx(() => GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: StreamBuilder(
                    stream: messagestream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return (snapshot.data!.docs.isEmpty)
                          ? const Empty()
                          : StickyGroupedListView(
                              shrinkWrap: true,
                              reverse: true,
                              order: StickyGroupedListOrder.DESC,
                              elements: snapshot.data!.docs,
                              groupBy: (dynamic element) => element['range'],
                              //  itemScrollController: itemScrollController, // optional
                              groupSeparatorBuilder: (dynamic element) =>
                                  const SizedBox(),
                              itemBuilder: (context, dynamic message) {
                                return Container(
                                  child: Row(
                                    children: <Widget>[
                                      if (message["idsend"] != iduser)
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  message["avatarsend"]),
                                        ),
                                      Expanded(
                                          child: Column(
                                        mainAxisAlignment:
                                            (message["idsend"] == iduser)
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            (message["idsend"] == iduser)
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          // Displayonlinefile(
                                          //   idmessage: message["idmessage"],
                                          //   avatarsend: message["avatarsend"],
                                          //   message: message["message"],
                                          //   typemessage: message["typemessage"],
                                          //   idsend: message["idsend"],
                                          //   namesend: message["namesend"],
                                          //   reponsefilename:
                                          //       message["namefilereponse"],
                                          // ),
                                          if (message["message"] != "")
                                            GestureDetector(
                                              onTap: () {
                                                Get.bottomSheet(
                                                    SingleChildScrollView(
                                                  child: Optionmessage(
                                                    idmessage: message.id,
                                                    idsend: message["idsend"],
                                                    typemessage:
                                                        message["typemessage"],
                                                    message: message["message"],
                                                    namereponse:
                                                        message["namesend"],
                                                    avataruser: avataruser,
                                                  ),
                                                ));
                                              },
                                              child: ChatBubble(
                                                elevation: 0,
                                                shadowColor: Colors.black,
                                                clipper: ChatBubbleClipper1(
                                                    type: (message["idsend"] ==
                                                            iduser)
                                                        ? BubbleType.sendBubble
                                                        : BubbleType
                                                            .receiverBubble),
                                                alignment: (message["idsend"] ==
                                                        iduser)
                                                    ? Alignment.topRight
                                                    : null,
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                backGroundColor:
                                                    (message["idsend"] ==
                                                            iduser)
                                                        ? Colors.white
                                                            .withOpacity(0.2)
                                                        : Colors.blueAccent,
                                                child: Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      if (message["idsend"] !=
                                                          iduser)
                                                        Text(
                                                          message["namesend"],
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Responsonline(
                                                        typereponse: message[
                                                            "typereponse"],
                                                        nameuser: message[
                                                            "nomreponse"],
                                                        urlfile: message[
                                                            "urlreponse"],
                                                        namefile:
                                                            message["namefile"],
                                                        message: message[
                                                            "messagereponse"],
                                                        idsend:
                                                            message["idsend"],
                                                      ),
                                                      Text(
                                                        message["message"],
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                        ],
                                      ))
                                    ],
                                  ),
                                );
                              },
                            );
                    },
                  )),
                  const SizedBox(
                    height: 10,
                  ),
                  Displaylocalfile(
                    idmessage: smscontrol.idmessagereponse.value,
                  ),
                  const Selectlocalfile(),
                  barmessage(),
                  const Suggestion()
                ],
              ),
            ),
          )),
    );
  }

  Widget barmessage() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      // color: Colors.white.withOpacity(0.1),
      child: Row(
        children: <Widget>[
          (_recordState != RecordState.stop)
              ? Expanded(
                  child: Container(
                  child: Row(
                    children: <Widget>[
                      Chip(
                        // padding: const EdgeInsets.all(10),
                        label: _buildText(),
                      ),
                      const SizedBox(width: 20),
                      _buildPauseResumeControl(),
                    ],
                  ),
                ))
              : Expanded(
                  child: DetectableTextField(
                  onChanged: (value) {
                    if (smscontrol.messagediting.value.text.isNotEmpty) {
                      smscontrol.write.value = true;
                    } else {
                      smscontrol.write.value = false;
                    }
                  },
                  controller: smscontrol.messagediting.value,
                  enableSuggestions: true,
                  maxLines: null,
                  basicStyle: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    prefixIcon: IconButton(
                        onPressed: () {
                          smscontrol.selectmedia(context, "document");
                        },
                        icon: const Icon(
                          Iconsax.document,
                          color: Colors.white,
                        )),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          smscontrol.selectmedia(context, "media");
                        },
                        icon: const Icon(
                          Iconsax.camera,
                          color: Colors.white,
                          size: 27,
                        )),
                    border: const OutlineInputBorder(
                      gapPadding: 2,
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    hintText: 'Taper votre message',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  detectionRegExp: detectionRegExp()!,
                  decoratedStyle: const TextStyle(
                    // fontSize: 20,
                    color: Colors.blue,
                  ),
                )),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              if (smscontrol.write.isTrue) {
                smscontrol.sendmessage(idbranche, nomusers, avataruser);
                print(nomusers);
              } else {
                (_recordState != RecordState.stop) ? _stop() : _start();
              }
            },
            onLongPress: () {
              if (smscontrol.write.isTrue) {
                Get.bottomSheet(SingleChildScrollView(
                  child: Translatesmssend(
                      message: smscontrol.messagediting.value.text),
                ));
              }
            },
            child: CircleAvatar(
                radius: 25,
                child: (smscontrol.write.isTrue ||
                        _recordState != RecordState.stop)
                    ? const Icon(
                        Iconsax.send1,
                        color: Colors.white,
                        size: 30,
                      )
                    : const Icon(
                        Iconsax.microphone_2,
                        color: Colors.white,
                        size: 30,
                      )),
          )
        ],
      ),
    );
  }

// AUDIO RECORD
  Widget _buildRecordStopControl() {
    late Icon icon;
    late Color color;

    if (_recordState != RecordState.stop) {
      icon = const Icon(Icons.stop, color: Colors.red, size: 30);
      color = Colors.red.withOpacity(0.1);
    } else {
      final theme = Theme.of(context);
      icon = Icon(Icons.mic, color: theme.primaryColor, size: 30);
      color = theme.primaryColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 56, height: 56, child: icon),
          onTap: () {
            (_recordState != RecordState.stop) ? _stop() : _start();
          },
        ),
      ),
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;
    late Color color;

    if (_recordState == RecordState.record) {
      icon = const Icon(
        Iconsax.pause5,
        color: Colors.white,
      );
      color = Colors.redAccent;
    } else {
      icon = const Icon(Iconsax.play5, color: Colors.white, size: 30);
      color = Colors.redAccent;
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: SizedBox(width: 50, height: 50, child: icon),
          onTap: () {
            (_recordState == RecordState.pause) ? _resume() : _pause();
          },
        ),
      ),
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return const Text("Enregistrement patientez...");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red, fontSize: 17),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
