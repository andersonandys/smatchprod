import 'dart:async';
import 'dart:io';

import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smatch/home/tabsrequette.dart';

class Creatspace extends StatefulWidget {
  const Creatspace({Key? key}) : super(key: key);

  @override
  _CreatspaceState createState() => _CreatspaceState();
}

class _CreatspaceState extends State<Creatspace> {
  Timer? _timer;
  late double _progress;
  String logo = "";
  double progress = 0.0;
  final requ = Get.put(Tabsrequette());
  File? imagefile;
  CollectionReference compte = FirebaseFirestore.instance.collection("noeud");
  final nommoment = TextEditingController();
  final descriptionmoment = TextEditingController();
  final pays = TextEditingController();
  final fb = TextEditingController();
  final yt = TextEditingController();
  String offre = "";
  final prix = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String nomuser = "";
  String avataruser = "";
  int newprix = 0;
  bool isload = false;
  int activestep = 0;
  bool filiale = false;
  List<StepperData> stepperData = [
    StepperData(
        title: StepperText(
          "Studio",
          textStyle: const TextStyle(
            color: Colors.white,
          ),
        ),
        iconWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: const Icon(Icons.looks_one, color: Colors.white),
        )),
    StepperData(
        title: StepperText("Information",
            textStyle: const TextStyle(
              color: Colors.white,
            )),
        iconWidget: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: const Icon(Icons.looks_two, color: Colors.white),
        )),
    StepperData(
      title: StepperText("Terme & condition",
          textStyle: const TextStyle(
            color: Colors.white,
          )),
    ),
  ];
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(30),
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50), color: Colors.white),
            height: 5,
            width: 50,
          ),
          const SizedBox(
            height: 20,
          ),
          const Text("Création de Space",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(
            height: 20,
          ),
          AnotherStepper(
            activeIndex: activestep,
            stepperList: stepperData,
            stepperDirection: Axis.horizontal,
            iconWidth:
                40, // Height that will be applied to all the stepper icons
            iconHeight:
                40, // Width that will be applied to all the stepper icons
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                if (activestep == 0) step1(),
                if (activestep == 1) step2(),
                if (activestep == 2) step3(),
              ],
            ),
          )),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (activestep != 0)
                ActionChip(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      print(activestep--);
                      setState(() {
                        activestep = activestep--;
                      });
                    },
                    avatar: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(10),
                    label: const Text(
                      'Retour',
                      style: TextStyle(color: Colors.black),
                    )),
              if (activestep != 2)
                ActionChip(
                    backgroundColor: Colors.white,
                    onPressed: () {
                      print(activestep);
                      if (activestep == 1) {
                        if (logo.isEmpty) {
                          requ.message(
                              "Echec", "Nous vous prions de choisir un logo");
                        } else if (nommoment.text.isEmpty) {
                          requ.message(
                              "Echec", "Nous vous prions de saisir un nom");
                        } else if (descriptionmoment.text.isEmpty) {
                          requ.message("Echec",
                              "Nous vous prions de saisir une description");
                        } else if (offre.isEmpty) {
                          requ.message("Echec",
                              "Nous vous prions de sélectionner une offre.");
                        } else {
                          if (offre == "payant") {
                            if (prix.text.isEmpty) {
                              requ.message("Echec",
                                  "Nous vous prions de saisir un prix");
                            } else {
                              if (filiale) {
                                if (yt.text.isEmpty) {
                                  requ.message("Echec",
                                      "Nous vous prions de saisir votre lien youtube");
                                } else if (fb.text.isEmpty) {
                                  requ.message("Echec",
                                      "Nous vous prions de saisir votre liien facebook");
                                } else {
                                  print(activestep++);
                                  setState(() {
                                    activestep = activestep++;
                                  });
                                }
                              } else {
                                print(activestep++);
                                setState(() {
                                  activestep = activestep++;
                                });
                              }
                            }
                          } else {
                            if (filiale) {
                              if (yt.text.isEmpty) {
                                requ.message("Echec",
                                    "Nous vous prions de saisir votre lien youtube");
                              } else if (fb.text.isEmpty) {
                                requ.message("Echec",
                                    "Nous vous prions de saisir votre liien facebook");
                              } else {
                                print(activestep++);
                                setState(() {
                                  activestep = activestep++;
                                });
                              }
                            } else {
                              print(activestep++);
                              setState(() {
                                activestep = activestep++;
                              });
                            }
                          }
                        }
                      } else {
                        print(activestep++);
                        setState(() {
                          activestep = activestep++;
                        });
                      }
                    },
                    avatar: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                    padding: const EdgeInsets.all(10),
                    label: const Text(
                      'Suivant',
                      style: TextStyle(color: Colors.black),
                    )),
              if (activestep == 2)
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      addchaine();
                    },
                    child: const Text(
                      "Créer mon space",
                      style: TextStyle(fontSize: 16),
                    ))
            ],
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  Widget step1() {
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Je suis',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            const SizedBox(
              height: 30,
            ),
            CarouselSlider(
              options:
                  CarouselOptions(height: 400.0, enableInfiniteScroll: false),
              items: [
                1,
                2,
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        padding: const EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7)),
                        child: (i == 1)
                            ? Column(
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.asset("assets/studio.png"),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        "Independant",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(10),
                                          backgroundColor: Colors.orangeAccent),
                                      onPressed: () {
                                        setState(() {
                                          filiale = false;
                                        });
                                      },
                                      child: const Text(
                                        "Selectionner",
                                        style: TextStyle(fontSize: 18),
                                      ))
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                    children: [
                                      SizedBox(
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Image.asset("assets/studio.png"),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        "Sous filiale",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(10),
                                          backgroundColor: Colors.orangeAccent),
                                      onPressed: () {
                                        setState(() {
                                          filiale = true;
                                        });
                                      },
                                      child: const Text(
                                        "Selectionner",
                                        style: TextStyle(fontSize: 18),
                                      ))
                                ],
                              ));
                  },
                );
              }).toList(),
            )
          ],
        ));
  }

  Widget step2() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 30),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  selectimage();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  radius: 40,
                  child: (logo.isEmpty && !isload)
                      ? const Center(
                          child: Icon(
                            Iconsax.camera,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : (logo.isEmpty && isload)
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                              child: Image.network(
                                logo,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                            ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  cursorHeight: 20,
                  autofocus: false,
                  controller: nommoment,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.white),
                    label: const Text("Nom de votre Space"),
                    fillColor: Colors.white.withOpacity(0.2),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            maxLines: 2,
            cursorHeight: 20,
            autofocus: false,
            controller: descriptionmoment,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              label: const Text("Description"),
              fillColor: Colors.white.withOpacity(0.2),
              filled: true,
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Colors.grey, width: 2),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text("Type d'abonnement",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: Container(
                  height: 120,
                  width: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: (offre == "gratuit")
                        ? Colors.greenAccent
                        : Colors.white.withOpacity(0.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Iconsax.money,
                        size: 40,
                        color: Colors.white,
                      ),
                      Text(
                        "Libre",
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    offre = "gratuit";
                    print(offre);
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                child: Container(
                  height: 120,
                  width: 150,
                  decoration: BoxDecoration(
                    color: (offre == "payant")
                        ? Colors.greenAccent
                        : Colors.white.withOpacity(0.2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        IconlyLight.wallet,
                        size: 40,
                        color: Colors.white,
                      ),
                      Text(
                        "Abonnement",
                        style: GoogleFonts.poppins(
                            fontSize: 20, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    offre = "payant";
                  });
                },
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          (offre == "payant")
              ? Padding(
                  padding: EdgeInsets.only(
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    cursorHeight: 20,
                    autofocus: false,
                    controller: prix,
                    decoration: InputDecoration(
                      label: const Text("Prix",
                          style: TextStyle(color: Colors.white)),
                      fillColor: Colors.white.withOpacity(0.2),
                      filled: true,
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      newprix = int.parse(value);
                    },
                  ),
                )
              : Container(),
          const SizedBox(
            height: 20,
          ),
          if (filiale)
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: yt,
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.white),
                label: const Text("Lien compte Youtube"),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),
          if (filiale)
            const SizedBox(
              height: 20,
            ),
          if (filiale)
            TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorHeight: 20,
              autofocus: false,
              controller: fb,
              decoration: InputDecoration(
                labelStyle: const TextStyle(color: Colors.white),
                label: const Text("Lien compte Facebook"),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget step3() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text(
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
        style: TextStyle(color: Colors.white, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  // uplaod de fichier
  selectimage() async {
    setState(() {
      progress = 0;
      isload = true;
      logo = "";
    });
    final fila = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (fila != null) {
      try {
        String fileName = fila.name;
        imagefile = File(fila.path);

        UploadTask task = FirebaseStorage.instance
            .ref()
            .child("business/$fileName")
            .putFile(File(fila.path));

        task.snapshotEvents.listen((event) {
          setState(() {
            progress = ((event.bytesTransferred.toDouble() /
                        event.totalBytes.toDouble()) *
                    100)
                .roundToDouble();

            print(progress);
          });
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {
        print("Quelque chose, c'est mal passé, nous vous prions de réessayer.");
      }
    }
  }

  Future<void> upload(fileName) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    setState(() {
      logo = downloadURL;
      isload = false;
    });
    print(logo);
  }

  addchaine() {
    _progress = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      EasyLoading.showProgress(_progress,
          maskType: EasyLoadingMaskType.black,
          status:
              "${(_progress * 100).toStringAsFixed(0)}% \n Création de votre Space \n Patientez s'il vous plaît");
      _progress += 0.01;

      if (_progress >= 1) {
        _timer?.cancel();
        EasyLoading.dismiss();
        Navigator.of(context).pop;
        requ.message("Succes", "Votre chaîne a été créée avec succès.");
      }
    });
    DateTime now = DateTime.now();
    String dateformat = DateFormat("yyyy-MM-dd - kk:mm").format(now);
    FirebaseFirestore.instance.collection("noeud").add({
      "nom": nommoment.text,
      "description": descriptionmoment.text,
      "idcreat": user!.uid,
      "logo": logo,
      "date": dateformat,
      "range": DateTime.now().millisecondsSinceEpoch,
      "wallet": 0,
      "nbrevideo": 0,
      "nbreuser": 1,
      "type": "Moment",
      "offre": offre,
      "mode": true,
      "ready": 0,
      "statut": "public",
      "idcompte": "",
      "prix": newprix,
      "type_paiement": "",
      "titre": "",
      "descriptionvideo": "",
      "vignette": "",
      "lienvideo": "",
      "playliste": "",
      "idcategorie": "",
      "idvideo": "",
      "message": 0,
      "lienyoutube": "",
      "lienfacebook": "",
      "filiale": filiale
    }).then((value) {
      FirebaseFirestore.instance
          .collection("noeud")
          .doc(value.id)
          .update({"idcompte": value.id});
      FirebaseFirestore.instance.collection("abonne").add({
        "iduser": user!.uid,
        "idcreat": user!.uid,
        "idcompte": value.id,
        "nom": nommoment.text,
        "logo": logo,
        "date": dateformat,
        "range": DateTime.now().millisecondsSinceEpoch,
        "offre": offre,
        "statut": 1,
        "type": "Moment",
        "message": 0,
        "isuser": 1,
        "nomuser": user!.displayName
      });
      Get.toNamed("/tabsvlog", arguments: [
        {"idchaine": value.id},
        {"nomchaine": nommoment.text},
      ]);
      nommoment.clear();
      descriptionmoment.clear();
      prix.clear();
      logo = "";
      pays.clear();
      offre = "";
    });
  }
}
