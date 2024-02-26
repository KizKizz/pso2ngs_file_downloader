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

    await File(file.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
      if (line.isNotEmpty) csvContent.add(line);
    });

    switch (filePathParts[1]) {
      case 'Enemies':
        if (filePathParts.last == 'EnemiesClassic.csv' || filePathParts.last == 'EnemyBaseStats.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        } else if (filePathParts.last == 'EnemiesNGS Miscellaneous.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        }
      case 'Music':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
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
        List<String> threeFieldsFiles = ['CasealVoices.csv', 'CastVoices.csv', 'DarkBlasts_DrivableVehicles.csv', 'FemaleVoices.csv', 'MaleVoices.csv', 'PhotonBlastCreatures.csv'];
        List<String> fourFieldsFiles = ['Mags.csv', 'MagsNGS.csv', 'General Character Animations.csv', 'General Character Effects.csv', 'General Character Animations NGS.csv', 'General Reboot Character Effects.csv'];

        if (threeFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {element.replaceAll(', (Not found)', '').trim();}
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 3) {
              String commas = '';
              for (int i = fields; i < 3; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 3) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (fourFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {element.replaceAll(', (Not found)', '').trim();}
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (filePathParts.last == 'DarkBlasts_DrivableVehiclesNGS.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Ice Hash']);
        }  else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Stage':
        if (filePathParts.last == 'Classic') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else if (filePathParts.last == 'NGS') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            }
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        }
        break;
      case 'UI':
        if (filePathParts.last == 'stamps.csv' || filePathParts.last == 'stampsNA.csv' || filePathParts.last == 'Vital_Gauge.csv') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash - Image']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        }
        break;
      case 'Units':
        headers.addAll(['Japanese Name', 'English Name', '1st model attach bone', '2nd model attach bone', 'Extra model attach bone', 'Object unhashed name', 'Object hashed name']);
        csvContent.removeRange(0, 2);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 7);
        }
        break;
      case 'Weapons':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
        }
      default:
        headers.addAll(['Japanese Name', 'English Name']);
        for (var line in csvContent) {
          int numMissingHeaders = line.split(',').length - headers.length;
          String commas = '';
          while (numMissingHeaders-- > 0) {
            commas += ',';
          }
          csvContent[csvContent.indexOf(line)] = '$commas$line';
        }
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
                : filePathInCsvDir.contains('PSO2') || filePathInCsvDir.contains('Classic') || filePathInCsvDir.contains('classic')
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

//Helpers

String itemInfoLineFieldPad(String line, int fieldNum) {
  int fields = line.split(',').length;
  String commas = '';
  if (fields < fieldNum) {
    for (int i = fields; i < fieldNum; i++) {
      commas += ',';
    }
  }
  return commas + line;
}
