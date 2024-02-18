// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
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
      body: Expanded(
        child: ResponsiveGridList(
        desiredItemWidth: 100,
        minSpacing: 10,
        children: List.generate(20, (index)=> index+1).map((i) {
          return Container(
            height: 100,
            alignment: Alignment(0, 0),
            color: Colors.cyan,
            child: Text(i.toString()),
          );
        }).toList()
    )
      ),
    );
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

  // Widget searchBtn() {
  //   return MaterialButton(
  //     onTap: () {
  //       if (!_sidebarXController.extended) {
  //         _sidebarXController.setExtended(true);
  //       } else {
  //         _sidebarXController.setExtended(false);
  //       }
  //     },
  //     iconWidget: Icon(Icons.search),
  //     label: 'Search',
  //   );
  // }
}
