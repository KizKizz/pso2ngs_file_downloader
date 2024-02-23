import 'dart:io';

import 'package:pso2ngs_file_locator/classes.dart';

String appTitle = 'PSO2NGS File Locator';
String curPageTitle = '';
String managementLink = 'http://patch01.pso2gs.net/patch_prod/patches/management_beta.txt';
String masterURL = '';
String patchURL = '';
String backupMasterURL = '';
String backupPatchURL = '';
String githubItemJsonLink = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_locator/main/json/itemData.json';
//List<String> fileListFromServer = [];
List<String> masterFileList = [];
List<String> patchFileList = [];
List<String> mixedFileList = [];
List<Item> items = [];
Directory refSheetsDir = Directory(Uri.file('${Directory.current.path}/ref_sheets').toFilePath());
Directory tempDir = Directory(Uri.file('${Directory.current.path}/temp').toFilePath());
File itemDataJson = File(Uri.file('${Directory.current.path}/json/itemData.json').toFilePath());
File itemFilterListJson = File(Uri.file('${Directory.current.path}/json/itemFilterList.json').toFilePath());
Directory iconsDir = Directory(Uri.file('${Directory.current.path}/icons').toFilePath());
String githubIconPath = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_locator/main';
String charToReplace = '[\\/:*?"<>|]';
bool overrideDebugMode = false;
bool filterBoxShow = true;
List<String> itemFilterChoices = ['PSO2', 'NGS'];
List<String> itemFilters = [];
