// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/main.dart';
// ignore: unused_import
import 'package:pso2ngs_file_locator/widgets/buttons.dart';
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
        title: Text('PSO2NGS File Locator'),
        actions: [lightDarkModeBtn()],
      ),
      body: Column(
        children: const [],
      ),
    );
  }

  //Buttons
  Widget lightDarkModeBtn() {
    return MaterialButton(
      onPressed: MyApp.themeNotifier.value == ThemeMode.dark
          ? () async {
              final prefs = await SharedPreferences.getInstance();
              MyApp.themeNotifier.value = ThemeMode.light;
              prefs.setBool('isDarkMode', false);
              setState(() {});
            }
          : () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.setBool('isDarkMode', true);
              MyApp.themeNotifier.value = ThemeMode.dark;
              setState(() {});
            },
      child: MyApp.themeNotifier.value == ThemeMode.dark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
    );
  }
}
