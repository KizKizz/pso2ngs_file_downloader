import 'dart:io';

bool isNumeric(String string) {
  if (string.isEmpty) {
    return false;
  }
  final number = num.tryParse(string);

  if (number == null) {
    return false;
  }

  return true;
}

void clearAppUpdateFolder() {
  String appUpdatePath = Uri.file('${Directory.current.path}/appUpdate').toFilePath();
  if (Directory(appUpdatePath).existsSync()) {
    Directory(appUpdatePath).deleteSync(recursive: true);
  }
}
