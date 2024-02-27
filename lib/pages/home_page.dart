// ignore_for_file: prefer_const_constructors, unused_import, duplicate_ignore

import 'dart:io';
import 'dart:typed_data';

import 'package:choice/choice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/main.dart';
import 'package:pso2ngs_file_locator/pages/info_popup.dart';
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
  List<Item> filteredItems = [];

  @override
  void initState() {
    if (itemFilters.contains('PSO2') && itemFilters.contains('NGS') && itemFilters.length == 2) {
      filteredItems = items;
    } else {
      filteredItems = items.where((element) => itemFilters.contains(element.itemType) && element.containsCategory(itemFilters)).toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double gridItemWidth = 100;
    double gridItemHeight = 200;
    if (itemFilters.contains('PSO2') && itemFilters.contains('NGS') && itemFilters.length == 2) {
      gridItemWidth = 100;
      gridItemHeight = 200;
    } else if (filteredItems.indexWhere((element) => element.csvFilePath.contains('Stamps')) != -1) {
      gridItemWidth = 300;
      gridItemHeight = 400;
    } else if (filteredItems.indexWhere((element) => element.csvFilePath.contains('Vital Gauge')) != -1) {
      gridItemWidth = 300;
      gridItemHeight = 200;
    } else {
      gridItemWidth = 100;
      gridItemHeight = 200;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
          elevation: 10,
          title: searchBox(),
          actions: [filterBoxBtn(), lightDarkModeBtn()],
        ),
        body: Row(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ResponsiveGridList(desiredItemWidth: gridItemWidth, minSpacing: 5, children: filteredItems.map((e) => itemBox(e, gridItemHeight)).toList()),
            ),
          ),
          Visibility(
            visible: filterBoxShow,
            child: SizedBox(
              width: 200,
              child: Card(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [filters()],
                    ),
                  )),
            ),
          ),
        ]));
  }

  //Item Box
  Widget itemBox(Item item, double maxHeight) {
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

    return Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
          elevation: 5,
          margin: EdgeInsets.all(0),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              itemInfoDialog(context, item);
            },
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
            ),
          ),
        ));
  }

  //Search box
  Widget searchBox() {
    return SearchBar(
      leading: Icon(Icons.search),
      hintText: 'Enter item\'s name, ice file\'s name to search',
      padding: MaterialStatePropertyAll(EdgeInsets.only(bottom: 2, left: 10, right: 10)),
      constraints: BoxConstraints(minHeight: 25, maxHeight: 25, maxWidth: double.infinity),
      side: MaterialStatePropertyAll(BorderSide(width: 1.5, color: Theme.of(context).hoverColor)),
      onChanged: (value) {
        if (value.isNotEmpty) {
          filteredItems = filteredItems.where((element) => element.infos.values.contains(value)).toList();
        } else {
          if (itemFilters.contains('PSO2') && itemFilters.contains('NGS') && itemFilters.length == 2) {
            filteredItems = items;
          } else {
            filteredItems = items.where((element) => itemFilters.contains(element.itemType) && element.containsCategory(itemFilters)).toList();
          }
        }
        setState(() {});
      },
    );
  }

  //Filters
  Widget filters() {
    return InlineChoice<String>.multiple(
      value: itemFilters,
      onChanged: (value) async {
        setState(() {
          itemFilters = value;
          if (itemFilters.contains('PSO2') && itemFilters.contains('NGS') && itemFilters.length == 2) {
            filteredItems = items;
          } else {
            filteredItems = items.where((element) => itemFilters.contains(element.itemType) && element.containsCategory(itemFilters)).toList();
          }
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList('itemFilters', itemFilters);
      },
      itemCount: itemFilterChoices.length,
      itemBuilder: (state, i) {
        return ChoiceChip(
          selected: state.selected(itemFilterChoices[i]),
          onSelected: state.onSelected(itemFilterChoices[i]),
          label: Text(itemFilterChoices[i]),
          elevation: 5,
        );
      },
      listBuilder: ChoiceList.createWrapped(
        spacing: 5,
        runSpacing: 5,
        alignment: WrapAlignment.center,
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
      ),
    );
  }

  //Buttons
  Widget lightDarkModeBtn() {
    return MaterialButton(
        minWidth: 30,
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
        child: Row(
          children: [
            MyApp.themeNotifier.value == ThemeMode.dark ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
            SizedBox(
              width: 5,
            ),
            //Text(MyApp.themeNotifier.value == ThemeMode.dark ? 'Dark Mode' : 'Light Mode')
          ],
        ));
  }

  Widget filterBoxBtn() {
    return MaterialButton(
        minWidth: 160,
        onPressed: filterBoxShow
            ? () async {
                final prefs = await SharedPreferences.getInstance();
                filterBoxShow = false;
                prefs.setBool('filterBoxShow', false);
                setState(() {});
              }
            : () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('filterBoxShow', true);
                filterBoxShow = true;
                setState(() {});
              },
        child: Row(
          children: [filterBoxShow ? Icon(Icons.filter_alt_outlined) : Icon(Icons.filter_list_alt), SizedBox(width: 5), Text(filterBoxShow ? 'Hide Filters' : 'Show Filters')],
        ));
  }
}
