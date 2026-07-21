import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.unauthorized = false});
  final String message;
  final bool unauthorized;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? _configuredBaseUrl();

  static String _configuredBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    return Platform.isAndroid
        ? 'http://10.0.2.2:9999/api'
        : 'http://localhost:9999/api';
  }

  final String baseUrl;
  String? token;

  Future<dynamic> get(String path, {Map<String, Object?>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: query?.map((key, value) => MapEntry(key, '$value')),
    );
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token?.isNotEmpty == true) headers['Authorization'] = 'Bearer $token';

    late http.Response response;
    switch (method) {
      case 'POST':
        response =
            await http.post(uri, headers: headers, body: jsonEncode(body));
        break;
      case 'PUT':
        response =
            await http.put(uri, headers: headers, body: jsonEncode(body));
        break;
      default:
        response = await http.get(uri, headers: headers);
        break;
    }

    if (response.body.isEmpty) {
      throw const ApiException('服务器返回了空响应');
    }
    final envelope = jsonDecode(utf8.decode(response.bodyBytes));
    if (envelope is! Map<String, dynamic>) {
      throw const ApiException('服务器响应格式错误');
    }
    final code = envelope['code'] as num?;
    if (response.statusCode == 401 || code == 401) {
      throw ApiException(
        (envelope['message'] as String?) ?? '登录已过期',
        unauthorized: true,
      );
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        code != 200) {
      throw ApiException((envelope['message'] as String?) ?? '请求失败');
    }
    return envelope['data'];
  }
}
