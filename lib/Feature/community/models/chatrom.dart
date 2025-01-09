class ChatRoom {
  final String id;
  final String name;
  final String creatorId;
  final DateTime createdAt;
  final List<String> members;

  ChatRoom({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.createdAt,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'members': members,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'],
      name: map['name'],
      creatorId: map['creatorId'],
      createdAt: DateTime.parse(map['createdAt']),
      members: List<String>.from(map['members']),
    );
  }
}
