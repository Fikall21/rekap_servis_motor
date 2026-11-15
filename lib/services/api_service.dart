import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _cachedBaseUrl;

  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    if (kIsWeb) {
      final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
      _cachedBaseUrl = 'http://$host:3000/api';
      return _cachedBaseUrl!;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await http
            .get(Uri.parse('http://localhost:3000/api/servis/0'))
            .timeout(const Duration(milliseconds: 500));
        _cachedBaseUrl = 'http://localhost:3000/api';
      } catch (_) {
        _cachedBaseUrl = 'http://10.0.2.2:3000/api';
      }
      return _cachedBaseUrl!;
    }

    _cachedBaseUrl = 'http://localhost:3000/api';
    return _cachedBaseUrl!;
  }

  static Future<Map<String, dynamic>> register(
      String nama, String email, String password) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server Docker: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('nama', data['user']['nama']);
        await prefs.setString('email', data['user']['email']);
        await prefs.setBool('is_logged_in', true);
      }

      return data;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Gagal terhubung ke server Docker: $e'
      };
    }
  }

  static Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;

    return {
      'id': prefs.getInt('user_id'),
      'nama': prefs.getString('nama'),
      'email': prefs.getString('email'),
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<List<dynamic>> getServisByUser(int userId) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/servis/$userId'));
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> tambahServis(Map<String, dynamic> payload) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/servis'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      return response.statusCode == 201 && data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateServis(int id, Map<String, dynamic> payload) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/servis/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hapusServis(int id) async {
    try {
      final baseUrl = await getBaseUrl();
      final response = await http.delete(Uri.parse('$baseUrl/servis/$id'));
      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}