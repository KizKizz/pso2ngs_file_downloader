// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/data_loaders/ref_sheets.dart';
import 'package:pso2ngs_file_locator/data_loaders/server_file_list.dart';
import 'package:pso2ngs_file_locator/functions/helpers.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
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
          List<String> tempChoices = [];
          for (var file in refSheetsDir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.csv')) {
            String fileName = p.basenameWithoutExtension(file.path).replaceAll('NGS', '').replaceAll('PSO2', '').trim();
            if (!tempChoices.contains(fileName) && !isNumeric(fileName[0])) {
              tempChoices.add(fileName);
            }
          }
          tempChoices.sort((a, b) => a.compareTo(b));
          itemFilterChoices.addAll(tempChoices);
          itemFilterListJson.writeAsStringSync(itemFilterChoices.join('\n'));

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
            final matchedItem = jsonItems.firstWhere(
              (element) => element.compare(item),
              orElse: () => Item('', '', '', [], '', {}),
            );
            if (matchedItem.iconImagePath.isNotEmpty) {
              item.itemType = matchedItem.itemType;
              item.iconImagePath = matchedItem.iconImagePath;
              if (matchedItem.itemType == '') {
                await imageSizeCheck(item);
              }
            } else {
              final jpItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('Japan'), orElse: () => const MapEntry('null', 'null'));
              final enItemNameEntry = item.infos.entries.firstWhere((element) => element.key.contains('English'), orElse: () => const MapEntry('null', 'null'));
              if (!jpItemNameEntry.value.toLowerCase().contains('unnamed') && !enItemNameEntry.value.contains('unnamed')) {
                await setIconImage(item);
              }
            }
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
        }

        setState(() {
          loadingStatus = 'Finished!';
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
    itemFilters = (prefs.getStringList('itemFilters') ?? [itemFilterChoices[0], itemFilterChoices[1]]);
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
