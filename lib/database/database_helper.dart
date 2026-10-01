import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static String get url {
    try {
      return dotenv.maybeGet('URI') ?? 'api.php?method=';
    } catch (_) {
      return 'api.php?method=';
    }
  }

  static Map<String, String> headersFor(String query) {
    String authorization;
    try {
      authorization = dotenv.maybeGet('AUTHORIZATION') ?? '';
    } catch (_) {
      authorization = '';
    }
    return {'Authorization': authorization, 'query': _headerSafeSql(query)};
  }

  static String _headerSafeSql(String query) {
    return query.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String sqlValue(Object? value) {
    if (value == null) return 'NULL';
    if (value is bool) return value ? '1' : '0';
    if (value is num) return value.toString();
    final escaped = value
        .toString()
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "''");
    return "'$escaped'";
  }

  static Future<List<Map<String, dynamic>>> query(String query) async {
    final response = await readTable(query);
    return _decodeRows(response);
  }

  static Future<dynamic> execute(String endpoint, String query) async {
    final response = await http.get(
      Uri.parse('$url$endpoint'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return _decodeBody(response.body);
  }

  static Future<http.Response> readTable(String query) async {
    final response = await http.get(
      Uri.parse('${url}get'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return response;
  }

  static Future<dynamic> insertTableRow(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final columns = data.keys.toList();
    final values = data.values.map(sqlValue).toList();
    final query =
        'INSERT INTO $tableName (${columns.join(', ')}) VALUES (${values.join(', ')})';
    final response = await http.get(
      Uri.parse('${url}insert'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return _decodeBody(response.body);
  }

  static Future<http.Response> updateTableRow(String query) async {
    final response = await http.get(
      Uri.parse('${url}update'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return response;
  }

  static Future<http.Response> deleteTableRow(String query) async {
    final response = await http.get(
      Uri.parse('${url}delete'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return response;
  }

  static Future<http.Response> createTable(
    String tableName,
    List<String> columns,
  ) async {
    final query =
        'CREATE TABLE IF NOT EXISTS $tableName (${columns.join(', ')})';
    final response = await http.get(
      Uri.parse('${url}create_table'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return response;
  }

  static Future<http.Response> dropTable(String tableName) async {
    final query = 'DROP TABLE IF EXISTS $tableName';
    final response = await http.get(
      Uri.parse('${url}drop_table'),
      headers: headersFor(query),
    );
    _throwForBadStatus(response);
    return response;
  }

  static Future<dynamic> uploadFile(
    String fileName,
    userId,
    List<int> userFile,
    String fileType,
  ) async {
    final response = await http.post(
      Uri.parse('${url}upload_file'),
      headers: headersFor(''),
      body: json.encode(<String, dynamic>{
        'file_name': fileName,
        'user_id': userId,
        'file_type': fileType,
        'user_file': base64.encode(userFile),
      }),
    );
    _throwForBadStatus(response);
    return _decodeBody(response.body);
  }

  static Future<dynamic> deleteFile(String file, id) async {
    final fileName = file.split('/').last;
    final response = await http.post(
      Uri.parse('${url}delete_file'),
      headers: headersFor(''),
      body: json.encode(<String, Object>{
        'path': 'uploads/users/$id/$fileName',
      }),
    );
    _throwForBadStatus(response);
    return _decodeBody(response.body);
  }

  static dynamic _decodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    return jsonDecode(trimmed);
  }

  static List<Map<String, dynamic>> _decodeRows(http.Response response) {
    final decoded = _decodeBody(response.body);
    final rows = _extractRows(decoded);
    return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }

  static List<dynamic> _extractRows(dynamic decoded) {
    if (decoded == null) return [];
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final key in ['data', 'rows', 'result', 'records']) {
        final value = decoded[key];
        if (value is List) return value;
        if (value is Map) return _extractRows(value);
      }
      if (decoded.containsKey('id') || decoded.containsKey('order_id')) {
        return [decoded];
      }
    }
    return [];
  }

  static void _throwForBadStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception(
      'API request failed: ${response.statusCode} ${response.body}',
    );
  }
}
