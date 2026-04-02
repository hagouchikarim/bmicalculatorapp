import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/constant.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final String basicAuth = 'Basic ${base64Encode(utf8.encode('express-client:express-secret'))}';

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/oauth/token'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
        if (data['user'] != null) {
          await storage.write(key: 'user_name', value: data['user']['name']?.toString() ?? 'User');
          await storage.write(key: 'user_gender', value: data['user']['gender']?.toString() ?? 'M');
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refreshToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/oauth/token'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': token,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<int> register(String username, String password, String name, String gender) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/oauth/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'name': name,
          'gender': gender,
        }),
      );
      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }
}
