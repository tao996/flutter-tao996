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
}
