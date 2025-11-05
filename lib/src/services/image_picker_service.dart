import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// 选择类型 [camera] 拍照；[gallery] 相册；[galleryVideo] 从相册选择一个视频；[cameraVideo] 拍摄一个视频；[media] 选择一个图片和视频
enum ImagePickerSource { camera, gallery, galleryVideo, cameraVideo, media }

enum ImagePickerMultipleSource { image, medio, video }

class ImagePickerService {
  /// 选择/拍摄一个图片或视频；
  /// 可以通过 `File(pickedFile.path)` 将结果转为一个 File 对象
  Future<XFile?> pick({
    ImagePickerSource source = ImagePickerSource.gallery,
  }) async {
    final picker = ImagePicker();
    switch (source) {
      case ImagePickerSource.camera:
        return await picker.pickImage(source: ImageSource.camera);
      case ImagePickerSource.gallery:
        return await picker.pickImage(source: ImageSource.gallery);
      case ImagePickerSource.galleryVideo:
        return await picker.pickVideo(source: ImageSource.gallery);
      case ImagePickerSource.cameraVideo:
        return await picker.pickVideo(source: ImageSource.camera);
      case ImagePickerSource.media:
        return await picker.pickMedia();
    }
  }

  Future<List<XFile>?> pickMultiple({
    ImagePickerMultipleSource source = ImagePickerMultipleSource.image,
  }) async {
    final picker = ImagePicker();
    switch (source) {
      case ImagePickerMultipleSource.image:
        return await picker.pickMultiImage();
      case ImagePickerMultipleSource.medio:
        return await picker.pickMultipleMedia();
      case ImagePickerMultipleSource.video:
        return await picker.pickMultiVideo();
    }
  }
}
