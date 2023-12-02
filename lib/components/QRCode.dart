// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ImageUploadDownloadDemo(),
//     );
//   }
// }
//
// class ImageUploadDownloadDemo extends StatefulWidget {
//   @override
//   _ImageUploadDownloadDemoState createState() =>
//       _ImageUploadDownloadDemoState();
// }
//
// class _ImageUploadDownloadDemoState extends State<ImageUploadDownloadDemo> {
//   final FirebaseStorage _storage = FirebaseStorage.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   String downloadedImagePath = '';
//
//   Future<void> uploadImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       final File imageFile = File(pickedFile.path);
//       final imageName = DateTime.now().millisecondsSinceEpoch.toString();
//
//       try {
//         final UploadTask task =
//             _storage.ref('images/$imageName.jpg').putFile(imageFile);
//
//         task.snapshotEvents.listen((TaskSnapshot snapshot) async {
//           print(snapshot.state.name);
//           if (snapshot.state == TaskState.success) {
//             final imageUrl = await snapshot.ref.getDownloadURL();
//             await _firestore.collection('images').add({'url': imageUrl});
//             print('Image uploaded to Firestore with URL: $imageUrl');
//           }
//         });
//       } catch (e) {
//         print('Failed to upload image: $e');
//       }
//     }
//   }
//
//   Future<void> downloadImage() async {
//     final querySnapshot = await _firestore.collection('images').get();
//     if (querySnapshot.docs.isNotEmpty) {
//       final imageUrl = querySnapshot.docs.first.get('url');
//
//       try {
//         final ref = _storage.refFromURL(imageUrl);
//         final File imageFile = File(
//             '${(await getApplicationDocumentsDirectory()).path}/downloaded_image.jpg');
//         await ref.writeToFile(imageFile);
//
//         setState(() {
//           downloadedImagePath = imageFile.path;
//         });
//
//         print('Image downloaded to: ${imageFile.path}');
//       } catch (e) {
//         print('Failed to download image: $e');
//       }
//     } else {
//       print('No image found in Firestore.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Upload and Download Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (downloadedImagePath.isNotEmpty)
//               Image.file(
//                 File(downloadedImagePath),
//                 width: 200,
//                 height: 200,
//               ),
//             ElevatedButton(
//               onPressed: uploadImage,
//               child: Text('Upload Image'),
//             ),
//             ElevatedButton(
//               onPressed: downloadImage,
//               child: Text('Download Image'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DownloadFileDemo(),
    );
  }
}

class DownloadFileDemo extends StatefulWidget {
  @override
  _DownloadFileDemoState createState() => _DownloadFileDemoState();
}

class _DownloadFileDemoState extends State<DownloadFileDemo> {
  // Replace this URL with the file URL you want to download
  final String fileUrl =
      'https://drive.google.com/uc?export=download&id=1SZ2_xy5wa6bhr46QQmz7rUC294cCpbdc';

  bool downloading = false;
  String downloadedFilePath = '';

  Future<void> downloadFile() async {
    setState(() {
      downloading = true;
    });

    final response = await http.get(Uri.parse(fileUrl));

    if (response.statusCode == 200) {
      // final appDir = await getApplicationDocumentsDirectory();
      // final fileName =
      //     'downloaded_file.jpg'; // Change the file name and extension as needed
      // final filePath = '${appDir.path}/$fileName';

      String customPath = '';

      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        customPath = directory!.path;
        // customPath = "/storage/emulated/0/Savings"
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        customPath = directory.path;
      }

      // customPath = '$customPath/downloaded_file.pdf';
      customPath = '$customPath/downloaded_file.jpg';

      // File file = File(filePath);
      File file = File(customPath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        // downloadedFilePath = filePath;
        downloadedFilePath = customPath;
        downloading = false;
      });

      // print('File downloaded to: $filePath');
      print('File downloaded to: $customPath');
    } else {
      setState(() {
        downloading = false;
      });
      print('Failed to download file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download File Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (downloading)
              CircularProgressIndicator()
            else if (downloadedFilePath.isNotEmpty)
              Text('File downloaded to: $downloadedFilePath'),
            ElevatedButton(
              onPressed: downloadFile,
              child: Text('Download File'),
            ),
          ],
        ),
      ),
    );
  }
}
