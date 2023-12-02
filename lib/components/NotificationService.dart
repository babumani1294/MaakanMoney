import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../pages/budget_copy/budget_copy_widget.dart';

class NotificationService {
  static Future<Response?> postNotificationRequest(
      String token, String getTitleMessage, String getBodyMessage) async {
    Response? res;
    var url = Uri.parse("https://fcm.googleapis.com/fcm/send");

    try {
      var response = await http.Client().post(url,
          body: jsonEncode({
            "to": token,
            "priority": "high",
            "notification": {
              "title": getTitleMessage,
              "body": getBodyMessage,
            },
            "data": {
              "custom_key":
              "custom_value" // Optional: You can include custom data here
            }
          }),
          headers: {
            "Accept": "application/json",
            "Content-type": "application/json",
            "Authorization":
            "key=AAAAb-_MBP8:APA91bFubSJ4pOcNkYMD9uFXekSyOQel1Mzojc1Q7noOPRiR-WNu_C_FgoZ-lQ6Maa1A52NqAoLM7tdQTZ7nEeXs_WUhhqjUg5B0P2lCp2rf95PxdR0PaOSVZUz8UeWJArogfm3gFKRp",
          });

      var body = response.body;
      print("JSON Response -- $body");
      if (response.statusCode == 200) {
        body = await response.body;
      }
      res = Response(response.statusCode, body);
    } on SocketException catch (e) {
      print(e);
      res = Response(
          001, 'No Internet Connection\nPlease check your network status');
    }

    print("res <- ${res?.resBody.toString()}");
    return res;
  }

  static Future<String?> getDocumentIDsAndData() async {
    final CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('AdminToken');

    // Get the documents in the collection
    QuerySnapshot querySnapshot = await collectionRef.get();

    // Iterate through the documents in the snapshot
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Access the document ID
      String documentID = documentSnapshot.id;

      // Access the document data as a Map
      Map<String, dynamic> documentData =
      documentSnapshot.data() as Map<String, dynamic>;

      // Access the value of the field (assuming there's only one field)
      dynamic fieldValue = documentData['token'];

      // Print the document ID and field value
      print('Document ID: $documentID, Token Value: $fieldValue');
      return fieldValue ?? "";
    }
  }
}
