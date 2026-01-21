import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/src/utils/tu/api_util.dart';
import 'package:tao996/src/utils/tu/color_message_util.dart';
import 'package:tao996/src/utils/tu/context_util.dart';
import 'package:tao996/src/utils/tu/data_util.dart';
import 'package:tao996/src/utils/tu/datetime_util.dart';
import 'package:tao996/src/utils/tu/device_util.dart';
import 'package:tao996/src/utils/tu/file_picker.dart';
import 'package:tao996/src/utils/tu/file_util.dart';
import 'package:tao996/src/utils/tu/form_helper.dart';
import 'package:tao996/src/utils/tu/fpath_util.dart';
import 'package:tao996/src/utils/tu/fn_util.dart';
import 'package:tao996/src/utils/tu/get_util.dart';
import 'package:tao996/src/utils/tu/image_picker.dart';
import 'package:tao996/src/utils/tu/number_util.dart';
import 'package:tao996/src/utils/tu/permission_util.dart';
import 'package:tao996/src/utils/tu/text_util.dart';
import 'package:tao996/src/utils/tu/zip.dart';
import 'package:tao996/src/utils/tu/url_util.dart';

class _TUtils {
  const _TUtils();

  final path = const FilepathUtil();
  final file = const FileUtil();
  final colorMsg = const ColorMessageUtil();
  final data = const DataUtil();
  final date = const DatetimeUtil();
  final fn = const FnUtil();
  final get = const GetUtil();
  final number = const NumberUtil();
  final permission = const PermissionUtil();
  final url = const UrlUtil();
  final zip = const ZipUtil();
  final imagePicker = const ImagePickerUtil();

  /// 直接调用将可能无法测试，建议使用 getIFilePickerService()
  final filePicker = const FilePickerService();
  final device = const DeviceUtil();
  final context = const ContextUtil();
  final text = const TextUtil();
  final form = const FormHelperUtil();

  final api = const ApiUtil();

  // 使用 Get.theme 替代 Theme.of(context)
  // Get.theme 会自动指向当前最新的主题，注意：无法随主题变换
  ThemeData get theme => Get.theme;

  ColorScheme get colorScheme => Get.context != null
      ? Theme.of(Get.context!).colorScheme
      : Get.theme.colorScheme;

  TextTheme get textTheme => Get.textTheme;
}

const tu = _TUtils();
