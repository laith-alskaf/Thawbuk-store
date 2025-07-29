import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'https://thawbuk.vercel.app/api';
  
  print('Testing API endpoints...');
  
  // Test 1: Get all products
  try {
    print('\n1. Testing GET /product');
    final response1 = await http.get(
      Uri.parse('$baseUrl/product'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Status: ${response1.statusCode}');
    if (response1.statusCode == 200) {
      final data = json.decode(response1.body);
      print('Response structure: ${data.keys}');
      if (data['products'] != null) {
        print('Products count: ${(data['products'] as List).length}');
      }
    } else {
      print('Error: ${response1.body}');
    }
  } catch (e) {
    print('Error in test 1: $e');
  }
  
  // Test 2: Get categories
  try {
    print('\n2. Testing GET /category');
    final response2 = await http.get(
      Uri.parse('$baseUrl/category'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Status: ${response2.statusCode}');
    if (response2.statusCode == 200) {
      final data = json.decode(response2.body);
      print('Response structure: ${data.keys}');
      if (data['categories'] != null) {
        final categories = data['categories'] as List;
        print('Categories count: ${categories.length}');
        if (categories.isNotEmpty) {
          final firstCategory = categories.first;
          print('First category: ${firstCategory['name']} (ID: ${firstCategory['_id']})');
          
          // Test 3: Get products by category
          try {
            print('\n3. Testing GET /product/byCategory');
            final response3 = await http.get(
              Uri.parse('$baseUrl/product/byCategory?category=${firstCategory['_id']}'),
              headers: {'Content-Type': 'application/json'},
            );
            print('Status: ${response3.statusCode}');
            if (response3.statusCode == 200) {
              final data3 = json.decode(response3.body);
              print('Response structure: ${data3.keys}');
              if (data3['data'] != null) {
                print('Products in category count: ${(data3['data'] as List).length}');
              }
            } else {
              print('Error: ${response3.body}');
            }
          } catch (e) {
            print('Error in test 3: $e');
          }
        }
      }
    } else {
      print('Error: ${response2.body}');
    }
  } catch (e) {
    print('Error in test 2: $e');
  }
  
  // Test 4: Get filtered products
  try {
    print('\n4. Testing GET /product/filter');
    final response4 = await http.get(
      Uri.parse('$baseUrl/product/filter'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Status: ${response4.statusCode}');
    if (response4.statusCode == 200) {
      final data = json.decode(response4.body);
      print('Response structure: ${data.keys}');
      if (data['data'] != null) {
        print('Filtered products count: ${(data['data'] as List).length}');
      }
    } else {
      print('Error: ${response4.body}');
    }
  } catch (e) {
    print('Error in test 4: $e');
  }
}