import 'dart:async';
import 'dart:convert';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:ipwhois/ipwhois.dart';
import 'package:mobileinsightserverpod/app_theme.dart';
import 'package:mobileinsightserverpod/generated/l10n.dart';
import 'package:mobileinsightserverpod/pages/ways_page.dart';
import 'package:mobileinsightserverpod/utils/constants.dart';
import 'package:mobileinsightserverpod/utils/functions.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

void main() async {
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences.setPrefix('mobileqmspro_');
    final sharedPreference = await SharedPreferences.getInstance();
    // await sharedPreference.clear();

    DateTime now = DateTime.now().toLocal();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    if (kIsWeb) {
      usePathUrlStrategy();
    }

    final config = await rootBundle.loadString('assets/config/$configFile');
    final mapConfig = loadYaml(config);
    String? reportUrl = mapConfig['serverpod']['reportUrl'];

    Catcher2Options debugOptions = Catcher2Options(SilentReportMode(), [
      ConsoleHandler(
          enableApplicationParameters: false,
          enableDeviceParameters: false,
          enableCustomParameters: false)
    ]);
    Catcher2Options releaseOptions = Catcher2Options(SilentReportMode(), [
      if (reportUrl != null && reportUrl.trim() != '') ...[
        HttpHandler(
          HttpRequestType.post,
          Uri.parse(reportUrl),
          enableCustomParameters: true,
          printLogs: true,
        ),
      ],
      ConsoleHandler(
          enableApplicationParameters: false,
          enableDeviceParameters: false,
          enableCustomParameters: false)
    ], customParameters: {
      'timeZoneOffset': now.timeZoneOffset.inHours.toString(),
      'timeZoneName': now.timeZoneName,
      'appName': 'mobileQMSPro',
      'appVersion':
          '${packageInfo.version}, buildNumber:${packageInfo.buildNumber}',
      'platform': Utils.getPlatformName(),
      'ipInfo': jsonEncode(await getMyIpInfo()),
    });
    Catcher2.addDefaultErrorWidget(showStacktrace: true);

    Catcher2(
        navigatorKey: Catcher2.navigatorKey,
        rootWidget: buildProvider(sharedPreference),
        debugConfig: debugOptions,
        releaseConfig: releaseOptions);
  });
}

Widget buildProvider(SharedPreferences prefs) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppTheme(prefs: prefs)),
    ],
    child: MyApp(prefs: prefs),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  static const String tag = 'MyApp';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(builder: (context, appTheme, _) {
      return OverlaySupport.global(
          child: MaterialApp(
        title: 'MobileQMS Pro',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          S.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        locale: const Locale('en'),
        themeMode: appTheme.appearanceDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
            primaryColor: Colors.white,
            brightness: Brightness.light,
            primaryColorDark: Colors.black,
            canvasColor: Colors.white,
            buttonTheme: const ButtonThemeData(
              buttonColor: Colors.black,
              textTheme: ButtonTextTheme.accent,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity),
        darkTheme: ThemeData(
          cupertinoOverrideTheme: const CupertinoThemeData(
            textTheme: CupertinoTextThemeData(), // This is required
          ),
          primaryColor: Colors.black,
          primaryColorLight: Colors.black,
          brightness: Brightness.dark,
          primaryColorDark: Colors.black,
          indicatorColor: Colors.white,
          canvasColor: Colors.black,
          buttonTheme: const ButtonThemeData(
            buttonColor: Colors.white,
            textTheme: ButtonTextTheme.normal,
          ),
        ),
        home: WaysPage(prefs: prefs),
      ));
    });
  }
}
