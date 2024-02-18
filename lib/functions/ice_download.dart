import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

Future<File> downloadIceFromOfficial(String iceName, String pathToSave) async {
  if (!Directory(tempDirPath).existsSync()) {
    await Directory(tempDirPath).create(recursive: true);
  } else {
    await Directory(tempDirPath).delete(recursive: true);
  }

  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  File downloadedIce = File('');

  if (patchFileList.where((element) => element.contains(iceName)).isNotEmpty) {
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
  } else if (patchFileList.where((element) => element.contains(iceName)).isNotEmpty) {
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
  } 
  // else {
  //   try {

  //     await dio.download('$patchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
  //     //debugPrint('patch ${file.statusCode}');
  //     downloadedIceList.add(path);
  //   } on DioException {
  //     try {
  //       await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
  //       downloadedIceList.add(path);
  //     } on DioException {
  //       try {
  //         await dio.download('$masterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
  //         //debugPrint('master ${file.statusCode}');
  //         downloadedIceList.add(path);
  //       } on DioException {
  //         try {
  //           await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
  //           downloadedIceList.add(path);
  //         } catch (e) {
  //           debugPrint(e.toString());
  //         }
  //       }
  //     }
  //   }
  // }

  dio.close();
  return downloadedIce;
}
