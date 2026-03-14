class NotificationModel {
  final String id;
  final String recipientUsername;
  final String message;
  final String? itemId;
  final String type;
  final bool isRead;
  final DateTime date;

  NotificationModel({
    required this.id,
    required this.recipientUsername,
    required this.message,
    this.itemId,
    required this.type,
    required this.isRead,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      recipientUsername: json['recipientUsername'],
      message: json['message'],
      itemId: json['itemId'],
      type: json['type'],
      isRead: json['isRead'] ?? false,
      date: DateTime.parse(json['date']),
    );
  }
}
