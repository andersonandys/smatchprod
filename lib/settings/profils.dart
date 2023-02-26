import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isolate_flutter/isolate_flutter.dart';
import 'package:path/path.dart' as path;

class FilePickerButton extends StatefulWidget {
  @override
  _FilePickerButtonState createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  List<File> _selectedFiles = [];
  List filedata = [];
  List filedisplay = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? files =
                await FilePicker.platform.pickFiles(allowMultiple: true);
            if (files != null) {
              for (var element in files.files) {
                setState(() {
                  filedisplay.add({
                    "name": element.name,
                    "extension": element.extension,
                    "path": element.path,
                  });
                });
              }
            } else {
              // User canceled the picker
            }
          },
          child: Text('Sélectionner des fichiers'),
        ),
        Text('Fichiers sélectionnés:${filedisplay.length}'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            launchupload("");
          },
          child: Text('Envoyer les fichiers'),
        ),
      ],
    );
  }

  void launchupload(idmessage) async {
    for (var element in filedisplay) {
      setState(() {
        FirebaseFirestore.instance.collection("fileUploads").add({
          "urlfile": "",
          "extension": element["extension"],
          "percente": 0,
          "finish": true,
          "namefile": element["name"],
          "localpath": element["path"],
          "idmessage": idmessage,
        }).then((value) {
          setState(() {
            filedata.add({
              "publicid": value.id,
              "localpath": element["path"],
            });
          });
        });
      });
    }
    final value = await IsolateFlutter.createAndStart(_sendfunction, filedata);
    updateFirestoreCollection(value);
  }

  static Future<List> _sendfunction(List files) async {
    final cloudinary = Cloudinary.full(
      apiKey: "489522481445921",
      apiSecret: "H9DpbxyRYerllQ4XGnWf6_SOczI",
      cloudName: "smatch",
    );
    List publicIds = [];
    final resources =
        await Future.wait(files.map((file) async => CloudinaryUploadResource(
            filePath: file["localpath"],
            resourceType: CloudinaryResourceType.auto,
            folder: 'test',
            publicId: file["publicid"],
            progressCallback: (count, total) {
              print('Uploading image from file with progress: $count/$total');
            })));
    List<CloudinaryResponse> responses =
        await cloudinary.uploadResources(resources);

    for (var response in responses) {
      if (response.isSuccessful) {
        print('Get your image from with ${response.secureUrl}');
        publicIds.add({
          "pathonline": response.secureUrl,
          "publicId": response.publicId,
          "status": "uploaded",
        });
      }
    }
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
      });
    }
  }
}
