import 'package:firebase_auth/firebase_auth.dart' as users;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smatch/business/dashvlog/tabsvlog.dart';
import 'package:smatch/business/vlog/home_page.dart';
import 'package:smatch/business/vlog/video_detail_page.dart';
import 'package:smatch/home/home.dart';
import 'package:smatch/home/settingsvideo.dart';
import 'package:smatch/home/social.dart';
import 'package:smatch/home/socialpub.dart';
import 'package:smatch/home/viewsocial.dart';
import 'package:smatch/message/isole/homeisole.dart';
import 'package:smatch/message/message.dart';
import 'package:smatch/message/settings.dart';
import 'package:smatch/navigator_key.dart';
import 'package:smatch/noeud/settingsnoeud.dart';
import 'package:smatch/onboarding.dart';
import 'package:smatch/wallet/walletuser.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'business/dashvlog/publicationvlog.dart';
import 'menu/menuhome.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   if (message.notification != null) {
  //     AwesomeNotifications().createNotificationFromJsonData(message.data);
  //   }
  //   AwesomeNotifications().createNotificationFromJsonData(message.data);
  // });
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
  configLoading();
  timeago.setLocaleMessages('fr', timeago.FrMessages());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('non');
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

EasyLoadingAnimation? CustomAnimation() {}

class MyApp extends StatelessWidget {
  users.User? user = users.FirebaseAuth.instance.currentUser;

  // This widget is the root of your application.
  MyApp({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: const Locale("fr"),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/', page: () => home()),
        GetPage(name: '/onboarding', page: () => OnBoarding()),
        GetPage(name: '/vlog/', page: () => HomeVlog()),
        GetPage(name: '/lecturevideo/', page: () => const VideoDetailPage()),
        GetPage(name: '/settingsnoeud/', page: () => Settingsnoeud()),
        GetPage(name: '/transactions/', page: () => const Transactions()),
        GetPage(name: '/readactualite/', page: () => const Readactualite()),
        // GetPage(name: '/viewimage/', page: () => const Viewimage()),
        // GetPage(name: '/viewvideo/', page: () => const Viewvideo()),
        GetPage(name: '/settingsbranche/', page: () => const Settingsbranche()),
        GetPage(name: '/messagebranche/', page: () => const Message()),
        GetPage(name: '/social/', page: () => const Social()),
        GetPage(name: '/viewsocial/', page: () => const Viewsocial()),
        GetPage(name: '/socialpub/', page: () => const Socialpub()),
        GetPage(name: '/readvideo/', page: () => const Readvideo()),
        GetPage(name: '/settingsvideo/', page: () => const Settingsvideo()),
        GetPage(name: '/mypubsocial/', page: () => const Mypublicationsocial()),
        GetPage(name: '/tabsvlog/', page: () => const Tabsvlog()),
        GetPage(name: '/publicationvlog/', page: () => const Publicationvlog()),
      ],
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          )),
      home: (user != null) ? const Menuhome() : OnBoarding(),
      navigatorKey: navigatorKey,
      builder: EasyLoading.init(),
    );
  }
}

// configuration
// verifier la configuration fb
// verifier les logo et splash screen
// effectuer un dernier test

      // permettre le statte sur modal bottom sheet
        // creatmoment() {
  //   showModalBottomSheet(
  //       enableDrag: true,
  //       isScrollControlled: true,
  //       shape: const RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
  //       ),
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return
  //           },
  //         );
  //       });
  // }
//  permet de pouvoir effectuer une recherche 
  // void _runFilter(String enteredKeyword) {
  //   List results = [];
  //   if (enteredKeyword.isEmpty) {
  //     // if the search field is empty or only contains white-space, we'll display all users
  //     results = compte;
  //   } else {
  //     results = compte
  //         .where((user) =>
  //             user["nom"].toLowerCase().contains(enteredKeyword.toLowerCase()))
  //         .toList();
  //     // we use the toLowerCase() method to make it case-insensitive
  //   }

  //   // Refresh the UI
  //   setState(() {
  //     allcomptesearch = results;
  //   });
  //   print(allcomptesearch);
  // }
  //https:firebasestorage.googleapis.com/v0/b/flutterprojet-e8896.appspot.com/o/business%2Favatar.png?alt=media&token=1c03953b-cd2d-4df3-808f-68e47ba0a8f

//   void uploadFileToServer(File imagePath) async {
//   var request = new http.MultipartRequest(
//       "POST", Uri.parse('your api url her'));
// request.fields['name'] = 'Rohan';
// request.fields['title'] = 'My first image';
// request.files.add(await http.MultipartFile.fromPath('profile_pic', imagePath.path));
//   request.send().then((response) {
//     http.Response.fromStream(response).then((onValue) {
//       try {
//         // get your response here...
//       } catch (e) {
//         // handle exeption
//       }
//     });
//   });
// }



// 070A0D
// 2D2F2F
// 1C1E22
// 13151B
// 070A0D
// 101418
// 00193D
// E9F2FF
// 000000