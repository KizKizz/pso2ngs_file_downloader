import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

Future<bool> itemInfoDialog(context, Item item) async {
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
              titlePadding: const EdgeInsets.only(top: 10, bottom: 15, left: 16, right: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nameStrings.join('\n'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                        width: 150,
                        height: 150,
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
                        )),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < infos.length; i++)
                    Wrap(
                      children: [
                        Text('${infos[i].split(':').first}:', style: const TextStyle(fontWeight: FontWeight.w500),),
                        Text(infos[i].split(':').last)
                      ],
                    )
                  ],
                ),
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
