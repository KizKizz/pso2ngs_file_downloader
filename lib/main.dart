// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pso2ngs_file_locator/functions/data_fetch.dart';
import 'package:pso2ngs_file_locator/functions/helpers.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    appWidth = (prefs.getDouble('appWidth') ?? 1280.0);
    appHeight = (prefs.getDouble('appHeight') ?? 720.0);
    WindowOptions windowOptions = WindowOptions(
      size: Size(appWidth, appHeight),
      center: true,
      skipTaskbar: false,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appTitle,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(
              useMaterial3: true,
            ),
            themeMode: currentMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const Splash(),
              '/home': (context) => const HomePage(),
            },
          );
        });
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isDarkMode = true;

  @override
  void initState() {
    if (!kIsWeb) clearAppUpdateFolder();
    getAppVer();

    if (kDebugMode && !kIsWeb) {
      iconsDir.createSync(recursive: true);
    }
    if (!kIsWeb) downloadDir.createSync(recursive: true);

    themeModeCheck();
    filtersCheck();
    super.initState();
  }

  Future<void> getAppVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    //appVersion = '2.4.10';
  }

  Future<void> themeModeCheck() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = (prefs.getBool('isDarkMode') ?? true);
    if (isDarkMode) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }
  }

  Future<void> filtersCheck() async {
    final prefs = await SharedPreferences.getInstance();
    filterBoxShow = (prefs.getBool('filterBoxShow') ?? true);
    selectedItemFilters = (prefs.getStringList('selectedItemFilters') ?? ['PSO2', 'NGS']);
  }

  Future<void> miscSettingsCheck() async {
    final prefs = await SharedPreferences.getInstance();
    showEmptyInfoFields = (prefs.getBool('showEmptyInfoFields') ?? false);
    extractIceFilesAfterDownload = (prefs.getBool('extractIceFilesAfterDownload') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FutureBuilder(
        future: kIsWeb ? itemDataFetchForWeb() : itemDataFetch(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: Image.asset('assets/images/logo.png'),
                ),
                Text(
                  loadingStatus.watch(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return Column(
              spacing: 40,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: Image.asset('assets/images/logo.png'),
                ),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            );
          } else {
            // Navigator.pushReplacementNamed(context, '/home');
            return const HomePage();
          }
        },
      )),
    );
  }
}
