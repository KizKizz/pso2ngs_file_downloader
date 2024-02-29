// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/data_loaders/ref_sheets.dart';
import 'package:pso2ngs_file_locator/data_loaders/server_file_list.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/pages/home_page.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => StateProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appTitle,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(
              useMaterial3: true,
            ),
            themeMode: currentMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const Splash(),
              '/home': (context) => const HomePage(),
            },
          );
        });
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isDarkMode = true;
  String loadingStatus = '';

  @override
  void initState() {
    if (kDebugMode) {
      iconsDir.createSync(recursive: true);
    }
    themeModeCheck();
    filtersCheck();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        loadingStatus = 'Fetching Server List';
      });
      var (mURL, pURL, bkMURL, bkPURL) = await getPatchServerLinks(managementLink);
      if (mURL.isNotEmpty) {
        setState(() {
          loadingStatus = 'Master Server Found';
        });
        masterURL = mURL;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (pURL.isNotEmpty) {
        setState(() {
          loadingStatus = 'Patch Server Found';
        });
        patchURL = pURL;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (bkMURL.isNotEmpty) {
        setState(() {
          loadingStatus = 'Master Backup Server Found';
        });
        backupMasterURL = bkMURL;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (bkPURL.isNotEmpty) {
        setState(() {
          loadingStatus = 'Patch Backup Server Found';
        });
        backupPatchURL = bkPURL;
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (masterURL.isNotEmpty && patchURL.isNotEmpty) {
        setState(() {
          loadingStatus = 'Loading Files From Server';
        });
        List<String> mList = [], pList = [];
        (mList, pList) = await getOfficialFileList(await fetchOfficialPatchFileList());
        masterFileList = mList;
        patchFileList = pList;

        setState(() {
          loadingStatus = 'Loading Items';
        });

        if (kDebugMode && !overrideDebugMode) {
          // get filter choices from sheets
          itemFilterListJson.createSync(recursive: true);
          itemFilters.add(Filter('Item Type', ['PSO2', 'NGS']));
          for (var mainDir in refSheetsDir.listSync().whereType<Directory>()) {
            final allFilesInMainDir = mainDir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.csv');
            if (allFilesInMainDir.isNotEmpty) {
              List<String> fileNameFilters = allFilesInMainDir.map((e) => p.basenameWithoutExtension(e.path).replaceAll('NGS', '').replaceAll('PSO2', '').trim()).toSet().toList();
              fileNameFilters.sort((a, b) => a.compareTo(b));
              Filter newFilter = Filter(p.basenameWithoutExtension(mainDir.path), fileNameFilters);
              itemFilters.add(newFilter);
            }
          }
          itemFilters.sort((a, b) => a.mainCategory.compareTo(b.mainCategory));
          filterDataSave();

          //fetch items
          items = await populateItemList();
          if (!itemDataJson.existsSync()) {
            await itemDataJson.create(recursive: true);
          }
          List<Item> jsonItems = [];
          if (itemDataJson.existsSync()) {
            final dataFromJson = itemDataJson.readAsStringSync();
            if (dataFromJson.isNotEmpty) {
              var jsonData = jsonDecode(dataFromJson);
              for (var data in jsonData) {
                jsonItems.add(Item.fromJson(data));
              }
            }
          }
          // pulls and index icons
          for (var item in items) {
            setState(() {
              loadingStatus = 'Loading\n${item.csvFileName}\n${items.indexOf(item)}/${items.length}\n${item.infos.values.first}\n${item.infos.values.elementAt(1)}';
            });
            await Future.delayed(const Duration(milliseconds: 10));

            final matchedItem = jsonItems.firstWhere(
              (element) => element.compare(item),
              orElse: () => Item('null', '', '', [], '', {}),
            );

            if (matchedItem.csvFileName != 'null') {
              //set icons
              if (matchedItem.iconImagePath.isNotEmpty) {
                item.iconImagePath = matchedItem.iconImagePath;
              } else {
                if (item.infos.keys.where((element) => element.toString().toLowerCase().contains('icon') || element.toString().toLowerCase().contains('image')).isNotEmpty) {
                  await setIconImage(context, item);
                }
              }

              //set type
              if (matchedItem.itemType.isNotEmpty) {
                item.itemType = matchedItem.itemType;
              } else {
                if (matchedItem.csvFileName.toLowerCase().contains('classic') || matchedItem.csvFilePath.toLowerCase().contains('classic')) {
                  item.itemType = 'PSO2';
                } else if (!matchedItem.csvFileName.toLowerCase().contains('classic') && !matchedItem.csvFilePath.toLowerCase().contains('classic')) {
                  await imageSizeCheck(item);
                } else if (matchedItem.iconImagePath.isEmpty && (item.csvFilePath.contains('Stamps') || item.csvFilePath.contains('Vital Gauge'))) {
                  item.itemType = 'NGS';
                } 
                if (item.iconImagePath.isEmpty) {
                  item.itemType = 'PSO2 | NGS';
                }
              }
            }

            // if (matchedItem.iconImagePath.isNotEmpty) {
            //   item.itemType = matchedItem.itemType;
            //   item.iconImagePath = matchedItem.iconImagePath;
            //   if (matchedItem.itemType == '' && (matchedItem.csvFileName.toLowerCase().contains('classic') || matchedItem.csvFilePath.toLowerCase().contains('classic'))) {
            //     item.itemType = 'PSO2';
            //   } else if (matchedItem.itemType == '' && !matchedItem.csvFileName.toLowerCase().contains('classic') && !matchedItem.csvFilePath.toLowerCase().contains('classic')) {
            //     await imageSizeCheck(item);
            //   } else if (matchedItem.iconImagePath.isEmpty && (item.csvFilePath.contains('Stamps') || item.csvFilePath.contains('Vital Gauge'))) {
            //     item.itemType = 'NGS';
            //   } else if (item.iconImagePath.isEmpty) {
            //     item.itemType = 'PSO2 | NGS';
            //   }
            // } else {
            //   final jpItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('Japan'), orElse: () => const MapEntry('null', 'null'));
            //   final enItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('English'), orElse: () => const MapEntry('null', 'null'));
            //   if (!jpItemNameEntry.value.toLowerCase().contains('unnamed') && !enItemNameEntry.value.contains('unnamed')) {
            //     await setIconImage(item);
            //   }
            //   if (item.iconImagePath.isEmpty) {
            //     item.itemType = 'PSO2 | NGS';
            //   }
            // }
          }
          itemDataSave();
        } else {
          Directory(itemDataJson.parent.path).createSync(recursive: true);
          Dio dio = Dio();
          await dio.download(githubItemJsonLink, itemDataJson.path);
          dio.close();
          if (itemDataJson.existsSync()) {
            final dataFromJson = itemDataJson.readAsStringSync();
            if (dataFromJson.isNotEmpty) {
              var jsonData = jsonDecode(dataFromJson);
              for (var data in jsonData) {
                items.add(Item.fromJson(data));
              }
            }
          }
          //load filters
          if (itemFilterListJson.existsSync()) {
            final dataFromJson = itemFilterListJson.readAsStringSync();
            if (dataFromJson.isNotEmpty) {
              var jsonData = jsonDecode(dataFromJson);
              for (var data in jsonData) {
                if (Filter.fromJson(data).mainCategory == 'Item Type') {
                  itemFilters.insert(0, Filter.fromJson(data));
                } else {
                  itemFilters.add(Filter.fromJson(data));
                }
              }
            }
          }
        }

        setState(() {
          loadingStatus = 'Finish!';
        });
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          loadingStatus = 'Failed to get server list\nPlease check your internet connection and try again later';
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
    super.initState();
  }

  Future<void> themeModeCheck() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = (prefs.getBool('isDarkMode') ?? true);
    if (isDarkMode) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }
  }

  Future<void> filtersCheck() async {
    final prefs = await SharedPreferences.getInstance();
    filterBoxShow = (prefs.getBool('filterBoxShow') ?? true);
    selectedItemFilters = (prefs.getStringList('selectedItemFilters') ?? ['PSO2', 'NGS']);
  }

  Future<void> miscSettingsCheck() async {
    final prefs = await SharedPreferences.getInstance();
    showEmptyInfoFields = (prefs.getBool('showEmptyInfoFields') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: Image.asset('assets/images/logo.png'),
            ),
            const Spacer(),
            Text(
              loadingStatus,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
