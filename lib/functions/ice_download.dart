import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

Future<File> downloadIceFromOfficial(String iceName, String pathToSave) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  File downloadedIce = File('');

  if (patchFileList.where((element) => element.split('/').last == iceName).isNotEmpty) {
    String webLinkPath = patchFileList.firstWhere((element) => element.contains(iceName));
    try {
      await dio.download('$patchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
      debugPrint('patch');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on DioException {
      try {
        await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  } else if (patchFileList.where((element) => element.split('/').last == iceName).isNotEmpty) {
    String webLinkPath = patchFileList.firstWhere((element) => element.contains(iceName));
    try {
      await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
      debugPrint('master');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on DioException {
      try {
        await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  } else {
      String webLinkPath = 'data/win32/$iceName';
      if (webLinkPath.isNotEmpty) {
        try {
          await dio.download('$patchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
          //debugPrint('patch ${file.statusCode}');
          downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
        } on DioException {
          try {
            await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
            downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
          } on DioException {
            try {
              await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
              //debugPrint('master ${file.statusCode}');
              downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
            } on DioException {
              try {
                await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
                downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        }
      }
    
  }

  dio.close();
  return downloadedIce;
}
