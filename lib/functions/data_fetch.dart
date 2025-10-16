import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/data_loaders/ref_sheets.dart';
import 'package:pso2ngs_file_locator/data_loaders/server_file_list.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

Future<bool> itemDataFetch() async {
  loadingStatus.value = 'Fetching Server List';

  var (mURL, pURL, bkMURL, bkPURL) = await getPatchServerLinks(managementLink);
  if (mURL.isNotEmpty) {
    loadingStatus.value = 'Master Server Found';

    masterURL = mURL;
    await Future.delayed(const Duration(microseconds: 10));
  }
  if (pURL.isNotEmpty) {
    loadingStatus.value = 'Patch Server Found';

    patchURL = pURL;
    await Future.delayed(const Duration(microseconds: 10));
  }
  if (bkMURL.isNotEmpty) {
    loadingStatus.value = 'Master Backup Server Found';

    backupMasterURL = bkMURL;
    await Future.delayed(const Duration(microseconds: 10));
  }
  if (bkPURL.isNotEmpty) {
    loadingStatus.value = 'Patch Backup Server Found';

    backupPatchURL = bkPURL;
    await Future.delayed(const Duration(microseconds: 10));
  }

  webURLFile.createSync(recursive: true);
  await webURLFile.writeAsString([masterURL, patchURL, backupMasterURL, backupPatchURL].join('\n'));

  if (masterURL.isNotEmpty && patchURL.isNotEmpty) {
    loadingStatus.value = 'Loading Files From Server';

    List<String> mList = [], pList = [];
    (mList, pList) = await getOfficialFileList(await fetchOfficialPatchFileList());
    masterFileList = mList;
    patchFileList = pList;

    loadingStatus.value = 'Loading Items';

    if (!kIsWeb && kDebugMode && !skipItemsRefresh) {
      // get filter choices from sheets
      itemFilterListJson.createSync(recursive: true);
      // itemFilters.add(Filter('Item Type', ['PSO2', 'NGS']));
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
        loadingStatus.value = 'Loading\n${item.csvFileName}\n${items.indexOf(item)}/${items.length}\n${item.infos.values.first}\n${item.infos.values.elementAt(1)}';

        await Future.delayed(const Duration(microseconds: 10));

        final matchedItem = jsonItems.firstWhere(
          (element) => element.compare(item),
          orElse: () => Item('null', '', '', [], '', '', -1, '', {}),
        );

        if (matchedItem.csvFileName != 'null') {
          //set icons
          if (matchedItem.iconImagePath.isNotEmpty) {
            item.iconImagePath = matchedItem.iconImagePath;
          } else {
            if (item.infos.keys.where((element) => element.toString().toLowerCase().contains('icon') || element.toString().toLowerCase().contains('image')).isNotEmpty) {
              await setIconImage(item);
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
            } else {
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
      //Directory(itemDataJson.parent.path).createSync(recursive: true);
      //await dio.download(githubItemJsonLink, itemDataJson.path);
      loadingStatus.value = 'Loading Item Data';
      await Future.delayed(const Duration(microseconds: 10));
      final itemDataRespond = await http.get(Uri.parse(githubItemJsonLink));
      if (itemDataRespond.statusCode == 200) {
        final dataFromJson = itemDataRespond.body;
        if (dataFromJson.isNotEmpty) {
          var jsonData = jsonDecode(dataFromJson);
          for (var data in jsonData) {
            items.add(Item.fromJson(data));
          }
        }
      } else {
        loadingStatus.value = 'Cannot Get Item Data From GitHub';
        await Future.delayed(const Duration(microseconds: 10));
      }
      //load filters
      loadingStatus.value = 'Loading Item Filters';
      await Future.delayed(const Duration(microseconds: 10));
      final itemFiltersRespond = await http.get(Uri.parse(githubItemFiltersJsonLink));
      if (itemFiltersRespond.statusCode == 200) {
        final dataFromJson = itemFiltersRespond.body;
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
      } else {
        loadingStatus.value = 'Cannot Get Item Filters From GitHub';
        await Future.delayed(const Duration(microseconds: 10));
      }
    }

    for (var item in items) {
      int index = itemCategoryList.indexWhere((e) => e.$1.contains(item.category!));
      if (index == -1) {
        itemCategoryList.add((item.category!, item.subCategory!.isNotEmpty ? [item.subCategory!] : []));
      } else {
        if (item.subCategory!.isNotEmpty && !itemCategoryList[index].$2.contains(item.subCategory!)) itemCategoryList[index].$2.add(item.subCategory!);
      }
    }
    itemCategoryList.sort((a, b) => a.$1.compareTo(b.$1));

    loadingStatus.value = 'Finish!';
    await Future.delayed(const Duration(microseconds: 10));
    return true;
  } else {
    loadingStatus.value = 'Failed to get server list\nPlease check your internet connection and try again later';
    await Future.delayed(const Duration(microseconds: 10));
    return false;
  }
}

Future<bool> itemDataFetchForWeb() async {
  final response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/refs/heads/main/web_data/webURL.txt'));
  if (response.statusCode == 200) {
    final urls = response.body.split('\n');
    if (urls.length > 3) {
      masterURL = urls[0];
      patchURL = urls[1];
      backupMasterURL = urls[2];
      backupPatchURL = urls[3];
    }
  }

  loadingStatus.value = 'Loading Item Data';
  await Future.delayed(const Duration(microseconds: 10));
  final itemDataRespond = await http.get(Uri.parse(githubItemJsonLink));
  if (itemDataRespond.statusCode == 200) {
    final dataFromJson = itemDataRespond.body;
    if (dataFromJson.isNotEmpty) {
      var jsonData = jsonDecode(dataFromJson);
      for (var data in jsonData) {
        items.add(Item.fromJson(data));
      }
    }
  } else {
    loadingStatus.value = 'Cannot Get Item Infos From GitHub';
    await Future.delayed(const Duration(microseconds: 10));
  }
  //load filters
  loadingStatus.value = 'Loading Item Filters';
  await Future.delayed(const Duration(microseconds: 10));
  final itemFiltersRespond = await http.get(Uri.parse(githubItemFiltersJsonLink));
  if (itemFiltersRespond.statusCode == 200) {
    final dataFromJson = itemFiltersRespond.body;
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
  } else {
    loadingStatus.value = 'Cannot Get Item Filters From GitHub';
    await Future.delayed(const Duration(microseconds: 10));
  }

  for (var item in items) {
    int index = itemCategoryList.indexWhere((e) => e.$1.contains(item.category!));
    if (index == -1) {
      itemCategoryList.add((item.category!, item.subCategory!.isNotEmpty ? [item.subCategory!] : []));
    } else {
      if (item.subCategory!.isNotEmpty && !itemCategoryList[index].$2.contains(item.subCategory!)) itemCategoryList[index].$2.add(item.subCategory!);
    }
  }
  itemCategoryList.sort((a, b) => a.$1.compareTo(b.$1));

  if (items.isEmpty || itemFilters.isEmpty) return false;
  return true;
}
