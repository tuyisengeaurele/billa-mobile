import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'image_picker_provider.dart';

enum PhotoSource { camera, gallery }

/// Takes or chooses a photo; null when the user backs out. A provider so tests need no platform picker.
final photoPickerProvider = Provider<Future<PickedImage?> Function(PhotoSource)>((ref) {
  return (source) async {
    final picked = await ImagePicker().pickImage(
      source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      // A full-size photo from a modern camera can pass the server's 5 MB limit, so it is scaled down here.
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (picked == null) return null;
    return (bytes: await picked.readAsBytes(), name: picked.name);
  };
});
