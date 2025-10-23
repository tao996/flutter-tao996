import 'package:flutter/material.dart';
import 'package:tao996/tao996.dart';

class MyDemoImage extends StatelessWidget {
  const MyDemoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      singleChildScrollView: false,
      appBar: AppBar(title: Text('Image')),
      body: MyBodyPadding(
        Column(
          children: [
            MyText.h3('占位符 myImagePlaceholder'),
            const SizedBox(height: 10),
            myImagePlaceholder('图片不存在'),
            const SizedBox(height: 10),
            MyText.h3('图片显示 MyImageCache'),
            const SizedBox(height: 10),
            MyImageCache(url: 'https://picsum.photos/250?image=9'),
            MyText.h3('点击图片可下载和分享'),
          ],
        ),
      ),
    );
  }
}
