import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/tabsrequette.dart';
import 'package:smatch/menu/menuwidget.dart';

class Mynoeud extends StatefulWidget {
  @override
  _MynoeudState createState() => _MynoeudState();
}

class _MynoeudState extends State<Mynoeud> {
  final _advancedDrawerController = AdvancedDrawerController();
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference userabonne =
      FirebaseFirestore.instance.collection("abonne");
  String nomuser = "";
  String avataruser = "";
  final requ = Get.put(Tabsrequette());
  final Stream<QuerySnapshot> _noeudstream = FirebaseFirestore.instance
      .collection('abonne')
      .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser)
      .where("type", isEqualTo: "noeud")
      .orderBy("range", descending: true)
      .snapshots();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getinfouser();
  }

  getinfouser() {
    print(FirebaseAuth.instance.currentUser!.uid);
    FirebaseFirestore.instance
        .collection('users')
        .where("iduser", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        nomuser = querySnapshot.docs.first['nom'];
        avataruser = querySnapshot.docs.first['avatar'];
      });
      print('object');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withBlue(25),
      appBar: AppBar(
        backgroundColor: Colors.black.withBlue(25),
        title: Text(
          'Noeud',
          style: GoogleFonts.poppins(fontSize: 30),
        ),
        leading: Menuwidget(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('abonne')
                .where("iduser", isEqualTo: user!.uid)
                .where("type", isEqualTo: "noeud")
                .orderBy("range", descending: true)
                .snapshots(),
            builder:
                (BuildContext contex, AsyncSnapshot<QuerySnapshot> _noeud) {
              if (!_noeud.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return (_noeud.data!.docs.isEmpty)
                  ? const Center(
                      heightFactor: 20,
                      child: Text(
                        "Aucun n??ud disponible pour l'instant",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        textAlign: TextAlign.justify,
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 5.0,
                              mainAxisExtent: 220),
                      itemCount: _noeud.data!.docs.length,
                      itemBuilder: (BuildContext ctx, index) {
                        return Stack(
                          children: [
                            Container(
                                decoration: const BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 5, right: 10),
                                  child: Column(children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(15.0)),
                                        child: CachedNetworkImage(
                                          imageUrl: _noeud.data!.docs[index]
                                              ['logo'],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        _noeud.data!.docs[index]['nom'],
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: ActionChip(
                                          backgroundColor: Colors.red,
                                          label: Text(
                                            "Quitter",
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            quitter(
                                                _noeud.data!.docs[index].id,
                                                _noeud.data!.docs[index]
                                                    ["nom"]);
                                          }),
                                    )
                                  ]),
                                )),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: (_noeud.data!.docs[index]["statut"] == 1 ||
                                      _noeud.data!.docs[index]["idcreat"] ==
                                          user!.uid)
                                  ? Center(
                                      child: GestureDetector(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('noeud')
                                            .where("idcompte",
                                                isEqualTo: _noeud.data!
                                                    .docs[index]["idcompte"])
                                            .get()
                                            .then((QuerySnapshot value) {
                                          Get.toNamed("/settingsnoeud",
                                              arguments: [
                                                {
                                                  "idnoeud": _noeud.data!
                                                      .docs[index]["idcompte"]
                                                },
                                                {
                                                  "nomnoeud": _noeud
                                                      .data!.docs[index]["nom"]
                                                },
                                                {
                                                  "idcreat": value
                                                      .docs.first['idcreat']
                                                }
                                              ]);
                                        });
                                      },
                                      child: const Icon(
                                        Icons.admin_panel_settings_rounded,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    ))
                                  : Container(),
                            )
                          ],
                        );
                      });
            }),
      )),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  quitter(idcompte, nom) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Vous ??tes sur le point de quitter $nom",
                  textAlign: TextAlign.justify,
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.black),
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orange.shade900)),
              child: const Text('Oui quitter',
                  style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                userabonne.doc(idcompte).delete();
                requ.message("sucess", "Votre demande a ??t?? prise en compte.");
              },
            ),
          ],
        );
      },
    );
  }
}
