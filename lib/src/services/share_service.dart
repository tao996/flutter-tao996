import 'dart:io';

import 'package:share_plus/share_plus.dart';

abstract class IShareService {
  Future<IShareStatus> shareXFile(File file, {String? text, String? subject});

  Future<IShareStatus> shareFilepath(
    String filepath, {
    String? text,
    String? subject,
  });

  /// 分享文本
  Future<IShareStatus> share(String text, {String? subject});
}

enum IShareStatus {
  /// The user has selected an action
  success,

  /// The user dismissed the share-sheet
  dismissed,

  /// The platform succeed to share content to user
  /// but the user action can not be determined
  unavailable,
}

class ShareService implements IShareService {
  ShareService();

  @override
  Future<IShareStatus> shareXFile(
    File file, {
    String? text,
    String? subject,
  }) async {
    final params = ShareParams(
      text: text,
      files: [XFile(file.path)],
      subject: subject,
    );
    final result = await SharePlus.instance.share(params);
    return IShareStatus.values[result.status.index];
  }

  @override
  Future<IShareStatus> shareFilepath(
    String filepath, {
    String? text,
    String? subject,
  }) async {
    final params = ShareParams(
      text: text,
      files: [XFile(filepath)],
      subject: subject,
    );
    final result = await SharePlus.instance.share(params);
    return IShareStatus.values[result.status.index];
  }

  @override
  Future<IShareStatus> share(String text, {String? subject}) async {
    final result = await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
    return IShareStatus.values[result.status.index];
  }
}
