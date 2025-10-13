import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../tao996.dart';

class MyTao996App extends StatelessWidget {
  final ISettingsService settingService;
  final Function? beforeBuild;
  final Locale? fallbackLocale;
  final Iterable<Locale>? supportedLocales;

  const MyTao996App({
    super.key,
    required this.settingService,
    this.beforeBuild,
    this.fallbackLocale,
    this.supportedLocales,
  });

  @override
  Widget build(BuildContext context) {
    final IThemeService themeService = getIThemeService();
    final IRouteService routeService = getIRouteService();
    if (routeService.routes.isEmpty) {
      throw Exception('app routes is empty');
    }

    DeviceService.calScreenSize(context);
    if (beforeBuild != null) {
      beforeBuild!();
    }
    // final dx = settingsService.navDragPosX;
    // if (-1 < dx && dx < 1) {
    //   settingsService.navDragPosX = DeviceService.screenWidth * 1 / 2 - 50;
    //   settingsService.navDragPosY = DeviceService.screenHeight * 8 / 10 - 100;
    // }
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'appTitle'.tr,
          localizationsDelegates: [
            RefreshLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:
              supportedLocales ??
              const [Locale('zh', 'CN'), Locale('en', 'US')],
          // locale: getILocaleService().locale,
          locale: Get.deviceLocale,
          fallbackLocale: fallbackLocale ?? const Locale('en', 'US'),
          translations: getTranslationService(),
          theme: themeService.buildLightTheme(lightDynamic),
          darkTheme: themeService.buildDarkTheme(darkDynamic),
          themeMode: [
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
          ][settingService.themeMode],
          initialRoute: routeService.initRoute,
          getPages: routeService.routes,
          defaultTransition: {
            'cupertino': Transition.cupertino,
            'fade': Transition.fade,
          }[settingService.transition],
          builder: (context, child) {
            // 在主题构建时设置 System UI 样式
            // themeService.systemUIOverlayStyle(
            //   Theme.of(context).appBarTheme.backgroundColor!,
            //   Theme.of(context).brightness,
            // );
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(settingService.textScaleFactor),
              ),
              child: child!,
            );
          },
          scrollBehavior: MyCustomScrollBehavior(), // 解决在桌面端无法上拉下拉
        );
      },
    );
  }
}

// https://github.com/peng8350/flutter_pulltorefresh/issues/544
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    // etc.
  };
}
