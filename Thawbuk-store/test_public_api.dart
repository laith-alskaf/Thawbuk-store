import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'https://thawbuk.vercel.app/api';
  
  print('Testing public API endpoints...');
  
  // Test different possible public endpoints
  final endpoints = [
    '/public/product',
    '/public/category',
    '/product/public',
    '/category/public',
    '/products',
    '/categories',
  ];
  
  for (final endpoint in endpoints) {
    try {
      print('\nTesting GET $endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Success! Response structure: ${data.keys}');
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  
  // Test with guest token or no auth
  print('\n\nTesting original endpoints without auth...');
  try {
    print('\nTesting GET /product (no auth)');
    final response = await http.get(
      Uri.parse('$baseUrl/product'),
      headers: {
        'Content-Type': 'application/json',
        // Try with a guest header
        'X-Guest-Access': 'true',
      },
    );
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success! Response structure: ${data.keys}');
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}