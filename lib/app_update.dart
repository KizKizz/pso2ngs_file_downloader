import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:url_launcher/url_launcher.dart';

double _downloadPercent = 0;
String _downloadErrorMsg = '';

Future<void> patchNotesDialog(context) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(0.8),
        titlePadding: const EdgeInsets.only(top: 10),
        title: const Center(child: Text('Patch Notes')),
        contentPadding: const EdgeInsets.all(10),
        content: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [for (int index = 0; index < patchNoteSplit.length; index++) Text('- ${patchNoteSplit[index]}')],
        )),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Download Page'),
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/KizKizz/pso2ngs_file_downloader/releases'));
            },
          ),
          ElevatedButton(
            child: const Text('Download Update'),
            onPressed: () {
              Navigator.of(context).pop();
              appDownloadDialog(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> appDownloadDialog(context) async {
  Dio dio = Dio();
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (dialogContext, setState) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_downloadPercent <= 0 && _downloadErrorMsg.isEmpty) {
            try {
              await dio.download('https://github.com/KizKizz/pso2ngs_file_downloader/releases/download/v$newVersion/PSO2NGSFileDownloader_v$newVersion.zip',
                  Uri.file('${Directory.current.path}/appUpdate/PSO2NGSFileDownloader_v$newVersion.zip').toFilePath(), options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
                  onReceiveProgress: (received, total) async {
                if (total != -1) {
                  _downloadPercent = received / total * 100;
                  if (_downloadPercent >= 100) {
                    await Future.delayed(const Duration(milliseconds: 100)); 
                    await extractFileToDisk(Uri.file('${Directory.current.path}/appUpdate/PSO2NGSFileDownloader_v$newVersion.zip').toFilePath(),
                        Uri.file('${Directory.current.path}/appUpdate/PSO2NGSFileDownloader_v$newVersion').toFilePath(),
                        asyncWrite: false);
                    try {
                      await dio.download("https://github.com/KizKizz/pso2ngs_file_downloader/raw/main/updater/updater.exe", Uri.file('${Directory.current.path}/appUpdate/updater.exe').toFilePath());
                    } catch (e) {
                      debugPrint(e.toString());
                      _downloadErrorMsg = e.toString();
                    }

                    Process.run(Uri.file('${Directory.current.path}/appUpdate/updater.exe').toFilePath(), ['PSO2NGSFileDownloader', newVersion, Directory.current.path]);
                    //Process.run(Uri.file('${Directory.current.path}/appUpdate/PSO2NGSMMUpdater.exe').toFilePath(), []);

                    // await patchFileGenerate();
                    // File patchLauncher = await patchFileLauncherGenerate();
                    // Process.run(patchLauncher.path, []);
                    //windowManager.destroy();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                  setState(
                    () {},
                  );
                }
              });
            } catch (e) {
              setState(
                () {
                  _downloadErrorMsg = e.toString();
                },
              );
            }
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
          backgroundColor: Theme.of(context).canvasColor.withOpacity(0.8),
          titlePadding: const EdgeInsets.only(top: 10),
          title: Center(child: _downloadErrorMsg.isEmpty ? const Text('Downloading Update') : const Text('Downloading Error')),
          contentPadding: const EdgeInsets.all(10),
          content: _downloadErrorMsg.isNotEmpty
              ? Text(_downloadErrorMsg)
              : Stack(
                  alignment: Alignment.center,
                  children: [const SizedBox(width: 60, height: 60, child: CircularProgressIndicator()), Text('${_downloadPercent.toStringAsFixed(0)} %')],
                ),
          actions: <Widget>[
            Visibility(
              visible: _downloadErrorMsg.isNotEmpty,
              child: ElevatedButton(
                child: const Text('Manual Download'),
                onPressed: () {
                  launchUrl(Uri.parse('https://github.com/KizKizz/pso2ngs_file_downloader/releases'));
                  dio.close();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Visibility(
              visible: _downloadErrorMsg.isNotEmpty,
              child: ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  dio.close();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      });
    },
  );
}