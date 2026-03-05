import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final GetStorage _storage = GetStorage();
  final http.Client _client = http.Client();

  Map<String, String> get _headers {
    final token = _storage.read('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String url, {dynamic body}) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String url, {dynamic body}) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String url) async {
    try {
      final response = await _client.delete(Uri.parse(url), headers: _headers);
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(String url, {dynamic body}) async {
    try {
      final response = await _client.patch(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> multipartRequest(
    String url, {
    required String method,
    Map<String, String>? fields,
    String? fileKey,
    String? filePath,
  }) async {
    try {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest(method, uri);

      final token = _storage.read('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (fileKey != null && filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            fileKey,
            bytes,
            filename: filePath.split(Platform.isWindows ? '\\' : '/').last,
          );
          request.files.add(multipartFile);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> dioMultipartRequest(
    String url, {
    required String method,
    Map<String, dynamic>? fields,
    String? fileKey,
    String? filePath,
  }) async {
    try {
      final dioClient = dio.Dio();
      final token = _storage.read('token');

      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final formDataMap = <String, dynamic>{};
      if (fields != null) {
        formDataMap.addAll(fields);
      }

      if (fileKey != null && filePath != null) {
        formDataMap[fileKey] = await dio.MultipartFile.fromFile(
          filePath,
          filename: filePath.split(Platform.isWindows ? '\\' : '/').last,
        );
      }

      final formData = dio.FormData.fromMap(formDataMap);

      final response = await dioClient.request(
        url,
        data: formData,
        options: dio.Options(
          method: method,
          headers: headers,
          validateStatus: (status) => true,
        ),
      );

      final httpResponse = http.Response(
        jsonEncode(response.data),
        response.statusCode ?? 500,
        headers: response.headers.map.map((k, v) => MapEntry(k, v.join(','))),
      );

      return _processResponse(httpResponse);
    } catch (e) {
      if (e is dio.DioException) {
        throw ApiException(e.message ?? 'Network error');
      }
      throw _handleError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        decoded['statusCode'] = response.statusCode;
      }
      return decoded;
    } else {
      String errorMessage = 'Something went wrong';
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? body['error'] ?? errorMessage;
      } catch (_) {}

      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) return error;
    return ApiException(error.toString());
  }
}
