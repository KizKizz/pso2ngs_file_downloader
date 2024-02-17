import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<(String, String, String, String)> getPatchServerLinks(String managementLink) async {
  Dio dio = Dio();
  // dio.options.headers = {
  //   "Access-Control-Allow-Credentials": "true",
  //   "Access-Control-Allow-Headers": "*",
  //   "Access-Control-Allow-Methods": "*",
  //   "Access-Control-Allow-Origin": "*"
  // };
  try {
    final response = await dio.get(Uri.parse(managementLink).toString());
    if (response.statusCode == 200) {
      List<String> managementFileLines = response.data.trim().split('\n');
      dio.close();
      return (
        managementFileLines.firstWhere((element) => element.contains('MasterURL=')).split('=').last.trim(),
        managementFileLines.firstWhere((element) => element.contains('PatchURL=')).split('=').last.trim(),
        managementFileLines.firstWhere((element) => element.contains('BackupMasterURL=')).split('=').last.trim(),
        managementFileLines.firstWhere((element) => element.contains('BackupPatchURL=')).split('=').last.trim()
      );
    } else {
      dio.close();
      return ('', '', '', '');
    }
  } on Error catch (e) {
    dio.close();
    debugPrint('Timeout Error: $e');
    return ('', '', '', '');
  }
}
