import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

Signal<String> downloadStatus = Signal('');
Signal<double> downloadProgress = Signal(0.0);

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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
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
                              ? kDebugMode && !kIsWeb
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (showEmptyInfoFields) {
                                  showEmptyInfoFields = false;
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setBool('showEmptyInfoFields', showEmptyInfoFields);
                                  infos = item.infos.entries
                                      .where((element) => !element.key.toString().toLowerCase().contains('name') && element.value.isNotEmpty)
                                      .map((e) => "${e.key}: ${e.value}")
                                      .toList();
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
                              child: Text(showEmptyInfoFields ? 'Hide Empty Fields' : 'Show Empty Fields'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (extractIceFilesAfterDownload) {
                                    extractIceFilesAfterDownload = false;
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setBool('extractIceFilesAfterDownload', extractIceFilesAfterDownload);
                                  } else {
                                    extractIceFilesAfterDownload = true;
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setBool('extractIceFilesAfterDownload', extractIceFilesAfterDownload);
                                  }
                                  setState(
                                    () {},
                                  );
                                },
                                child: Text(extractIceFilesAfterDownload ? 'Extract Ice Files: ON' : 'Extract Ice Files: OFF'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                              child: const Text('Close'),
                              onPressed: () async {
                                Navigator.pop(context, false);
                              }),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              itemDownloadingDialog(context, item);
                            },
                            child: const Text('Download'))
                      ],
                    )
                  ],
                )
              ]);
        });
      });
}

Future<bool> itemDownloadingDialog(context, Item item) async {
  String? outputDirPath;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 15, left: 16, right: 16),
              title: Center(child: const Text('Downloading')),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: SizedBox(
                width: 250,
                height: 100,
                child: FutureBuilder(
                  future: kIsWeb ? filesDownloadWeb(item) : filesDownload(context, item),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      if (!kIsWeb) {
                        return Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LinearPercentIndicator(
                              //width: MediaQuery.of(context).size.width / 2,
                              animation: true,
                              lineHeight: 22.0,
                              // animationDuration: 2500,
                              barRadius: const Radius.circular(13),
                              backgroundColor: Theme.of(context).canvasColor,
                              percent: downloadProgress.watch(context),
                              center: Text('${(downloadProgress.watch(context) * 100).round()}%'),
                              progressColor: Theme.of(context).progressIndicatorTheme.linearTrackColor,
                            ),
                            Text(
                              downloadStatus.watch(context),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      } else {
                        return SizedBox();
                      }
                    } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                      return Column(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      );
                    } else {
                      outputDirPath = snapshot.data;
                      return Column(
                        spacing: 5,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearPercentIndicator(
                            //width: MediaQuery.of(context).size.width / 2,
                            animation: true,
                            lineHeight: 22.0,
                            // animationDuration: 2500,
                            barRadius: const Radius.circular(13),
                            backgroundColor: Theme.of(context).canvasColor,
                            percent: downloadProgress.watch(context),
                            center: Text('${(downloadProgress.watch(context) * 100).round()}%'),
                            progressColor: Theme.of(context).progressIndicatorTheme.linearTrackColor,
                          ),
                          Text(
                            downloadStatus.watch(context),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: outputDirPath != null && Directory(outputDirPath!).existsSync() && !kIsWeb
                        ? null
                        : () {
                            Navigator.pop(context, true);
                            launchUrlString(outputDirPath!);
                          },
                    child: const Text('Open'))
              ]);
        });
      });
}
