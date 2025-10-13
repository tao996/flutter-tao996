import 'package:get/get.dart';

class TranslationService extends Translations {
  final Map<String, Map<String, String>> _keys = {
    'zh_CN': {
      'confirm': '确定',
      'cancel': '取消',
      // 以下这些单词为备用
      'open': '开启',
      'close': '关闭',
      'save': '保存',
      'insert': '添加',
      'edit': '编辑',
      'delete': '删除',
      'preview': '预览',
      'unknown': '未知',
      'yes': '是',
      'no': '否',
      'search': '搜索',
      'paramError': '参数错误',
      'success': '成功',
      'failed': '失败',
      'error': '错误',

      'confirmDelete': '删除?',
      'delete success': '删除成功',
      'delete failed': '删除失败',
      'save success': '保存成功',
      'save failed': '保存失败',
      'add success': '添加成功',
      'add failed': '添加失败',

      // smart_refresher_widget
      'pullUpLoadMore': '上拉加载更多',
      'loadFailedRetry': '加载失败，请重试',
      'noMoreData': '没有更多数据了',

      // font_service.dart
      'failed to read font files': '读取字体文件失败',
      'failed to read theme font': '读取主题字体失败',
      'failed to delete font': '删除字体失败',
      'failed to import fonts': '读取字体失败',
      // locale_service.dart
      'error language data': '语言格式错误',
      // messages_service.dart
      'deleteConfirmTitle': '警告?',
      'deleteConfirmContent': '确定要删除 @title 吗?',
      // http_service.dart
      'No Internet Connection': '网络错误或连接异常',
      // image
      'Click to load image': '点击加载图片',
      'image loading': '加载中...',
      'image load error': '图片加载失败',
      // image_viewer
      'image downloading': '正在下载图片...',
      'image download error': '图片下载失败',
      'download and save success': '下载并保存成功',
      'download but save failed': '下载但保存失败: @reason',
      'image sharing': '准备分享图片',
      'image not exists': '图片不存在',
      'share failed': '分享失败: @reason',
      'Download': '下载',
      'Share': '分享',
      'Flash On':'打开灯光',
      'Flash Off':'关闭灯光',

      // 权限
      'Permission storage deny': '没有存储权限',
      // URL
      'openUrlFailed': '打开 @title 链接失败',
      'urlIsEmpty': '@title 链接为空',
    },
    'en_US': {},
  };

  @override
  Map<String, Map<String, String>> get keys => _keys;

  void addKeys(Map<String, Map<String, String>> newKeys) {
    newKeys.forEach((key, value) {
      if (_keys.containsKey(key)) {
        _keys[key]!.addAll(value);
      } else {
        _keys[key] = value;
      }
    });
  }
}

/*
带参数的翻译
'message': '同步了 @count 个订阅',
使用
 'message'.trParams({'count': })

class ChildTranslation extends MyTranslation {
    @override
    Map<String, Map<String, String>> get keys => {
        ...super.keys,
        'zh_CN': {
            ...(super.keys['zh_CN'] ?? {}),
            'submit': '提交',
        },
    };
}

// 使用服务
class AppTranslation {
  static const Map<String, Map<String, String>> keys = {
    'zh_CN': {'appTitle': 'TAO996 DEMO'},
  };
}
getTranslationService().addKeys(AppTranslation.keys);
dprint(getTranslationService().keys);
 */
