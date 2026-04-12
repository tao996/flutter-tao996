import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/src/db/kv.dart';
import 'package:tao996/src/translation/translation.dart';

import 'display_setting_controller.dart';

class DisplaySettingView extends StatelessWidget {
  const DisplaySettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DisplaySettingController());
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dark_mode_rounded),
          title: Text('darkMode'.tr),
          subtitle: Obx(
            () => Text(
              ['followSystem'.tr, 'close'.tr, 'open'.tr][c.themeMode.value],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const VerticalDivider(indent: 12, endIndent: 12, width: 24),
              Obx(
                () => Switch(
                  value: c.themeMode.value == 2,
                  onChanged: (value) =>
                      c.changeThemeMode(value ? 2 : 1, context),
                ),
              ),
            ],
          ),
          onTap: () {
            int mode = c.themeMode.value;
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.dark_mode_rounded),
                title: Text('darkMode'.tr),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 3; i++)
                          RadioListTile(
                            value: i,
                            groupValue: mode,
                            title: Text(
                              ['followSystem'.tr, 'close'.tr, 'open'.tr][i],
                            ),
                            onChanged: (value) {
                              if (value != null && value != mode) {
                                setState(() {
                                  mode = value;
                                });
                              }
                            },
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('cancel'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      c.changeThemeMode(mode, context);
                      Get.back();
                    },
                    child: Text('confirm'.tr),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.font_download_rounded),
          title: Text('fontGlobal'.tr),
          subtitle: Obx(
            () => Text(
              c.globalFont.value == 'system'
                  ? 'fontDefault'.tr
                  : c.globalFont.value.split('.').first,
            ),
          ),
          onTap: () async {
            String selectedFont = c.globalFont.value;
            await c.refreshFontList();
            Get.dialog(
              StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    icon: const Icon(Icons.font_download_rounded),
                    title: Text('fontGlobal'.tr),

                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (String font in c.fontList)
                          RadioListTile(
                            value: font,
                            groupValue: selectedFont,
                            title: Text(
                              font == 'system'
                                  ? 'fontDefault'.tr
                                  : font.split('.').first,
                              style: TextStyle(fontFamily: font),
                            ),
                            onChanged: (value) {
                              if (value != null && value != selectedFont) {
                                setState(() {
                                  selectedFont = value;
                                });
                              }
                            },
                            secondary: font == 'system'
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_rounded,
                                    ),
                                    onPressed: () async {
                                      await c.deleteFont(font);
                                      setState(() {});
                                    },
                                  ),
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              c.importFont().then((_) {
                                setState(() {});
                              });
                            },
                            child: Text('fontImport'.tr),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text('cancel'.tr),
                          ),
                          TextButton(
                            onPressed: () {
                              c.changeGlobalFont(selectedFont);
                              Get.back();
                            },
                            child: Text('confirm'.tr),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.text_fields_rounded),
          title: Text('textScale'.tr),
          subtitle: Obx(
            () => Text(
              'textScaleFactor'.tr + c.textScaleFactor.value.toStringAsFixed(1),
            ),
          ),
          onTap: () {
            double factor = c.textScaleFactor.value;
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.text_fields_rounded),
                title: Text('textScale'.tr),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return SizedBox(
                      height: 64,
                      child: Slider(
                        value: factor,
                        min: 0.8,
                        max: 2.0,
                        divisions: 12,
                        label: factor.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            factor = value;
                          });
                        },
                      ),
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('cancel'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      c.changeTextScaleFactor(factor);
                      Get.back();
                    },
                    child: Text('confirm'.tr),
                  ),
                ],
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.language_rounded),
          title: Text('language'.tr),
          subtitle: Obx(() => Text(getSelectedLanguage(c.language.value))),
          onTap: () {
            String selectedLanguage = c.language.value;
            Get.dialog(
              AlertDialog(
                icon: const Icon(Icons.language_rounded),
                title: Text('language'.tr),
                content: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (KV<String> k in kvLanguages)
                          RadioListTile<String>(
                            value: k.value,
                            groupValue: selectedLanguage,
                            title: Text(k.label),
                            onChanged: (value) {
                              if (value != null && value != selectedLanguage) {
                                setState(() {
                                  selectedLanguage = value;
                                });
                              }
                            },
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text('cancel'.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      c.changeLanguage(selectedLanguage);
                      Get.back();
                    },
                    child: Text('confirm'.tr),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
