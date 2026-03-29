# tao996

A new Flutter plugin project.

## 权限

* [image picker](https://pub.dev/packages/image_picker) 全平台
* [flutter_image_gallery_saver](https://pub.dev/packages/flutter_image_gallery_saver)

只适用于 `android` 和 `ios`

```
// ios
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app requires access to your photo library to save images.</string>
```

* [file_selector](https://pub.dev/packages/file_selector)

因为 `fultter_image_gallery_saver` 只适用于 `android` 和 `ios`，所以我们还需要兼容 pc 端的

```
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

###  mockito

`build.yaml`

使用 `flutter pub run build_runner build` 来更新 `lib/src/mocks`
（或 `dart run build_runner build --delete-conflicting-outputs`）