import 'dart:convert';
import 'dart:typed_data';

enum ItemType { lost, found }

class Item {
  final String id;
  final String title;
  final String description;
  final String location;
  final Uint8List? imageBytes;
  final DateTime date;
  ItemType type;
  final String postedBy;
  final String? foundBy;
  final String status;

  Item({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.imageBytes,
    required this.date,
    required this.type,
    required this.postedBy,
    this.foundBy,
    this.status = 'active',
  });

  String get claimManager => foundBy ?? postedBy;

  factory Item.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['imageBase64'] != null && json['imageBase64'] != '') {
      bytes = base64Decode(json['imageBase64']);
    }
    return Item(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      imageBytes: bytes,
      date: DateTime.parse(json['date']),
      type: json['type'] == 'lost' ? ItemType.lost : ItemType.found,
      postedBy: json['postedBy'],
      foundBy: json['foundBy'],
      status: json['status'] ?? 'active',
    );
  }
}
