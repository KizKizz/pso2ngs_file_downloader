// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

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
              desiredItemWidth: 150,
              minSpacing: 5,
              children: List.generate(items.length - 1, (index) => index + 1).map((i) {
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
    Uint8List imgFile = Uint8List(0);
    item.infos.forEach((key, value) async {
      if (key.contains('Icon')) {
        File imgFile = await downloadIceFromOfficial(value, tempDirPath);
        if (imgFile.existsSync()) {
          await getIconData(imgFile);
        }
      }
    });
    return Container(
        height: 250,
        decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border.all(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              imgFile.isNotEmpty
                  ? Image.memory(imgFile)
                  : Image.asset(
                      'assets/images/logo.png',
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fitWidth,
                    ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [for (int i = 0; i < nameStrings.length; i++) Text(nameStrings[i], textAlign: TextAlign.center)],
              ),
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
