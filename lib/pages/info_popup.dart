import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<String> infos = [];
  if (showEmptyInfoFields) {
    infos = item.infos.entries.where((element) => !element.key.toString().toLowerCase().contains('name')).map((e) => "${e.key}: ${e.value}").toList();
  } else {
    infos = item.infos.entries.where((element) => !element.key.toString().toLowerCase().contains('name') && element.value.isNotEmpty).map((e) => "${e.key}: ${e.value}").toList();
  }
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(Theme.of(context).canvasColor.value).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 15, left: 16, right: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nameStrings.join('\n'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
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
                          Text(
                            '${infos[i].split(':').first}:',
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                          ),
                          Text(infos[i].split(':').last)
                        ],
                      )
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              actions: <Widget>[
                Tooltip(
                  message: showEmptyInfoFields ? 'Hide Empty Fields' : 'Show Empty Fields',
                  textStyle: TextStyle(fontSize: 14, color: Theme.of(context).buttonTheme.colorScheme!.primary),
                  decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme!.background),
                  enableTapToDismiss: true,
                  child: CupertinoCheckbox(
                    value: showEmptyInfoFields,
                    onChanged: (value) async {
                      if (showEmptyInfoFields) {
                        showEmptyInfoFields = false;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showEmptyInfoFields', showEmptyInfoFields);
                        infos = item.infos.entries.where((element) => !element.key.toString().toLowerCase().contains('name') && element.value.isNotEmpty).map((e) => "${e.key}: ${e.value}").toList();
                      } else {
                        showEmptyInfoFields = true;
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('showEmptyInfoFields', showEmptyInfoFields);
                        infos = item.infos.entries.where((element) => !element.key.toString().toLowerCase().contains('name')).map((e) => "${e.key}: ${e.value}").toList();
                      }
                      setState(
                        () {},
                      );
                    },
                  ),
                ),
                ElevatedButton(
                    child: const Text('Close'),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      filesDownload(context, item);
                    },
                    child: const Text('Download'))
              ]);
        });
      });
}

Future<bool> itemDownloadingDialog(context, Directory fileDownloadedDir) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(Theme.of(context).canvasColor.value).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 15, left: 16, right: 16),
              title: const Text('Downloading'),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.watch<StateProvider>().downloadFileName.isEmpty ? 'Connecting...' : context.watch<StateProvider>().downloadFileName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  LinearPercentIndicator(
                    //width: MediaQuery.of(context).size.width / 2,
                    animation: true,
                    lineHeight: 22.0,
                    // animationDuration: 2500,
                    barRadius: const Radius.circular(13),
                    backgroundColor: Theme.of(context).canvasColor,
                    percent: context.watch<StateProvider>().downloadPercentage,
                    center: Text('${(context.watch<StateProvider>().downloadPercentage * 100).toStringAsFixed(1)}%'),
                    progressColor: Theme.of(context).progressIndicatorTheme.linearTrackColor,
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Provider.of<StateProvider>(context, listen: false).downloadFileNameReset();
                      Provider.of<StateProvider>(context, listen: false).downloadPercentageReset();
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: Provider.of<StateProvider>(context, listen: false).downloadFileName != 'Finished!'
                        ? null
                        : () {
                            Navigator.pop(context, false);
                            Provider.of<StateProvider>(context, listen: false).downloadFileNameReset();
                            Provider.of<StateProvider>(context, listen: false).downloadPercentageReset();
                            launchUrl(Uri.directory(downloadDir.path));
                          },
                    child: const Text('Open'))
              ]);
        });
      });
}
