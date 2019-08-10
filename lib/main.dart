import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:githao/network/dio_client.dart';
import 'package:githao/pages/splash.dart';
import 'package:githao/provide/locale_provide.dart';
import 'package:githao/provide/theme_provide.dart';
import 'package:githao/provide/user_provide.dart';
import 'package:githao/routes/app_route.dart';
import 'package:githao/utils/shared_preferences.dart';
import 'package:provide/provide.dart';

import 'generated/i18n.dart';

// Must be top-level function
_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}


void main() {
  //Custom jsonDecodeCallback
  (dioClient.dio.transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

  final providers = Providers()
    ..provide(Provider.value(UserProvide()))
    ..provide(Provider.value(LocaleProvide()))
    ..provide(Provider.value(ThemeProvide()));
  runApp(ProviderNode(
    providers: providers,
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SpUtil.getInstance().then((sp) {
      //theme初始化
      int themeIndex = sp.getInt(SharedPreferencesKeys.themeIndex);
      if(themeIndex != null) {
        Provide.value<ThemeProvide>(context).changeTheme(themeIndex);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Provide<LocaleProvide>(
        builder: (context, child, localeProvide) {
          return Provide<ThemeProvide>(
        builder: (context, child, themeProvide) {
          return MaterialApp(
            locale: localeProvide.locale,
            // 定义静态路由，不能传递参数
            routes: appRoute.routes,
            //动态路由，可传递参数
            onGenerateRoute: appRoute.generateRoute,
            navigatorObservers: [
              appRoute,
            ],
            // 国际化设置
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: S.delegate.supportedLocales,
            //指定默认语言
//            localeResolutionCallback: S.delegate.resolution(fallback: const Locale('en','')),
            title: 'githao',
            onGenerateTitle: (context) => S.of(context).appTitle,
            theme: themeProvide.themeData,
            home: SplashPage(),
          );
        },
      );
  }
    );
  }
}
