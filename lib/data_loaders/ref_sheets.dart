import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/classes.dart';

String curRefDirPath = Uri.file('${Directory.current.path}/ref_sheets').toFilePath();

Future<List<Item>> populateItemList() async {
  List<Item> itemList = [];
  final csvFiles = Directory(curRefDirPath).listSync(recursive: true).whereType<File>().where((file) => p.extension(file.path) == '.csv');
  for (var file in csvFiles) {
    List<String> headers = ['Csv', 'Game'];
    List<String> infos = [];
    List<String> csvContent = [];

    String filePathInCsvDir = file.path.split('ref_sheets').last;
    final filePathParts = p.split(filePathInCsvDir);

    infos.add(p.basename(file.path));
    filePathInCsvDir.contains('NGS') ? infos.add('NGS') : infos.add('PSO2');

    await File(file.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) => csvContent.add(line));

    switch (filePathParts[1]) {
      case 'Player':
        headers.addAll(csvContent[0].split(','));
        csvContent.removeAt(0);
        break;
      case 'Units':
        headers.addAll(csvContent[1].split(','));
        csvContent.removeAt(0);
        break;
      default:
        headers.addAll(['Type', 'Subtype', 'JP Name', 'EN Name', 'Icon']);
        break;
    }

    for (var line in csvContent) {
      if (line.split(',').isNotEmpty) {
        infos.addAll(line.split(','));
        if (p.basename(file.path) == 'Accessories.csv') {
          itemList.add(await itemFromCsv(headers, infos));
        }
        infos.removeRange(2, infos.length);
      }
    }
  }

  return itemList;
}

Future<Item> itemFromCsv(List<String> headers, List<String> infos) async {
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
  return Item.fromMap(infoMap);
}
