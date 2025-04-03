import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:signals/signals.dart';

String appTitle = 'PSO2NGS File Downloader';
double appWidth = 0;
double appHeight = 0;
String appVersion = '';
String newVersion = '';
String patchNotes = '';
Signal<String> loadingStatus = Signal('');
Signal<bool> isUpdateAvailable = Signal(false);
List<String> patchNoteSplit = [];
String curPageTitle = '';
String managementLink = 'http://patch01.pso2gs.net/patch_prod/patches/management_beta.txt';
String masterURL = '';
String patchURL = '';
String backupMasterURL = '';
String backupPatchURL = '';
String githubItemJsonLink = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/itemData.json';
String githubItemFiltersJsonLink = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/itemFilterList.json';
//List<String> fileListFromServer = [];
List<String> masterFileList = [];
List<String> patchFileList = [];
List<String> mixedFileList = [];
List<Item> items = [];
Directory refSheetsDir = Directory(Uri.file('${Directory.current.path}/ref_sheets').toFilePath());
Directory refSheetsJPDir = Directory(Uri.file('${Directory.current.path}/ref_sheets_jp').toFilePath());
Directory webDataDir = Directory(Uri.file('${Directory.current.path}/web_data').toFilePath());
File webURLFile = File(Uri.file('${Directory.current.path}/web_data/webURL.txt').toFilePath());
Directory tempDir = Directory(Uri.file('${Directory.current.path}/temp').toFilePath());
File itemDataJson = File(Uri.file('${Directory.current.path}/json/itemData.json').toFilePath());
File playerItemDataJson = File(Uri.file('${Directory.current.path}/json/playerItemData.json').toFilePath());
File itemFilterListJson = File(Uri.file('${Directory.current.path}/json/itemFilterList.json').toFilePath());
Directory iconsDir = Directory(Uri.file('${Directory.current.path}/icons').toFilePath());
Directory downloadDir = Directory(Uri.file('${Directory.current.path}/Downloaded Items').toFilePath());
String zamboniExePath = Uri.file('${Directory.current.path}/Zamboni/Zamboni.exe').toFilePath();
String githubIconPath = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main';
String charToReplace = '[\\/:*?"<>|]';
bool overrideDebugMode = false;
bool filterBoxShow = true;
List<Filter> itemFilters = [];
List<String> selectedItemFilters = [];
bool showEmptyInfoFields = false;
bool extractIceFilesAfterDownload = false;
List<Widget> downloadedItemList = [];
List<String> searchedFilterList = [];
List<String> allFilterList = [];
List<String> defaultCategoryDirs = [
  'Accessories', //0
  'Basewears', //1
  'Body Paints', //2
  'Cast Arm Parts', //3
  'Cast Body Parts', //4
  'Cast Leg Parts', //5
  'Costumes', //6
  'Emotes', //7
  'Eyes', //8
  'Face Paints', //9
  'Hairs', //10
  'Innerwears', //11
  'Mags', //12
  'Misc', //13
  'Motions', //14
  'Outerwears', //15
  'Setwears', //16
  'Weapons' //17
];
