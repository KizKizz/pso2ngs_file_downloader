import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

Future<List<Item>> populateItemList() async {
  List<Item> itemList = [];
  final csvFiles = refSheetsDir.listSync(recursive: true).whereType<File>().where((file) => p.extension(file.path) == '.csv');
  for (var file in csvFiles) {
    List<String> headers = [];
    List<String> infos = [];
    List<String> csvContent = [];

    String filePathInCsvDir = file.path.split('ref_sheets').last;
    final filePathParts = p.split(filePathInCsvDir);

    await File(file.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) => csvContent.add(line));

    switch (filePathParts[1]) {
      case 'Enemies':
        if (filePathParts.last == 'EnemiesClassic.csv' || filePathParts.last == 'EnemyBaseStats.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        } else if (filePathParts.last == 'EnemiesNGS Miscellaneous.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = ',,$line';
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        }
      case 'Music':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          int fields = line.split(',').length;
          if (fields < 4) {
            for (int i = fields; i < 4; i++) {
              csvContent[csvContent.indexOf(line)] = ',$line';
            }
          }
        }
      case 'NPC':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        break;
      case 'Objects':
        if (filePathParts.last == 'Room Goods.csv') {
          headers.addAll(csvContent[1].split(','));
          csvContent.removeRange(0, 2);
        } else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Pets':
        headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        csvContent.removeAt(0);
        break;
      case 'Player':
        List<String> headerlessFiles = ['CasealVoices.csv', 'CastVoices.csv', 'DarkBlasts_DrivableVehicles.csv', 'FemaleVoices.csv', 'MaleVoices.csv'];
        if (headerlessFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
        } else if (filePathParts.last == 'DarkBlasts_DrivableVehiclesNGS.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Ice Hash']);
        } else if (filePathParts.last == 'Mags.csv' || filePathParts.last == 'MagsNGS.csv') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        } else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Units':
        headers.addAll(csvContent[1].split(','));
        csvContent.removeRange(0, 2);
        break;
      default:
        headers.addAll(['Japanese Name', 'English Name', 'Icon']);
        break;
    }

    for (var line in csvContent) {
      if (line.split(',').isNotEmpty) {
        List<String> fields = line.split(',');
        for (var element in fields) {
          fields[fields.indexOf(element)] = element.trim();
        }
        infos.addAll(fields);
        //if (p.basename(file.path) == 'Accessories.csv') {
        itemList.add(await itemFromCsv(
            p.basename(file.path),
            p.dirname(filePathInCsvDir),
            filePathInCsvDir.contains('NGS')
                ? 'NGS'
                : filePathInCsvDir.contains('PSO2')
                    ? 'PSO2'
                    : '',
            [p.basenameWithoutExtension(file.path)],
            '',
            headers,
            infos));
        //}
        infos.clear();
      }
    }
  }

  return itemList;
}

Future<Item> itemFromCsv(String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String iconImagePath, List<String> headers, List<String> infos) async {
  if (headers.length > infos.length) {
    for (var i = infos.length; i < headers.length; i++) {
      infos.add('');
    }
  } else if (infos.length > headers.length) {
    for (var i = headers.length; i < infos.length; i++) {
      headers.add('Unknown ($i)');
    }
  }

  final infoMap = Map.fromIterables(headers, infos);
  return Item.fromMap(csvFileName, csvFilePath, itemType, itemCategories, iconImagePath, infoMap);
}
