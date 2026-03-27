import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/project.dart';

class ApiService {
  static const String _url =
      'https://script.google.com/macros/s/AKfycby6dpm8hfPDT4iqOrd6351-0fJRzJbm1Py-krljbcBSboFu-N0aWuDCBiIjKdV91JZH/exec';

  static Future<List<Project>> fetchProjects() async {
    final response = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);

    List<dynamic> raw;
    if (decoded is List) {
      raw = decoded;
    } else if (decoded is Map) {
      if (decoded['data'] is List) {
        raw = decoded['data'] as List;
      } else if (decoded['records'] is List) {
        raw = decoded['records'] as List;
      } else if (decoded['result'] is List) {
        raw = decoded['result'] as List;
      } else {
        raw = [decoded];
      }
    } else {
      throw Exception('Unexpected response format');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(Project.fromJson)
        .where((p) => p.fullName.isNotEmpty || p.projectTitle.isNotEmpty)
        .toList();
  }
}
