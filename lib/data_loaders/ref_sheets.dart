import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/classes.dart';

String curRefDirPath = Uri.file('${Directory.current.path}/ref_sheets').toFilePath();

Future<List<Item>> populateItemList() async {
  List<Item> itemList = [];
  final csvFiles = Directory(curRefDirPath).listSync(recursive: true).whereType<File>().where((file) => p.extension(file.path) == '.csv');
  for (var file in csvFiles) {
    itemList.add(itemFromCsv(file));
  }

  return itemList;
}

Item itemFromCsv(File csvFile) {
  List<String> headers = ['Game'];
  List<String> infos = [];
  if (csvFile.path.split('ref_sheets').last.contains('NGS')) {
    infos.add('NGS');
  }

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
