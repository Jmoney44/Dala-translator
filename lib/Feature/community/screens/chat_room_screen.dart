import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google/Feature/community/models/chatrom.dart';
import 'package:google/components/message_bubble.dart';

class ChatRoomScreen extends StatelessWidget {
  final String roomId;
  final TextEditingController _messageController = TextEditingController();

  ChatRoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('chatRooms').doc(roomId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            final room = ChatRoom.fromMap(snapshot.data!.data() as Map<String, dynamic>);
            return Text(room.name);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chatRooms').doc(roomId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message = snapshot.data!.docs[index];
                    return MessageBubble(
                      text: message['text'],
                      isMe: message['senderId'] == FirebaseAuth.instance.currentUser?.uid,
                      senderName: message['senderName'],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) async {
    if (_messageController.text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('chatRooms').doc(roomId).collection('messages').add({
      'text': _messageController.text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Anonymous',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }
}
