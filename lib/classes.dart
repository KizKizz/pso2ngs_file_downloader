import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

part 'classes.g.dart';

@JsonSerializable()
class Item {
  Item(this.infos, this.iconImageData);

  Map<String, String> infos = {};
  String iconImageData;

  bool compare(Item bItem) {
    if (infos.entries.length != bItem.infos.entries.length) {
      return false;
    } else {
      for (int i = 0; i < infos.entries.length; i++) {
        if (infos.entries.elementAt(i).key != bItem.infos.entries.elementAt(i).key || infos.entries.elementAt(i).value != bItem.infos.entries.elementAt(i).value) {
          return false;
        }
      }
      return true;
    }
  }

  Item.fromMap(Map<String, String> infos) : this(infos, '');
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
