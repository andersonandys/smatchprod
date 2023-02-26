import 'dart:isolate';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

void main() {
  final ReceivePort receivePort = ReceivePort();
  Isolate.spawn(isolateEntry, receivePort.sendPort);

  receivePort.listen((data) {
    if (data is SendPort) {
      final SendPort sendPort = data;

      // Choose a file using file_picker
      chooseFile().then((File file) async {
        if (file != null) {
          String filename = path.basename(file.path);
          final FirebaseStorage storage = FirebaseStorage.instance;
          final Reference ref = storage.ref().child(filename);

          // Send the file to the isolate for upload
          sendPort.send({
            'type': 'upload',
            'file': file,
            'filename': filename,
            'ref': ref.fullPath,
          });
        }
      });
    }
  });
}

void isolateEntry(SendPort sendPort) {
  final ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((data) async {
    if (data['type'] == 'upload') {
      // Upload the file to Firebase Storage
      final FirebaseStorage storage = FirebaseStorage.instance;
      final Reference ref = storage.ref().child(data['filename']);
      final UploadTask uploadTask = ref.putFile(data['file']);

      // Monitor the upload task for progress and completion
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: $progress');
      }, onError: (error) {
        print('Error uploading file: $error');
      });

      try {
        // Wait for the upload task to complete
        await uploadTask;
        print('Upload complete');

        // Get the download URL for the file
        String downloadURL = await ref.getDownloadURL();
        print('Download URL: $downloadURL');
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  });
}

Future<File> chooseFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: ['jpg', "png", "mp4"],
  );
  if (result != null) {
    return File(result.files.single.path!);
  } else {
    return Future.value(null);
  }
}
