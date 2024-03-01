//App version Check
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';

List<String> currentVersionValues = appVersion.split('.');
Future<void> checkForUpdates(context) async {
  final jsonVal = await loadJsonFromGithub();
  if (jsonVal.entries.first.key != 'null') {
    int curMajor = int.parse(currentVersionValues[0]);
    int curMinor = int.parse(currentVersionValues[1]);
    int curPatch = int.parse(currentVersionValues[2]);

    String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
    List<String> newVersionValues = newVersionValue.split('.');
    int newMajor = int.parse(newVersionValues[0]);
    int newMinor = int.parse(newVersionValues[1]);
    int newPatch = int.parse(newVersionValues[2]);

    if (newPatch > curPatch && newMinor >= curMinor && newMajor >= curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    } else if (newPatch <= curPatch && newMinor > curMinor && newMajor >= curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    } else if (newPatch <= curPatch && newMinor <= curMinor && newMajor > curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    }
  }
}

Future<Map<String, dynamic>> loadJsonFromGithub() async {
  String jsonResponse = '{"null": "null"}';
  try {
    Dio dio = Dio();
    final response = await dio.get('https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/app_version.json');
    if (response.statusCode == 200) {
      jsonResponse = response.data;
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }
  return jsonDecode(jsonResponse);
}
