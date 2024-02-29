import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/pages/home_page.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';

Future<File> downloadIceFromOfficial(context, String iceName, String pathToSave) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  File downloadedIce = File('');

  if (patchFileList.where((element) => element.split('/').last == iceName).isNotEmpty) {
    String webLinkPath = patchFileList.firstWhere((element) => element.contains(iceName));
    try {
      await dio.download(
        '$patchURL$webLinkPath.pat',
        Uri.file('$pathToSave/$webLinkPath').toFilePath(),
        onReceiveProgress: (count, total) {
          if (total != -1) {
            progressBarController.
            //Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total * 100);
          }
        },
      );
      debugPrint('patch');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on Exception {
      try {
        await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } catch (e) {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  } else if (patchFileList.where((element) => element.split('/').last == iceName).isNotEmpty) {
    String webLinkPath = patchFileList.firstWhere((element) => element.contains(iceName));
    try {
      await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
      debugPrint('master');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on Exception {
      try {
        await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } catch (e) {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  } else {
    String webLinkPath = '';
    if (iceName.split('\\').length > 1) {
      webLinkPath = 'data/win32reboot/${iceName.replaceAll('\\', '/')}';
    } else {
      webLinkPath = 'data/win32/$iceName';
    }
    if (webLinkPath.isNotEmpty) {
      try {
        await dio.download('$patchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
        //debugPrint('patch ${file.statusCode}');
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } on Exception {
        try {
          await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
          downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
        } on Exception {
          try {
            await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
            //debugPrint('master ${file.statusCode}');
            downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
          } on Exception {
            try {
              await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath());
              downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
            } catch (e) {
              debugPrint(e.toString());
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  dio.close();
  return downloadedIce;
}

Future<void> filesDownload(context, Item item) async {
  List<String> downloadableKeys = ['Icon', 'Normal Quality', 'High Quality', 'Ice Hash', 'Hash', 'Sounds', 'Linked Inner'];
  await downloadDir.create(recursive: true);
  if (downloadDir.existsSync()) {
    for (var entry in item.infos.entries) {
      if (downloadableKeys.where((element) => entry.key.toString().toLowerCase().contains(element.toLowerCase())).isNotEmpty) {
        List<String> nameStrings = [];
        item.infos.forEach((key, value) {
          if (key.toLowerCase().contains('name') && value.isNotEmpty) {
            nameStrings.add(value);
          }
        });
        if (nameStrings.isEmpty) {
          nameStrings.add(item.infos.values.firstWhere(
            (element) => element.isNotEmpty,
            orElse: () => 'Unknown',
          ));
        }
        String dlSavePath =
            entry.value.split('\\').length < 2 ? Uri.file('${downloadDir.path}/${nameStrings.join(' - ')}/win32reboot').toFilePath() : Uri.file('${downloadDir.path}/win32').toFilePath();
        Directory subDir = await Directory(dlSavePath).create(recursive: true);
        if (subDir.existsSync()) {
          downloadIceFromOfficial(context, entry.value, subDir.path);
        }
      }
    }
  }
}
