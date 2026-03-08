import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tao996/tao996.dart';

class FontController extends GetxController {
  final List<String> allFonts = [];
  final RxList<String> filteredFonts = <String>[].obs; // 用于搜索过滤
  final RxBool hasLoaded = false.obs;

  Future<void> loadFonts() async {
    if (hasLoaded.value) {
      return;
    }
    final List<String> fonts = await tu.font.loadFonts();
    allFonts.assignAll(fonts);
    filteredFonts.assignAll(fonts);
    hasLoaded.value = true;
  }

  void filterFonts(String query) {
    if (query.isEmpty) {
      filteredFonts.assignAll(allFonts);
    } else {
      filteredFonts.assignAll(
        allFonts
            .where((f) => f.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}

class MyFont {
  FontController? _controller;

  FontController get controller {
    _controller ??= Get.put(FontController());
    return _controller!;
  }

  void showFontPickerDialog(
    BuildContext context, {
    void Function(String)? onChange,
  }) {
    final FontController fontController = controller;
    final TextEditingController searchController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("选择系统字体"),
        content: SizedBox(
          width: 400, // 桌面端建议固定宽度
          height: 500,
          child: Column(
            children: [
              // 搜索框
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: "搜索字体名称...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: fontController.filterFonts,
              ),
              const SizedBox(height: 12),
              // 列表
              Expanded(
                child: fontController.allFonts.isEmpty
                    ? MyEmptyStateWidget(title: 'font'.tr)
                    : Obx(() {
                        return ListView.builder(
                          itemCount: fontController.filteredFonts.length,
                          itemBuilder: (context, index) {
                            final font = fontController.filteredFonts[index];
                            return ListTile(
                              title: Text(font),
                              // 🚀 核心预览效果：应用该字体
                              subtitle: Text(
                                "预览内容: The quick brown fox 123",
                                style: TextStyle(
                                  fontFamily: font,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () {
                                // 假设你的表单变量是 controller.form.fontFamily
                                onChange?.call(font);
                                Get.back();
                              },
                            );
                          },
                        );
                      }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)),
        ],
      ),
    );
  }

  Widget build(
    BuildContext context,
    String fontFamily, {
    void Function(String)? onChange,
  }) {
    return ListTile(
      title: const Text("字体样式"),
      subtitle: Text(
        fontFamily.isEmpty ? "默认系统字体" : fontFamily,
        style: TextStyle(
          // 在表单行也展示选中的字体效果
          fontFamily: fontFamily,
          // fontWeight: FontWeight.bold,
        ),
      ),
      trailing: const Icon(Icons.font_download_outlined),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      onTap: () async {
        await controller.loadFonts();
        if (!context.mounted) {
          tu.sd.error('error'.tr);
          return;
        }
        showFontPickerDialog(context, onChange: onChange);
      },
    );
  }
}
