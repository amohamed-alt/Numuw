import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class NumuwPickedFile {
  const NumuwPickedFile({
    required this.name,
    required this.bytes,
    this.path,
    this.mimeHint,
  });

  final String name;
  final List<int> bytes;
  final String? path;
  final String? mimeHint;
}

/// Centralized media/document selection for prescriptions, vaccination cards,
/// reports and assistant attachments.
class MediaPickerService {
  MediaPickerService._();

  static final MediaPickerService instance = MediaPickerService._();
  final ImagePicker _images = ImagePicker();

  Future<NumuwPickedFile?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return null;
    return NumuwPickedFile(
      name: file.name,
      bytes: bytes,
      path: file.path,
      mimeHint: file.extension,
    );
  }

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) =>
      _images.pickImage(
        source: source,
        imageQuality: 88,
        maxWidth: 2048,
        requestFullMetadata: false,
      );
}
