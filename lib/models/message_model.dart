class ChatMessage {
  final String id;
  final String itemId;
  final String senderUsername;
  final String text;
  final DateTime date;

  ChatMessage({
    required this.id,
    required this.itemId,
    required this.senderUsername,
    required this.text,
    required this.date,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      itemId: json['itemId'],
      senderUsername: json['senderUsername'],
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}
