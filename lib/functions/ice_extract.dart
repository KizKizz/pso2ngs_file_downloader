import 'dart:io';

import 'package:path/path.dart' as p;


String zamboniExePath = Uri.file('${Directory.current.path}/Zamboni/Zamboni.exe').toFilePath();

Future<Directory> extractIce(File iceFile, String savePath) async {

  await Process.run('$zamboniExePath -outdir "$savePath"', [iceFile.path]);

  return Directory(Uri.file('$savePath/${p.basenameWithoutExtension(iceFile.path)}_ext').toFilePath());
}
