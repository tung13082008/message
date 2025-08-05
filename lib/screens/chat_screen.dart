import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart'; // Import đúng widget

class ChatScreen extends StatelessWidget {
  final String currentUid5;
  final String otherUid5;

  const ChatScreen({
    super.key,
    required this.currentUid5,
    required this.otherUid5,
  });

  String get chatId => ([currentUid5, otherUid5]..sort()).join("_");

  @override
  Widget build(BuildContext context) {
    final id = chatId;
    final messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: Text('Chat với $otherUid5')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: messages.snapshots(),
              builder: (ctx, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final msg = docs[i];
                    return MessageBubble(
                      text: msg['text'],
                      sender: msg['senderId'],
                      isMe: msg['senderId'] == currentUid5,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(
            chatId: id,
            senderId: currentUid5,
          ),
        ],
      ),
    );
  }
}
