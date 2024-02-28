// ignore_for_file: prefer_const_constructors, unused_import, duplicate_ignore

import 'dart:io';
import 'dart:typed_data';

import 'package:choice/choice.dart';
import 'package:flutter/cupertino.dart';
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
    if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && selectedItemFilters.length == 2) {
      filteredItems = items;
    } else {
      filteredItems = items.where((element) => selectedItemFilters.contains(element.itemType) && element.containsCategory(selectedItemFilters)).toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double gridItemWidth = 100;
    double gridItemHeight = 200;
    if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && itemFilters.length == 2) {
      gridItemWidth = 100;
      gridItemHeight = 200;
      // } else if (filteredItems.indexWhere((element) => element.csvFilePath.contains('Stamps')) != -1) {
      //   gridItemWidth = 300;
      //   gridItemHeight = 400;
      // } else if (filteredItems.indexWhere((element) => element.csvFilePath.contains('Vital Gauge')) != -1) {
      //   gridItemWidth = 300;
      //   gridItemHeight = 200;
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
              width: 250,
              height: double.infinity,
              child: Card(
                  margin: EdgeInsets.only(top: 5, bottom: 5, left: 0, right: 5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.symmetric(vertical: 2),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: itemFilters.length,
                                itemBuilder: (context, index) {
                                  int appliedFilters = selectedItemFilters.where((element) => itemFilters[index].fileFilters.contains(element)).length;
                                  return ExpansionTile(
                                    dense: true,
                                    title: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      runAlignment: WrapAlignment.center,
                                      spacing: 5,
                                      children: [
                                        Text(
                                          itemFilters[index].mainCategory,
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            margin: EdgeInsets.symmetric(vertical: 0),
                                            padding: const EdgeInsets.only(left: 2, right: 2),
                                            decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5.0))),
                                            child: Text('$appliedFilters / ${itemFilters[index].fileFilters.length}')),
                                      ],
                                    ),
                                    children: [filters(itemFilters[index])],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(width: double.infinity, child: clearAllFiltersBtn()),
                      ),
                    ],
                  )),
            ),
          ),
        ]));
  }

  //Item Box
  Widget itemBox(Item item, double maxHeight) {
    List<String> nameStrings = [];
    item.infos.forEach((key, value) {
      if (key.contains('Name') && value.isNotEmpty) {
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
          filteredItems = filteredItems.where((element) => element.infos.values.where((element) => element.toLowerCase().contains(value.toLowerCase())).isNotEmpty).toList();
        } else {
          if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && selectedItemFilters.length == 2) {
            filteredItems = items;
          } else {
            filteredItems = items.where((element) => selectedItemFilters.contains(element.itemType) && element.containsCategory(selectedItemFilters)).toList();
          }
        }
        setState(() {});
      },
    );
  }

  //Filters
  Widget filters(Filter filter) {
    return InlineChoice<String>.multiple(
      value: selectedItemFilters,
      onChanged: (value) async {
        setState(() {
          selectedItemFilters = value;
          if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && selectedItemFilters.length == 2) {
            filteredItems = items;
          } else {
            filteredItems = items.where((element) => selectedItemFilters.contains(element.itemType) && element.containsCategory(selectedItemFilters)).toList();
          }
        });
        final prefs = await SharedPreferences.getInstance();
        prefs.setStringList('selectedItemFilters', selectedItemFilters);
      },
      itemCount: filter.fileFilters.length,
      itemBuilder: (state, i) {
        return ChoiceChip(
          selected: state.selected(filter.fileFilters[i]),
          onSelected: state.onSelected(filter.fileFilters[i]),
          label: Text(filter.fileFilters[i]),
          elevation: 5,
        );
      },
      // groupBuilder: ChoiceList.createWrapped(
      //   spacing: 2,
      //   runSpacing: 2,
      //   alignment: WrapAlignment.center,
      //   padding: const EdgeInsets.symmetric(
      //     horizontal: 2,
      //     vertical: 2,
      //   ),
      // ),
      listBuilder: ChoiceList.createWrapped(
        spacing: 2,
        runSpacing: 2,
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
    return Tooltip(
      message: MyApp.themeNotifier.value == ThemeMode.dark ? 'Light Mode' : 'Dark Mode',
      textStyle: TextStyle(fontSize: 14, color: Theme.of(context).buttonTheme.colorScheme!.primary),
      decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme!.background),
      enableTapToDismiss: true,
      child: MaterialButton(
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
          )),
    );
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

  Widget clearAllFiltersBtn() {
    return ElevatedButton(
        child: const Text('Clear All Filter'),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          selectedItemFilters = ['PSO2', 'NGS'];
          prefs.setStringList('selectedItemFilters', selectedItemFilters);
          filteredItems = items;
          setState(() {});
        });
  }
}
