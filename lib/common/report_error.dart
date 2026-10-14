import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:homiletics/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart' show DatabaseException;

/// Maximum number of characters of error text sent to the server.
const int _kMaxErrorMessageLength = 500;

/// Patterns for the parts of a sqflite [DatabaseException] message that can
/// contain user-entered text:
/// - the `sql '...' args [...]` tail sqflite appends in `toString()`;
/// - Android's `, while compiling: <sql>` suffix on SQLiteException messages.
final List<RegExp> _sqlDetailPatterns = [
  RegExp(r"\s*sql\s+'.*$", dotAll: true),
  RegExp(r'\s*args\s+\[.*$', dotAll: true),
  RegExp(r',?\s*while compiling:.*$', dotAll: true),
];

/// Builds the error text sent to the server, with user content stripped and
/// the length capped.
@visibleForTesting
String describeErrorForReport(Object error) {
  String message;
  if (error is DatabaseException) {
    // Never send the SQL or its bound arguments — they hold user content.
    message = error.toString();
    for (final pattern in _sqlDetailPatterns) {
      message = message.replaceAll(pattern, '');
    }
    message = 'DatabaseException(code ${error.getResultCode()}): $message';
  } else {
    message = error.toString();
  }
  if (message.length > _kMaxErrorMessageLength) {
    message = '${message.substring(0, _kMaxErrorMessageLength)}…';
  }
  return message;
}

/// Reports [error] to the Homiletics API.
///
/// Never throws and times out after 10 seconds, so it is safe to call without
/// awaiting.
Future<void> sendError(Object error, String identifier) async {
  try {
    final response = await http
        .post(
          Uri.parse('$kHomileticsApiBase/errors'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'phone_os': Platform.operatingSystem,
            'error': '$identifier - ${describeErrorForReport(error)}',
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('sendError: server responded ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('sendError: failed to report "$identifier": $e');
  }
}
