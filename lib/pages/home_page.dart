// ignore_for_file: prefer_const_constructors, unused_import, duplicate_ignore

import 'dart:io';
import 'dart:typed_data';

import 'package:choice/choice.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/functions/ice_download.dart';
import 'package:pso2ngs_file_locator/functions/icon_load.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/main.dart';
import 'package:pso2ngs_file_locator/pages/info_popup.dart';
import 'package:pso2ngs_file_locator/state_provider.dart';
import 'package:pso2ngs_file_locator/version_check.dart';
// ignore: unused_import
import 'package:pso2ngs_file_locator/widgets/buttons.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

MenuController menuAnchorController = MenuController();

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  List<Item> filteredItems = [];
  TextEditingController searchBarController = TextEditingController();
  TextEditingController filterSearchBarController = TextEditingController();

  @override
  void initState() {
    checkForUpdates(context);
    windowManager.addListener(this);
    if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && selectedItemFilters.length == 2) {
      filteredItems = items;
    } else {
      filteredItems = items.where((element) => selectedItemFilters.contains(element.itemType) && element.containsCategory(selectedItemFilters)).toList();
    }

    final dledItems = downloadDir.listSync().whereType<Directory>().map((e) => p.basenameWithoutExtension(e.path)).toList();
    downloadedItemList.add(
      Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
        child: Center(
          child: ElevatedButton(
              child: const Text('Open Download Folder'),
              onPressed: () async {
                launchUrl(Uri.directory(downloadDir.path));
              }),
        ),
      ),
    );
    if (dledItems.isNotEmpty) {
      downloadedItemList.add(
        Divider(
          thickness: 1,
          indent: 5,
          endIndent: 5,
          height: 0,
        ),
      );
      for (var name in dledItems) {
        downloadedItemList.add(ListTile(title: Text(name), dense: true));
      }
    }
    for (var filter in itemFilters) {
      for (var ff in filter.fileFilters) {
        allFilterList.add(ff);
      }
    }
    super.initState();
  }

  Future<void> getAppVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    //appVersion = '2.4.10';
  }

  @override
  Future<void> onWindowResized() async {
    Size curWindowSize = await windowManager.getSize();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('appWidth', curWindowSize.width);
    prefs.setDouble('appHeight', curWindowSize.height);
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
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
        toolbarHeight: 30,
        elevation: 10,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Expanded(child: searchBox()), itemCounter()],
        ),
        actions: [downloadMenuBtn(), filterBoxBtn(), lightDarkModeBtn()],
      ),
      bottomNavigationBar: context.watch<StateProvider>().isUpdateAvailable ? newVersionBanner() : null,
      body: Padding(
        padding: EdgeInsets.only(left: 0, right: 5, top: 5, bottom: 5),
        child: Row(children: [
          Expanded(child: ResponsiveGridList(desiredItemWidth: gridItemWidth, minSpacing: 5, children: filteredItems.map((e) => itemBox(e, gridItemHeight)).toList())),
          Visibility(
            visible: filterBoxShow,
            child: SizedBox(
              width: 250,
              height: double.infinity,
              child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 5,
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
                        child: filterSearchBox(),
                      ),
                      //searched filters
                      Visibility(
                        visible: searchedFilterList.isNotEmpty,
                        child: Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [searchedFilters()],
                            ),
                          ),
                        ),
                      ),

                      //normal filters
                      Visibility(
                        visible: searchedFilterList.isEmpty,
                        child: Expanded(
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
                                      maintainState: true,
                                      //tilePadding: EdgeInsets.all(10),
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
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(width: double.infinity, child: clearAllFiltersBtn()),
                      ),
                    ],
                  )),
            ),
          ),
        ]),
      ),
    );
  }

  //Item Box
  Widget itemBox(Item item, double maxHeight) {
    List<String> nameStrings = [];
    item.infos.forEach((key, value) {
      if (key.toLowerCase().contains('name') && value.isNotEmpty) {
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
      controller: searchBarController,
      leading: Icon(Icons.search),
      hintText: 'Search Items',
      padding: MaterialStatePropertyAll(EdgeInsets.only(bottom: 2, left: 10, right: 10)),
      constraints: BoxConstraints(minHeight: 25, maxHeight: 25, maxWidth: double.infinity),
      side: MaterialStatePropertyAll(BorderSide(width: 1.5, color: Theme.of(context).hoverColor)),
      backgroundColor: MaterialStatePropertyAll(Theme.of(context).canvasColor),
      elevation: MaterialStatePropertyAll(0),
      trailing: [
        Visibility(
          visible: searchBarController.text.isNotEmpty,
          child: MaterialButton(
            minWidth: 10,
            onPressed: () {
              searchBarController.clear();
              filteredItems = items;
              setState(() {});
            },
            child: Icon(Icons.close),
          ),
        )
      ],
      onChanged: (value) {
        //searchBarController.text = value;
        if (value.isNotEmpty) {
          if (selectedItemFilters.contains('PSO2') && selectedItemFilters.contains('NGS') && selectedItemFilters.length == 2) {
            filteredItems = items;
          } else {
            filteredItems = items.where((element) => selectedItemFilters.contains(element.itemType) && element.containsCategory(selectedItemFilters)).toList();
          }
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

  //Item Count
  Widget itemCounter() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 5),
      child: Text('${filteredItems.length} / ${items.length} Items'),
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

  // Filter search
  Widget filterSearchBox() {
    return SearchBar(
      controller: filterSearchBarController,
      leading: Icon(Icons.search),
      hintText: 'Search Filters',
      padding: MaterialStatePropertyAll(EdgeInsets.only(bottom: 2, left: 10, right: 10)),
      constraints: BoxConstraints(minHeight: 30, maxHeight: 30, maxWidth: double.infinity),
      side: MaterialStatePropertyAll(BorderSide(width: 1.5, color: Theme.of(context).hoverColor)),
      backgroundColor: MaterialStatePropertyAll(Theme.of(context).canvasColor),
      elevation: MaterialStatePropertyAll(0),
      trailing: [
        Visibility(
          visible: filterSearchBarController.text.isNotEmpty,
          child: MaterialButton(
            minWidth: 10,
            onPressed: () {
              filterSearchBarController.clear();
              searchedFilterList.clear();
              setState(() {});
            },
            child: Icon(Icons.close),
          ),
        ),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          searchedFilterList = allFilterList.where((element) => element.toLowerCase().contains(value.toLowerCase())).toList();
        } else {
          searchedFilterList.clear();
        }
        setState(() {});
      },
    );
  }

  //Searched Filters
  Widget searchedFilters() {
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
      itemCount: searchedFilterList.length,
      itemBuilder: (state, i) {
        return ChoiceChip(
          selected: state.selected(searchedFilterList[i]),
          onSelected: state.onSelected(searchedFilterList[i]),
          label: Text(searchedFilterList[i]),
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

  //New update banner
  Widget newVersionBanner() {
    return ScaffoldMessenger(
        child: Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).hintColor),
        ),
        child: MaterialBanner(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          padding: const EdgeInsets.all(0),
          leadingPadding: const EdgeInsets.only(left: 15, right: 5),
          leading: Icon(
            Icons.new_releases,
            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent,
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'New Update Available',
                    style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text('New version: $newVersion - Current version: $appVersion'),
                  ),
                  // TextButton(
                  //     onPressed: (() {
                  //       setState(() {
                  //         patchNotesDialog(context);
                  //       });
                  //     }),
                  //     child: Text(curLangText!.uiPatchNote)),
                ],
              ),
              Row(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 5),
                  //   child: ElevatedButton(
                  //       onPressed: (() async {
                  //         final prefs = await SharedPreferences.getInstance();
                  //         prefs.setString('versionToSkipUpdate', appVersion);
                  //         versionToSkipUpdate = appVersion;
                  //         Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                  //         setState(() {});
                  //       }),
                  //       child: Text(curLangText!.uiSkipMMUpdate)),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                        onPressed: (() {
                          Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                          setState(() {});
                        }),
                        child: Text('Close')),
                  ),
                  ElevatedButton(
                      onPressed: (() {
                        //patchNotesDialog(context);
                      }),
                      child: Text('Update')),
                ],
              )
            ],
          ),
          actions: const [SizedBox()],
        ),
      ),
    ));
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
        minWidth: 180,
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
        child: const Text('Clear All Filters'),
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          selectedItemFilters = ['PSO2', 'NGS'];
          prefs.setStringList('selectedItemFilters', selectedItemFilters);
          filteredItems = items;
          setState(() {});
        });
  }

  Widget downloadMenuBtn() {
    return Tooltip(
      message: 'Downloaded Items',
      textStyle: TextStyle(fontSize: 14, color: Theme.of(context).buttonTheme.colorScheme!.primary),
      decoration: BoxDecoration(color: Theme.of(context).buttonTheme.colorScheme!.background),
      enableTapToDismiss: true,
      child: MenuAnchor(
          builder: (BuildContext context, MenuController controller, Widget? child) {
            return MaterialButton(
              minWidth: 30,
              child: const Icon(
                Icons.download,
              ),
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
            );
          },
          onOpen: () {
            setState(() {});
          },
          style: MenuStyle(shape: MaterialStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(5)));
          })),
          controller: menuAnchorController,
          menuChildren: downloadedItemList),
    );
  }
}
