import 'dart:io';

import 'package:pso2ngs_file_locator/classes.dart';

String appTitle = 'PSO2NGS File Locator';
String curPageTitle = '';
String managementLink = 'http://patch01.pso2gs.net/patch_prod/patches/management_beta.txt';
String masterURL = '';
String patchURL = '';
String backupMasterURL = '';
String backupPatchURL = '';
//List<String> fileListFromServer = [];
List<String> masterFileList = [];
List<String> patchFileList = [];
List<String> mixedFileList = [];
List<Item> items = [];
Directory tempDir = Directory(Uri.file('${Directory.current.path}/temp').toFilePath());
File itemDataJson = File(Uri.file('${Directory.current.path}/json/itemData.json').toFilePath());
Directory iconsDir = Directory(Uri.file('${Directory.current.path}/icons').toFilePath());
String githubIconPath = '';
String charToReplace = '[\\/:*?"<>|]';

