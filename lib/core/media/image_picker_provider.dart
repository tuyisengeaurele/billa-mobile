import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

typedef PickedImage = ({List<int> bytes, String name});

/// Wrapped in a provider so tests can supply an image without a platform
/// picker; returns null when the user backs out.
final imagePickerProvider = Provider<Future<PickedImage?> Function()>((ref) {
  return () async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return null;
    return (bytes: await picked.readAsBytes(), name: picked.name);
  };
});
