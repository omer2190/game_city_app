class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String type;
  final int timestamp;
  final bool read;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.read,
  });

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId']?.toString() ?? '',
      content: (map['text'] ?? map['content'])?.toString() ?? '',
      type: map['type']?.toString() ?? 'text',
      timestamp: map['createdAt'] is int
          ? map['createdAt']
          : (map['timestamp'] is int
                ? map['timestamp']
                : int.tryParse(
                        (map['createdAt'] ?? map['timestamp'] ?? '0')
                            .toString(),
                      ) ??
                      0),
      read: map['read'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': content,
      'type': type,
      'createdAt': timestamp,
      'read': read,
    };
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
