import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isolate_flutter/isolate_flutter.dart';
import 'package:smatch/message/isole/upload_isolate.dart';
import 'package:smatch/message/isole/workupload.dart';
import 'package:smatch/message/record.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Messagecontroller extends GetxController {
  var write = false.obs;
  var messagediting = TextEditingController().obs;
  var typereponse = "".obs;
  var messagereponse = "".obs;
  var typemessage = "sms".obs;
  var nomreponse = "".obs;
  var namefile = "".obs;
  var urlreponse = "".obs;
  var listdef = [].obs;
  var nbre = 0.obs;
  var extension = "".obs;
  var filedisplay = [].obs;
  String userid = FirebaseAuth.instance.currentUser!.uid;
  var filelist = [].obs;
  var filedata = [].obs;
  var pathfile = "".obs;
  var idmessagereponse = "".obs;
  var namefilereponse = "".obs;
  var finalislise = [].obs;
  var images = [].obs;
  sendmessage(idbranche, namesend, avatarsend) {
    DateTime now = DateTime.now();
    String dateformat = DateFormat("kk:mm").format(now);
    listdef.value = filelist;
    FirebaseFirestore.instance.collection('message').add({
      "message": messagediting.value.text,
      "idbranche": idbranche,
      "idsend": userid,
      "urlfile": "",
      "typemessage": typemessage.value,
      "vignette": "",
      "range": DateTime.now().millisecondsSinceEpoch,
      "date": dateformat,
      "messagereponse": messagereponse.value,
      "nomreponse": nomreponse.value,
      "namesend": namesend,
      "avatarsend": avatarsend,
      "namefile": namefile.value,
      "idnoeud": "",
      "typereponse": typereponse.value,
      "urlreponse": urlreponse.value,
      "namefilereponse": namefilereponse.value,
      "idmessage": "",
      "finish": false,
    }).then((value) {
      FirebaseFirestore.instance
          .collection('message')
          .doc(value.id)
          .update({"idmessage": value.id});

      if (filedisplay.isNotEmpty) {
        for (var element in filedisplay) {
          FirebaseFirestore.instance.collection("fileUploads").add({
            "urlfile": element["urlbase64"],
            "extension": element["extension"],
            "finish": true,
            "namefile": element["name"],
            "localpath": element["localpath"],
            "idmessage": value.id,
          });
        }
      } else {
        print('vide oww');
      }

      filelist.clear();
    });
    messagediting.value.clear();
    nomreponse.value = "";
    messagereponse.value = "";
    typereponse.value = "";
    urlreponse.value = "";
    namefilereponse.value = "";
  }

  selectmedia(context, type) async {
    filedisplay.clear();
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: const AssetPickerConfig(maxAssets: 5, selectedAssets: []),
    );

    if (result != null) {
      await Future.forEach(result, (AssetEntity asset) async {
        final bytes = await asset.originBytes;
        final File? path = await asset.file;
        final String base64 = base64Encode(bytes!);
        final String extensions = getExtension(path!.path);

        final FirebaseStorage storage = FirebaseStorage.instance;

        Reference storageRef = storage.ref().child(asset.title.toString());
        UploadTask uploadTask =
            storageRef.putString(base64, format: PutStringFormat.base64);
        TaskSnapshot downloadUrl = (await uploadTask);
        String url = await downloadUrl.ref.getDownloadURL();
        print(url);

        filedisplay.add({
          "localpath": path.path,
          "urlbase64": base64,
          "extension": extensions,
          "name": asset.title,
        });
      });
    }
  }

  selectdocument() async {
    filelist.clear();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      typemessage.value = "file";
      String? file = result.files.single.path;
      filelist.add(file);
      namefile.value = result.files.single.name;
      extension.value = result.files.single.extension!;
    } else {}
  }

  void launchupload(idmessage) async {
    // finalislise.value = filedisplay.value;
    await uplaodelement(idmessage);
    // print(filedata);
    await IsolateFlutter.createAndStart(_sendfunction, filedata).then((value) {
      print(value);
      updateFirestoreCollection(value);
    });
  }

  uplaodelement(idmessage) async {}

  static Future<List> _sendfunction(List datafile) async {
    final cloudinary = Cloudinary.full(
      apiKey: "489522481445921",
      apiSecret: "H9DpbxyRYerllQ4XGnWf6_SOczI",
      cloudName: "smatch",
    );
    List publicIds = [];
    final resources =
        await Future.wait(datafile.map((file) async => CloudinaryUploadResource(
            filePath: file["localpath"],
            resourceType: CloudinaryResourceType.auto,
            folder: 'test',
            publicId: file["publicid"],
            progressCallback: (count, total) {
              // print('Uploading image from file with progress: $count/$total');
            })));
    List<CloudinaryResponse> responses =
        await cloudinary.uploadResources(resources);

    for (var response in responses) {
      if (response.isSuccessful) {
        publicIds.add({
          "pathonline": response.secureUrl,
          "publicId": response.publicId,
          "status": "uploaded",
        });
      }
    }
    print(publicIds);
    print("vide okay");
    return publicIds;
  }

  updateFirestoreCollection(publicIds) async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('fileUploads');
    for (var publicId in publicIds) {
      await collection
          .doc(publicId["publicId"].toString().substring(5))
          .update({
        "urlfile": publicId["pathonline"],
        "finish": true,
      });
    }
  }
}

// import 'package:firebase_storage/firebase_storage.dart';

// Future<void> uploadFile(String base64String) async {
//   final StorageReference storageReference = FirebaseStorage.instance.ref().child("myfile.jpg");
//   final StorageUploadTask uploadTask = storageReference.putData(base64Decode(base64String));
//   await uploadTask.onComplete;
// }
