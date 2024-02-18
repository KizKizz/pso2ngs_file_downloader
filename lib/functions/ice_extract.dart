import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/global_vars.dart';


String zamboniExePath = Uri.file('${Directory.current.path}/Zamboni/Zamboni.exe').toFilePath();

Future<Directory> extractIce(File iceFile) async {
  if (!Directory(tempDirPath).existsSync()) {
    await Directory(tempDirPath).create(recursive: true);
  } 

  await Process.run('$zamboniExePath -outdir "$tempDirPath"', [iceFile.path]);

  return Directory(Uri.file('$tempDirPath/${p.basenameWithoutExtension(iceFile.path)}_ext').toFilePath());
}
