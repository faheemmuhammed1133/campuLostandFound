import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<http.Response> _request(
    Future<http.Response> Function() request,
    String action,
  ) async {
    try {
      return await request();
    } catch (error, stackTrace) {
      final message = _stringifyError(error);
      Error.throwWithStackTrace(
        Exception('$action failed: $message'),
        stackTrace,
      );
    }
  }

  static String _stringifyError(Object error) {
    final text = error.toString().trim();
    if (text.isEmpty || text == 'null') {
      return 'Unknown client error';
    }
    return text;
  }

  static dynamic _tryDecodeJson(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return jsonDecode(trimmed);
  }

  static Map<String, dynamic> _decodeMap(String body, String action) {
    final decoded = _tryDecodeJson(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw FormatException('Invalid response for $action: expected an object');
  }

  static List<Map<String, dynamic>> _decodeList(String body, String action) {
    final decoded = _tryDecodeJson(body);
    if (decoded is List) {
      return decoded.map((entry) => Map<String, dynamic>.from(entry)).toList();
    }
    throw FormatException('Invalid response for $action: expected a list');
  }

  static String _extractErrorMessage(
    http.Response response,
    String fallback,
  ) {
    try {
      final decoded = _tryDecodeJson(response.body);
      if (decoded is Map && decoded['error'] != null) {
        final message = decoded['error'].toString().trim();
        if (message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Fall back to a generic message when error payload is not valid JSON.
    }

    final body = response.body.trim();
    if (body.isNotEmpty && body.length <= 200) {
      return '$fallback ($body)';
    }
    return fallback;
  }

  // Auth
  static Future<String> login(String username, String password) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ),
      'Login request',
    );

    if (response.statusCode == 200) {
      final data = _decodeMap(response.body, 'login');
      final usernameValue = data['username'];
      if (usernameValue is String && usernameValue.isNotEmpty) {
        return usernameValue;
      }
      throw const FormatException('Login response is missing username');
    } else {
      throw Exception(_extractErrorMessage(response, 'Login failed'));
    }
  }

  static Future<String> register(String username, String password) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ),
      'Registration request',
    );

    if (response.statusCode == 201) {
      final data = _decodeMap(response.body, 'register');
      final usernameValue = data['username'];
      if (usernameValue is String && usernameValue.isNotEmpty) {
        return usernameValue;
      }
      throw const FormatException('Registration response is missing username');
    } else {
      throw Exception(_extractErrorMessage(response, 'Registration failed'));
    }
  }

  // Items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final response = await _request(
      () => http.get(Uri.parse('$baseUrl/items')),
      'Load items request',
    );
    if (response.statusCode == 200) {
      return _decodeList(response.body, 'items');
    }
    throw Exception(_extractErrorMessage(response, 'Failed to load items'));
  }

  static Future<Map<String, dynamic>> createItem({
    required String title,
    required String description,
    required String location,
    String? imageBase64,
    required String type,
    required String postedBy,
  }) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'location': location,
          'imageBase64': imageBase64,
          'type': type,
          'postedBy': postedBy,
        }),
      ),
      'Create item request',
    );
    if (response.statusCode == 201) {
      return _decodeMap(response.body, 'create item');
    }
    throw Exception(_extractErrorMessage(response, 'Failed to create item'));
  }

  static Future<void> markAsFound(String itemId, String username) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/items/$itemId/mark-found'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'foundBy': username}),
      ),
      'Mark item as found request',
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to mark item as found'),
      );
    }
  }

  static Future<void> deleteItem(String itemId) async {
    final response = await _request(
      () => http.delete(
        Uri.parse('$baseUrl/items/$itemId'),
      ),
      'Delete item request',
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response, 'Failed to delete item'));
    }
  }

  // Claims
  static Future<List<Map<String, dynamic>>> getClaims(String itemId) async {
    final response = await _request(
      () => http.get(
        Uri.parse('$baseUrl/claims?itemId=$itemId'),
      ),
      'Load claims request',
    );
    if (response.statusCode == 200) {
      return _decodeList(response.body, 'claims');
    }
    throw Exception(_extractErrorMessage(response, 'Failed to load claims'));
  }

  static Future<void> createClaim({
    required String itemId,
    required String claimerUsername,
    required String description,
  }) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/claims'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemId': itemId,
          'claimerUsername': claimerUsername,
          'description': description,
        }),
      ),
      'Create claim request',
    );
    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response, 'Failed to create claim'));
    }
  }

  static Future<void> approveClaim(String claimId) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/claims/$claimId/approve'),
      ),
      'Approve claim request',
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response, 'Failed to approve claim'));
    }
  }

  static Future<void> rejectClaim(String claimId) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/claims/$claimId/reject'),
      ),
      'Reject claim request',
    );
    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response, 'Failed to reject claim'));
    }
  }

  // Notifications
  static Future<List<Map<String, dynamic>>> getNotifications(
      String username) async {
    final response = await _request(
      () => http.get(
        Uri.parse('$baseUrl/notifications?username=$username'),
      ),
      'Load notifications request',
    );
    if (response.statusCode == 200) {
      return _decodeList(response.body, 'notifications');
    }
    throw Exception(
      _extractErrorMessage(response, 'Failed to load notifications'),
    );
  }

  static Future<void> markNotificationRead(String notificationId) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
      ),
      'Mark notification read request',
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to mark notification as read'),
      );
    }
  }

  static Future<void> markAllNotificationsRead(String username) async {
    final response = await _request(
      () => http.put(
        Uri.parse('$baseUrl/notifications/read-all?username=$username'),
      ),
      'Mark all notifications read request',
    );
    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(
          response,
          'Failed to mark all notifications as read',
        ),
      );
    }
  }

  // Messages
  static Future<List<Map<String, dynamic>>> getMessages(String itemId) async {
    final response = await _request(
      () => http.get(
        Uri.parse('$baseUrl/messages?itemId=$itemId'),
      ),
      'Load messages request',
    );
    if (response.statusCode == 200) {
      return _decodeList(response.body, 'messages');
    }
    throw Exception(_extractErrorMessage(response, 'Failed to load messages'));
  }

  static Future<List<Map<String, dynamic>>> getConversations(
      String username) async {
    final response = await _request(
      () => http.get(
        Uri.parse('$baseUrl/messages/conversations?username=$username'),
      ),
      'Load conversations request',
    );
    if (response.statusCode == 200) {
      return _decodeList(response.body, 'conversations');
    }
    throw Exception(
      _extractErrorMessage(response, 'Failed to load conversations'),
    );
  }

  static Future<Map<String, dynamic>> getItem(String itemId) async {
    final response = await _request(
      () => http.get(
        Uri.parse('$baseUrl/items/$itemId'),
      ),
      'Load item request',
    );
    if (response.statusCode == 200) {
      return _decodeMap(response.body, 'item');
    }
    throw Exception(_extractErrorMessage(response, 'Failed to load item'));
  }

  static Future<void> sendMessage({
    required String itemId,
    required String senderUsername,
    required String text,
  }) async {
    final response = await _request(
      () => http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'itemId': itemId,
          'senderUsername': senderUsername,
          'text': text,
        }),
      ),
      'Send message request',
    );
    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response, 'Failed to send message'));
    }
  }

  // Location
  static Future<String> fetchCurrentApproxLocation() async {
    final response = await _request(
      () => http.get(Uri.parse('https://ipapi.co/json/')),
      'Fetch location request',
    );

    if (response.statusCode != 200) {
      throw Exception(
        _extractErrorMessage(response, 'Failed to fetch current location'),
      );
    }

    final data = _decodeMap(response.body, 'location lookup');
    final city = data['city']?.toString().trim() ?? '';
    final region = data['region']?.toString().trim() ?? '';
    final country = data['country_name']?.toString().trim() ?? '';

    final parts = [city, region, country].where((value) => value.isNotEmpty);
    final formatted = parts.join(', ');
    if (formatted.isNotEmpty) {
      return formatted;
    }

    final lat = data['latitude']?.toString().trim() ?? '';
    final lng = data['longitude']?.toString().trim() ?? '';
    if (lat.isNotEmpty && lng.isNotEmpty) {
      return '$lat, $lng';
    }

    throw const FormatException('Location API returned incomplete data');
  }
}
