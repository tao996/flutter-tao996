import 'dart:math';

final RegExp halfWidthChars = RegExp("[a-zA-Z0-9\\s.,!?:;\"'\\-]");

class TextUtil {
  const TextUtil();

  static const String kTagSeparator = ',';

  List<String> getTagsList(String tags) {
    if (tags.isNotEmpty) {
      return tags.split(kTagSeparator).where((s) => s.isNotEmpty).toList();
    }
    return [];
  }

  /// 按指定格式保存 tags, [isSave] 为 true 时，在最前和最后添加分割符，即返回为 ",tagA,tagB,"，如果为 false，则返回 "tagA,tagB"
  String formatTags({
    String? input,
    List<String>? listInput,
    bool isSave = true,
  }) {
    if (input == null && listInput == null) {
      throw ArgumentError('input or listInput must not be null');
    }
    final data = listInput != null
        ? listInput.where((s) => s.isNotEmpty)
        : input!
              .split(kTagSeparator) // 拆分成 ["", "tagA", "tagB", ""]
              .where((s) => s.isNotEmpty);
    if (data.isNotEmpty) {
      return isSave
          ? '$kTagSeparator${data.join(kTagSeparator)}$kTagSeparator'
          : data.join(kTagSeparator);
    }
    return '';
  }

  String merge(
    String separator,
    String text0, [
    String? text1,
    String? text2,
    String? text3,
    String? text4,
    String? text5,
    String? text6,
    String? text7,
    String? text8,
    String? text9,
    String? text10,
    String? text11,
    String? text12,
    String? text13,
    String? text14,
    String? text15,
  ]) {
    return [
      text0,
      text1,
      text2,
      text3,
      text4,
      text5,
      text6,
      text7,
      text8,
      text9,
      text10,
      text11,
      text12,
      text13,
      text14,
      text15,
    ].where((element) => element != null && element.isNotEmpty).join(separator);
  }

  /// 获取字符串长度（两个半角宽字符算一个长度）
  int textLength(String text) {
    // 1. 获取所有半角字符 (英文字母、数字、空格和标点)
    final Iterable<Match> matches = halfWidthChars.allMatches(text);
    final int halfCharCount = matches.length;

    // 2. 估算半角字符折算成的“汉字宽度”
    // 经验值：2 个半角字符 ~= 1 个全角汉字
    final double estimatedHalfWidth = halfCharCount / 2.0;

    // 3. 计算全角字符 (非半角字符) 的数量
    // 简单地用总长度减去半角字符数
    final int fullCharCount = text.length - halfCharCount;

    // 4. 总估算宽度 (以汉字为基准单位)
    return fullCharCount + estimatedHalfWidth.ceil();
  }

  /// 获取最大宽度
  int maxLength(List<String> texts) {
    int l = 0;
    for (String text in texts) {
      // dprint('length:  $text -- ${textLength(text)}');
      l = max(l, textLength(text));
    }
    return l;
  }
}
