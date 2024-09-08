import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

// import 'package:package_info_plus/package_info_plus.dart';

Future<void> sendError(Object error, String identifier) async {
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var client = http.Client();
  await client.post(
      Uri.parse(
          'https://homiletics-directus.cloud.plodamouse.com//items/app_error'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone_os': Platform.operatingSystem,
        'error': "$identifier - ${error.toString()}"
      }));
}
