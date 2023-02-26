import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shape_of_view_null_safe/shape_of_view_null_safe.dart';
import 'package:smatch/home/tabsrequette.dart';

class HomeVlog extends StatefulWidget {
  @override
  _HomeVlogState createState() => _HomeVlogState();
}

class _HomeVlogState extends State<HomeVlog> {
  String idchaine = Get.arguments[0]['idchaine'];
  String nomchaine = Get.arguments[1]['nomchaine'];
  String logochaine = Get.arguments[2]['logo'];
  String poster = Get.arguments[3]['vignette'];
  String titre = Get.arguments[4]['titre'];
  String iduser = FirebaseAuth.instance.currentUser!.uid;
  final Stream<QuerySnapshot> playliste = FirebaseFirestore.instance
      .collection('categorie')
      .where("idcompte", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _videovlog = FirebaseFirestore.instance
      .collection('videovlog')
      .where("idvlog", isEqualTo: Get.arguments[0]["idchaine"])
      .orderBy("range", descending: true)
      .snapshots();
  final requ = Get.put(Tabsrequette());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: size.height - 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stack(
                  //   children: [
                  //     Container(
                  //       height: 500,
                  //       decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //               image: CachedNetworkImageProvider(poster),
                  //               fit: BoxFit.cover)),
                  //     ),
                  //     Container(
                  //         height: 500,
                  //         decoration: BoxDecoration(
                  //             gradient: LinearGradient(
                  //                 colors: [
                  //               Colors.black.withOpacity(0.85),
                  //               Colors.black.withOpacity(0.0),
                  //             ],
                  //                 end: Alignment.topCenter,
                  //                 begin: Alignment.bottomCenter))),
                  //     Container(
                  //       padding: const EdgeInsets.all(10),
                  //       height: 500,
                  //       width: size.width,
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.end,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         children: [
                  //           Center(
                  //             child: Text(
                  //               titre.toUpperCase(),
                  //               style: GoogleFonts.odibeeSans(
                  //                   fontSize: 45, color: Colors.white),
                  //               maxLines: 2,
                  //               overflow: TextOverflow.ellipsis,
                  //             ),
                  //           ),
                  //           const SizedBox(
                  //             height: 15,
                  //           ),
                  //           Text(
                  //             nomchaine.toUpperCase(),
                  //             style: const TextStyle(
                  //                 fontSize: 20, color: Colors.white),
                  //           )
                  //         ],
                  //       ),
                  //     )
                  //   ],
                  // ),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: AlignmentDirectional.topCenter,
                    fit: StackFit.loose,
                    children: [
                      ShapeOfView(
                        elevation: 10,
                        height: 400,
                        width: MediaQuery.of(context).size.width,
                        shape: ArcShape(
                            direction: ArcDirection.Outside,
                            height: 40,
                            position: ArcPosition.Bottom),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 18, top: 120),
                                    child: Text(
                                      titre.toUpperCase(),
                                      style: GoogleFonts.odibeeSans(shadows: [
                                        const Shadow(
                                            color: Colors.black,
                                            blurRadius: 9,
                                            offset: Offset(1, 1)),
                                      ], fontSize: 45, color: Colors.white),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 6.0),
                                    child: Text(
                                      nomchaine.toUpperCase(),
                                      style: const TextStyle(shadows: [
                                        Shadow(
                                            color: Colors.black,
                                            blurRadius: 9,
                                            offset: Offset(1, 1)),
                                      ], fontSize: 20, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        child: GestureDetector(
                          onTap: () {
                            FirebaseFirestore.instance
                                .collection('noeud')
                                .where("idcompte", isEqualTo: idchaine)
                                .get()
                                .then((QuerySnapshot value) {
                              if (value.docs.first["lienvideo"] == "") {
                                requ.message(
                                    "Echec", "Aucune video n'a été definie");
                              } else {
                                Get.toNamed("/lecturevideo", arguments: [
                                  {"videourl": value.docs.first['lienvideo']},
                                  {
                                    "description":
                                        value.docs.first['descriptionvideo']
                                  },
                                  {"titre": value.docs.first['titre']},
                                  {"vignette": value.docs.first['vignette']},
                                  {"date": value.docs.first['date']},
                                  {"nomchaine": nomchaine},
                                  {"idvideo": value.docs.first['idvideo']},
                                  {"categorie": value.docs.first['playliste']},
                                ]);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 13, left: 8, top: 5, bottom: 5),
                              child: Row(
                                children: const [
                                  Icon(
                                    IconlyBold.play,
                                    size: 30,
                                    color: Colors.red,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Regarder",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 60,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // afficher toutes les video des series
                      const Padding(
                        padding: EdgeInsets.only(left: 15, right: 15),
                        child: Text(
                          "Toutes les séries",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      StreamBuilder(
                          stream: _videovlog,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> videovlog) {
                            if (!videovlog.hasData) {
                              return const Center(
                                heightFactor: 2,
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (videovlog.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                heightFactor: 2,
                                child: CircularProgressIndicator(),
                              );
                            }
                            return (videovlog.data!.docs.isEmpty)
                                ? const Center(
                                    child: Text(
                                    "Aucune série disponible",
                                    style: TextStyle(color: Colors.white),
                                  ))
                                : Container(
                                    height: 170,
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: videovlog.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    FirebaseFirestore.instance
                                                        .collection('videovlog')
                                                        .doc(videovlog.data!
                                                            .docs[index].id)
                                                        .update({
                                                      "vue":
                                                          FieldValue.increment(
                                                              1)
                                                    });
                                                    Get.toNamed("/lecturevideo",
                                                        arguments: [
                                                          {
                                                            "videourl": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['video']
                                                          },
                                                          {
                                                            "description": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['description']
                                                          },
                                                          {
                                                            "titre": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['titre']
                                                          },
                                                          {
                                                            "vignette": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['vignette']
                                                          },
                                                          {
                                                            "date": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['date']
                                                          },
                                                          {
                                                            "nomchaine":
                                                                nomchaine
                                                          },
                                                          {
                                                            "idvideo": videovlog
                                                                .data!
                                                                .docs[index]
                                                                .id
                                                          },
                                                          {
                                                            "categorie": videovlog
                                                                    .data!
                                                                    .docs[index]
                                                                ['playliste']
                                                          },
                                                        ]);
                                                  },
                                                  child: Container(
                                                    width: 150,
                                                    height: 170,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        image: DecorationImage(
                                                            image: CachedNetworkImageProvider(
                                                                videovlog.data!
                                                                            .docs[
                                                                        index][
                                                                    'vignette']),
                                                            fit: BoxFit.cover)),
                                                  )),
                                              const SizedBox(
                                                width: 10,
                                              )
                                            ],
                                          );
                                        }),
                                  );
                          }),

                      // affichage par listes des playslistes

                      StreamBuilder(
                          stream: playliste,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> playsliste) {
                            if (!playsliste.hasData) {
                              return Column(
                                children: const <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    heightFactor: 2,
                                    child: CircularProgressIndicator(),
                                  )
                                ],
                              );
                            }
                            if (playsliste.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                children: const <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    heightFactor: 2,
                                    child: CircularProgressIndicator(),
                                  )
                                ],
                              );
                            }
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: playsliste.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15, bottom: 5),
                                            child: Text(
                                              playsliste.data!.docs[index]
                                                  ['nomcategorie'],
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection("videovlog")
                                              .where("idvlog",
                                                  isEqualTo: idchaine)
                                              .where("idcategorie",
                                                  isEqualTo: playsliste
                                                      .data!.docs[index].id)
                                              .orderBy("range",
                                                  descending: true)
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  videopub) {
                                            if (!videopub.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            if (videopub.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                            return (videopub.data!.docs.isEmpty)
                                                ? const Center(
                                                    child: Text(
                                                      'Aucune série disponible',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 170,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            bottom: 10),
                                                    child: ListView.builder(
                                                        physics:
                                                            BouncingScrollPhysics(),
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        shrinkWrap: true,
                                                        itemCount: videopub
                                                            .data!.docs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Row(
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: () {
                                                                    Get.toNamed(
                                                                        "/lecturevideo",
                                                                        arguments: [
                                                                          {
                                                                            "videourl":
                                                                                videopub.data!.docs[index]['video']
                                                                          },
                                                                          {
                                                                            "description":
                                                                                videopub.data!.docs[index]['description']
                                                                          },
                                                                          {
                                                                            "titre":
                                                                                videopub.data!.docs[index]['titre']
                                                                          },
                                                                          {
                                                                            "vignette":
                                                                                videopub.data!.docs[index]['vignette']
                                                                          },
                                                                          {
                                                                            "date":
                                                                                videopub.data!.docs[index]['date']
                                                                          },
                                                                          {
                                                                            "nomchaine":
                                                                                nomchaine
                                                                          },
                                                                          {
                                                                            "idvideo":
                                                                                videopub.data!.docs[index].id
                                                                          },
                                                                          {
                                                                            "categorie":
                                                                                videopub.data!.docs[index]['playliste']
                                                                          },
                                                                        ]);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 150,
                                                                    height: 170,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                6),
                                                                        image: DecorationImage(
                                                                            image:
                                                                                CachedNetworkImageProvider(videopub.data!.docs[index]['vignette']),
                                                                            fit: BoxFit.cover)),
                                                                  )),
                                                              const SizedBox(
                                                                width: 10,
                                                              )
                                                            ],
                                                          );
                                                        }),
                                                  );
                                          }),
                                    ],
                                  );
                                });
                          }),
                    ],
                  )
                ],
              ),
            ),
            Container(
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    CachedNetworkImageProvider(logochaine),
                                radius: 30,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
