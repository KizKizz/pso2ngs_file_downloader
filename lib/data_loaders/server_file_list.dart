// ignore_for_file: unused_import

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:http/http.dart' as http;



Future<(String, String, String, String)> getPatchServerLinks(String managementLink) async {
  final response = await http.get(Uri.parse(managementLink), headers: {'Content-Type': 'text/plain'});
  if (response.statusCode == 200) {
    List<String> managementFileLines = response.body.split('\n');
    return (
      managementFileLines.firstWhere((element) => element.contains('MasterURL=')).split('=').last.trim(),
      managementFileLines.firstWhere((element) => element.contains('PatchURL=')).split('=').last.trim(),
      managementFileLines.firstWhere((element) => element.contains('BackupMasterURL=')).split('=').last.trim(),
      managementFileLines.firstWhere((element) => element.contains('BackupPatchURL=')).split('=').last.trim()
    );
  }
  return ('', '', '', '');
}

Future<List<String>> fetchOfficialPatchFileList() async {
  List<String> patchFileList = [];

  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  try {
    final response = await dio.get('${patchURL}patchlist_region1st.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 1: Success');
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${backupPatchURL}patchlist_region1st.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 1: Success');
    }
  } catch (e) {
    // returnStatus.add('Patch list 1: Failed');
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_classic.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 2: Success');
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${backupPatchURL}patchlist_classic.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 2: Success');
    }
  } catch (e) {
    // returnStatus.add('Patch list 2: Failed');
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_avatar.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 3: Success');
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${backupPatchURL}patchlist_avatar.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      patchFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      // returnStatus.add('Patch list 3: Success');
    }
  } catch (e) {
    // returnStatus.add('Patch list 3: Failed');
    debugPrint(e.toString());
  }

  dio.close();
  return patchFileList;
}

Future<(List<String>, List<String>)> getOfficialFileList(List<String> fileList) async {
  //File(Uri.file('$tempDirPath/fileList.txt').toFilePath()).writeAsStringSync(fileList.join('\n'));
  List<String> returnMasterFiles = [];
  List<String> returnPatchFiles = [];

  for (var line in fileList) {
    if (line.isNotEmpty) {
      if (line.trim().substring(line.length - 2, line.length - 1) == 'm') {
        returnMasterFiles.add(line.split('.pat').first);
      } else if (line.trim().substring(line.length - 2, line.length - 1) == 'p') {
        returnPatchFiles.add(line.split('.pat').first);
      }
    }
  }

  return (returnMasterFiles, returnPatchFiles);
}
