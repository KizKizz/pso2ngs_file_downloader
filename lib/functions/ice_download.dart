import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';
import 'package:path/path.dart' as p;

Future<File> downloadIceFromOfficial(context, String iceName, String pathToSave) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  File downloadedIce = File('');

  if (patchFileList.where((element) => element.split('/').last == iceName).isNotEmpty) {
    String webLinkPath = patchFileList.firstWhere((element) => element.contains(iceName));
    try {
      await dio.download('$patchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
        if (total != -1) {
          Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
          Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
        }
      });
      debugPrint('patch');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on Exception {
      try {
        await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
          if (total != -1) {
            Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
            Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
          }
        });
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
      await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
        if (total != -1) {
          Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
          Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
        }
      });
      debugPrint('master');
      downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
    } on Exception {
      try {
        await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
          if (total != -1) {
            Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
            Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
          }
        });
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
        await dio.download('$patchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
          if (total != -1) {
            Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
            Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
          }
        });
        //debugPrint('patch ${file.statusCode}');
        downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
      } on Exception {
        try {
          await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
            if (total != -1) {
              Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
              Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
            }
          });
          downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
        } on Exception {
          try {
            await dio.download('$masterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
              if (total != -1) {
                Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
                Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
              }
            });
            //debugPrint('master ${file.statusCode}');
            downloadedIce = File(Uri.file('$pathToSave/$webLinkPath').toFilePath());
          } on Exception {
            try {
              await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$pathToSave/$webLinkPath').toFilePath(), onReceiveProgress: (count, total) {
                if (total != -1) {
                  Provider.of<StateProvider>(context, listen: false).downloadFileNameSet(iceName);
                  Provider.of<StateProvider>(context, listen: false).downloadPercentageSet(count / total);
                }
              });
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
  List<String> downloadableKeys = ['Icon', 'Normal Quality', 'High Quality', 'Hash', 'Hash', 'Sounds', 'Linked Inner'];
  downloadDir.createSync(recursive: true);
  if (downloadDir.existsSync()) {
    List<String> nameStrings = [];
    item.infos.forEach((key, value) {
      if (key.toLowerCase().contains('name') && value.isNotEmpty) {
        nameStrings.add(value.replaceAll(RegExp(charToReplace), '_').trim());
      }
    });
    if (nameStrings.isEmpty) {
      nameStrings.add(item.infos.values.firstWhere(
        (element) => element.isNotEmpty,
        orElse: () => 'Unknown',
      ));
    }
    String dlSavePath = Uri.file('${downloadDir.path}/${p.basenameWithoutExtension(item.csvFileName)}/${nameStrings.join(' - ')}').toFilePath();
    Directory subDir = await Directory(dlSavePath).create(recursive: true);

    // itemDownloadingDialog(context, subDir);
    for (var entry in item.infos.entries) {
      if (downloadableKeys.where((element) => entry.key.toString().toLowerCase().contains(element.toLowerCase())).isNotEmpty && entry.value.isNotEmpty) {
        if (subDir.existsSync()) {
          File downloadedFile = await downloadIceFromOfficial(context, entry.value, subDir.path);
          if (downloadedFile.existsSync() && extractIceFilesAfterDownload) {
            await Process.run('$zamboniExePath -outdir "${downloadedFile.parent.path}"', [downloadedFile.path]);
          }
        }
      }
    }
    if (dlSavePath.isNotEmpty) {
      List<String> infoList = item.infos.entries.map((e) => '${e.key}: ${e.value}').toList();
      File fileInfo = File(Uri.file('$dlSavePath/files_info.txt').toFilePath());
      await fileInfo.create(recursive: true);
      fileInfo.writeAsStringSync(infoList.join('\n'));
      Provider.of<StateProvider>(context, listen: false).downloadFileNameSet('Finished!');
      if (downloadedItemList.length == 1) {
        downloadedItemList.add(const Divider(
          thickness: 1,
          indent: 5,
          endIndent: 5,
          height: 0,
        ));
      }
      downloadedItemList.insert(2, ListTile(title: Text(nameStrings.join(' - ')), dense: true));
    }
  }
}
