import 'dart:convert';
import '../config.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = Config.apiUrl;

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('auth_token', token);
  }

  static Future<void> saveOwner(Map<String, dynamic> owner) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('owner_data', jsonEncode(owner));
  }

  static Future<Map<String, dynamic>?> getSavedOwner() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString('owner_data');
    if (d == null) return null;
    return jsonDecode(d);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('owner_data');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await getToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['message'] ?? 'Request failed (${res.statusCode})');
  }

  // ── AUTH ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: await _headers(auth: false),
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password
        }));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email, 'password': password}));
    final data = _handle(res);
    if (data['token'] != null) {
      await saveToken(data['token']);
      if (data['owner'] != null) await saveOwner(data['owner']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> googleAuth(String idToken) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/google'),
        headers: await _headers(auth: false),
        body: jsonEncode({'idToken': idToken}));
    final data = _handle(res);
    if (data['token'] != null) {
      await saveToken(data['token']);
      if (data['owner'] != null) await saveOwner(data['owner']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/verify-email-otp'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email, 'otp': otp}));
    final data = _handle(res);
    if (data['token'] != null) {
      await saveToken(data['token']);
      if (data['owner'] != null) await saveOwner(data['owner']);
    }
    return data;
  }

  static Future<Map<String, dynamic>> resendOTP({
    required String email,
    String type = 'verify',
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/resend-otp'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email, 'type': type}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/forgot-password'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> verifyResetOTP({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/verify-reset-otp'),
        headers: await _headers(auth: false),
        body: jsonEncode({'email': email, 'otp': otp}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/reset-password'),
        headers: await _headers(auth: false),
        body: jsonEncode({
          'email': email,
          'resetToken': resetToken,
          'newPassword': newPassword
        }));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me'),
        headers: await _headers());
    return _handle(res);
  }

  // ── PROPERTIES ───────────────────────────────────────────
  static Future<Map<String, dynamic>> createProperty({
    required String propertyType,
    required String propertyName,
    required String location,
    String localLandmark = '',
    required Map<String, dynamic> details,
  }) async {
    final body = {
      'propertyType': propertyType,
      'propertyName': propertyName,
      'location': location,
      'localLandmark': localLandmark,
      ...details,
    };
    final res = await http.post(Uri.parse('$baseUrl/properties'),
        headers: await _headers(), body: jsonEncode(body));
    return _handle(res);
  }

  // ✅ Update property (for edit screen)
  static Future<Map<String, dynamic>> updateProperty(
      String id, Map<String, dynamic> data) async {
    final res = await http.put(Uri.parse('$baseUrl/properties/$id'),
        headers: await _headers(), body: jsonEncode(data));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> uploadPropertyPhotos({
    required String propertyId,
    required List<Uint8List> imageBytes,
    required List<String> fileNames,
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/properties/$propertyId/photos'));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    for (int i = 0; i < imageBytes.length; i++) {
      final name = fileNames.isNotEmpty ? fileNames[i] : 'photo_$i.jpg';
      final ext = name.split('.').last.toLowerCase();
      final mime = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
      request.files.add(http.MultipartFile.fromBytes('photos', imageBytes[i],
          filename: name, contentType: MediaType.parse(mime)));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getMyProperties(
      {String? status, String? type}) async {
    var url = '$baseUrl/properties';
    final params = <String>[];
    if (status != null) params.add('status=$status');
    if (type != null) params.add('type=$type');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    final res = await http.get(Uri.parse('$baseUrl/properties/dashboard'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> updatePropertyStatus(
      String id, String status) async {
    final res = await http.patch(Uri.parse('$baseUrl/properties/$id/status'),
        headers: await _headers(), body: jsonEncode({'status': status}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> deleteProperty(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/properties/$id'),
        headers: await _headers());
    return _handle(res);
  }

  // ── VISITS ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> getVisits(
      {String? category, String? status}) async {
    var url = '$baseUrl/visits';
    final params = <String>[];
    if (category != null) params.add('category=$category');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) url += '?${params.join('&')}';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> confirmVisit(String id) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/confirm'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> rescheduleVisit(String id,
      {required String newDate,
      required String newTime,
      String reason = ''}) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/reschedule'),
        headers: await _headers(),
        body: jsonEncode(
            {'newDate': newDate, 'newTime': newTime, 'reason': reason}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> cancelVisit(
      String id, String reason) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/cancel'),
        headers: await _headers(), body: jsonEncode({'reason': reason}));
    return _handle(res);
  }

  // ── NOTIFICATIONS ────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() async {
    final res = await http.get(Uri.parse('$baseUrl/notifications'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<void> markAllRead() async {
    await http.patch(Uri.parse('$baseUrl/notifications/read-all'),
        headers: await _headers());
  }

  static Future<void> clearNotifications() async {
    await http.delete(Uri.parse('$baseUrl/notifications/clear'),
        headers: await _headers());
  }

  // ── MESSAGES ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getChats() async {
    final res = await http.get(Uri.parse('$baseUrl/messages'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    final res = await http.get(Uri.parse('$baseUrl/messages/$chatId'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> sendReply(
      String chatId, String text) async {
    final res = await http.post(Uri.parse('$baseUrl/messages/$chatId/reply'),
        headers: await _headers(), body: jsonEncode({'text': text}));
    return _handle(res);
  }

  // ── DOCUMENT UPLOAD ──────────────────────────────────────
  /// Upload registry and/or NOC documents for a property.
  static Future<Map<String, dynamic>> uploadDocuments({
    required String propertyId,
    Uint8List? registryBytes,
    String? registryFileName,
    Uint8List? nocBytes,
    String? nocFileName,
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/properties/$propertyId/documents'),
    );
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (registryBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'registry',
        registryBytes,
        filename: registryFileName ?? 'registry.pdf',
        contentType:
            MediaType.parse(_mimeFor(registryFileName ?? 'registry.pdf')),
      ));
    }
    if (nocBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'noc',
        nocBytes,
        filename: nocFileName ?? 'noc.pdf',
        contentType: MediaType.parse(_mimeFor(nocFileName ?? 'noc.pdf')),
      ));
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static String _mimeFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ── OWNER CHAT ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getOwnerChats() async {
    final res = await http.get(Uri.parse('$baseUrl/customers/owner-chats'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getOwnerChatMessages(
      String chatId) async {
    final res = await http.get(
        Uri.parse('$baseUrl/customers/owner-chats/$chatId/messages'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> ownerSendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? linkUrl,
  }) async {
    final res = await http.post(
        Uri.parse('$baseUrl/customers/owner-chats/$chatId/messages'),
        headers: await _headers(),
        body: jsonEncode({
          'text': text,
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (linkUrl != null) 'linkUrl': linkUrl
        }));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> ownerPollMessages(
      String chatId, String since) async {
    final uri = Uri.parse('$baseUrl/customers/owner-chats/$chatId/poll')
        .replace(queryParameters: {'since': since});
    final res = await http.get(uri, headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> confirmVisitOwner(String id,
      {String note = ''}) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/confirm'),
        headers: await _headers(), body: jsonEncode({'ownerNote': note}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> cancelVisitOwner(
      String id, String reason) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/cancel'),
        headers: await _headers(), body: jsonEncode({'reason': reason}));
    return _handle(res);
  }

  static Future<Map<String, dynamic>> completeVisitOwner(String id) async {
    final res = await http.patch(Uri.parse('$baseUrl/visits/$id/complete'),
        headers: await _headers());
    return _handle(res);
  }

  // ── OWNER MESSAGE ACTIONS ─────────────────────────────────
  static Future<Map<String, dynamic>> ownerUploadChatPhoto({
    required String chatId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final token = await getToken();
    final request = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/customers/owner-chats/$chatId/upload'));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files
        .add(http.MultipartFile.fromBytes('photo', bytes, filename: fileName));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw Exception(body['message'] ?? 'Upload failed');
  }

  static Future<Map<String, dynamic>> ownerEditMessage({
    required String chatId,
    required String msgId,
    required String newText,
  }) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/customers/owner-chats/$chatId/messages/$msgId'),
      headers: await _headers(),
      body: jsonEncode({'text': newText}),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> ownerDeleteMessage({
    required String chatId,
    required String msgId,
    required String scope,
  }) async {
    final req = http.Request('DELETE',
        Uri.parse('$baseUrl/customers/owner-chats/$chatId/messages/$msgId'));
    req.headers.addAll(await _headers());
    req.body = jsonEncode({'scope': scope});
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getVisitById(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/visits/$id'),
        headers: await _headers());
    return _handle(res);
  }

  static Future<Map<String, dynamic>> uploadOwnerChatAudio({
    required String chatId,
    required List<int> bytes,
    required String fileName,
  }) async {
    final uri =
        Uri.parse('$baseUrl/customers/owner-chats/$chatId/upload-audio');
    final req = http.MultipartRequest('POST', uri);
    req.headers.addAll(await _headers());
    req.files.add(http.MultipartFile.fromBytes('audio', bytes,
        filename: fileName, contentType: MediaType('audio', 'webm')));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> submitSupportTicket({
    required String subject,
    required String message,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/support/owner'),
      headers: await _headers(),
      body: jsonEncode({'subject': subject, 'message': message}),
    );
    return _handle(res);
  }

  // Owner schedules a visit directly
  static Future<Map<String, dynamic>> scheduleVisitOwner({
    required String propertyId,
    required String visitorName,
    required String visitorPhone,
    required String visitDate,
    required String visitTime,
    String requirement = '',
    String? customerId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/visits'),
      headers: await _headers(),
      body: jsonEncode({
        'propertyId': propertyId,
        'visitorName': visitorName,
        'visitorPhone': visitorPhone,
        'visitDate': visitDate,
        'visitTime': visitTime,
        'requirement': requirement,
        if (customerId != null) 'customerId': customerId,
      }),
    );
    return _handle(res);
  }

  // Owner edits visit date/time directly (sends updated card to chat)
  static Future<Map<String, dynamic>> editVisitOwner(
    String id, {
    required String visitDate,
    required String visitTime,
  }) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/visits/$id/edit'),
      headers: await _headers(),
      body: jsonEncode({'visitDate': visitDate, 'visitTime': visitTime}),
    );
    return _handle(res);
  }

  // Owner sends a note/message on a visit (shown to customer on their booking card)
  static Future<Map<String, dynamic>> sendVisitNote(
      String id, String note) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/visits/$id/note'),
      headers: await _headers(),
      body: jsonEncode({'note': note}),
    );
    return _handle(res);
  }

  // Owner accepts a customer-edited visit
  static Future<Map<String, dynamic>> acceptVisitOwner(String id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/visits/$id/accept'),
      headers: await _headers(),
    );
    return _handle(res);
  }
}
