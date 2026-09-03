import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppStatusBarStyle {
  static const light = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}
