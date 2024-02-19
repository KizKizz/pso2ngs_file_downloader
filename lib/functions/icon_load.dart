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

Future<Uint8List> getIconData(File iconIceFile) async {
  Directory extractedIceDir = await extractIce(iconIceFile, iconIceFile.parent.path);
  if (extractedIceDir.existsSync()) {
    File ddsItemIcon = extractedIceDir.listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
    if (ddsItemIcon.path.isNotEmpty && ddsItemIcon.existsSync()) {
      File newItemIcon = File(Uri.file('${p.dirname(ddsItemIcon.path)}/${p.basenameWithoutExtension(ddsItemIcon.path)}.png').toFilePath());
      await Process.run(ddsToPngExePath, [ddsItemIcon.path, newItemIcon.path, '-ddstopng']);
      if (newItemIcon.existsSync()) {
        return await newItemIcon.readAsBytes();
      }
    }
  }
  return Uint8List(0);
}

Future<void> setIconImageData() async {
  for (var item in items) {
    if (item.infos.entries.where((element) => element.key == 'Icon').isNotEmpty && item.infos.entries.firstWhere((element) => element.key == 'Icon').value.isNotEmpty) {
      String iconIceName = item.infos.entries.firstWhere((element) => element.key == 'Icon').value;
      File downloadedImageIce = await downloadIceFromOfficial(iconIceName, tempDir.path);
      if (downloadedImageIce.existsSync()) {
        final iconImageValue = await getIconData(downloadedImageIce);
        item.iconImageData = String.fromCharCodes(iconImageValue);
      }
    }
  }

  itemDataSave();

  tempDir.deleteSync(recursive: true);
}

Future<void> setIconImage(Item item) async {
  await tempDir.create(recursive: true);
  if (item.infos.entries.where((element) => element.key == 'Icon').isNotEmpty && item.infos.entries.firstWhere((element) => element.key == 'Icon').value.isNotEmpty) {
    String iconIceName = item.infos.entries.firstWhere((element) => element.key == 'Icon').value;
    if (iconIceName.isNotEmpty) {
      File downloadedImageIce = await downloadIceFromOfficial(iconIceName, tempDir.path);
      if (downloadedImageIce.existsSync()) {
        final iconImageValue = await getIconData(downloadedImageIce);
        item.iconImageData = String.fromCharCodes(iconImageValue);
      }
    }
  }

  itemDataSave();
  tempDir.deleteSync(recursive: true);
}

Uint8List iconImageConvert(String uint8String) {
  List<int> list = uint8String.codeUnits;
  return Uint8List.fromList(list);
}
