import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
// import 'package:package_info_plus/package_info_plus.dart';

Future<void> sendError(Object error, String identifier) async {
  // PackageInfo packageInfo = await PackageInfo.fromPlatform();
  var client = http.Client();
  http.Response response = await client.post(
      Uri.parse('https://homiletics.cloud.zipidy.org/items/app_errors'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'phone_os': Platform.operatingSystem,
        'message': "$identifier - ${error.toString()}"
      }));
}
