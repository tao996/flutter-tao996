import 'package:image_picker/image_picker.dart';
import 'package:tao996/tao996.dart';

class ImagePickerUtil {
  const ImagePickerUtil();

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
