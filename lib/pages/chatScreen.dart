import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/constants.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'User/UserScreen_Notifer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? adminId;
  final String? userId;
  final String? callNo;
  final String? getDocId;
  final String? userName;

  ChatScreen(
      {required this.adminId,
      required this.userId,
      required this.callNo,
      required this.getDocId,
      required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        title: Text(
          widget.userName ?? "",
          style: GlobalTextStyles.secondaryText1(
              textColor: FlutterFlowTheme.of(context).secondary2,
              txtWeight: FontWeight.w700),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: widget.callNo,
                    );
                    await launchUrl(launchUri);
                  },
                  child: Icon(
                    Icons.call,
                    color: FlutterFlowTheme.of(context).primaryBtnText,
                    size: 24.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('users')
                  .doc(widget.getDocId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final content = message['content'];

                    final sender = message['sender'];
                    final isSender = sender == widget.adminId;
                    // Constants.isAdmin ? widget.adminId : widget.userId,

                    return Align(
                      alignment: Constants.isAdmin
                          ? isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft
                          : isSender
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSender
                              ? FlutterFlowTheme.of(context).primary
                              : Colors.green,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          content,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 25, left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getChatId() {
    // Sort the adminId and userId to ensure consistent chat ID
    final sortedIds = [widget.adminId, widget.userId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void _sendMessage(String message) {
    Future<bool> isCollectionEmpty(String collectionName) async {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    }

    final chatId = getChatId();

    firestore
        .collection('users')
        .doc(widget.getDocId)
        .collection('messages')
        .add({
      'sender': Constants.isAdmin ? widget.adminId : widget.userId,
      'receiver': Constants.isAdmin ? widget.userId : widget.adminId,
      'content': message,
      'userDocId': widget.getDocId,
      'timestamp': DateTime.now(),
    }).then((_) {
      _updateBadgeIfNewMessage(
          widget.getDocId, Constants.isAdmin ? widget.adminId : widget.userId);
    }).catchError((error) {
      print('$error');
    });
  }

  void _updateBadgeIfNewMessage(String? userId, String? senderType) {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'notificationByAdmin': senderType == Constants.adminId ? true : false,
    }).then((_) {
      print('User $userId badge count incremented by 1.');
    }).catchError((error) {
      print('Error updating user $userId badge count: $error');
    });
  }
}
