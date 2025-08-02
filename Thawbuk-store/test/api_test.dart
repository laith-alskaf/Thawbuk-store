import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  const baseUrl = 'https://thawbuk.vercel.app/api';

  group('Auth API', () {
    // Generate a unique email for each test run to avoid conflicts
    final uniqueEmail = 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com';

    test('Register a new user successfully', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': uniqueEmail,
          'password': 'password123',
          'role': 'admin',
          'companyDetails': {
            'companyName': 'Test Company ${DateTime.now().millisecondsSinceEpoch}',
            'companyAddress': {
              'city': 'Damascus'
            }
          }
        }),
      );
      expect(response.statusCode, 201, reason: 'API should return 201 on successful registration. Body: ${response.body}');
    });

    test('Attempt to register a user with an existing email', () async {
      // First, register a user
      await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'existing@example.com',
          'password': 'password123',
          'role': 'admin',
          'companyDetails': {
            'companyName': 'Existing Company',
            'companyAddress': {
              'city': 'Aleppo'
            }
          }
        }),
      );

      // Then, attempt to register again with the same email
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'existing@example.com',
          'password': 'password456',
          'role': 'admin',
          'companyDetails': {
            'companyName': 'Existing Company',
            'companyAddress': {
              'city': 'Homs'
            }
          }
        }),
      );
      // Assuming the API returns a 400 Bad Request status for existing users that are not verified
      expect(response.statusCode, 400, reason: 'API should return 400 if email already exists and is not verified. Body: ${response.body}');
    });

    test('Login with a registered user', () async {
      // Register a user to ensure they exist for login
      final loginEmail = 'loginuser_${DateTime.now().millisecondsSinceEpoch}@example.com';
      await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': loginEmail,
          'password': 'password123',
          'role': 'admin',
          'companyDetails': {
            'companyName': 'Login Company ${DateTime.now().millisecondsSinceEpoch}',
            'companyAddress': {
              'city': 'Latakia'
            }
          }
        }),
      );

      // Now, log in with the user
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': loginEmail,
          'password': 'password123',
        }),
      );
      expect(response.statusCode, 200, reason: 'API should return 200 on successful login. Body: ${response.body}');
      final body = json.decode(response.body);
      expect(body['token'], isNotNull, reason: 'Response body should contain a token.');
    });

    test('Login with incorrect password', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': 'testuser@example.com',
          'password': 'wrongpassword',
        }),
      );
      // Assuming the API returns a 401 Unauthorized status for incorrect credentials
      expect(response.statusCode, 401, reason: 'API should return 401 for incorrect password. Body: ${response.body}');
    });
  });
}
