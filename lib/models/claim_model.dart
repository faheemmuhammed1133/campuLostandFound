enum ClaimStatus { pending, approved, rejected }

class Claim {
  final String id;
  final String itemId;
  final String claimerUsername;
  final String description;
  final DateTime date;
  ClaimStatus status;

  Claim({
    required this.id,
    required this.itemId,
    required this.claimerUsername,
    required this.description,
    required this.date,
    this.status = ClaimStatus.pending,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['_id'],
      itemId: json['itemId'],
      claimerUsername: json['claimerUsername'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      status: _parseStatus(json['status']),
    );
  }

  static ClaimStatus _parseStatus(String status) {
    switch (status) {
      case 'approved':
        return ClaimStatus.approved;
      case 'rejected':
        return ClaimStatus.rejected;
      default:
        return ClaimStatus.pending;
    }
  }
}
