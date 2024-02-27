import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

Future<bool> itemInfoDialog(context, Item item) async {
  ScrollController controller = ScrollController();
  List<String> nameStrings = [];
  item.infos.forEach((key, value) {
    if (key.contains('Name')) {
      nameStrings.add(value);
    }
  });
  if (nameStrings.isEmpty) {
    nameStrings.add(item.infos.values.firstWhere(
      (element) => element.isNotEmpty,
      orElse: () => 'Unknown',
    ));
  }

  List<String> infos = item.infos.entries.where((element) => !element.key.toString().toLowerCase().contains('name')).map((e) => "${e.key}: ${e.value}").toList();
  return await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(Theme.of(context).canvasColor.value).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 0, left: 16, right: 16),
              title: Center(
                child: Text(nameStrings.join('\n'), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(minHeight: 80, minWidth: 80, maxHeight: 150, maxWidth: 150),
                    child: Card(
                      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
                      elevation: 5,
                      margin: const EdgeInsets.all(0),
                      clipBehavior: Clip.hardEdge,
                      child: item.iconImagePath.isNotEmpty
                          ? kDebugMode
                              ? Image.file(width: double.infinity, filterQuality: FilterQuality.high, fit: BoxFit.contain, File(Uri.file(Directory.current.path + item.iconImagePath).toFilePath()))
                              : Image.network(width: double.infinity, filterQuality: FilterQuality.high, fit: BoxFit.contain, githubIconPath + item.iconImagePath.replaceAll('\\', '/'))
                          : Image.asset(
                              width: double.infinity,
                              'assets/images/unknown.png',
                              filterQuality: FilterQuality.high,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemExtent: 50,
                        shrinkWrap: true, controller: controller, physics: const AlwaysScrollableScrollPhysics(), itemCount: infos.length, itemBuilder: (context, index) => Text(infos[index])),
                  )
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Close'),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Download'))
              ]));
}
