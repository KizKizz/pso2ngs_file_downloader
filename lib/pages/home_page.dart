// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/main.dart';
// ignore: unused_import
import 'package:pso2ngs_file_locator/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';

SidebarXController _sidebarXController = SidebarXController(selectedIndex: 0);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   elevation: 10,
      //   title: Text('PSO2NGS File Locator'),
      //   actions: [lightDarkModeBtn()],
      // ),
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 2, bottom: 2),
            child: SidebarX(
              controller: _sidebarXController,
              theme: SidebarXTheme(
                  decoration:
                      BoxDecoration(border: Border.all(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5)), color: Theme.of(context).hoverColor)),
              extendedTheme: SidebarXTheme(
                  width: 200,
                  decoration:
                      BoxDecoration(border: Border.all(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5)), color: Theme.of(context).hoverColor)),
              items: [searchBtn()],
              footerItems: [lightDarkModeBtn()],
            ),
          ),
          // Your app screen body
        ],
      ),
    );
  }

  //Buttons
  SidebarXItem lightDarkModeBtn() {
    return SidebarXItem(
      onTap: MyApp.themeNotifier.value == ThemeMode.dark
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
      iconWidget: MyApp.themeNotifier.value == ThemeMode.dark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
      label: MyApp.themeNotifier.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
    );
  }

  SidebarXItem searchBtn() {
    return SidebarXItem(
      onTap: () {
        if (!_sidebarXController.extended) {
          _sidebarXController.setExtended(true);
        } else {
          _sidebarXController.setExtended(false);
        }
      },
      iconWidget: Icon(Icons.search),
      label: 'Search',
    );
  }
}
