import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'network_info.dart';

class HttpClient {
  final SharedPreferences sharedPreferences;
  final NetworkInfo? networkInfo;

  HttpClient(this.sharedPreferences, {this.networkInfo});
  static var client = http.Client();

  /// فحص الاتصال بالإنترنت
  Future<void> _checkConnection() async {
    if (networkInfo != null) {
      final isConnected = await networkInfo!.isConnected;
      if (!isConnected) {
        throw const NetworkException(
            'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى.');
      }
    }
  }

  /// طباعة تفاصيل الطلب
  void _logRequest(String method, String url, Map<String, String> headers,
      {Map<String, dynamic>? body}) {
    developer.log('🚀 HTTP REQUEST', name: 'HttpClient');
    developer.log('Method: $method', name: 'HttpClient');
    developer.log('URL: $url', name: 'HttpClient');
    developer.log('Headers: ${jsonEncode(headers)}', name: 'HttpClient');
    if (body != null) {
      developer.log('Body: ${jsonEncode(body)}', name: 'HttpClient');
    }
    developer.log('─' * 50, name: 'HttpClient');
  }

  /// طباعة تفاصيل الاستجابة
  void _logResponse(http.Response response) {
    developer.log('📥 HTTP RESPONSE', name: 'HttpClient');
    developer.log('Status Code: ${response.statusCode}', name: 'HttpClient');
    developer.log('Headers: ${jsonEncode(response.headers)}',
        name: 'HttpClient');
    developer.log('Body: ${response.body}', name: 'HttpClient');
    developer.log('─' * 50, name: 'HttpClient');
  }

  /// الحصول على الرؤوس الأساسية
  Map<String, String> get _headers {
    final token = sharedPreferences.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json; charset=utf-8',
      'Accept-Charset': 'utf-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// طلب GET
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    await _checkConnection();
    try {
      var url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      if (queryParameters != null) {
        // Filter out null values and encode all values
        final validQueryParameters = queryParameters.entries
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key, entry.value.toString()))
            .toList();

        url =
            url.replace(queryParameters: Map.fromEntries(validQueryParameters));
      }

      // Log request
      _logRequest('GET', url.toString(), _headers);

      final response = await http.get(url, headers: _headers);

