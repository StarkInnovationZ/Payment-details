import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/project.dart';

class ApiService {
  // Replace with your actual Google Apps Script Web App URL
  static const String _url = 'https://script.google.com/macros/s/AKfycby6dpm8hfPDT4iqOrd6351-0fJRzJbm1Py-krljbcBSboFu-N0aWuDCBiIjKdV91JZH/exec';

  // Timeout duration for API calls
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetches projects from Google Apps Script with robust error handling
  /// Handles multiple response formats:
  /// 1. Direct array: [{ ... }, { ... }]
  /// 2. Wrapped object: { "data": [...] }
  /// 3. Wrapped object: { "result": [...] }
  /// 4. Wrapped object: { "projects": [...] }
  static Future<List<Project>> fetchProjects() async {
    try {
      print('🔄 [API] Fetching projects from: $_url');
      
      final response = await http
          .get(Uri.parse(_url))
          .timeout(_timeout);

      print('📡 [API] Response status: ${response.statusCode}');
      print('📡 [API] Response body length: ${response.body.length} chars');

      if (response.statusCode != 200) {
        throw ApiException(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Parse response body
      final decodedResponse = json.decode(response.body);
      print('📦 [API] Decoded response type: ${decodedResponse.runtimeType}');

      // Extract data array from various possible response formats
      List<dynamic> dataList = _extractDataList(decodedResponse);

      if (dataList.isEmpty) {
        print('⚠️  [API] Warning: Empty data list received');
        return [];
      }

      print('✅ [API] Found ${dataList.length} records');

      // Convert to Project objects
      final projects = dataList.asMap().entries.map((entry) {
        try {
          final json = entry.value;
          if (json is! Map<String, dynamic>) {
            throw ApiException(
              'Invalid project format at index ${entry.key}: expected Map, got ${json.runtimeType}',
            );
          }
          return Project.fromJson(json);
        } catch (e) {
          print('❌ [API] Error parsing project at index ${entry.key}: $e');
          rethrow;
        }
      }).toList();

      print('✅ [API] Successfully parsed ${projects.length} projects');
      return projects;
    } on http.ClientException catch (e) {
      print('❌ [API] Network error: $e');
      throw ApiException(
        'Network error: Unable to connect to server',
        originalError: e,
      );
    } on TimeoutException catch (e) {
      print('❌ [API] Timeout error: $e');
      throw ApiException(
        'Connection timeout: Server took too long to respond',
        originalError: e,
      );
    } on FormatException catch (e) {
      print('❌ [API] JSON format error: $e');
      throw ApiException(
        'Invalid response format: Unable to parse JSON',
        originalError: e,
      );
    } catch (e) {
      print('❌ [API] Unexpected error: $e');
      throw ApiException(
        'Failed to load projects: $e',
        originalError: e,
      );
    }
  }

  /// Extracts data list from various response formats
  static List<dynamic> _extractDataList(dynamic response) {
    // Format 1: Direct array
    if (response is List<dynamic>) {
      print('🔍 [API] Response format: Direct array');
      return response;
    }

    // Format 2-4: Object with data/result/projects key
    if (response is Map<String, dynamic>) {
      // Try common key names in order of likelihood
      const keys = ['data', 'result', 'projects', 'records', 'rows'];
      
      for (final key in keys) {
        if (response.containsKey(key)) {
          final value = response[key];
          if (value is List<dynamic>) {
            print('🔍 [API] Response format: Object with "$key" array');
            return value;
          }
        }
      }

      // If no recognized key found, check if the object itself is the project
      // (unlikely but possible)
      print('🔍 [API] Response format: Single object (will wrap in array)');
      return [response];
    }

    print('❌ [API] Unknown response format: ${response.runtimeType}');
    throw ApiException('Unknown response format: ${response.runtimeType}');
  }

  /// Submits a new project to the Google Apps Script
  static Future<bool> submitProject(Map<String, dynamic> data) async {
    try {
      print('📤 [API] Submitting project...');
      
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(data),
          )
          .timeout(_timeout);

      print('📡 [API] Submit response status: ${response.statusCode}');
      
      final success = response.statusCode == 200 && 
                     (response.body == "Success" || response.body == '"Success"');
      
      if (success) {
        print('✅ [API] Project submitted successfully');
      } else {
        print('❌ [API] Submit failed: ${response.body}');
      }
      
      return success;
    } catch (e) {
      print('❌ [API] Error submitting project: $e');
      throw ApiException(
        'Failed to submit project: $e',
        originalError: e,
      );
    }
  }

  /// Deletes a project from the Google Apps Script
  static Future<bool> deleteProject(String invoiceNo) async {
    try {
      print('🗑️  [API] Deleting project: $invoiceNo');
      
      final response = await http
          .post(
            Uri.parse(_url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'action': 'delete',
              'invoiceNo': invoiceNo,
            }),
          )
          .timeout(_timeout);

      print('📡 [API] Delete response status: ${response.statusCode}');
      
      final success = response.statusCode == 200;
      
      if (success) {
        print('✅ [API] Project deleted successfully');
      } else {
        print('❌ [API] Delete failed: ${response.body}');
      }
      
      return success;
    } catch (e) {
      print('❌ [API] Error deleting project: $e');
      throw ApiException(
        'Failed to delete project: $e',
        originalError: e,
      );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'ApiException: $message\nOriginal error: $originalError';
    }
    return 'ApiException: $message';
  }
}