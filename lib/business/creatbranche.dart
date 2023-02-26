import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';

class Creatbranche extends StatefulWidget {
  const Creatbranche({Key? key}) : super(key: key);

  @override
  _CreatbrancheState createState() => _CreatbrancheState();
}

class _CreatbrancheState extends State<Creatbranche> {
  String affiche = "";
  final requ = Get.put(Tabsrequette());
  final _nombrancheController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantcontroller = TextEditingController();
  String offre = "";
  String typebranche = "";
  bool check = false;
  String statut = "";
  final sendrequ = Get.put(Changevalue());
  String nomuser = "";
  String avataruser = "";
  String token = "";
  double progress = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
        token = querySnapshot.docs.first["token"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          color: Colors.black.withBlue(25),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                      height: 5,
                      width: 50,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(50)))),
                ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text("Création de branche",
                      style: GoogleFonts.poppins(
                          fontSize: 20, color: Colors.white)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            selectimage();
                          },
                          child: Obx(() => CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: (requ.affiche.isEmpty)
                                    ? null
                                    : NetworkImage(
                                        requ.affiche.value,
                                      ),
                                child: (requ.affiche.isEmpty)
                                    ? const Icon(
                                        Iconsax.camera,
                                        color: Colors.white,
                                        size: 30,
                                      )
                                    : null,
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: TextFormField(
                          style: const TextStyle(color: Colors.white),
                          controller: _nombrancheController,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.2),
                            filled: true,
                            labelStyle: const TextStyle(color: Colors.white),
                            label: const Text("Nom de la branche"),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextFormField(
                        controller: _descriptionController,
                        minLines: 2,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                          labelStyle: const TextStyle(color: Colors.white),
                          label: const Text('Description de la branche'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Offre",
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                        selectedColor: Colors.greenAccent,
                        onSelected: (value) {
                          offre = "gratuit";
                          setState(
                            () {
                              offre = "gratuit";
                            },
                          );
                        },
                        padding: const EdgeInsets.all(10),
                        label: const Text('Gratuite'),
                        selected: (offre == "gratuit") ? true : false),
                    const SizedBox(
                      height: 20,
                    ),
                    ChoiceChip(
                        selectedColor: Colors.greenAccent,
                        onSelected: (value) {
                          setState(
                            () {
                              offre = "abonnement";
                            },
                          );
                        },
                        padding: const EdgeInsets.all(10),
                        label: const Text('Abonnement'),
                        selected: (offre == "abonnement") ? true : false),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                if (offre == "abonnement")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 30),
                    child: TextFormField(
                      controller: _montantcontroller,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        fillColor: Colors.white.withOpacity(0.2),
                        filled: true,
                        labelStyle: const TextStyle(color: Colors.white),
                        label: const Text('Prix abonnement'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Type de branche",
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: (typebranche == "inbox")
                                          ? Colors.greenAccent
                                          : Colors.white.withOpacity(0.2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Iconsax.message,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Inbox",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  typebranche = "inbox";
                                });
                              },
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: (typebranche == "social")
                                          ? Colors.greenAccent
                                          : Colors.white.withOpacity(0.2),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Icon(
                                          Iconsax.activity,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Social",
                                          style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                requ.message("Echec",
                                    "Ce type de branche n'est pas disponible dans votre région");
                              },
                            ),
                          ],
                        )
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                if (typebranche == "social")
                  ListTile(
                    leading: Switch(
                        activeColor: Colors.greenAccent,
                        activeTrackColor: Colors.greenAccent,
                        trackColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.white;
                          }
                          return Colors.white;
                        }),
                        value: check,
                        onChanged: (value) {
                          setState(() {
                            check = value;
                          });
                        }),
                    title: const Text(
                      'Publcation dans la branche',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Tout les utilisateur pourront publier dans la branche. \n NB : Cette option n'est pas modifiable",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Statut",
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: (statut == "public")
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Icons.public_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Publique",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        statut = "public";
                        setState(() {
                          statut = "public";
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      child: Stack(
                        children: [
                          Container(
                            height: 120,
                            width: 150,
                            decoration: BoxDecoration(
                              color: (statut == "prive")
                                  ? Colors.greenAccent
                                  : Colors.white.withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Iconsax.security_user,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Privé",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (offre == "abonnement") {
                          requ.message('Echec',
                              "Désole, vous ne pouvez pas activiter le statut privé pour une offre d'abonnement");
                        } else {
                          setState(() {
                            statut = "prive";
                          });
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_nombrancheController.text.isEmpty) {
                    requ.message("Echec",
                        "Nous vous prions de saisir le nom de la branche");
                  } else if (_descriptionController.text.isEmpty) {
                    requ.message("Echec",
                        "Nous vous prions de saisir la description de votre branche");
                  } else if (statut.isEmpty) {
                    requ.message("Echec",
                        "Nous vous prions de sélectionner le statut adéquat à votre branche.");
                  } else if (typebranche.isEmpty) {
                    requ.message("Echec",
                        "Nous vous prions de sélectionner le type de branche adequat a votre utilisation.");
                  } else {
                    if (offre == "abonnement") {
                      if (_montantcontroller.text.isEmpty) {
                        requ.message("Echec",
                            "Nous vous prions de saisir un prix pour l'abonnement.");
                      } else {
                        requ.creatbranche(
                            _nombrancheController.text,
                            _descriptionController.text,
                            statut,
                            sendrequ.idnoeuds.value,
                            avataruser,
                            nomuser,
                            offre,
                            _montantcontroller.text,
                            token,
                            typebranche,
                            requ.affiche.value,
                            check);
                        _nombrancheController.clear();
                        _descriptionController.clear();
                        _montantcontroller.clear();
                        statut = "";
                        offre = "";

                        requ.message("Success", "Branche ajouté avec succès");
                        Navigator.of(context).pop();
                      }
                    } else {
                      requ.creatbranche(
                          _nombrancheController.text,
                          _descriptionController.text,
                          statut,
                          sendrequ.idnoeuds.value,
                          avataruser,
                          nomuser,
                          offre,
                          0,
                          token,
                          typebranche,
                          requ.affiche.value,
                          check);
                      _nombrancheController.clear();
                      _descriptionController.clear();
                      _montantcontroller.clear();
                      statut = "";
                      offre = "";
                      requ.message("Success", "Branche ajouté avec succès");
                      Navigator.of(context).pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    fixedSize: Size(MediaQuery.of(context).size.width, 70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Text(
                  "Valider",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  selectimage() async {
    setState(() {
      progress = 0;
    });
    final fila = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (fila != null) {
      try {
        String fileName = fila.name;

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
          });
        });
        task.whenComplete(() => upload(fileName));
      } on FirebaseException catch (e) {}
    }
  }

  Future<void> upload(fileName) async {
    String downloadURL = await FirebaseStorage.instance
        .ref()
        .child('business/$fileName')
        .getDownloadURL();
    setState(() {
      affiche = downloadURL;
    });
    requ.affiche.value = downloadURL;
  }
}