      // Log response
      _logResponse(response);

      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ GET ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('GET request failed: ${e.toString()}');
    }
  }

  /// طلب POST
  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      // Log request
      _logRequest('POST', url.toString(), _headers, body: body);

      final response = await client.post(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST request failed: ${e.toString()}');
    }
  }

  /// طلب PUT
  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      // Log request
      _logRequest('PUT', url.toString(), _headers, body: body);

      final response = await http.put(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );

      // Log response
      _logResponse(response);

      return _handleResponse(response);
    } catch (e) {
      throw ServerException('PUT request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (مع إرجاع بيانات)
  Future<Map<String, dynamic>> delete(String endpoint) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      // Log request
      _logRequest('DELETE', url.toString(), _headers);

      final response = await http.delete(url, headers: _headers);

      // Log response
      _logResponse(response);

      return _handleResponse(response);
    } catch (e) {
      throw ServerException('DELETE request failed: ${e.toString()}');
    }
  }

  /// طلب DELETE (للحالات التي لا تحتاج رد)
  Future<void> deleteVoid(String endpoint) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');

      // Log request
      _logRequest('DELETE', url.toString(), _headers);

      final response = await http.delete(url, headers: _headers);

      // Log response
      _logResponse(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        throw ServerException(
            'Delete failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('DELETE request failed: ${e.toString()}');
    }
  }

  /// معالجة الاستجابة
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {}; // استجابة فارغة صحيحة
      }

      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ServerException('Invalid JSON response: ${e.toString()}');
      }
    } else if (statusCode == 401) {
      // إزالة التوكن المنتهي الصلاحية
      sharedPreferences.remove(AppConstants.tokenKey);
      throw const UnauthorizedException('Token expired or invalid');
    } else if (statusCode >= 400 && statusCode < 500) {
      try {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Client error occurred'};

        // استخراج الرسالة من البنية المختلفة للاستجابة
        String errorMessage = 'Client error';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ??
              errorBody['error']?['message'] ??
              errorBody['error']?['details'] ??
              errorBody['details'] ??
              'Client error occurred';
        }
        throw ClientException(errorMessage);
      } catch (e) {
        throw const ClientException('خطأ في البيانات المرسلة');
      }
    } else if (statusCode >= 500) {
      try {
        final errorBody = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Server error occurred'};

        String errorMessage = 'Server error';
        if (errorBody is Map<String, dynamic>) {
          errorMessage = errorBody['message'] ??
              errorBody['error']?['message'] ??
              errorBody['error'] ??
              'Server error occurred';
              
          // إضافة تفاصيل إضافية للتشخيص
          if (statusCode == 500) {
            developer.log('🔥 SERVER ERROR 500 DETAILS:', name: 'HttpClient');
            developer.log('Error Body: ${jsonEncode(errorBody)}', name: 'HttpClient');
          }
        }
        throw ServerException(errorMessage);
      } catch (e) {
        throw const ServerException('خطأ في الخادم');
      }
    }

    throw ServerException('Unexpected status code: $statusCode');
  }

  /// طلب POST مع ملفات (multipart/form-data)
  Future<Map<String, dynamic>> postWithFiles(String endpoint,
      {Map<String, dynamic>? fields, List<File>? files, String fileFieldName = 'images'}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // إنشاء multipart request
      final request = http.MultipartRequest('POST', url);
      
      // إضافة headers
      final token = sharedPreferences.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      
      // إضافة الحقول النصية
      if (fields != null) {
        fields.forEach((key, value) {
          if (value is List) {
            // تحويل القوائم إلى JSON strings
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });
      }
      
      // إضافة الملفات
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          
          // التحقق من وجود الملف وحجمه
          if (!await file.exists()) {
            throw ServerException('الملف غير موجود: ${file.path}');
          }
          
          final fileSize = await file.length();
          if (fileSize == 0) {
            throw ServerException('الملف فارغ: ${file.path}');
          }
          
          // حد أقصى 10 ميجابايت للملف الواحد
          if (fileSize > 10 * 1024 * 1024) {
            throw ServerException('حجم الملف كبير جداً (أكثر من 10 ميجابايت): ${file.path}');
          }
          
          // تحديد نوع الملف بناءً على الامتداد
          String? contentType;
          final extension = file.path.toLowerCase().split('.').last;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            case 'gif':
              contentType = 'image/gif';
              break;
            case 'webp':
              contentType = 'image/webp';
              break;
            default:
              contentType = 'image/jpeg'; // افتراضي
          }
          
          final multipartFile = await http.MultipartFile.fromPath(
            fileFieldName, // 'images' - multer.array('images')
            file.path,
            filename: 'image_$i.$extension',
            contentType: MediaType.parse(contentType),
          );
          request.files.add(multipartFile);
          
          developer.log('Added file: ${file.path}, size: ${fileSize} bytes, type: $contentType', name: 'HttpClient');
        }
      }
      
      // Log request
      developer.log('🚀 HTTP MULTIPART REQUEST', name: 'HttpClient');
      developer.log('Method: POST', name: 'HttpClient');
      developer.log('URL: $url', name: 'HttpClient');
      developer.log('Headers: ${request.headers}', name: 'HttpClient');
      developer.log('Fields: ${request.fields}', name: 'HttpClient');
      developer.log('Files: ${request.files.length} files', name: 'HttpClient');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        developer.log('File $i: field=${file.field}, filename=${file.filename}, length=${file.length}', name: 'HttpClient');
      }
      developer.log('─' * 50, name: 'HttpClient');
      
      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST WITH FILES ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST with files request failed: ${e.toString()}');
    }
  }

  /// طلب POST مع ملفات (طريقة بديلة)
  Future<Map<String, dynamic>> postWithFilesAlternative(String endpoint,
      {Map<String, dynamic>? fields, List<File>? files}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // إنشاء multipart request
      final request = http.MultipartRequest('POST', url);
      
      // إضافة headers
      final token = sharedPreferences.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      
      // إضافة الحقول النصية
      if (fields != null) {
        fields.forEach((key, value) {
          if (value is List) {
            // تحويل القوائم إلى JSON strings
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });
      }
      
      // إضافة الملفات بطرق مختلفة للتجربة
      if (files != null && files.isNotEmpty) {
        // الطريقة الأولى: images[0], images[1], etc.
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final multipartFile = await http.MultipartFile.fromPath(
            'images[$i]', // images[0], images[1], etc.
            file.path,
            filename: 'image_$i.jpg',
          );
          request.files.add(multipartFile);
        }
      }
      
      // Log request
      developer.log('🚀 HTTP MULTIPART REQUEST (ALTERNATIVE)', name: 'HttpClient');
      developer.log('Method: POST', name: 'HttpClient');
      developer.log('URL: $url', name: 'HttpClient');
      developer.log('Headers: ${request.headers}', name: 'HttpClient');
      developer.log('Fields: ${request.fields}', name: 'HttpClient');
      developer.log('Files: ${request.files.length} files', name: 'HttpClient');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        developer.log('File $i: field=${file.field}, filename=${file.filename}', name: 'HttpClient');
      }
      developer.log('─' * 50, name: 'HttpClient');
      
      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST WITH FILES ALTERNATIVE ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST with files alternative request failed: ${e.toString()}');
    }
  }

  /// طلب POST مع صور كـ base64 (طريقة ثالثة)
  Future<Map<String, dynamic>> postWithBase64Images(String endpoint,
      {Map<String, dynamic>? fields, List<File>? files}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // تحويل الصور إلى base64
      final List<String> base64Images = [];
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          final Uint8List bytes = await file.readAsBytes();
          final String base64String = base64Encode(bytes);
          base64Images.add('data:image/jpeg;base64,$base64String');
        }
      }
      
      // إضافة الصور كـ base64 إلى الحقول
      final Map<String, dynamic> bodyData = Map<String, dynamic>.from(fields ?? {});
      if (base64Images.isNotEmpty) {
        bodyData['images'] = base64Images;
      }
      
      // Log request
      developer.log('🚀 HTTP BASE64 REQUEST', name: 'HttpClient');
      developer.log('Method: POST', name: 'HttpClient');
      developer.log('URL: $url', name: 'HttpClient');
      developer.log('Headers: $_headers', name: 'HttpClient');
      developer.log('Body keys: ${bodyData.keys.toList()}', name: 'HttpClient');
      developer.log('Images count: ${base64Images.length}', name: 'HttpClient');
      developer.log('─' * 50, name: 'HttpClient');

      final response = await client.post(
        url,
        headers: _headers,
        body: jsonEncode(bodyData),
      );

      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST BASE64 ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST base64 request failed: ${e.toString()}');
    }
  }

  /// طلب POST مع ملفات منفصلة (طريقة رابعة)
  Future<Map<String, dynamic>> postWithSeparateFiles(String endpoint,
      {Map<String, dynamic>? fields, List<File>? files}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // إنشاء multipart request
      final request = http.MultipartRequest('POST', url);
      
      // إضافة headers
      final token = sharedPreferences.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      
      // إضافة الحقول النصية
      if (fields != null) {
        fields.forEach((key, value) {
          if (value is List) {
            // تحويل القوائم إلى JSON strings
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });
      }
      
      // إضافة الملفات بأسماء منفصلة
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final multipartFile = await http.MultipartFile.fromPath(
            'image$i', // image0, image1, image2, etc.
            file.path,
            filename: 'image_$i.jpg',
          );
          request.files.add(multipartFile);
        }
      }
      
      // Log request
      developer.log('🚀 HTTP SEPARATE FILES REQUEST', name: 'HttpClient');
      developer.log('Method: POST', name: 'HttpClient');
      developer.log('URL: $url', name: 'HttpClient');
      developer.log('Headers: ${request.headers}', name: 'HttpClient');
      developer.log('Fields: ${request.fields}', name: 'HttpClient');
      developer.log('Files: ${request.files.length} files', name: 'HttpClient');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        developer.log('File $i: field=${file.field}, filename=${file.filename}', name: 'HttpClient');
      }
      developer.log('─' * 50, name: 'HttpClient');
      
      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ POST SEPARATE FILES ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('POST separate files request failed: ${e.toString()}');
    }
  }

  /// طلب PUT مع ملفات (لتعديل المنتجات مع صور)
  Future<Map<String, dynamic>> putWithFiles(String endpoint,
      {Map<String, dynamic>? fields, List<File>? files, String fileFieldName = 'images'}) async {
    await _checkConnection();
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      
      // إنشاء multipart request مع PUT method
      final request = http.MultipartRequest('PUT', url);
      
      // إضافة headers
      final token = sharedPreferences.getString(AppConstants.tokenKey);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      
      // إضافة الحقول النصية
      if (fields != null) {
        fields.forEach((key, value) {
          if (value is List) {
            // إرسال كل عنصر في القائمة كحقل منفصل
            for (int i = 0; i < value.length; i++) {
              request.fields['${key}[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        });
      }
      
      // إضافة الملفات
      if (files != null && files.isNotEmpty) {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          
          // التحقق من وجود الملف وحجمه
          if (!await file.exists()) {
            throw ServerException('الملف غير موجود: ${file.path}');
          }
          
          final fileSize = await file.length();
          if (fileSize == 0) {
            throw ServerException('الملف فارغ: ${file.path}');
          }
          
          // حد أقصى 10 ميجابايت للملف الواحد
          if (fileSize > 10 * 1024 * 1024) {
            throw ServerException('حجم الملف كبير جداً (أكثر من 10 ميجابايت): ${file.path}');
          }
          
          // تحديد نوع الملف بناءً على الامتداد
          String? contentType;
          final extension = file.path.toLowerCase().split('.').last;
          switch (extension) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            case 'gif':
              contentType = 'image/gif';
              break;
            case 'webp':
              contentType = 'image/webp';
              break;
            default:
              contentType = 'application/octet-stream';
          }
          
          final multipartFile = await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            filename: '${DateTime.now().millisecondsSinceEpoch}_$i.$extension',
            contentType: MediaType.parse(contentType),
          );
          
          request.files.add(multipartFile);
        }
      }
      
      // Log request
      developer.log('🚀 HTTP PUT WITH FILES REQUEST', name: 'HttpClient');
      developer.log('Method: PUT', name: 'HttpClient');
      developer.log('URL: $url', name: 'HttpClient');
      developer.log('Headers: ${request.headers}', name: 'HttpClient');
      developer.log('Fields: ${request.fields}', name: 'HttpClient');
      developer.log('Files: ${request.files.length} files', name: 'HttpClient');
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        developer.log('File $i: field=${file.field}, filename=${file.filename}', name: 'HttpClient');
      }
      developer.log('─' * 50, name: 'HttpClient');
      
      // إرسال الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Log response
      _logResponse(response);
      return _handleResponse(response);
    } catch (e) {
      developer.log('❌ PUT WITH FILES ERROR: ${e.toString()}', name: 'HttpClient');
      throw ServerException('PUT with files request failed: ${e.toString()}');
    }
  }
}
