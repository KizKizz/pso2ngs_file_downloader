import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

part 'classes.g.dart';

@JsonSerializable()
class Item {
  Item(this.csvFileName, this.csvFilePath, this.itemType, this.itemCategories, this.category, this.subCategory, this.categoryIndex, this.iconImagePath, this.infos);

  String csvFileName;
  String csvFilePath;
  String itemType;
  List<String> itemCategories;
  String? category;
  String? subCategory;
  int? categoryIndex;
  String iconImagePath;
  Map<String, String> infos = {};

  bool filteredItem(List<String> filters) {
    if (filters.contains('PSO2') && filters.contains('NGS') && filters.length == 2) {
      return true;
    } else if (filters.where((element) => itemType.contains(element)).isNotEmpty && filters.length == 1) {
      return true;
    } else {
      if (filters.where((element) => itemType.contains(element)).isNotEmpty && filters.where((e) => itemCategories.contains(e)).isNotEmpty) {
        return true;
      } else if (filters.where((element) => itemType.contains(element)).isNotEmpty && itemCategories.where((e) => filters.contains(e.replaceAll('PSO2', '').replaceAll('NGS', ''))).isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // bool compareNames(Item bItem) {
  //   String jpName = infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
  //   String bItemJPName = bItem.infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
  //   if (jpName == 'null' || bItemJPName == 'null') return false;
  //   if (jpName == bItemJPName && jpName.isNotEmpty && bItemJPName.isNotEmpty) {
  //     return true;
  //   } else if (jpName.isEmpty && bItemJPName.isEmpty) {
  //     String enName = infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
  //     String bItemENName = bItem.infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
  //     if (enName == 'null' || bItemENName == 'null' || enName.isEmpty || bItemENName.isEmpty) return false;
  //     if (enName == bItemENName) return true;
  //   }
  //   return false;
  // }

  bool compareNames(Item bItem) {
    if (csvFileName != bItem.csvFileName ||
            csvFilePath != bItem.csvFilePath ||
            // itemType != bItem.itemType ||
            itemCategories.length != bItem.itemCategories.length
        //iconImagePath != bItem.iconImagePath ||
        // infos.entries.length != bItem.infos.entries.length
        ) {
      return false;
    } else {
      for (int i = 0; i < itemCategories.length; i++) {
        if (itemCategories[i] != bItem.itemCategories[i]) {
          return false;
        }
      }
      String jpName = infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
      String bItemJPName = bItem.infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
      String enName = infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
      String bItemENName = bItem.infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
      if (jpName != bItemJPName && (jpName != 'null' || bItemJPName != 'null') && jpName.isNotEmpty && bItemJPName.isNotEmpty) {
        return false;
      }
      if (enName != bItemENName && (enName != 'null' || bItemENName != 'null') && enName.isNotEmpty && bItemENName.isNotEmpty) {
        return false;
      }

      if (infos.entries.length == bItem.infos.entries.length && infos.entries.length > 2 && bItem.infos.entries.length > 2) {
        for (int i = 2; i < infos.entries.length; i++) {
          if (infos.entries.elementAt(i).key != bItem.infos.entries.elementAt(i).key || infos.entries.elementAt(i).value != bItem.infos.entries.elementAt(i).value) {
            return false;
          }
        }
      }
      return true;
    }
  }

  bool compare(Item bItem) {
    if (csvFileName != bItem.csvFileName ||
        csvFilePath != bItem.csvFilePath ||
        // itemType != bItem.itemType ||
        itemCategories.length != bItem.itemCategories.length ||
        //iconImagePath != bItem.iconImagePath ||
        infos.entries.length != bItem.infos.entries.length) {
      return false;
    } else {
      for (int i = 0; i < itemCategories.length; i++) {
        if (itemCategories[i] != bItem.itemCategories[i]) {
          return false;
        }
      }
      for (int i = 0; i < infos.entries.length; i++) {
        if (infos.entries.elementAt(i).key != bItem.infos.entries.elementAt(i).key || infos.entries.elementAt(i).value != bItem.infos.entries.elementAt(i).value) {
          return false;
        }
      }
      return true;
    }
  }

  Item.fromMap(
      String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String category, String subCategory, int categoryIndex, String iconImagePath, Map<String, String> infos)
      : this(csvFileName = csvFileName, csvFilePath = csvFilePath, itemType = itemType, itemCategories = itemCategories, category = category, subCategory = subCategory, categoryIndex = categoryIndex,
            iconImagePath = iconImagePath, infos = infos);

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class Filter {
  Filter(this.mainCategory, this.fileFilters);
  String mainCategory;
  List<String> fileFilters;

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
  Map<String, dynamic> toJson() => _$FilterToJson(this);
}

void itemDataSave() {
  if (!itemDataJson.existsSync()) {
    itemDataJson.createSync(recursive: true);
  }
  items.map((item) => item.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  itemDataJson.writeAsStringSync(encoder.convert(items));

  //separate data and save for mod manager
  if (!playerItemDataJson.existsSync()) {
    playerItemDataJson.createSync(recursive: true);
  }
  final playerItems = items
      .where((element) =>
          element.csvFilePath.contains('\\Player') || element.csvFilePath.contains('\\UI\\Vital Gauge') || element.csvFilePath.contains('\\UI\\Line Duel') || element.csvFilePath.contains('\\Weapons'))
      .toList();
  playerItems.map((item) => item.toJson()).toList();
  const JsonEncoder encoder2 = JsonEncoder.withIndent('  ');
  playerItemDataJson.writeAsStringSync(encoder2.convert(playerItems));
}

void filterDataSave() {
  if (!itemFilterListJson.existsSync()) {
    itemFilterListJson.createSync(recursive: true);
  }
  itemFilters.map((filter) => filter.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  itemFilterListJson.writeAsStringSync(encoder.convert(itemFilters));
}
