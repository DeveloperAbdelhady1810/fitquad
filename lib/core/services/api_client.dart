import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = kDebugMode
      ? 'http://192.168.8.102:8080/api/v1'       // dev: simulator uses localhost
      : 'https://api.fitquad.com/api/v1';     // production

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';

  // ── Token storage ─────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Headers ───────────────────────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── HTTP verbs ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await http.get(uri, headers: await _headers(auth: auth));
    return _handle(response);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> uploadMultipart(
    String path,
    File file, {
    String fileField = 'photo',
    Map<String, String>? fields,
  }) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl$path');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer ${token ?? ''}';
    if (fields != null) req.fields.addAll(fields);
    req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    final streamed = await req.send();
    final response = await http.Response.fromStream(streamed);
    return _handle(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.delete(uri, headers: await _headers(auth: auth));
    return _handle(response);
  }

  // ── Response handler ──────────────────────────────────────────
  static Map<String, dynamic> _handle(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ?? 'Request failed';
    final errors = body['errors'] as Map<String, dynamic>?;
    throw ApiException(message: message, errors: errors, statusCode: response.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final int statusCode;

  const ApiException({
    required this.message,
    this.errors,
    required this.statusCode,
  });

  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    final first = errors!.values.first;
    if (first is List && first.isNotEmpty) return first.first.toString();
    return message;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
