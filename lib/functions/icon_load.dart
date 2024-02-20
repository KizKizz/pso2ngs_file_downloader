// ignore_for_file: unused_import

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/functions/ice_extract.dart';
import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/global_vars.dart';

String ddsToPngExePath = Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath();

Future<File> getIconData(File iconIceFile, String saveLocation, String enItemName) async {
  Directory extractedIceDir = await extractIce(iconIceFile, iconIceFile.parent.path);
  if (extractedIceDir.existsSync()) {
    File ddsItemIcon = extractedIceDir.listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
    if (ddsItemIcon.path.isNotEmpty && ddsItemIcon.existsSync()) {
      Directory(saveLocation).createSync(recursive: true);
      File newItemIcon = File('');
      if (enItemName.isNotEmpty) {
        newItemIcon = File(Uri.file('$saveLocation/${p.basenameWithoutExtension(enItemName.replaceAll(RegExp(charToReplace), '_').trim())}.png').toFilePath());
      } else {
        newItemIcon = File(Uri.file('$saveLocation/${p.basenameWithoutExtension(ddsItemIcon.path)}.png').toFilePath());
      }
      await Process.run(ddsToPngExePath, [ddsItemIcon.path, newItemIcon.path, '-ddstopng']);
      if (newItemIcon.existsSync()) {
        return newItemIcon;
      }
    }
  }
  return File('');
}

// Future<void> setIconImageData() async {
//   for (var item in items) {
//     if (item.infos.entries.where((element) => element.key == 'Icon').isNotEmpty && item.infos.entries.firstWhere((element) => element.key == 'Icon').value.isNotEmpty) {
//       String iconIceName = item.infos.entries.firstWhere((element) => element.key == 'Icon').value;
//       File downloadedImageIce = await downloadIceFromOfficial(iconIceName, tempDir.path);
//       if (downloadedImageIce.existsSync()) {
//         final enItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('English'), orElse: () => const MapEntry('null', 'null'));
//         String enItemName = '';
//         if (enItemNameEntry.key != 'null') {
//           enItemName = enItemNameEntry.value;
//         }
//         final iconImage = await getIconData(downloadedImageIce, Uri.file('${iconsDir.path}${item.cvsFilePath}/${p.basenameWithoutExtension(item.csvFileName)}').toFilePath(), enItemName);
//         if (iconImage.path.isNotEmpty && iconImage.existsSync()) {
//           item.iconImagePath = iconImage.path.replaceFirst(Uri.file(Directory.current.path).toFilePath(), '');
//         }
//       }
//     }
//   }

//   //itemDataSave();

//   tempDir.deleteSync(recursive: true);
// }

Future<void> setIconImage(Item item) async {
  await tempDir.create(recursive: true);
  final enItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('English'), orElse: () => const MapEntry('null', 'null'));
  String enItemName = '';
  if (enItemNameEntry.key != 'null') {
    enItemName = enItemNameEntry.value;
  }
  String iconImageFilePath =
      Uri.file('${iconsDir.path}${item.csvFilePath}/${p.basenameWithoutExtension(item.csvFileName)}/${enItemName.replaceAll(RegExp(charToReplace), '_').trim()}.png').toFilePath();
  if (File(iconImageFilePath).existsSync()) {
    item.iconImagePath = iconImageFilePath.replaceFirst(Uri.file(Directory.current.path).toFilePath(), '');
  } else {
    if (item.infos.entries.where((element) => element.key == 'Icon').isNotEmpty && item.infos.entries.firstWhere((element) => element.key == 'Icon').value.isNotEmpty) {
      String iconIceName = item.infos.entries.firstWhere((element) => element.key == 'Icon').value;
      if (iconIceName.isNotEmpty) {
        File downloadedImageIce = await downloadIceFromOfficial(iconIceName, tempDir.path);
        if (downloadedImageIce.existsSync()) {
          final iconImage = await getIconData(downloadedImageIce, Uri.file('${iconsDir.path}${item.csvFilePath}/${p.basenameWithoutExtension(item.csvFileName)}').toFilePath(), enItemName);
          if (iconImage.path.isNotEmpty && iconImage.existsSync()) {
            item.iconImagePath = iconImage.path.replaceFirst(Uri.file(Directory.current.path).toFilePath(), '');
          }
        }
      }
    }
    tempDir.deleteSync(recursive: true);
  }

  //itemDataSave();
  
}

Uint8List iconImageConvert(String uint8String) {
  List<int> list = uint8String.codeUnits;
  return Uint8List.fromList(list);
}