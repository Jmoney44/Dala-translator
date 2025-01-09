import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google/Feature/community/models/chatrom.dart';
import 'package:google/Feature/community/screens/chat_room_screen.dart';
import 'package:google/components/bottom_navbar.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = "chat_screen";
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomNavigationBar(currentIndex: 3),
      appBar: AppBar(
        title: Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreateRoomDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chatRooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final room = ChatRoom.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>);

              return ListTile(
                title: Text(room.name),
                subtitle: Text('Created by: ${room.creatorId}'),
                trailing: Text('${room.members.length} members'),
                onTap: () => _joinRoom(context, room),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Chat Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && nameController.text.isNotEmpty) {
                final room = ChatRoom(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  creatorId: user.uid,
                  createdAt: DateTime.now(),
                  members: [user.uid],
                );

                await FirebaseFirestore.instance.collection('chatRooms').doc(room.id).set(room.toMap());

                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _joinRoom(BuildContext context, ChatRoom room) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !room.members.contains(user.uid)) {
      await FirebaseFirestore.instance.collection('chatRooms').doc(room.id).update({
        'members': FieldValue.arrayUnion([user.uid])
      });
    }

    // Navigate to chat room screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(roomId: room.id),
      ),
    );
  }
}
