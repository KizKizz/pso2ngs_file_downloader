import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

part 'classes.g.dart';

@JsonSerializable()
class Item {
  Item(this.csvFileName, this.csvFilePath, this.itemType, this.itemCategories, this.iconImagePath, this.infos);

  String csvFileName;
  String csvFilePath;
  String itemType;
  List<String> itemCategories;
  String iconImagePath;
  Map<String, String> infos = {};

  bool containsCategory(List<String> filters) {
    for (var cateName in itemCategories) {
      if (filters.contains(cateName)) {
        return true;
      }
    }
    return false;
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

  Item.fromMap(String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String iconImagePath, Map<String, String> infos)
      : this(csvFileName = csvFileName, csvFilePath = csvFilePath, itemType = itemType, itemCategories = itemCategories, iconImagePath = iconImagePath, infos = infos);

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

void itemDataSave() {
  if (!itemDataJson.existsSync()) {
    itemDataJson.createSync(recursive: true);
  }
  items.map((item) => item.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  itemDataJson.writeAsStringSync(encoder.convert(items));
}
