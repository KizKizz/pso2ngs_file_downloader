// ignore_for_file: prefer_const_constructors, unused_import, duplicate_ignore

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/main.dart';
// ignore: unused_import
import 'package:pso2ngs_file_locator/widgets/buttons.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
          elevation: 10,
          //title: Text('PSO2NGS File Locator'),
          actions: [lightDarkModeBtn()],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: ResponsiveGridList(
              desiredItemWidth: 100,
              minSpacing: 5,
              children: List.generate(items.length, (index) => index).map((i) {
                return itemBox(items[i]);
              }).toList()),
        ));
  }

  //Item Box
  Widget itemBox(Item item) {
    List<String> nameStrings = [];
    item.infos.forEach((key, value) {
      if (key.contains('Name')) {
        nameStrings.add(value);
      }
    });
    return Container(
        constraints: BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              item.iconImagePath.isNotEmpty
                  ? kDebugMode
                      ? Image.file(width: double.infinity, filterQuality: FilterQuality.high, fit: BoxFit.contain, File(Uri.file(Directory.current.path + item.iconImagePath).toFilePath()))
                      : Image.network(width: double.infinity, filterQuality: FilterQuality.high, fit: BoxFit.contain, githubIconPath + item.iconImagePath.replaceAll('\\', '/'))
                  : Image.asset(
                      width: double.infinity,
                      'assets/images/unknown.png',
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.contain,
                    ),
              Expanded(
                  child: Center(
                child: Text(
                  nameStrings.join('\n'),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
        ));
  }

  //Buttons
  Widget lightDarkModeBtn() {
    return MaterialButton(
      minWidth: 25,
      onPressed: MyApp.themeNotifier.value == ThemeMode.dark
          ? () async {
              final prefs = await SharedPreferences.getInstance();
              MyApp.themeNotifier.value = ThemeMode.light;
              prefs.setBool('isDarkMode', false);
              //setState(() {});
            }
          : () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('isDarkMode', true);
              MyApp.themeNotifier.value = ThemeMode.dark;
              //setState(() {});
            },
      child: MyApp.themeNotifier.value == ThemeMode.dark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
      //label: MyApp.themeNotifier.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
    );
  }
}
