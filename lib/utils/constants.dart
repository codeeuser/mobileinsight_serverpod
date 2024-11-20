import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobileinsightserverpod/utils/functions.dart';

class Constant {
  static bool sendTestException = false;
}

const String configFile =
    (kReleaseMode == true) ? 'production.yaml' : 'development.yaml';

class Texts {
  static const String appName = "MobileInsight";
}

class WidgetProp {
  static const double width = 500;
}

class Prefs {
  static const String language = "lang";
  static const String appearanceDark = "appearanceDark";
  static const String serverpodServiceServerUrl = "serverpodServiceServerUrl";
  static const String serverpodServiceServerSecretKey =
      "serverpodServiceServerSecretKey";
}

class ScreenProp {
  static const double width = 700;
  static const double widthScreenLimit = 900;
  static const double widthPhoneScreenLimit = 500;
  static const double heightSettingMenu = 300;

  static double widthExpanded(BuildContext context) {
    double widthExpanded = (Utils.isPhoneSize(context) == true) ? 240 : 280;
    return widthExpanded;
  }
}
