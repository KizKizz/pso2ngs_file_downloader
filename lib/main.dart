import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:pso2ngs_file_locator/data_loaders/server_file_list.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';
import 'package:pso2ngs_file_locator/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
    themeModeCheck();
    super.initState();
  }

  Future<void> themeModeCheck() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = (prefs.getBool('isDarkMode') ?? true);
    if (isDarkMode) {
      MyApp.themeNotifier.value = ThemeMode.dark;
    } else {
      MyApp.themeNotifier.value = ThemeMode.light;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String loadingStatus = '';
    return FlutterSplashScreen(
      //duration: const Duration(milliseconds: 2000),
      asyncNavigationCallback: () async {
        loadingStatus = 'Fetching Server List';
        //setState(() {});
        var (mURL, pURL, bkMURL, bkPURL) = await getPatchServerLinks(managementLink);
        if (mURL.isNotEmpty) {
          loadingStatus = 'Master Server Found';
          //setState(() {});
          masterURL = mURL;
        }
        if (pURL.isNotEmpty) {
          loadingStatus = 'Patch Server Found';
          //setState(() {});
          patchURL = pURL;
        }
        if (bkMURL.isNotEmpty) {
          loadingStatus = 'Master Backup Server Found';
          //setState(() {});
          backupMasterURL = bkMURL;
        }
        if (bkPURL.isNotEmpty) {
          loadingStatus = 'Patch Backup Server Found';
          //setState(() {});
          backupPatchURL = bkPURL;
        }

        if (masterURL.isNotEmpty && patchURL.isNotEmpty) {
          loadingStatus = 'Done';
          //setState(() {});
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          loadingStatus = 'Failed to get server list\nPlease check your internet connection and try again later';
          //setState(() {});
        }
      },
      //nextScreen: const HomePage(),
      backgroundColor: Theme.of(context).canvasColor,
      splashScreenBody: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Image.asset('assets/images/logo.png'),
            ),
            const Spacer(),
            Text(
              loadingStatus,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
