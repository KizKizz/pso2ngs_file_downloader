import 'dart:io';
import 'dart:typed_data';

import 'package:pso2ngs_file_locator/functions/ice_extract.dart';
import 'package:path/path.dart' as p;

String ddsToPngExePath = Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath();

Future<Uint8List> getIconData(File iconIceFile) async {
  final extractedIceDir = await extractIce(iconIceFile);
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
